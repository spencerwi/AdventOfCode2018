require "../day23"
require "spec"

describe Nanobot do

    describe ".parse" do

        it "works correctly for valid input" do
            sample_input = "pos=<1,3,2>, r=4"

            result = Nanobot.parse(sample_input)

            result.x.should eq 1
            result.y.should eq 3
            result.z.should eq 2
            result.radius.should eq 4
        end

        it "works correctly for valid input with negative numbers" do
            sample_inputs = {
                "pos=<-1,3,2>, r=4" => Nanobot.new(-1,3,2,4),
                "pos=<1,-3,2>, r=4" => Nanobot.new(1,-3,2,4),
                "pos=<1,3,-2>, r=4" => Nanobot.new(1,3,-2,4),
            }
            sample_inputs.each do |(sample_input, expected_result)| 
                Nanobot.parse(sample_input).should eq expected_result
            end
        end

        it "works correctly for invalid input" do
            invalid_inputs = [
                "pos=<1,3,2>, r=",
                "pos=<1,3,2>, r=a",
                "pos=<1,3,>, r=4",
                "pos=<1,3,a>, r=4",
                "pos=<1,,2>, r=4",
                "pos=<1,a,2>, r=4",
                "pos=<,3,2>, r=4",
                "pos=<a,3,2>, r=4",
            ]

            invalid_inputs.each do |invalid_input|
                expect_raises(ArgumentError, "Invalid string: '#{invalid_input}'") do
                    Nanobot.parse(invalid_input)
                end
            end
        end

    end

    describe "#distance_to" do
        it "works correctly for sample input" do
            bot = Nanobot.new(0, 0, 0, 4)

            sample_cases = {
                Nanobot.new(0,0,0,0) => 0,
                Nanobot.new(1,0,0,0) => 1,
                Nanobot.new(4,0,0,0) => 4,
                Nanobot.new(0,2,0,0) => 2,
                Nanobot.new(0,5,0,0) => 5,
                Nanobot.new(0,0,3,0) => 3,
                Nanobot.new(1,1,1,0) => 3,
                Nanobot.new(1,1,2,0) => 4,
                Nanobot.new(1,3,1,0) => 5,
            }

            sample_cases.each do |(input, expected_distance)|
                bot.distance_to(input).should eq expected_distance
            end
        end
    end

    describe "#is_in_range" do
        it "works correctly for sample input" do
            bot = Nanobot.new(0, 0, 0, 4)

            sample_cases = {
                Nanobot.new(0,0,0,0) => true,
                Nanobot.new(1,0,0,0) => true,
                Nanobot.new(4,0,0,0) => true,
                Nanobot.new(0,2,0,0) => true,
                Nanobot.new(0,5,0,0) => false,
                Nanobot.new(0,0,3,0) => true,
                Nanobot.new(1,1,1,0) => true,
                Nanobot.new(1,1,2,0) => true,
                Nanobot.new(1,3,1,0) => false,
            }

            sample_cases.each do |(input, expected_distance)|
                bot.is_in_range?(input).should eq expected_distance
            end
        end
    end

end

describe Day23 do

    describe "#part_a" do 
        it "behaves correctly for sample input" do
            sample_input = <<-INPUT
            pos=<0,0,0>, r=4
            pos=<1,0,0>, r=1
            pos=<4,0,0>, r=3
            pos=<0,2,0>, r=1
            pos=<0,5,0>, r=3
            pos=<0,0,3>, r=1
            pos=<1,1,1>, r=1
            pos=<1,1,2>, r=1
            pos=<1,3,1>, r=1
            INPUT

            Day23.new(sample_input.lines).part_a.should eq 7
        end
    end

    describe "#part_b" do 
        it "behaves correctly for sample input" do
            sample_input = <<-INPUT
            pos=<10,12,12>, r=2
            pos=<12,14,12>, r=2
            pos=<16,12,12>, r=4
            pos=<14,14,14>, r=6
            pos=<50,50,50>, r=200
            pos=<10,10,10>, r=5
            INPUT

            Day23.new(sample_input.lines).part_b.should eq 36
        end
    end
end
