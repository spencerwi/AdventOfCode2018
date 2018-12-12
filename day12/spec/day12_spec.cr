require "../day12"
require "spec"

# describe Rule do

#     describe ".parse" do

#         it "errors on incorrect input" do
#             invalid_rules = ["", "Foo bar", "   ", "...#.. => ", ". => ?"]
#             invalid_rules.each do |invalid_rule|
#                 expect_raises(Exception, "Invalid rule string: '#{invalid_rule}'") do 
#                     Rule.parse invalid_rule
#                 end
#             end
#         end

#         it "parses correct inputs" do
#             valid_rules_with_expected_results = {
#                 "..... => ." => {0, false},
#                 "....# => #" => {1, true},
#                 "...#. => #" => {2, true},
#                 "..#.# => ." => {5, false},
#                 ".#... => #" => {8, true},
#                 "##### => #" => {1 + 2 + 4 + 8 + 16, true}
#             }

#             valid_rules_with_expected_results.each do |rule_str, expected_result|
#                 rule = Rule.parse(rule_str)

#                 rule.value.should eq expected_result[0]
#                 rule.results_in_plant?.should eq expected_result[1]
#             end
#         end
#     end

#     describe "#matches" do

#         it "should report matches correctly" do
#             rule = Rule.new(8, true)

#             rule.matches?(8).should be_true
#         end

#         it "should report mismatches correctly" do
#             rule = Rule.new(8, true)

#             rule.matches?(1).should be_false
#         end

#     end
# end

describe Garden do

    sample_input = <<-INPUT
    initial state: #..#.#..##......###...###
    
    ...## => #
    ..#.. => #
    .#... => #
    .#.#. => #
    .#.## => #
    .##.. => #
    .#### => #
    #.#.# => #
    #.### => #
    ##.#. => #
    ##.## => #
    ###.. => #
    ###.# => #
    ####. => #
    INPUT


    describe ".parse" do

        it "parses valid input correctly" do
            garden = Garden.parse(sample_input.lines)

            garden.to_s.should eq("#..#.#..##......###...###")

            garden.rules.should eq ({
                "00011".to_u32(2) => true,
                "00100".to_u32(2) => true,
                "01000".to_u32(2) => true,
                "01010".to_u32(2) => true,
                "01011".to_u32(2) => true,
                "01100".to_u32(2) => true,
                "01111".to_u32(2) => true,
                "10101".to_u32(2) => true,
                "10111".to_u32(2) => true,
                "11010".to_u32(2) => true,
                "11011".to_u32(2) => true,
                "11100".to_u32(2) => true,
                "11101".to_u32(2) => true,
                "11110".to_u32(2) => true,
            })
        end

    end

    describe "#tick" do

        it "should work as expected for sample input" do
            garden = Garden.parse(sample_input.lines)

            garden.tick
            puts garden.to_s

            "...#...#....#.....#..#..#..#...........".should contain(garden.to_s)
        end

    end

end

describe Day12 do

    sample_input = <<-INPUT
    initial state: #..#.#..##......###...###
    
    ...## => #
    ..#.. => #
    .#... => #
    .#.#. => #
    .#.## => #
    .##.. => #
    .#### => #
    #.#.# => #
    #.### => #
    ##.#. => #
    ##.## => #
    ###.. => #
    ###.# => #
    ####. => #
    INPUT

    describe "#part_a" do 

        it "behaves correctly for sample input" do
            day12 = Day12.new(sample_input.lines)

            day12.solve(20).should eq 325
        end

    end

end
