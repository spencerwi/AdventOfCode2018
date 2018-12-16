module PQueue
  VERSION = "0.1.0"
end

# Wrapper for queue's elements
private struct Element(P, T)
  getter priority, unwrapped

  include Comparable(self)

  def initialize(@priority : P, @unwrapped : T)
  end

  def <=>(other : self) : Int32
    self.priority <=> other.priority
  end
end

module Heap(P, T)
  include Iterable(T)
  include Enumerable(T)

  # Returns `true` if the queue is empty, `false` otherwise
  # delegate empty?, @elements
  def empty?
    @elements.empty?
  end

  # Returns the current number of elements in the queue
  # delegate size, @elements
  def size
    @elements.size
  end

  # Removes and returns the item with the highest priority.
  # If the queue is empty, it yields the block.
  def pop
    if empty?
      yield
    else
      @elements.swap 0, @elements.size - 1
      e = @elements.pop.unwrapped
      bubble_down
      e
    end
  end

  # Like `#pop`, but raises `IndexError` if the queue is empty.
  def pop
    pop { raise IndexError.new }
  end

  # Like `#pop`, but returns `nil` if the queue is empty.
  def pop?
    pop { nil }
  end

  # Returns the next item to be popped (without removing it).
  # If the queue is empty, it yields the block.
  def peek
    if empty?
      yield
    else
      @elements.first.unwrapped
    end
  end

  # Like `#peek`, but raises `IndexError` if the queue is empty.
  def peek
    peek { raise IndexError.new }
  end

  # Like `#peek`, but returns `nil` if the queue is empty.
  def peek?
    peek { nil }
  end

  # Returns the highest priority item's priority (without removing it).
  # If the queue is empty, it yields the block.
  def priority
    if empty?
      yield
    else
      @elements.first.priority
    end
  end

  # Like `#priority`, but raises `IndexError` if the queue is empty.
  def priority
    priority { raise IndexError.new }
  end

  # Like `#priority`, but returns `nil` if the queue is empty.
  def priority?
    priority { nil }
  end

  # Returns a human-readable string representation
  def to_s(io : IO)
    io << "PriorityQueue{"
    unless empty?
      priority.inspect io
      io << " => "
      peek.inspect io
      if size > 1
        io << "... [+"
        (size - 1).inspect io
        io << "]"
      end
    end
    io << "}"
  end

  # Inserts a new element into the queue, at given priority.
  def []=(priority : P, element : T)
    @elements << Element.new priority, element
    bubble_up
  end

  # Returns a new `PriorityQueue` that has exactly `self`'s elements.
  def dup
    self.class.new @elements.dup
  end

  # Yields each element in the queue in order of priority.
  def each
    q = dup
    until q.empty?
      yield q.pop
    end
  end

  # Returns an `Iterator` over the elements in the queue
  # in order of priority.
  def each
    q = dup
    xs = [] of T
    each { |x| xs << x }
    xs.each
  end

  # Traverses the heap up
  abstract def bubble_up(i = nil)

  # Traverses the head down
  abstract def bubble_down(i = nil)
end

# Returns the index of the parent
# of the element at index `i`
private def parent(i)
  (i - 1) / 2
end

# Returns the index of the child
# of the element at index `i`
private def child(i)
  i * 2 + 1
end

module PriorityQueue
  extend self

  class Max(P, T)
    include Heap(P, T)

    def initialize(@elements = [] of Element(P, T))
    end

    private def bubble_up(i = nil)
      i = @elements.size - 1 unless i
      return if i == 0
      p = parent i
      return if @elements[p] >= @elements[i]
      @elements.swap i, p
      bubble_up p
    end

    private def bubble_down(i = nil)
      i = 0 unless i
      c = child i
      return if c >= @elements.size
      c += 1 if c < @elements.size - 1 &&
                @elements[c + 1] > @elements[c]
      return if @elements[i] >= @elements[c]
      @elements.swap i, c
      bubble_down c
    end
  end

  class Min(P, T)
    include Heap(P, T)

    def initialize(@elements = [] of Element(P, T))
    end

    private def bubble_up(i = nil)
      i = @elements.size - 1 unless i
      return if i == 0
      p = parent i
      return if @elements[p] <= @elements[i]
      @elements.swap i, p
      bubble_up p
    end

    private def bubble_down(i = nil)
      i = 0 unless i
      c = child i
      return if c >= @elements.size
      c += 1 if c < @elements.size - 1 &&
                @elements[c + 1] < @elements[c]
      return if @elements[i] <= @elements[c]
      @elements.swap i, c
      bubble_down c
    end
  end
end
