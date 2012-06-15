#!/usr/bin/env ruby

require 'rubygems'
require 'rest_client'
require 'yaml'
require 'json'
require 'text-table'
require 'pp'

CONFIGURATION_FILE = File.expand_path('~/.sprintlyrb')
API_PROTO = 'https'
API_HOST = 'sprint.ly'
API_PATH = '/api/'

class Sprintly
  def initialize
    load_configuration 
    @api = "#{API_PROTO}://#{@conf['username'].gsub('@','%40')}:#{@conf['apikey']}@#{API_HOST}#{API_PATH}"
    get_products(true)
  end

  def get_products(show_items = false, archived = true)
    products = api_get('products')
    api_fail unless products != false

    puts "\n=== Your#{archived == false ? ' current ': ''} Sprint.ly products are ===\n\n"
    JSON.parse(products).each do |product|
      puts "#{product['name']}" 
      show_item_table(product['id']) unless show_items == false
    end
  end

  def get_items(product_id)
    items = api_get('items', 'products', product_id)
    api_fail unless items != false
    return items 
  end

private
  def api_fail
    abort "\nThe API was unable to retrieve results. Please check your settings and connectivity.\n\n"
  end

  def api_get(endpoint, path = nil, value = nil)
    extra = (path != nil and value != nil) ? "#{path}/#{value}/" : ''
    res = RestClient.get "#{@api}#{extra}#{endpoint}.json", {:accept => :json}
    return res.code == 200 ? res : false
  end

  def prompt(*args)
    print(*args)
    gets
  end

  def show_item_table(product_id)
    items = JSON.parse(get_items(product_id))
    if items.size > 0
      table = Text::Table.new
      table.head = ['Item', 'Title', 'Status', 'Type', 'Score', 'Tags']
      items.each do |item|
        table.rows << [item['number'], item['title'], item['status'], item['type'], item['score'], item['tags'].to_a.join(',')]
      end
      puts "#{table.to_s}\n"
    else
      puts "-- No items for this product. --\n\n"
    end
  end

  def load_configuration
    if File.file?(CONFIGURATION_FILE)
      @conf = YAML.load_file(CONFIGURATION_FILE)
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
end

sprintly = Sprintly.new
