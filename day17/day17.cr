enum Direction
    Down,
    Left,
    Right,
end

alias X = Int32
alias Y = Int32
struct Coords
    getter x, y
    def initialize(@x : X, @y : Y)
    end

    def [](idx : Int32)
        case idx
        when 0 then @x
        when 1 then @y
        else raise IndexError.new(idx)
        end
    end
    def []=(idx : Int32, value)
        case idx
        when 0 then @x = value
        when 1 then @y = value
        else raise IndexError.new(idx)
        end
    end

    def shifted_by(x : X, y : Y) : Coords
        return Coords.new(@x + x, @y + y)
    end

    def peek(direction : Direction) : Coords
        new_x, new_y = case direction
                       when .down?  then {@x,   @y+1}
                       when .left?  then {@x-1, @y}
                       when .right? then {@x+1, @y}
                       end.not_nil!
        return Coords.new(new_x, new_y)
    end

    def to_s
        "{" + @x.to_s + ", " + @y.to_s + "}"
    end
end

class ClayVein
    getter coords
    def initialize(@coords : Array(Coords))
    end

    def min_x
        @coords.min_of(&.x)
    end
    def max_x
        @coords.max_of(&.x)
    end
    def min_y
        @coords.min_of(&.y)
    end
    def max_y
        @coords.max_of(&.y)
    end

    def self.parse(line : String)
        components = line.split(", ")
        x_component = components.find {|c| /x=/ =~ c}.not_nil!
        y_component = components.find {|c| /y=/ =~ c}.not_nil!

        x_start, x_end = self.parse_range(x_component)
        y_start, y_end = self.parse_range(y_component)

        # Every vein is a straight line, no rects or anything
        coords = 
            if x_start == x_end
                (y_start..y_end).map {|y| Coords.new(x_start, y) }
            else
                (x_start..x_end).map {|x| Coords.new(x, y_start) }
            end

        return ClayVein.new(coords)
    end

    def apply(ground : Ground)
        @coords.each {|coords| ground[coords] = Element::Clay}
    end

    private def self.parse_range(component : String) : Tuple(Int32, Int32)
        if /(?<start>\d+)\.\.(?<end>\d+)/ =~ component
            return {$~["start"].to_i, $~["end"].to_i}
        else
            c = component.split("=")[1].to_i
            return {c, c}
        end
    end
end

enum Element
    Sand,
    Clay,
    Spring,
    WaterAtRest,
    WaterFlow

    def to_c
        case self
        when Sand then '.'
        when Clay then '#'
        when WaterAtRest then '~'
        when WaterFlow then '|'
        when Spring then '+'
        else raise "Unknown element: #{self}"
        end
    end
end

class Ground
    @arr : Array(Array(Element))
    @last_water_cell : Coords
    @spring_x : X
    getter width, height

    def initialize(@width : Int32, @height : Int32)
        @arr = Array(Array(Element)).new(height) do 
            Array(Element).new(width, Element::Sand) 
        end
        @last_water_cell = Coords.new(500, 0)
        @spring_x = 500
        self[500, 0] = Element::Spring
    end

    def grow_x_by(count : Int32)
        @arr.each do |row|
            count.times { row << Element::Sand }
        end
        @width += count
    end

    # Getters by x,y, tuples, and ranges
    def [](x : X, y : Y) : Element
        @arr[y][x]
    end
    def [](coords : Coords) : Element
        self[coords.x, coords.y]
    end
    def [](x_range : Range(X, X), y : Y) : Array(Element)
        @arr[y][x_range]
    end
    def [](x : X, y_range : Range(Y, Y)) : Array(Element)
        y_range.map {|y| self[x,y]} 
    end

    # Setters by x,y, tuples, and ranges
    def []=(x : X, y : Y, value : Element)
        @arr[y][x] = value
    end
    def []=(coords : Coords, value : Element)
        self[coords.x, coords.y] = value
    end
    def []=(x : X, y_range : Range(Y, Y), value : Element)
        y_range.each {|y| self[x, y] = value}
    end
    def []=(x_range : Range(X, X), y : Y, value : Element)
        x_range.each {|x| self[x, y] = value}
    end

    def is_in_bounds?(coords : Coords) : Bool
        return false if coords.x < 0 || coords.y < 0
        return false if coords.x >= @width
        return false if coords.y >= @height
        return true
    end

    def count_cells_where(skip_count : Y, &block) : Int32
        @arr.skip(skip_count).map_with_index do |row, y|
            row.count {|cell| yield cell}
        end.sum
    end

    # Sim logic
    def flow(coords : Coords)
        return unless self.is_in_bounds?(coords)
        one_space_down = coords.peek(Direction::Down)
        return unless self.is_in_bounds?(one_space_down)

        # If there's sand beneath us, flow down
        if self[one_space_down].sand?
            self[one_space_down] = Element::WaterFlow
            self.flow(one_space_down) # flow downwards, recursively
        end

        # Now if there's clay or water-at-rest beneath us, we should try to flow
        # left and/or right.
        case self[one_space_down]
        when .water_at_rest?, .clay? then
            one_space_right = coords.peek(Direction::Right)
            if self.is_in_bounds?(one_space_right) && self[one_space_right].sand?
                self[one_space_right] = Element::WaterFlow
                self.flow(one_space_right)
            end

            one_space_left = coords.peek(Direction::Left)
            if self.is_in_bounds?(one_space_left) && self[one_space_left].sand?
                self[one_space_left] = Element::WaterFlow
                self.flow(one_space_left)
            end

            # Finally, if we're "boxed-in" at this level (walls on both sides,
            # water-at-rest or clay below), then all the water on this level
            # should be marked "at rest"
            if self.boxed_in?(coords)
                self.put_water_to_rest(coords, Direction::Left)
                self.put_water_to_rest(coords, Direction::Right)
                self[coords] = Element::WaterAtRest
            end
        end
    end

    # Traverses in `direction` from `start` marking water_flow cells as 
    # water-at-rest.
    private def put_water_to_rest(start : Coords, direction : Direction)
        current_cell = start.peek(direction)
        while self.is_in_bounds?(current_cell)
            break unless self[current_cell].water_flow?
            self[current_cell] = Element::WaterAtRest
            current_cell = current_cell.peek(direction)
        end
    end

    # Returns whether a given cell is "boxed in" on the left and right by clay
    private def boxed_in?(coords : Coords) : Bool
        return false unless self.has_wall_in_direction?(coords, Direction::Left) 
        return false unless self.has_wall_in_direction?(coords, Direction::Right)
        return true
    end

    # Returns whether a clay cell exists directly in `direction` from `coords`
    private def has_wall_in_direction?(coords : Coords, direction : Direction)
        return false if direction.down? # then it wouldn't be a wall, it'd be a floor, silly!
        current_cell = coords.peek(direction)
        while self.is_in_bounds?(current_cell)
            break if self[current_cell].sand?
            return true if self[current_cell].clay?
            current_cell = current_cell.peek(direction)
        end
        return false
    end

    # Convenience printer
    def to_s(x_range : Range(X, X)? = nil, y_range : Range(Y, Y)? = nil)
        x_range = x_range || (0...@width)
        y_range = y_range || (0...@height)
        y_range.map do |y|
            x_range.map do |x|
                self[x,y].to_c
            end.join("")
        end.join("\n")
    end
end

class Day17
    @veins : Array(ClayVein)
    @ground : Ground
    getter veins, ground

    @has_flowed : Bool

    def initialize(input : Array(String))
        @veins = input.map {|line| ClayVein.parse(line)}
        max_x = @veins.max_of(&.max_x)
        max_y = @veins.max_of(&.max_y)
        @ground = Ground.new(max_x + 1, max_y + 1) 
        @veins.each(&.apply(@ground))
        @has_flowed = false
    end

    # Part A problem statement: how many tiles can water reach?
    def part_a : Int32
        unless @has_flowed
            @ground.flow(Coords.new(500, 0))
            @has_flowed = true
        end
        min_y = @veins.min_of(&.min_y)
        @ground.count_cells_where(min_y) {|cell| cell.water_at_rest? || cell.water_flow?}
    end

    # Part B problem statement: how many tiles are "water at rest"?
    def part_b : Int32
        unless @has_flowed
            @ground.flow(Coords.new(500, 0))
            @has_flowed = true
        end
        min_y = @veins.min_of(&.min_y)
        @ground.count_cells_where(min_y) {|cell| cell.water_at_rest?}
    end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
    day17 = Day17.new(File.read_lines("input.txt"))
    puts "17A: #{day17.part_a}"
    puts "17B: #{day17.part_b}"
end
