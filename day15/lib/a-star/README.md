# A* pathfinding algorithm

[![GitHub release](https://img.shields.io/github/release/petoem/a-star.cr.svg?style=flat-square)](https://github.com/petoem/a-star.cr/releases)
[![Travis](https://img.shields.io/travis/petoem/a-star.cr.svg?style=flat-square)](https://travis-ci.org/petoem/a-star.cr)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/petoem/a-star.cr/blob/master/LICENSE)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  a-star:
    github: petoem/a-star.cr
```

## Usage

```crystal
require "a-star"

# `Node(T)` is generic and can store any type eg. `String`
a = AStar::Node.new "A"
b = AStar::Node.new "B"
c = AStar::Node.new "C"
d = AStar::Node.new "D"

# Connect nodes to each other
# `Node#connect` connects self to other and vice versa with given distance
a.connect b, 1
b.connect c, 3
c.connect d, 2
b.connect d, 1

# Runs A* search from `start` to `goal` and uses block as heuristic function
# Returns an `Array` of `Node(T)` or `Nil`
path = AStar.search a, d do |node, goal|
  # Your heuristic algorithm here ...
end

if path
  puts "Found a solution."
else
  puts "No path found."
end
```

See [examples](examples) directory for more.

## Contributing

1. [Fork it](https://github.com/petoem/a-star.cr/fork)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [petoem](https://github.com/petoem) Michael Petö - creator, maintainer
