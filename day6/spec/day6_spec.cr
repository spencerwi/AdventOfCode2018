require "../day6"
require "spec"

describe Day6 do

    input = <<-INPUT
    1, 1
    1, 6
    8, 3
    3, 4
    5, 5
    8, 9
    INPUT

    describe "#part_a" do
        it "works correctly for sample input" do
            Day6.new(input.lines).part_a.should eq 17
        end
    end

    describe "#part_b" do
        it "works correctly for sample input" do
            Day6.new(input.lines, safe_region_size = 32).part_b.should eq 16
        end
    end
end
