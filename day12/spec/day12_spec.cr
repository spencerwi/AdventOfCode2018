require "../day12"
require "spec"

describe Rule do

    describe ".parse" do

        it "errors on incorrect input" do
            invalid_rules = ["", "Foo bar", "   ", "...#.. => ", ". => ?"]
            invalid_rules.each do |invalid_rule|
                expect_raises(Exception, "Invalid rule string: '#{invalid_rule}'") do 
                    Rule.parse invalid_rule
                end
            end
        end

        it "parses correct inputs" do
            valid_rules_with_expected_results = {
                ". => ." => ".",
                ". => #" => ".",
                "# => #" => "#", 
                "# => ." => "#", 
                ".# => #" => ".#",
                ".#. => #" => ".#."
            }

            valid_rules_with_expected_results.each do |rule_str, expected_result|
                rule = Rule.parse(rule_str)

                rule.pattern.should eq expected_result
            end
        end
    end

    describe "#matches" do

        it "should report matches correctly" do
            rule = Rule.new(".#.##")

            rule.matches?(".#.##").should be_true
        end

        it "should report mismatches correctly" do
            rule = Rule.new(".#.##")

            rule.matches?("##.##").should be_false
            rule.matches?("...##").should be_false
            rule.matches?(".####").should be_false
            rule.matches?(".#..#").should be_false
            rule.matches?(".#.#.").should be_false
            rule.matches?("")
            rule.matches?(".#.##.").should be_false
            rule.matches?(".#.###").should be_false
        end

    end
end

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

            garden.rules.should eq [
                Rule.parse("...## => #"),
                Rule.parse("..#.. => #"),
                Rule.parse(".#... => #"),
                Rule.parse(".#.#. => #"),
                Rule.parse(".#.## => #"),
                Rule.parse(".##.. => #"),
                Rule.parse(".#### => #"),
                Rule.parse("#.#.# => #"),
                Rule.parse("#.### => #"),
                Rule.parse("##.#. => #"),
                Rule.parse("##.## => #"),
                Rule.parse("###.. => #"),
                Rule.parse("###.# => #"),
                Rule.parse("####. => #"),
            ]
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
            day12 = Day12.new(sample_input.lines, 20)

            day12.part_a.should eq 325
        end

    end

end
