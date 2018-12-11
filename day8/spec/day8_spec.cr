require "../day8"
require "spec"

describe Day8 do

    input = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"

    describe "#part_a" do
        it "works correctly for sample input" do
            Day8.new(input.split.map(&.to_i)).part_a.should eq 138
        end
    end

    describe "#part_b" do
        it "works correctly for sample input" do
            Day8.new(input.split.map(&.to_i)).part_b.should eq 66
        end
    end

end
