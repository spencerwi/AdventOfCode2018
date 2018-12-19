require "../day18"
require "spec"


describe Forest do
    
    describe "#tick" do

        it "behaves correctly for sample input" do
            sample_input = <<-INPUT
            .#.#...|#.
            .....#|##|
            .|..|...#.
            ..|#.....#
            #.#|||#|#|
            ...#.||...
            .|....|...
            ||...#|.#|
            |.||||..|.
            ...#.|..|.
            INPUT

            forest = Forest.new(sample_input.lines)
            
            forest.tick

            forest.to_s.should eq <<-OUTPUT
            .......##.
            ......|###
            .|..|...#.
            ..|#||...#
            ..##||.|#|
            ...#||||..
            ||...|||..
            |||||.||.|
            ||||||||||
            ....||..|.
            OUTPUT

            forest.tick

            forest.to_s.should eq <<-OUTPUT
            .......#..
            ......|#..
            .|.|||....
            ..##|||..#
            ..###|||#|
            ...#|||||.
            |||||||||.
            ||||||||||
            ||||||||||
            .|||||||||
            OUTPUT

        end

    end

end

describe Day18 do

    describe "#part_a" do 

        it "behaves correctly for sample input" do
            sample_input = <<-INPUT
            .#.#...|#.
            .....#|##|
            .|..|...#.
            ..|#.....#
            #.#|||#|#|
            ...#.||...
            .|....|...
            ||...#|.#|
            |.||||..|.
            ...#.|..|.
            INPUT

            day18 = Day18.new(sample_input.lines)

            day18.part_a.should eq 1147
        end

    end

end
