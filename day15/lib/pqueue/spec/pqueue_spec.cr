require "./spec_helper"

describe PriorityQueue do
  it "can be constructed using a Hash-like literal" do
    PriorityQueue::Max{
      1 => :one,
      2 => :two,
    }
  end

  it "PriorityQueue::Max pops highest-priority elements" do
    q = PriorityQueue::Max(Int32, Symbol).new
    q[2] = :two
    q[6] = :six
    q[3] = :three
    q[1] = :one
    q[4] = :four
    q[5] = :five
    q.to_a.should eq [:six, :five, :four, :three, :two, :one]
  end

  it "PriorityQueue::Min pops lowest-priority elements" do
    q = PriorityQueue::Min(Int32, Symbol).new
    q[2] = :two
    q[6] = :six
    q[3] = :three
    q[1] = :one
    q[4] = :four
    q[5] = :five
    q.to_a.should eq [:one, :two, :three, :four, :five, :six]
  end

  it "returns items of the same priority in the order
      they were included" do
    q = PriorityQueue::Max(Int32, Symbol).new
    q[1] = :one
    q[2] = :a
    q[2] = :b
    q[3] = :three
    q.to_a.should eq [:three, :a, :b, :one]
  end

  it "yields to block if popped when empty" do
    q = PriorityQueue::Max(Int32, Symbol).new
    yielded = false
    q.pop { yielded = true }
    yielded.should be_true
  end

  it "raises an error if popped without block when empty" do
    q = PriorityQueue::Max(Int32, Symbol).new
    expect_raises(IndexError) { q.pop }
  end

  it "can peek at the top element and its priority" do
    q = PriorityQueue::Max(Int32, Symbol).new
    q[2] = :two
    q[6] = :six
    q[3] = :three
    q.peek?.should eq :six
    q.priority?.should eq 6
    q.pop
    q.peek?.should eq :three
    q.priority?.should eq 3
    q.pop
    q.peek?.should eq :two
    q.priority?.should eq 2
    q.pop
    q.peek?.should be_nil
    q.priority?.should be_nil
  end

  it "stringifies correctly" do
    q = PriorityQueue::Max(Int32, Symbol).new
    q[2] = :two
    q[6] = :six
    q[3] = :three
    q.to_s.should eq "PriorityQueue{6 => :six... [+2]}"
    q.pop
    q.to_s.should eq "PriorityQueue{3 => :three... [+1]}"
    q.pop
    q.to_s.should eq "PriorityQueue{2 => :two}"
    q.pop
    q.to_s.should eq "PriorityQueue{}"
  end

  it "can duplicate" do
    a = [:a]
    q1 = PriorityQueue::Max(Int32, Array(Symbol)).new
    q1[1] = a
    q2 = q1.dup
    q1.pop.pop
    q1.size.should eq 0
    q2.pop.size.should eq 0
    q2.size.should eq 0
  end

  it "can return all elements in order" do
    q = PriorityQueue::Max(Int32, Symbol).new
    q[2] = :two
    q[6] = :six
    q[3] = :three
    q.to_a.should eq [:six, :three, :two]
  end
end
