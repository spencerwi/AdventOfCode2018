module Directions
    enum Turn
        Left,
        Straight,
        Right

        def next : Turn
            Turn.from_value((self.value + 1) % 3)
        end
    end

    enum Compass
        North,
        East,
        West,
        South

        def self.of_char(c : Char) : Compass
            case c 
            when '^' then North
            when '>' then East
            when '<' then West
            when 'v' then South
            else raise "Invalid cart char: '#{c}'"
            end
        end

        def to_char : Char
            # .to_char is just the reverse of .of_char.
            ['^', '>', 'v', '<'].find {|c| Compass.of_char(c) == self}.not_nil!
        end

        # We want a "clean" grid to work from so that carts trying to figure out
        # what the track looks like under them don't see another cart instead of
        # the track.
        def replacement_track_char : Char
            case self
            when North, South then '|'
            when East, West then '-'
            end.not_nil!
        end

        # If I'm facing a given compass direction, and I want to turn in some
        # turn-direction, what direction will I be facing then?
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
    include Directions # So I don't have to keep typing Directions::

    getter direction, x, y
    @direction : Compass
    @next_turn : Turn

    def initialize(cart_char : Char, @x : Int32, @y : Int32)
        @direction = Compass.of_char(cart_char)
        @next_turn = Turn::Left
    end

    def self.is_cart_char?(c : Char)
        ['>', '^', 'v', '<'].includes?(c)
    end

    def to_char 
        @direction.to_char
    end

    # Updates the cart by moving one step in the appropriate direction and 
    # turning if needed.
    def tick(grid : Array(Array(Char)))
        track_under_cart = grid[@y][@x]
        case track_under_cart
        when '|', '-' then self.move(@direction)
        when '\\', '/' then self.handle_curve(track_under_cart)
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
        # Turn towards the appropriate direction first
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

        # Then move in that direction
        self.move(@direction)
    end

    private def handle_intersection
        # First, turn towards the appropriate compass direction, based on what 
        # our next turn-direction should be,
        @direction = @direction.turn(@next_turn)
        # then update our memory of what our next turn-direction should be,
        @next_turn = @next_turn.next
        # and then move.
        self.move(@direction)
    end

end

class Day13

    # Used by `#tick` to determine how to handle crashes
    enum CrashBehavior
        ReportFirst
        RemoveCrashedCarts
    end

    getter grid, carts
    @grid : Array(Array(Char))
    @carts : Array(Cart)

    def initialize(input_lines : Array(String))
        @carts = [] of Cart
        @grid = input_lines.map_with_index do |row, y|
            row.chars.map_with_index do |char, x|
                # Parse and replace each cart character with the appropriate 
                # kind of track, so that our grid is "clean" and we know for
                # sure what kind of track is at each spot.
                if Cart.is_cart_char?(char)
                    cart = Cart.new(char, x, y)
                    @carts << cart
                    cart.direction.replacement_track_char
                else
                    char
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


    # Advances carts one at a time, checking for collisions and handling the 
    # collision based on the provided crash_behavior. If crash_behavior is
    # `ReportFirst`, then we return immediately on identifying a collision to 
    # report its location. If crash_behavior is `RemoveCrashedCarts`, then we 
    # continue in the case of crashes, but we remove the crashed carts from our 
    # list of carts (and eventually just return nil, since there's nothing 
    # interesting to report).
    def tick(crash_behavior : CrashBehavior) : Tuple(Int32, Int32)?
        new_carts = @carts.dup

        # Move all carts one at a time, starting from the top-left one
        @carts.sort_by {|c| {c.y, c.x} }.each do |cart| 
            cart.tick(@grid)
            # Look for carts already in the spot we just moved into.
            carts_already_occupying_new_position = 
                @carts.reject {|other| other == cart}
                .select {|other| other.x == cart.x && other.y == cart.y}

            # If there's a crash, then we go into crash_behavior
            unless carts_already_occupying_new_position.empty?
                if crash_behavior.report_first?
                    return {cart.x, cart.y}
                elsif crash_behavior.remove_crashed_carts?
                    # Remove all crashed carts.
                    new_carts.delete(cart) # First the current one
                    carts_already_occupying_new_position.each {|c| new_carts.delete(c)} # and any others on that spot
                end
            end
        end

        @carts = new_carts
        return nil
    end

    # A convenience method allowing us to animate the simulation in a terminal
    private def redraw_sim_output
        puts `clear`
        puts self.to_s
    end

    # A convenience method for drawing the track, used particularly in specs.
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
