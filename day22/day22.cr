alias Coords = Tuple(Int32, Int32)

enum CellType
    Rocky,
    Wet,
    Narrow

    def risk_level
        self.value
    end

    def to_s
        case self
        when Rocky then "."
        when Wet then "="
        when Narrow then "|"
        end.not_nil!
    end
end

struct Cell
    getter geo_index, erosion_level, type
    def initialize(@geo_index : Int32, @erosion_level : Int32, @type : CellType)
    end

    def risk_level : Int32
        @type.risk_level
    end

    def self.default : Cell
        Cell.new(0, 0, CellType::Rocky)
    end

    def to_s : String
        @type.to_s
    end
end

class Cave
    @grid : Array(Array(Cell))
    getter target

    def initialize(@depth : Int32, @target : Coords)
        target_x, target_y = @target
        @grid = Array(Array(Cell)).new(target_y + 1) do 
            # Gotta have some default because the crystal compiler doesn't like 
            # indirect initialization, so we fill in the grid later in fill_grid
            Array(Cell).new(target_x + 1, Cell.default) 
        end
        self.fill_grid # Crystal compiler needed some help
    end

    def total_risk_level(bottom_right : Coords) : Int32
        max_x, max_y = bottom_right
        @grid.first(max_y + 1).sum(0) do |row|
            row.first(max_x + 1).sum(0, &.risk_level)
        end
    end

    private def fill_grid
        target_x, target_y = @target
        (target_y + 1).times do |y|
            (target_x + 1).times do |x|
                geo_index = self.geologic_index(x, y)
                erosion_level = self.erosion_level(x, y)
                cell_type = CellType.from_value(erosion_level % 3)
                @grid[y][x] = Cell.new(geo_index, erosion_level, cell_type)
            end
        end
    end

    def geologic_index(x : Int32, y : Int32) : Int32
        return 0 if {x,y} == {0,0}
        return 0 if {x,y} == @target
        return x * 16807 if y == 0
        return y * 48271 if x == 0
        return @grid[y][x - 1].erosion_level * @grid[y - 1][x].erosion_level
    end

    def erosion_level(x : Int32, y : Int32) : Int32
        geo_index = self.geologic_index(x, y)
        return (geo_index + @depth) % 20183
    end

    def cell_type(x : Int32, y : Int32) : CellType
        index = self.erosion_level(x, y) % 3
        return CellType.from_value(index)
    end

    def self.parse(lines : Array(String)) : Cave
        depth = lines[0].split(": ")[1].to_i
        target_x, target_y = lines[1].split(": ")[1].split(",").map(&.to_i)
        return Cave.new(depth, {target_x, target_y})
    end

    def to_s : String
        @grid.map do |row|
            row.map(&.to_s).join("")
        end.join("\n")
    end
end

class Day22
    @cave : Cave

    def initialize(input_lines : Array(String))
        @cave = Cave.parse(input_lines)
    end

    def part_a
        @cave.total_risk_level(@cave.target)
    end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
    day22 = Day22.new(File.read_lines("input.txt"))
    puts "22A: #{day22.part_a}"
end
