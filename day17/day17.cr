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
    Water

    def to_c
        case self
        when Sand then '.'
        when Clay then '#'
        when Water then '~'
        when Spring then '+'
        else raise "Unknown element: #{self}"
        end
    end

    def can_be_filled_with_water?
        self == Sand
    end
end

class SimulationEnded < Exception
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

    # Sim logic
    def tick
        down_one = @last_water_cell.shifted_by(0, 1)
        SimulationEnded if down_one.y >= @height

        if self[down_one].sand?
            @last_water_cell = down_one
            self[down_one] = Element::Water
        else 
            # if we can't just drop water down, backtrack to the spring, and
            # find the bottom of its "waterfall", then look to the left and 
            # right of that. Keep backtracking "up" the "waterfall" as 
            # needed.
            bottom_of_direct_spring_flow : Y = 
                (0...@height).take_while do |y| 
                    self[@spring_x, y].water? || self[@spring_x, y].spring?
                end.last

            loop do 
                cursor_position = Coords.new(@spring_x, bottom_of_direct_spring_flow)
                # try going left if you can, stop when you hit a wall or fill a spot
                until self[cursor_position].clay? 
                    cursor_position = cursor_position.shifted_by(-1, 0)
                    if self[cursor_position].sand?
                        @last_water_cell = cursor_position
                        self[cursor_position] = Element::Water
                        return
                    end
                end
                # try going left if you can, stop when you hit a wall or fill a spot
                cursor_position = Coords.new(@spring_x, bottom_of_direct_spring_flow)
                until self[cursor_position].clay? 
                    cursor_position = cursor_position.shifted_by(1, 0)
                    if self[cursor_position].sand?
                        @last_water_cell = cursor_position
                        self[cursor_position] = Element::Water
                        return
                    end
                end

                # Nothing yet? Then backtrack up the flow one step and try again.
                bottom_of_direct_spring_flow -= 1
            end
        end
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

    def initialize(input : Array(String))
        @veins = input.map {|line| ClayVein.parse(line)}
        max_x = @veins.max_of(&.max_x)
        max_y = @veins.max_of(&.max_y)
        @ground = Ground.new(max_x + 1, max_y + 1) 
        @veins.each(&.apply(@ground))
    end

    def part_a
        puts "Problem incomplete!"
    end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
    day17 = Day17.new(File.read_lines("input.txt"))
    puts "17A: #{day17.part_a}"
end
