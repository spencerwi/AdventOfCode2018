require "../day7"
require "spec"

describe Day7 do

    input = <<-INPUT
    Step C must be finished before step A can begin.
    Step C must be finished before step F can begin.
    Step A must be finished before step B can begin.
    Step A must be finished before step D can begin.
    Step B must be finished before step E can begin.
    Step D must be finished before step E can begin.
    Step F must be finished before step E can begin.
    INPUT
    
    describe "#part_a" do
        it "works correctly for sample input" do
            Day7.new(input.lines, worker_count = 1, step_base_time = 0).part_a.should eq "CABDFE"
        end
    end

    describe "#part_b" do
        it "works correctly for sample input" do
            Day7.new(input.lines, worker_count = 2, step_base_time = 0).part_b.should eq 15
        end
    end

end
