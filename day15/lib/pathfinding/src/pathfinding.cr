require "pqueue"
require "math"

module Pathfinding
  extend self
  VERSION = "0.1.0"

  # A* algorithm.
  def astar(
    start : T,
    success : T -> Bool,
    costf : (T, T) -> Cost,
    heuristic : T -> Cost,
    neighbours : T -> Array(T)
  ) : {path: Array(T), cost: Cost}? forall T, Cost
    q = PriorityQueue::Min{Cost.zero => start}
    prev = {} of T => T
    cost = {start => Cost.zero} # {} of T => Cost
    goal = loop do
      break if q.empty?
      u = q.pop
      break u if success.call u
      neighbours.call(u).each do |v|
        new_cost = cost[u] + costf.call(u, v)
        if !cost.has_key?(v) || new_cost < cost[v]
          cost[v] = new_cost
          priority = new_cost + heuristic.call(v)
          q[priority] = v
          prev[v] = u
        end
      end
    end
    if goal
      path = create_path(start, prev, goal)
      cost = cost[goal]
      {path: path, cost: cost}
    end
  end

  # Dijkstra algorithm.
  def dijkstra(
    start : T,
    success : T -> Bool,
    costf : (T, T) -> Cost,
    neighbours : T -> Array(T)
  ) : {path: Array(T), cost: Cost}? forall T, Cost
    heuristic = ->(x : T) { 0 }
    astar(start, success, costf, heuristic, neighbours)
  end

  # Breadth-First Search algorithm.
  def bfs(
    start : T,
    success : T -> Bool,
    neighbours : T -> Array(T)
  ) : Array(T)? forall T
    q = Deque(T).new
    q << start
    prev = {} of T => T
    goal = loop do
      break if q.empty?
      u = q.shift
      break u if success.call(u)
      neighbours.call(u).each do |v|
        if !prev.has_key? v
          prev[v] = u
          q << v
        end
      end
    end
    create_path(start, prev, goal) if goal
  end

  private def create_path(
    start : T,
    prev : Hash(T, T),
    goal : T
  ) : Array(T)? forall T
    u = goal
    path = [] of T
    while u != start
      path << u
      u = prev[u]
    end
    path << start
    return path.reverse
  end

  module Heuristic
    # Manhattan distance heuristic.
    # Intended for grids with 4 directions of movement.
    def self.manhattan(
      node : T,
      goal : T,
      weight : Cost
    ) : Cost forall T, Cost
      dx = (node.x - goal.x).abs
      dy = (node.y - goal.y).abs
      d = weight
      d * (dx + dy)
    end

    # Diagonal distance heuristic.
    # Intended for grids with 8 directions of movement.
    def self.diagonal(
      node : T,
      goal : T,
      weight : Cost,
      weight_diag : Cost
    ) : Cost forall T, Cost
      dx = (node.x - goal.x).abs
      dy = (node.y - goal.y).abs
      d = weight
      d2 = weight_diag
      d * (dx + dy) + (d2 - 2 * d) * Math.min(dx, dy)
    end

    # Chebyshev distance heuristic.
    # Intended for grids with 8 directions of movement.
    def self.chebyshev(node : T, goal : T) : Cost forall T, Cost
      diagonal(node, goal, 1, 1)
    end

    # Octile distance heuristic.
    # Intended for grids with 8 directions of movement.
    def self.octile(node : T, goal : T) : Cost forall T, Cost
      diagonal(node, goal, 1, Math.sqrt 2)
    end

    # Euclidean distance heuristic.
    # Intended for grids with any number of directions of movement.
    def self.euclidean(
      node : T,
      goal : T,
      weight : Cost
    ) : Cost forall T, Cost
      dx = (node.x - goal.x).abs
      dy = (node.y - goal.y).abs
      d = weight
      d * Math.sqrt(dx**2 + dy**2)
    end
  end

end
