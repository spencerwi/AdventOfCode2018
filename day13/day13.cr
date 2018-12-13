module Directions
    enum Turn
        Left,
        Straight,
        Right

        def next
            Turn.from_value((self.value + 1) % 3)
        end
    end

    enum Compass
        North,
        East,
        West,
        South

        def self.of_char(c : Char)
            case c 
            when '^' then North
            when '>' then East
            when '<' then West
            when 'v' then South
            else raise "Invalid cart char: '#{c}'"
            end
        end

        def to_char
            ['^', '>', 'v', '<'].find {|c| Compass.of_char(c) == self}.not_nil!
        end

        def replacement_track_char
            case self
            when North, South then '|'
            when East, West then '-'
            end.not_nil!
        end

        def turn(turn : Turn) : Compass
            return self if turn.straight?

            case self
            when .north? then
                case turn
                when .left? then West
                when .right? then East
                end
            when .east? then
                case turn
                when .left? then North
                when .right? then South
                end
            when .west? then
                case turn
                when .left? then South
                when .right? then North
                end
            when .south? then
                case turn
                when .left? then East
                when .right? then West
                end
            end.not_nil!
        end
    end
end

class Cart
    include Directions
    def self.is_cart_char?(c : Char)
        ['>', '^', 'v', '<'].includes?(c)
    end

    getter direction, x, y
    @direction : Compass
    @next_turn : Turn

    def initialize(cart_char : Char, @x : Int32, @y : Int32)
        @direction = Compass.of_char(cart_char)
        @next_turn = Turn::Left
    end

    def to_char 
        @direction.to_char
    end

    def tick(grid : Array(Array(Char)))
        char_under_cart = grid[@y][@x]
        case char_under_cart
        when '|', '-' then self.move(@direction)
        when '\\', '/' then self.handle_curve(char_under_cart)
        when '+' then self.handle_intersection
        end
    end

    private def move(direction : Compass)
        @x, @y = case direction
                 when .north? then {@x,   @y-1}
                 when .east?  then {@x+1, @y}
                 when .west?  then {@x-1, @y}
                 when .south? then {@x,   @y+1}
                 end.not_nil!
    end

    private def handle_curve(curve_char : Char)
        @direction =
            if curve_char == '\\'
                case @direction 
                when .north? then Compass::West
                when .east?  then Compass::South
                when .west?  then Compass::North 
                when .south? then Compass::East 
                end
            elsif curve_char == '/'
                case @direction
                when .north? then Compass::East
                when .east?  then Compass::North
                when .west?  then Compass::South
                when .south? then Compass::West
                end
            end.not_nil!
        self.move(@direction)
    end

    private def handle_intersection
        @direction = @direction.turn(@next_turn)
        @next_turn = @next_turn.next
        self.move(@direction)
    end

end

class Day13

    enum CrashBehavior
        ReportFirst
        RemoveCrashedCarts
    end

    getter grid, carts

    @carts : Array(Cart)
    @grid : Array(Array(Char))

    def initialize(input_lines : Array(String))
        @grid = input_lines.map(&.chars)

        @carts = Array(Cart).new
        @grid.each_with_index do |row, y|
            row.each_with_index do |char, x|
                if Cart.is_cart_char?(char)
                    cart = Cart.new(char, x, y)
                    @grid[y][x] = cart.direction.replacement_track_char
                    @carts << cart
                end
            end
        end
    end

    # Part A problem statement: locate the site of the first crash.
    def part_a(show_simulation : Bool = false) : Tuple(Int32, Int32)
        self.redraw_sim_output if show_simulation
        loop do
            crash_location = self.tick(CrashBehavior::ReportFirst)
            self.redraw_sim_output if show_simulation
            return crash_location unless crash_location.nil?
        end
    end

    # Part B problem statement: remove any carts that collide, and
    # then report the location of the last remaining cart.
    def part_b(show_simulation : Bool = false) : Tuple(Int32, Int32)
        self.redraw_sim_output if show_simulation
        loop do
            self.tick(CrashBehavior::RemoveCrashedCarts)
            self.redraw_sim_output if show_simulation
            if @carts.size == 1
                return {@carts[0].x, @carts[0].y}
            end
        end
    end


    # Advances carts one at a time, checking for collisions and reporting the
    # location of the first collision, if any occurred.
    def tick(crash_behavior : CrashBehavior) : Tuple(Int32, Int32)?
        new_carts = @carts.dup

        # Move all carts, starting from the top-left one
        @carts.sort_by {|c| {c.y, c.x} }.each do |cart| 
            cart.tick(@grid)
            carts_already_occupying_new_position = 
                @carts.reject {|other| other == cart}
                .select {|other| other.x == cart.x && other.y == cart.y}

            if carts_already_occupying_new_position.size > 0
                if crash_behavior.report_first?
                    return {cart.x, cart.y}
                elsif crash_behavior.remove_crashed_carts?
                    # remove all crashed carts
                    new_carts.delete(cart) # this one
                    carts_already_occupying_new_position.each {|c| new_carts.delete(c)} # and any others on that spot
                end
            end
        end

        @carts = new_carts
        return nil
    end

    private def redraw_sim_output
        puts `clear`
        puts self.to_s
    end

    def to_s
        @grid.map_with_index do |row, y|
            row.map_with_index do |char, x|
                cart_at_location = @carts.find{|c| c.x == x && c.y == y}
                if cart_at_location
                    cart_at_location.to_char
                else
                    char
                end
            end.join("")
        end.join("\n")
    end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
    day13 = Day13.new(File.read_lines("input.txt"))
    puts "13A: #{day13.part_a}"

    # Reset state by re-reading input
    day13 = Day13.new(File.read_lines("input.txt"))
    puts "13B: #{day13.part_b}"
end
