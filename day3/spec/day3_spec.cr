require "../day3"
require "spec"

describe Day3 do

    input = <<-INPUT
    #1 @ 1,3: 4x4
    #2 @ 3,1: 4x4
    #3 @ 5,5: 2x2
    INPUT

    describe "#part_a" do
        it "works correctly for sample input" do
            Day3.new(input.lines).part_a.should eq 4
        end
    end

    describe "#part_b" do
        it "works correctly for sample input" do
            Day3.new(input.lines).part_b.should eq 3
        end
    end

end

