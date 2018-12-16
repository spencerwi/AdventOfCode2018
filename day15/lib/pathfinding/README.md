
[![Build Status](https://travis-ci.org/dawkot/pathfinding.svg?branch=master)](https://travis-ci.org/dawkot/pathfinding)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](<https://dawkot.github.io/pathfinding/index.html>)
# pathfinding

A pathfinding library.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  pathfinding:
    github: dawkot/pathfinding
```

## Usage

```crystal
require "pathfinding"

start = :a

success = ->(x : Symbol) { x == :e }

neighbours = ->(x : Symbol) do
  case x
  when :a then [:b]
  when :b then [:a, :c, :d]
  when :c then [:a]
  when :d then [:e, :a]
  when :e then [:b]
  else         [] of Symbol
  end
end

Pathfinding.bfs(start, success, neighbours) # => [:a, :b, :d, :e]
```

## Contributing

1. Fork it (<https://github.com/your-github-user/pathfinding/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [dawkot](https://github.com/your-github-user) - creator, maintainer
