def manhattan_distance(
    x1 : Int64, y1 : Int64, z1 : Int64,
    x2 : Int64, y2 : Int64, z2 : Int64
) : Int64
    return [
        x2 - x1,
        y2 - y1,
        z2 - z1
    ].map(&.abs).sum
end
struct Nanobot
    getter x, y, z, radius
    def initialize(@x : Int64, @y : Int64, @z : Int64, @radius : Int64)
    end

    def distance_to(other : Nanobot) : Int64
        self.distance_to(other.x, other.y, other.z)
    end

    def distance_to(x : Int64, y : Int64, z : Int64) : Int64
        manhattan_distance(@x, @y, @z, x, y, z)
    end

    def is_in_range?(other : Nanobot) : Bool
        self.distance_to(other) <= @radius
    end
    def is_in_range?(x : Int64, y : Int64, z : Int64) : Bool
        self.distance_to(x, y, z) <= @radius
    end

    def self.parse(str : String) : Nanobot
        if /pos=<(?<x>-?\d+),(?<y>-?\d+),(?<z>-?\d+)>, r=(?<radius>\d+)/ =~ str
            x, y, z, radius = ["x", "y", "z", "radius"].map {|field| $~[field].to_i64 }
            return Nanobot.new(x, y, z, radius)
        else
            raise ArgumentError.new("Invalid string: '#{str}'")
        end
    end
end

class Day23
    @bots : Array(Nanobot)

    def initialize(input_lines : Array(String))
        @bots = input_lines.map {|line| Nanobot.parse(line)}
    end

    # Part A problem statement: how many nanobots are in range
    # of the nanobot with the strongest signal?
    def part_a
        largest_radius_bot = @bots.max_by(&.radius).not_nil!
        @bots.select do |other_bot|
            largest_radius_bot.is_in_range?(other_bot)
        end.size
    end

    # Part B problem statement: find the point that is in range of the highest
    # number of other nanobots, with ties broken by the closest one to 0,0,0
    # in terms of manhattan distance -- and then return the manhattan distance
    def part_b
        min_x, max_x = @bots.minmax_of(&.x)
        min_y, max_y = @bots.minmax_of(&.y)
        min_z, max_z = @bots.minmax_of(&.z)

        xs = (min_x..max_x).to_a
        ys = (min_y..max_y).to_a
        zs = (min_z..max_z).to_a

        highest_bots_seen = 0
        closest_distance_to_origin = Int64::MAX
        Array(Int64).each_product(xs, ys, zs) do |(x, y, z)|
            bots_that_can_see_this_point = @bots.select {|other| other.is_in_range?(x,y,z)}.size
            if bots_that_can_see_this_point > highest_bots_seen
                # If this is the new high (no ties), record its distance and seen-by-bots count
                distance_to_origin = manhattan_distance(0, 0, 0, x, y, z)
                closest_distance_to_origin = distance_to_origin
                highest_bots_seen = bots_that_can_see_this_point
            elsif bots_that_can_see_this_point == highest_bots_seen 
                # on a tiebreaker, go with the closest one to the origin
                distance_to_origin = manhattan_distance(0, 0, 0, x, y, z)
                closest_distance_to_origin = Math.min(closest_distance_to_origin, distance_to_origin)
            end
        end

        return closest_distance_to_origin
    end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
    day23 = Day23.new(File.read_lines("input.txt"))
    puts "23A: #{day23.part_a}"
    puts "23B: #{day23.part_b}"
end
