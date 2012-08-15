#!/usr/bin/env ruby

require 'rubygems'
require 'rest_client'
require 'yaml'
require 'json'
require 'text-table'
require 'trollop'
require 'pp'

CONFIGURATION_FILE = File.expand_path('~/.sprintlyrb')
API_PROTO = 'https'
API_HOST = 'sprint.ly'
API_PATH = '/api/'

class Sprintly
  def initialize
    load_configuration 
    options
  end

  def get_products(show_items = false, show_archived = true, show_people = false, show_products = 'all')
    products = api_get('products')
    api_fail unless products != false

    puts
    puts "=== Your Sprint.ly products are ===\n\n" if show_products == 'all'
    products.each do |product|
      if show_products == 'all' or make_slug(product['name']) == show_products
        if product['archived'] == false or show_archived == true
          puts "#{product['name']}#{product['archived'] == true ? ' [Archived]' : ''} (#{make_slug(product['name'])})"
          puts show_item_table(product['id'], product['archived']) unless show_items == false
          puts show_people_list(product['id']) unless show_people == false or product['archived'] == true
          puts if show_people == true or show_items == true
        end
      end
    end
  end

  def show_item_table(product_id, archived = false)
    return "-- This product has been archived. --\n" unless archived == false
    items = get_items(product_id)
    if items.size > 0
      table = Text::Table.new
      table.head = ['Item', 'Title', 'Status', 'Type', 'Score', 'Tags']
      items.each do |item|
        table.rows << [item['number'], item['title'], item['status'], item['type'], item['score'], item['tags'].to_a.join(',')]
      end
      return "#{table.to_s}"
    else
      return "-- No items for this product. --\n"
    end
  end

  def show_people_list(product_id)
    return "People Involved: " + get_people(product_id).collect { |person| "#{person['first_name']} #{person['last_name']}" }.join(', ')
  end

private
  def options
    opts = Trollop::options do
      version "Sprint.ly Ruby 1.0 (c) 2012 Mark Stanislav"
      banner <<-EOS.gsub(/^ {6}/,'')

      Usage:
      #{$0} [options]
      EOS

      opt :items, "Show items table with products", :default => false, :short => "-i"
      opt :archived, "Show archived products", :default => false, :short => "-a"
      opt :team, "Show which team members involved with a product", :default => false, :short => "-t"
      opt :product, "Specify whether to show a specific product or ALL products", :default => 'all', :short => "-p"
    end

    get_products(opts[:items], opts[:archived], opts[:team], opts[:product])
  end

  def api_fail
    abort "\nThe API was unable to retrieve results. Please check your settings and connectivity.\n\n"
  end

  def api_get(endpoint, path = nil, value = nil)
    extra = (path != nil and value != nil) ? "#{path}/#{value}/" : ''
    res = RestClient.get "#{@api}#{extra}#{endpoint}.json", {:accept => :json}
    return res.code == 200 ? JSON.parse(res) : false
  end

  def prompt(*args)
    print(*args)
    gets
  end

  def get_items(product_id)
    items = api_get('items', 'products', product_id)
    api_fail unless items != false
    return items 
  end

  def get_people(product_id)
    people = api_get('people','products', product_id)
    api_fail unless people != false
    return people
  end

  def load_configuration
    if File.file?(CONFIGURATION_FILE)
      @conf = YAML.load_file(CONFIGURATION_FILE)
      @api = "#{API_PROTO}://#{@conf['username'].gsub('@','%40')}:#{@conf['apikey']}@#{API_HOST}#{API_PATH}"
    else
      puts "\nYour configuration file #{CONFIGURATION_FILE} is missing, please answer the following questions:\n\n" 
      set_configuration 
    end
  end

  def check_configuration(username, apikey)
    if username != '' and apikey != ''
      File.open(CONFIGURATION_FILE, 'w+') { |f| f.write({'username' => username, 'apikey' => apikey}.to_yaml) }

      if File.file?(CONFIGURATION_FILE)
        puts "\nYour configuration has been successfully saved!\n\n"
      else
        puts "\nThere was a problem writing your configuration file #{CONFIGURATION_FILE}, please check the path you've configured.\n\n"
      end
    else
      puts "\nYour username and/or API key cannot be blank. Please try again:\n\n"
      set_configuration
    end
  end

  def set_configuration
    username = prompt("What is your Sprint.ly username? ").strip
    apikey = prompt("What is your Sprint.ly API key? ").strip

    check_configuration(username, apikey)
  end

  def make_slug(product)
    return product.gsub("'", "").gsub('"', '').gsub(' ', '-').downcase
  end 
end

sprintly = Sprintly.new
