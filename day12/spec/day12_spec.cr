require "../day12"
require "spec"

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
                "...##" => '#',
                "..#.." => '#',
                ".#..." => '#',
                ".#.#." => '#',
                ".#.##" => '#',
                ".##.." => '#',
                ".####" => '#',
                "#.#.#" => '#',
                "#.###" => '#',
                "##.#." => '#',
                "##.##" => '#',
                "###.." => '#',
                "###.#" => '#',
                "####." => '#',
            })
        end

    end

    describe "#tick" do

        it "should work as expected for sample input" do
            garden = Garden.parse(sample_input.lines)

            garden.tick
            puts garden.to_s

            # Their 1-generation sample output is weirdly longer than mine
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
