# Usage

## Showing current products
```
$ ./sprintly.rb products

=== Your Sprint.ly products are ===

Pool 100

Sprintly Ruby
```

## Showing current + archived products
```
$ ./sprintly.rb -a products

=== Your Sprint.ly products are ===

Test Product [Archived]

Pool 100

Sprintly Ruby
```

## Showing current products with an item table listing
```
$ ./sprintly.rb -i products

=== Your Sprint.ly products are ===

Pool 100
-- No items for this product. --

Sprintly Ruby
+------+--------------------------------------------+---------+------+-------+---------------+
| Item |                   Title                    | Status  | Type | Score |     Tags      |
+------+--------------------------------------------+---------+------+-------+---------------+
| 11   | Add README documentation for example usage | backlog | task | ~     | documentation |
+------+--------------------------------------------+---------+------+-------+---------------+
```

## Script Help
```
$ ./sprintly.rb -h

Usage:
./sprintly.rb [options] products
     --items, -i:   Show items table with products
  --archived, -a:   Show archived products
    --people, -p:   Show people involved with a product
   --version, -v:   Print version and exit
      --help, -h:   Show this message
```

# TODO
* Option to show items of only a certain type
* Option to show items that are of a certain status
