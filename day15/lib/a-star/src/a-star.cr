require "./a-star/*"

# A* pathfinding algorithm
module AStar
  extend self

  # Runs A* search from `start` to `goal` and uses block as heuristic function.
  # Returns `Array(T)` or `Nil` if no path was found.
  def search(start : T, goal : T, &block) forall T
    open = [] of T
    closed = [] of T
    open << start
    start.g = 0
    start.f = yield start, goal

    until open.empty?
      current = open.sort! { |a, b| a.f <=> b.f }.first
      return reconstruct_path goal if current == goal

      open.delete current
      closed << current

      current.neighbor.each do |neighbor, distance|
        next if closed.includes? neighbor
        open << neighbor unless open.includes? neighbor
        if (new_g = current.g + distance) < neighbor.g
          neighbor.parent = current
          neighbor.g = new_g
          neighbor.f = new_g + yield neighbor, goal
        end
      end
    end
    open.map! &.reset
    closed.map! &.reset
    nil
  end

  # Reconstructs the path based on a `Node` (usually the goal).
  # Returns path as an `Array` with start being the first element and goal last.
  def reconstruct_path(node)
    path = [] of typeof(node)
    path << node
    while node = node.parent
      path << node
    end
    path.reverse!
  end

  # Represents one node from a graph.
  # Every `Node(T)` can store something in its data getter e.g. coordinates.
  class Node(T)
    getter data : T
    property parent : self?
    property g : Number::Primitive = Float64::INFINITY
    property f : Number::Primitive = Float64::INFINITY
    getter neighbor = Hash(self, Number::Primitive).new

    # Create a new node and optionally set its data field.
    def initialize(@data : T = nil); end

    # Connect `self` to another `node` with a `distance`.
    def connect(node : self, distance : Number::Primitive)
      @neighbor[node] = distance
      node.neighbor[self] = distance
    end

    # Resets F and G values back to its initial state `Float64::INFINITY`.
    # Returns `self`.
    def reset
      @g = Float64::INFINITY
      @f = Float64::INFINITY
      self
    end

    # Appends `#data` to the given IO object.
    def to_s(io : IO) : Nil
      io << @data
    end
  end
end
