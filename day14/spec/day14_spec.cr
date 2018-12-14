require "../day14"
require "spec"

describe Day14 do

    describe "#tick" do
        it "behaves correctly" do
            day14 = Day14.new("9")
            
            day14.tick
            day14.to_s.should eq "(3) [7] 1 0"

            day14.tick
            day14.to_s.should eq "3 7 1 [0] (1) 0"
        end
    end

    describe "#part_a" do 
        it "behaves correctly for sample input" do
            inputs_and_expected_outputs = {
                "9" => "5158916779",
                "5" => "0124515891",
                "18" => "9251071085",
                "2018" => "5941429882",
            }

            inputs_and_expected_outputs.each do |input, expected_output|
                day14 = Day14.new(input)
                day14.part_a.should eq expected_output
            end
        end
    end

    describe "#part_b" do
        it "behaves correctly for sample input" do
            inputs_and_expected_outputs = {
                "51589" => 9,
                "01245" => 5,
                "92510" => 18,
                "59414" => 2018,
            }

            inputs_and_expected_outputs.each do |input, expected_output|
                day14 = Day14.new(input)
                day14.part_b.should eq expected_output
            end
        end
    end

end
