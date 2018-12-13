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

    def part_a
        loop do
            crash_location = self.tick
            return crash_location unless crash_location.nil?
        end
    end

    # Advances carts one at a time, checking for collisions and reporting the
    # location of the first collision, if any occurred.
    def tick : Tuple(Int32, Int32)?
        @carts.each do |cart| 
            cart.tick(@grid)
            carts_already_occupying_new_position = 
                @carts.reject {|other| other == cart}
                .select {|other| other.x == cart.x && other.y == cart.y}

            return {cart.x, cart.y} unless carts_already_occupying_new_position.empty?
        end
        return nil
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
end
