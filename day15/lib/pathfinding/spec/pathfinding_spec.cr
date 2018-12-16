require "./spec_helper"

struct Point
  getter x, y

  def initialize(@x : Int32, @y : Int32)
  end

  def sides
    [{@x + 1, @y}, {@x - 1, @y}, {@x, @y + 1}, {@x, @y - 1}]
      .map { |(x, y)| Point.new x, y }
      .to_a
  end

  def diagonal
    [{@x + 1, @y + 1}, {@x - 1, @y - 1},
     {@x + 1, @y - 1}, {@x - 1, @y + 1}]
      .map { |(x, y)| Point.new x, y }
      .to_a
  end

  def distance(other : self)
    (@x - other.x).abs + (@y - other.y).abs
  end
end

describe Pathfinding do
  it "finds a path in a simple graph using breadth-first search" do
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

    Pathfinding.bfs(start, success, neighbours)
      .should eq [:a, :b, :d, :e]
  end

  it "finds an optimal path on a simple grid using 
      dijkstra and bfs" do
    goal = Point.new 3, 3
    start = Point.new 0, 0
    success = ->(p : Point) { p == goal }
    cost = ->(a : Point, b : Point) { 1 }
    neighbours = ->(p : Point) { p.sides + p.diagonal }

    dijkstra = Pathfinding.dijkstra(start, success, cost, neighbours)
      .not_nil!
      .[:path]
    
    bfs = Pathfinding.bfs(start, success, neighbours)
      .not_nil!
    
    expected = [
      Point.new(0, 0), Point.new(1, 1),
      Point.new(2, 2), Point.new(3, 3),
    ]

    (dijkstra == bfs == expected).should eq true
  end

  it "finds an optimal path on a grid with obstacles using
      astar" do
    goal = Point.new 10, 6
    walls = [
      Point.new(0, 3), Point.new(1, 3), Point.new(2, 3),
      Point.new(2, 2), Point.new(3, 2),
      Point.new(3, 1), Point.new(4, 1),
      Point.new(4, 0),
      Point.new(-1, 6), Point.new(0, 6),
      Point.new(1, 5), Point.new(2, 5), Point.new(3, 5),
      Point.new(4, 4), Point.new(5, 4),
      Point.new(5, 3), Point.new(6, 3),
      Point.new(7, 2), Point.new(7, 1), Point.new(7, 0),
      Point.new(8, -1), Point.new(9, -2),
    ]
    
    start = Point.new 0, 0
    success = ->(p : Point) { p == goal }
    cost = ->(a : Point, b : Point) { 1 }
    
    neighbours = ->(p : Point) do 
      p.sides.reject { |p| walls.includes? p }
    end
    
    heuristic = ->(p : Point) do
      Pathfinding::Heuristic.manhattan(p, goal, weight: 1)
    end
    
    Pathfinding.astar(start, success, cost, heuristic, neighbours)
      .not_nil!  
      .[:path]
      .size
      .should eq 23
  end
end
