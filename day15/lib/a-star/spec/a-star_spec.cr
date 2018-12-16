require "./spec_helper"

describe AStar do
  it "search direct path from A to B" do
    a = AStar::Node.new "A"
    b = AStar::Node.new "B"

    a.connect b, 3

    path = AStar.search a, b do |node1, node2|
      0
    end
    path.should eq([a, b])
  end

  it "search shortest path of two possible" do
    a = AStar::Node.new "A"
    b = AStar::Node.new "B"
    c = AStar::Node.new "C"
    d = AStar::Node.new "D"

    # long route
    a.connect b, 1
    b.connect c, 3
    c.connect d, 2

    # short route
    b.connect d, 1

    path = AStar.search a, d do |node1, node2|
      0
    end
    path.should eq([a, b, d])
  end

  it "no possible path" do
    a = AStar::Node.new "A"
    b = AStar::Node.new "B"
    c = AStar::Node.new "C"

    # no connection to goal
    a.connect b, 2

    path = AStar.search a, c do |node1, node2|
      0
    end
    path.should be_nil
  end

  it "use node data" do
    a = AStar::Node.new({x: 0, y: 0})
    b = AStar::Node.new({x: 0, y: 0})
    c = AStar::Node.new({x: 0, y: 0})
    d = AStar::Node.new({x: 0, y: 0})
    e = AStar::Node.new({x: 0, y: 0})

    a.connect b, 1
    b.connect c, 3
    c.connect d, 2
    d.connect e, 4

    path = AStar.search a, e do |node1, node2|
      node1.data[:x] + node2.data[:x]
    end
    path.should eq([a, b, c, d, e])
  end

  it "Node#to_s(io) appends correct data" do
    io = IO::Memory.new
    AStar::Node.new("Spec").to_s io
    io.to_s.should eq("Spec")

    io.clear
    AStar::Node.new({spec: true}).to_s io
    io.to_s.should eq("{spec: true}")
  end
end
