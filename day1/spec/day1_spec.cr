require "../day1"
require "spec"

describe Day1 do
    describe "#part_a" do
        it "works correctly for sample input" do
            input = <<-SAMPLE
            +1
            -2
            +3
            +1
            SAMPLE
            day1 = Day1.new(input)

            day1.part_a.should eq 3 
        end
    end

    describe "#part_b" do
        it "works correctly for sample input" do
            sample_inputs_with_expected_outputs = {
                "+1, -1" => 0,
                "+3, +3, +4, -2, -4" => 10,
                "-6, +3, +8, +5, -6" => 5,
                "+7, +7, -2, -7, -4" => 14
            }
            sample_inputs_with_expected_outputs.each do |input_str, expected_output|
                day1 = Day1.new(input_str.gsub(", ", "\n"))
                day1.part_b.should eq expected_output
            end
        end
    end
end
