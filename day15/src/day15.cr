require "a-star" # Look, I could implement A* pathfinding myself, but why? then

abstract class GridElement
  abstract def tick(grid : Grid)
  abstract def to_char : Char
end

abstract class AnimateObject < GridElement
  @hp : Int32

  property hp
  def initialize
    @hp = 200
  end

  abstract def move

  abstract def hates?(other : GridElement)

  def find_targets(grid : Grid) : Array(AnimateObject)
    # TODO : this!
    return [] of AnimateObject
  end

  def attack(other : AnimateObject)
    if self.hates?(other)
      other.hp = Math.max(other.hp - 3, 0)
    end
  end

  def is_alive?
    @hp > 0
  end
end

class Elf < AnimateObject
  def tick(grid : Grid)
    # TODO: this
  end

  def move
    # TODO: this
  end

  def hates?(other : GridElement)
    other.is_a?(Goblin)
  end

  def to_char
    'E'
  end
end

class Goblin < AnimateObject
  def tick(grid : Grid)
    # TODO: this
  end

  def move
    # TODO: this
  end

  def hates?(other : GridElement)
    other.is_a?(Elf)
  end

  def to_char
    'G'
  end
end

class EmptySpace < GridElement
  def tick(grid : Grid)
    # no-op, empty spaces don't do anything
  end

  def to_char
    '.'
  end
end

class Wall < GridElement
  def tick(grid : Grid)
    # no-op, empty spaces don't do anything
  end

  def to_char
    '#'
  end
end

alias X = Int32
alias Y = Int32
alias Coords = Tuple(X, Y)


class Grid
  def initialize(@arr : Array(Array(GridElement)))
  end

  def [](x : X, y : Y)
    @arr[y][x]
  end

  def []=(x : X, y : Y, value : GridElement)
    @arr[y][x] = value
  end

  def height
    @arr.size
  end

  def width
    @arr[0].size
  end

  def neighbors(e : GridElement) # "Neighbors" in pathfinding terms
    e_x, e_y = self.location_of(e)
    if (e_location)
      return [
        {e_x + 1, e_y}, # 1 cell right
        {e_x - 1, e_y}, # 1 cell left
        {e_x, e_y + 1}, # 1 cell down
        {e_x, e_y - 1}, # 1 cell up
      ].select {|coords| self.is_in_bounds?(coords)}
        .map {|x, y| self.[x,y]}
        .reject(&.is_a?(Wall))
    else
      return [] of GridElement
    end
  end

  def location_of(e : GridElement) : Coords?
    @arr.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        return {x, y} if cell == e
      end
    end

    return nil
  end

  def tick
    # "Turn order" happens from top to bottom, left to right
    @arr.rows.each do |row, y|
      row.cells.each do |cell, x|
        cell.tick(self)
        if cell.is_a?(AnimateObject) && !cell.is_alive?
          @arr[x, y] = EmptySpace.new
        end
      end
    end
  end

  private def is_in_bounds?(x_y : Coords)
    return false if x < 0 || y < 0
    return false if y >= self.height
    return false if x >= self.width
    return true
  end

  def to_s : String
    @arr.map do |row|
      row.map(&.to_char).join("")
    end.join("\n")
  end

  def self.parse(input_lines : Array(String)) : Grid
    arr = input_lines.map do |row|
      row.chars.map do |cell|
        case cell
        when '#' then Wall.new
        when '.' then EmptySpace.new
        when 'G' then Goblin.new
        when 'E' then Elf.new
        else raise "Unrecognized character: '#{cell}'"
        end.not_nil!
      end
    end
    Grid.new(arr)
  end
end

class Day15
  @grid : Grid

  def initialize(input_lines : Array(String))
    @grid = Grid.parse(input_lines)
  end

  def part_a
    # TODO: this!
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day15 = Day15.new(File.read_lines("input.txt"))
  puts "15A: #{day15.part_a}"
end
