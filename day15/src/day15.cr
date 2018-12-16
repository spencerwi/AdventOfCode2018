require "pathfinding" # Pull in a BFS lib to do pathfinding on the grid

abstract class GridElement
  abstract def tick(grid : Grid, own_coords : Coords)
  abstract def to_char : Char
end

abstract class Warrior < GridElement
  @hp : Int32

  property hp
  def initialize
    @hp = 200
  end

  def tick(grid : Grid, own_coords : Coords)
    enemies_in_attack_range : Array(Warrior) = grid.neighbors(own_coords)
      .map {|coords, other_element| other_element}
      .select {|other| self.hates?(other)}
      .map(&.as(Warrior))

    if enemies_in_attack_range.empty?
      self.move(grid, own_coords)
    else
      # TODO: pick an enemy and attack
      self.attack(enemies_in_attack_range.first.not_nil!)
    end
  end

  def move(grid : Grid, own_coords : Coords)
    targets = self.find_targets(grid)
    spaces_in_range_of_targets = targets.flat_map do |target_coords, target|
      grid.neighbors(target_coords).select(&.is_a?(EmptySpace))
    end

    paths_to_attack_targets = spaces_in_range_of_targets.map do |space_coords, space|
      {space_coords, grid.path_between(own_coords, space_coords)}
    end.reject {|_, path| path.nil?}
      .to_h

    destination, _ = paths_to_attack_targets.min_by do |space_coords, path|
      x, y = space_coords
      {path.not_nil!.size, x, y}
    end

    if destination && destination[1]
      current_x, current_y = own_coords
      dest_x, dest_y = destination.not_nil!
      grid[current_x, current_y] = EmptySpace.new
      grid[dest_x, dest_y] = self
    end
  end

  abstract def hates?(other : GridElement)

  def find_targets(grid : Grid) : Array(Tuple(Coords, Warrior))
    grid.cells.select {|coords, cell| self.hates?(cell) }
      .map {|coords, cell| {coords, cell.as(Warrior)} }
  end

  def attack(other : Warrior)
    if self.hates?(other)
      other.hp = Math.max(other.hp - 3, 0)
    end
  end

  def is_alive?
    @hp > 0
  end
end

class Elf < Warrior

  def hates?(other : GridElement)
    other.is_a?(Goblin)
  end

  def to_char
    'E'
  end
end

class Goblin < Warrior
  def hates?(other : GridElement)
    other.is_a?(Elf)
  end

  def to_char
    'G'
  end
end

class EmptySpace < GridElement
  def tick(grid : Grid, own_coords : Coords)
    # no-op, empty spaces don't do anything
  end

  def to_char
    '.'
  end
end

class Wall < GridElement
  def tick(grid : Grid, own_coords : Coords)
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

  def cells : Array(Tuple(Coords, GridElement))
    result = [] of Tuple(Coords, GridElement)
    @arr.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        result << { {x, y}, cell }
      end
    end
    return result
  end

  def neighbors(coords : Coords) : Array(Tuple(Coords, GridElement))
    x, y = coords
    return [
      {x + 1, y}, # 1 cell right
      {x - 1, y}, # 1 cell left
      {x, y + 1}, # 1 cell down
      {x, y - 1}, # 1 cell up
    ].select {|coords| self.is_in_bounds?(coords)}
      .map {|x, y| { {x, y}, self.[x,y] } }
  end

  def path_between(a : Coords, b : Coords) : Array(Coords)?
    a_x, a_y = a
    b_x, b_y = b
    success = ->(c : Coords) { c == b }
    find_neighbors = ->(c : Coords) do
      self.neighbors(c).reject {|coords, elem| elem.is_a?(Wall)}.map {|coords, elem| coords}
    end
    return Pathfinding.bfs(a, success, find_neighbors)
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
    @arr.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        cell.tick(self, {x, y})
        if cell.is_a?(Warrior) && !cell.is_alive?
          self[x, y] = EmptySpace.new
        end
      end
    end
  end

  def living_warriors
    @arr.flat_map do |row|
      row.select(&.is_a?(Warrior))
    end
  end

  def winning_side
    elves = @arr.flat_map do |row|
      row.select(&.is_a?(Elf))
    end

    return Goblin if elves.empty?

    goblins = @arr.flat_map do |row|
      row.select(&.is_a?(Goblins))
    end

    return Elf if goblins.empty?

    return nil
  end

  private def is_in_bounds?(x_y : Coords)
    x, y = x_y
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
    round_count = 0
    loop do
      @grid.tick
    end
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day15 = Day15.new(File.read_lines("input.txt"))
  puts "15A: #{day15.part_a}"
end
