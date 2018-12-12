require "../day10"
require "spec"

describe Star do

    rng = Random.new

    it "parses string input correctly" do
        10_000.times do 
            x, y, vx, vy = rng.next_int, rng.next_int, rng.next_int, rng.next_int
            star = Star.parse("position=< #{x},#{y}> velocity=<#{vx}, #{vy}>")

            star.position.should eq({x, y})
            star.velocity.should eq({vx, vy})
        end
    end

    it "moves correctly" do
        10_000.times do 
            x, y, vx, vy = rng.next_int, rng.next_int, rng.next_int, rng.next_int
            star = Star.new({x,y}, {vx,vy})

            star.tick

            star.position.should eq({x + vx, y + vy})
        end
    end

end

describe Day10 do

    it "prints the night sky correctly" do
        sample_input = <<-INPUT
        position=< 9,  1> velocity=< 0,  2>
        position=< 7,  0> velocity=<-1,  0>
        position=< 3, -2> velocity=<-1,  1>
        position=< 6, 10> velocity=<-2, -1>
        position=< 2, -4> velocity=< 2,  2>
        position=<-6, 10> velocity=< 2, -2>
        position=< 1,  8> velocity=< 1, -1>
        position=< 1,  7> velocity=< 1,  0>
        position=<-3, 11> velocity=< 1, -2>
        position=< 7,  6> velocity=<-1, -1>
        position=<-2,  3> velocity=< 1,  0>
        position=<-4,  3> velocity=< 2,  0>
        position=<10, -3> velocity=<-1,  1>
        position=< 5, 11> velocity=< 1, -2>
        position=< 4,  7> velocity=< 0, -1>
        position=< 8, -2> velocity=< 0,  1>
        position=<15,  0> velocity=<-2,  0>
        position=< 1,  6> velocity=< 1,  0>
        position=< 8,  9> velocity=< 0, -1>
        position=< 3,  3> velocity=<-1,  1>
        position=< 0,  5> velocity=< 0, -1>
        position=<-2,  2> velocity=< 2,  0>
        position=< 5, -2> velocity=< 1,  2>
        position=< 1,  4> velocity=< 2,  1>
        position=<-2,  7> velocity=< 2, -2>
        position=< 3,  6> velocity=<-1, -1>
        position=< 5,  0> velocity=< 1,  0>
        position=<-6,  0> velocity=< 2,  0>
        position=< 5,  9> velocity=< 1, -2>
        position=<14,  7> velocity=<-2,  0>
        position=<-3,  6> velocity=< 2, -1>
        INPUT

        expected_output = <<-OUTPUT
        ........#.............
        ................#.....
        .........#.#..#.......
        #..........#.#.......#
        ...............#......
        ....#.................
        ..#.#....#............
        .......#..............
        ......#...............
        ...#...#.#...#........
        ....#..#..#.........#.
        .......#..............
        ...........#..#.......
        #...........#.........
        ...#.......#..........
        OUTPUT

        day10 = Day10.new(sample_input.lines)
        fake_stdout = IO::Memory.new(0)

        day10.print_night_sky({-6, 15}, {-4, 11}, fake_stdout)

        fake_stdout.to_s.strip.should eq(expected_output.strip)
    end

    # Since Day 10's solution just keeps spitting output until we stop it, there's
    # not a great way to TDD the solve method itself.
end
