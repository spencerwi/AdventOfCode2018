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
    describe "#tick" do
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

            ground.tick

            ground.to_s(494..506, 0..13).should eq <<-OUTPUT
            ......+......
            ......~.....#
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

            6.times { ground.tick }

            ground.to_s(494..506, 0..13).should eq <<-OUTPUT
            ......+......
            ......~.....#
            .#..#.~.....#
            .#..#.~#.....
            .#..#.~#.....
            .#....~#.....
            .#...~~#.....
            .#######.....
            .............
            .............
            ....#.....#..
            ....#.....#..
            ....#.....#..
            ....#######..
            OUTPUT

            4.times { ground.tick }


            loop do  
                begin
                    ground.tick
                rescue SimulationEnded
                    ground.to_s(494..506, 0..13).should eq <<-OUTPUT
                    ......+......
                    ......~.....#
                    .#..#~~~~...#
                    .#..#~~#~....
                    .#..#~~#~....
                    .#~~~~~#~....
                    .#~~~~~#~....
                    .#######~....
                    ........~....
                    ...~~~~~~....
                    ...~#~~~~~#..
                    ...~#~~~~~#..
                    ...~#~~~~~#..
                    ...~#######..
                    OUTPUT
                end
            end

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
        end
    end

end
