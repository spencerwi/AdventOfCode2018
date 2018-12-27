require "../day17"
require "spec"

describe ClayVein do

    describe "#parse" do

        it "handles x-ranges correctly" do
            vein = ClayVein.parse("x=1..3, y=10")
            vein.coords.should eq [
                {1, 10},
                {2, 10},
                {3, 10}
            ]
        end

        it "handles y-ranges correctly" do
            vein = ClayVein.parse("x=1, y=10..12")
            vein.coords.should eq [
                {1, 10},
                {1, 11},
                {1, 12}
            ]
        end

        it "handles y,x coords correctly" do
            vein = ClayVein.parse("y=1, x=10..12")
            vein.coords.should eq [
                {10, 1},
                {11, 1},
                {12, 1}
            ]
        end

    end

end

describe Ground do
    describe "#flow" do
        it "behaves correctly" do
            input = <<-INPUT
            x=495, y=2..7
            y=7, x=495..501
            x=501, y=3..7
            x=498, y=2..4
            x=506, y=1..2
            x=498, y=10..13
            x=504, y=10..13
            y=13, x=498..504
            INPUT
            day17 = Day17.new(input.lines)

            ground = day17.ground

            ground.flow(Coords.new(500, 0))
            puts ground.to_s(494..506, 0..13)
            ground.to_s(494..506, 0..13).should eq <<-OUTPUT
            ......+......
            ......|.....#
            .#..#||||...#
            .#..#~~#|....
            .#..#~~#|....
            .#~~~~~#|....
            .#~~~~~#|....
            .#######|....
            ........|....
            ...|||||||||.
            ...|#~~~~~#|.
            ...|#~~~~~#|.
            ...|#~~~~~#|.
            ...|#######|.
            OUTPUT
        end
    end

end

describe Day17 do

    it "parses input correctly" do 
        input = <<-INPUT
        x=495, y=2..7
        y=7, x=495..501
        x=501, y=3..7
        x=498, y=2..4
        x=506, y=1..2
        x=498, y=10..13
        x=504, y=10..13
        y=13, x=498..504
        INPUT

        day17 = Day17.new(input.lines)
        day17.veins.size.should eq input.lines.size
        day17.ground.width.should eq 507
        day17.ground.height.should eq 14

        day17.veins.each do |vein|
            vein.coords.each do |coord|
                day17.ground[coord].should eq Element::Clay
            end
        end

        day17.ground.to_s(494..506, 0..13).should eq <<-OUTPUT
        ......+......
        ............#
        .#..#.......#
        .#..#..#.....
        .#..#..#.....
        .#.....#.....
        .#.....#.....
        .#######.....
        .............
        .............
        ....#.....#..
        ....#.....#..
        ....#.....#..
        ....#######..
        OUTPUT
    end

    describe "#part_a" do 
        it "behaves correctly for sample input" do
            input = <<-INPUT
            x=495, y=2..7
            y=7, x=495..501
            x=501, y=3..7
            x=498, y=2..4
            x=506, y=1..2
            x=498, y=10..13
            x=504, y=10..13
            y=13, x=498..504
            INPUT

            day17 = Day17.new(input.lines)
            day17.veins.size.should eq input.lines.size

            day17.part_a.should eq 57
        end
    end

    describe "#part_b" do 
        it "behaves correctly for sample input" do
            input = <<-INPUT
            x=495, y=2..7
            y=7, x=495..501
            x=501, y=3..7
            x=498, y=2..4
            x=506, y=1..2
            x=498, y=10..13
            x=504, y=10..13
            y=13, x=498..504
            INPUT

            day17 = Day17.new(input.lines)
            day17.veins.size.should eq input.lines.size

            day17.part_b.should eq 29
        end
    end

end
