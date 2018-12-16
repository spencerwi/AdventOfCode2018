[![Build Status](https://travis-ci.org/dawkot/pqueue.svg?branch=master)](https://travis-ci.org/dawkot/pqueue)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://dawkot.github.io/pqueue/index.html)
# pqueue

Max and min priority queues.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  pqueue:
    github: dawkot/pqueue
```

## Usage

```crystal
require "pqueue"

q = PriorityQueue::Max{
  2 => :two,
  3 => :three,
  1 => :one,
}

q.pop # => :three
q.pop # => :two

q.size # => 1
```

## Contributing

1. Fork it (<https://github.com/dawkot/pqueue/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [dawkot](https://github.com/dawkot) - creator, maintainer
