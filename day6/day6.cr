# A convenience class for checking grid logic and iterating over cells.
class Grid
    def initialize(@size : Int32)
    end

    # A convenience iterator for working with all cells in the grid.
    def each_cell(&block)
        (0..@size).each do |x|
            (0..@size).each do |y|
                yield x, y
            end
        end
    end

    # Determines if a point is on the edge of the grid
    def is_on_edge?(x : Int32, y : Int32)
        return x == 0 || y == 0 || x == @size || y == @size
    end
end

# These are the points we're given as inputs. It's helpful to have specific 
# objects representing them, so we can use a Hash(Point, Area). It's a struct
# instead of a class so that it uses value equality, and because it'll be 
# immutable once constructed, so identity doesn't really matter.
struct Point 
    getter x, y
    def initialize(@x : Int32, @y : Int32)
    end

    def self.parse(str : String) : Point
        x, y = str.split(", ").map(&.to_i)       
        return Point.new(x, y)
    end
end

# These are the areas claimed by each point. We really just care about:
#  - what point the area belongs to
#  - how big the area is, and
#  - whether the area is considered "infinite".
# An area is considered "infinite" if it touches an edge of the grid, or if its 
# "claiming point" touches an edge of the grid.
class Area
    property size, is_infinite
    @size : Int32

    def initialize(@is_infinite : Bool = false)
        @size = 0
    end
end

# Finally, our solver class
class Day6
    @input : Array(Point)
    @grid : Grid
    
    def initialize(input_str : Array(String), @safe_region_size : Int32 = 10_000)
        @input = input_str.map {|str| Point.parse(str)}

        max_x = @input.max_of(&.x)
        max_y = @input.max_of(&.y)
        grid_size = Math.max(max_x, max_y)
        @grid = Grid.new(grid_size)
    end

    # Part A problem statement: Find the size of the largest finite area 
    def part_a : Int32
        # First, ensure we have an area per point, and check if the point
        # makes the area already infinite by being on an edge.
        areas_by_point : Hash(Point, Area) = @input.map do |point| 
            area = Area.new(is_infinite: @grid.is_on_edge?(point.x, point.y))
            {point, area}
        end.to_h

        # Next, for each cell in the grid, find its closest point, then "grow"
        # that point's area by one, checking to see if we're on the edge, and
        # if so, marking the area as infinite.
        @grid.each_cell do |x, y|
            closest_point = self.find_closest_point(x, y)
            if closest_point
                areas_by_point[closest_point].size += 1
                if @grid.is_on_edge?(x, y)
                    areas_by_point[closest_point].is_infinite = true
                end
            end
        end

        # Having done the setup, now we can directly map the problem statement
        # to our output: we want size of the largest finite area, so 
        return areas_by_point.map {|point, area| area} # take all the areas
            .reject(&.is_infinite) # filter down to only the finite ones
            .max_of(&.size) # and take the size of the largest one by size
    end

    # Part B problem statement: find the size of a "safe region", where "safe"
    # is defined as containing only cells within a "total distance" of 10,000 
    # from our points. Total distance is defined as the sum of the manhattan 
    # distances between the cell and each point, so A_dist + B_dist + C_dist...
    def part_b : Int32
        safe_region_size = 0
        @grid.each_cell do |x, y|
            total_distance = @input.map do |point| 
                self.manhattan_distance(x, y, point.x, point.y)
            end.sum
            safe_region_size += 1 if total_distance < @safe_region_size
        end
        return safe_region_size 
    end

    # Returns the closest single point to a given x,y coordinate. If there are 
    # more than one points tied by distance, we return nil.
    private def find_closest_point(x, y) : Point?
        distances_to_points = @input.group_by do |point| 
            self.manhattan_distance(x, y, point.x, point.y)
        end
        _, closest_points = distances_to_points.min_by {|distance, points| distance}
        if closest_points.size == 1
            return closest_points[0]
        else
            return nil
        end
    end

    private def manhattan_distance(x1, y1, x2, y2)
        return (x2 - x1).abs + (y2 - y1).abs
    end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
    day6 = Day6.new(File.read_lines("input.txt"), safe_region_size = 10_000)
    puts "6A: #{day6.part_a}"
    puts "6B: #{day6.part_b}"
end
