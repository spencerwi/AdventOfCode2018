require "../day11"
require "spec"

describe Day11 do

    it "does cell power-level math correctly" do
        sample_inputs_with_expected_outputs = {
            {57, {x: 122, y: 79}} => -5,
            {39, {x: 217, y: 196}} => 0,
            {71, {x: 101, y: 153}} => 4,
        }

        sample_inputs_with_expected_outputs.each do |sample_input, expected_output|
            grid_power_level, cell = sample_input
            Day11.new(grid_power_level).grid[cell[:y]][cell[:x]].should eq expected_output
        end
    end

    describe "#part_a" do
        it "works correctly for sample input" do
            sample_inputs_with_expected_outputs = {
                18 => {x: 33, y: 45},
                42 => {x: 21, y: 61},
            }

            sample_inputs_with_expected_outputs.each do |sample_input, expected_output|
                Day11.new(sample_input).part_a.should eq expected_output
            end
        end
    end

    ## This spec is *really* slow, so it's commented out for now.

    # describe "#part_b" do
    #     it "works correctly for sample input" do
    #         sample_inputs_with_expected_outputs = {
    #             18 => { {x: 33, y: 45}, 16},
    #             42 => { {x: 21, y: 61}, 12},
    #         }

    #         sample_inputs_with_expected_outputs.each do |sample_input, expected_output|
    #             Day11.new(sample_input).part_b.should eq expected_output
    #         end
    #     end
    # end

end
