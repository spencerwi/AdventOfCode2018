require "../day9"
require "spec"

describe Day9 do

    describe "#part_a" do
        it "works correctly for sample input" do
            sample_inputs_with_expected_outputs = {
                "10 players; last marble is worth 1618 points" => 8317,
                "13 players; last marble is worth 7999 points" => 146373,
                "17 players; last marble is worth 1104 points" => 2764,
                "17 players; last marble is worth 1104 points" => 2764,
                "21 players; last marble is worth 6111 points" => 54718,
                "30 players; last marble is worth 5807 points" => 37305
            }

            sample_inputs_with_expected_outputs.each do |sample_input, expected_output|
                Day9.new(sample_input).part_a.should eq expected_output
            end
        end
    end

    # There's no sample input/output for part_b, since it's just part_a but larger
end
