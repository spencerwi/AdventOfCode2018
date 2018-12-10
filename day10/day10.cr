alias X = Int32
alias Y = Int32
class Star
  getter position, velocity

  def initialize(@position : Tuple(X, Y), @velocity : Tuple(X, Y))
  end

  def tick
    x, y = @position
    vx, vy = @velocity
    @position = {x + vx, y + vy}
  end

  def self.parse(input_line : String) : Star
    if /position=<\s*(?<x>-?\d+),\s*(?<y>-?\d+)> velocity=<\s*(?<vx>-?\d+),\s*(?<vy>-?\d+)/ =~ input_line
      x, y, vx, vy = ["x", "y", "vx", "vy"].map {|group| $~[group].to_i}
      return Star.new(position = {x, y}, velocity = {vx, vy})
    else
      raise "Invalid line: #{input_line}"
    end
  end
end

class Day10
  @stars : Array(Star)

  def initialize(input_lines : Array(String))
    @stars = input_lines.map {|line| Star.parse(line)}
  end

  def solve
    seconds_passed = 0
    loop do

      # If the stars are suuuuper far apart, we know they can't possibly be letters yet.
      smallest_x, largest_x = @stars.minmax_of(&.position[0])
      smallest_y, largest_y = @stars.minmax_of(&.position[1])

      if (largest_x - smallest_x) <= 100 && (largest_y - smallest_y) < 100
        (smallest_y..largest_y).each do |y|
          if @stars.any? {|star| star.position[1] == y} # skip blank rows
            (smallest_x..largest_x).map do |x|
              if @stars.any? {|star| star.position == {x,y}}
                print "#"
              else
                print " "
              end
            end
            print "\n"
          end
        end

        # Write the image to a file, and wait for user to hit enter
        puts "#{seconds_passed} seconds have passed. Hit enter to move forward 1 second"
        _ = read_line
      end

      seconds_passed += 1
      @stars.each(&.tick)
    end
  end

  def part_b
  end

  def print_usage_and_exit
    puts "Usage: day10 [A|a|B|b]"
    exit 1
  end
end

day10 = Day10.new(File.read_lines("input.txt"))
day10.solve
