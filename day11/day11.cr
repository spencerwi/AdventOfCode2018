alias Point = NamedTuple(x: Int32, y: Int32)

# These aliases aren't necessary at all, but they help readability
alias Size = Int32
alias PowerGrid = Array(Array(Int32))

class Day11
    @grid : PowerGrid

    def initialize(serial_number : Int32)
        @grid = Array.new(300) do |y|
            Array.new(300) do |x| 
                rack_id = x + 10 # start with the rack id (x-coordinate times 10)
                power_level = rack_id * y # multiply it by the y-coordinate
                power_level += serial_number # increase it by the serial number 
                power_level *= rack_id # multiply by the rack id
                hundreds_digit = # take only the hundreds digit
                    if power_level < 100
                        0
                    else
                        power_level.to_s.chars[-3].to_i
                    end
                power_level = hundreds_digit - 5 # subtract 5
            end
        end

    end

    # Part A: Find the top-left point of the highest-powered 3x3 subgrid.
    def part_a : Point
        point, size = self.find_highest_power_grid_of_size(3)
        return point
    end

    # Part B: Find the top-left point and subgrid size of the highest-powered
    # subgrid of any size.
    def part_b : Tuple(Point, Size)
        # This part can take a really long time, so we cheat a bit. 
        # As it turns out, most inputs will eventually reach a point where 
        # growing the "sum grid" size just makes grid sums more and more 
        # negative, as each cell will be somewhere between -5 and 4 (since the 
        # last step of the "power level" math is to subtract 5 from a single 
        # digit (0 through 9). Thus, each cell is more likely to be negative 
        # than positive, and so there will likely be a point where growing the 
        # grid size larger just makes the max grid sum get more negative, as 
        # you'll be including more and more negative numbers.
        if self.grid_trends_negative?
            puts "Grid grends negative, so we can stop searching once we first go negative."
            largest_grid_sum = Int64::MIN
            largest_grid_sum_size = 0
            largest_grid_sum_point = nil
            (2..300).each do |size|
                point, sum = self.find_highest_power_grid_of_size(size)
                if sum > largest_grid_sum
                    largest_grid_sum = sum
                    largest_grid_sum_size = size
                    largest_grid_sum_point = point
                end
                break if sum < 0
            end
            return {largest_grid_sum_point.not_nil!, largest_grid_sum_size}
        else 
            # If the whole grid doesn't trend negative, then this could be a 
            # *really* long process, so let's start spitting out answers as we 
            # go, and we can try each of them to see if one of the "along the 
            # way" answers is correct.
            point, size, _ = (2..300).to_a.map do |size|
                point, sum = self.find_highest_power_grid_of_size(size)
                puts "Largest for size #{size} is #{point} with a sum of #{sum}"
                {point, size, sum}
            end.max_by {|point, size, sum| sum}
            return {point, size}
        end
    end

    private def grid_trends_negative? : Bool
        whole_grid_sum = self.grid_sum({x: 0, y: 0}, 300)
        return whole_grid_sum < 0
    end

    private def find_highest_power_grid_of_size(size : Size) : Tuple(Point, Int32)
        valid_cell_corners = (0..@grid.size - size).to_a
            .product((0..@grid.size - size).to_a)

        points_with_grid_sums = valid_cell_corners.map do |x, y|
            grid_sum = self.grid_sum({x: x, y: y}, size)
            { {x: x, y: y}, grid_sum }
        end
        return points_with_grid_sums.max_by {|point, sum| sum}
    end

    private def grid_sum(top_left : Point, size : Size) : Int32
        x, y = top_left[:x], top_left[:y]
        every_x_y_combination_in_grid = (x..x + (size - 1)).to_a.product((y..y + (size - 1)).to_a)
        cells_in_grid = every_x_y_combination_in_grid.map {|x, y| @grid[y][x]}

        return cells_in_grid.sum
    end
end

day11 = Day11.new(8772) 
puts "11A: #{day11.part_a}"
puts "11B: #{day11.part_b}"
