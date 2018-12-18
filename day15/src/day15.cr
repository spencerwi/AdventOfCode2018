require "pathfinding" # Pull in a BFS lib to do pathfinding on the grid

alias X = Int32
alias Y = Int32
alias Coords = Tuple(X, Y)

abstract class GridElement
  abstract def to_char : Char
end

class EmptySpace < GridElement
  def to_char
    '.'
  end
end

class Wall < GridElement
  def to_char
    '#'
  end
end

class Warrior < GridElement
  class BattleIsOver < Exception
  end

	enum Team
		Elf,
    Goblin
	end

  @hp : Int32

  property hp
	getter team
  def initialize(@team : Team)
    @hp = 200
  end

  # Returns Coords for where the Warrior should be at the end of its turn.
  # Raises `BattleIsOver` if there are no more enemies, since the stopping
  # condition for the simulation is that a *warrior notices* that there are
  # no more enemies.
  def tick(grid : Grid, own_coords : Coords, verbose : Bool = false) : Coords
    enemies_in_range = self.find_enemies_in_attack_range(grid, own_coords)
    enemy_to_attack = enemies_in_range.first?
    puts "I'm #{self.to_s} @ #{own_coords}" if verbose
    puts "Enemies in range: #{enemies_in_range.map(&.to_s)}, Enemy to attack: #{enemy_to_attack.to_s}" if verbose

		# If there's nobody right next to us to attack, then move closer
		final_destination =
			if enemy_to_attack.nil?
				self.move(grid, own_coords)
			else
				own_coords
			end

		# If there's anyone to attack now, then do it.
    if enemy_to_attack.nil?
      enemies_in_range = self.find_enemies_in_attack_range(grid, final_destination)
      enemy_to_attack = enemies_in_range.first?
      puts "Enemies in range: #{enemies_in_range.map(&.to_s)}, Enemy to attack: #{enemy_to_attack.to_s}" if verbose
    end
		self.attack(enemy_to_attack) unless enemy_to_attack.nil?
		return final_destination
  end

  # Returns Coords for where the warrior should be at the end of its turn
  def move(grid : Grid, own_coords : Coords) : Coords
    targets = self.find_targets(grid)
    raise BattleIsOver.new if targets.empty?

    spaces_in_range_of_targets = targets.flat_map do |target_coords, target|
      grid.neighbors(target_coords).select(&.[1].is_a?(EmptySpace))
    end

    paths_to_attack_targets = spaces_in_range_of_targets.map do |space_coords, space|
      {space_coords, grid.path_between(own_coords, space_coords)}
    end.reject {|_, path| path.nil?}
      .to_h

    return own_coords if paths_to_attack_targets.empty?

    target_square, path_to_target_square = paths_to_attack_targets.min_by do |space_coords, path|
      # Choose the shortest path. If there's a tie, choose the top-left-most
      # space as your next step.
      x, y = space_coords
      {path.not_nil!.size, y, x}
    end

    if path_to_target_square && path_to_target_square[1]
      return path_to_target_square[1]
    else
      return own_coords
    end
  end

  def attack(other : Warrior)
    if self.hates?(other)
      other.hp = Math.max(other.hp - 3, 0)
    end
  end

  def hates?(other : GridElement)
		return other.is_a?(Warrior) && other.team != @team
	end

  def is_alive?
    @hp > 0
  end

	def to_char
		case @team
			when .elf? then 'E'
			when .goblin? then 'G'
			else '.'
		end
	end

	def to_s
		"#{self.to_char}(#{@hp})"
	end

  private def find_targets(grid : Grid) : Array(Tuple(Coords, Warrior))
    grid.cells.select {|coords, cell| self.hates?(cell) }
      .map {|coords, cell| {coords, cell.as(Warrior)} }
  end

	private def find_enemies_in_attack_range(grid : Grid, own_coords : Coords) : Array(Warrior)
		grid.neighbors(own_coords)
			.select {|coords, other| self.hates?(other)}
      .map {|coords, other_element| {coords, other_element.as(Warrior)}}
      .sort_by do |coords, enemy|
        # Choose the lowest-hp target, with reading-order-position as the tiebreaker
        {enemy.hp, coords[1], coords[0]}
      end.map {|coords, enemy| enemy}
	end

end
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
    # Return neighbors in "reading order": up, left, right, down
    return [
      {x, y - 1}, # 1 cell up
      {x - 1, y}, # 1 cell left
      {x + 1, y}, # 1 cell right
      {x, y + 1}, # 1 cell down
    ].select {|coords| self.is_in_bounds?(coords)}
      .map {|x, y| { {x, y}, self.[x,y] } }
  end

  def path_between(a : Coords, b : Coords) : Array(Coords)?
    a_x, a_y = a
    b_x, b_y = b
    success = ->(c : Coords) { c == b }
    find_neighbors = ->(c : Coords) do
      self.neighbors(c).select {|coords, elem| elem.is_a?(EmptySpace)}.map {|coords, elem| coords}
    end
    return Pathfinding.bfs(a, success, find_neighbors)
  end

  def tick
    warriors_who_need_to_move = self.living_warriors
    warriors_who_need_to_move.each do |warrior, coords|
      next unless warrior.is_alive? # The warrior might have died before we "got to them"
      x, y = coords
      new_location = warrior.tick(self, coords)
      # They're moving, so put an empty space where they're moving from
      self[x, y] = EmptySpace.new
			# then move them to their destination (which may be the same as their
			# current location).
			new_x, new_y = new_location
			self[new_x, new_y] = warrior
    end

    # Do a "final sweep" to sweep away dead warriors from the battlefield
    warriors_who_need_to_move.reject {|warrior, coords| warrior.is_alive?}
      .each {|dead_warrior, coords| self[coords[0], coords[1]] = EmptySpace.new}
  end

  def living_warriors : Array(Tuple(Warrior, Coords))
    warriors = [] of Tuple(Warrior, Coords)

    # "Turn order" happens from top to bottom, left to right
    @arr.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        if cell.is_a?(Warrior)
          warriors << {cell.as(Warrior), {x, y}}
        end
      end
    end

    return warriors
  end

  def winning_side
    cells = self.cells
    there_are_still_elves = cells.any? do |coords, cell|
			cell.is_a?(Warrior) && cell.as(Warrior).is_alive? && cell.as(Warrior).team.elf?
		end
    there_are_still_goblins = cells.any? do |coords, cell|
			cell.is_a?(Warrior) && cell.as(Warrior).is_alive? && cell.as(Warrior).team.goblin?
		end

		case {there_are_still_elves, there_are_still_goblins}
		when {true, false} then Warrior::Team::Elf
		when {false, true} then Warrior::Team::Goblin
		else nil
		end
  end

  private def is_in_bounds?(x_y : Coords)
    x, y = x_y
    return false if x < 0 || y < 0
    return false if y >= self.height
    return false if x >= self.width
    return true
  end

  def score : Int32?
    self.living_warriors.map {|warrior, coords| warrior.hp}.sum
  end

  def to_s(include_health : Bool = false)  : String
    @arr.map do |row|
      row_str = row.map(&.to_char).join("")
      if include_health
        warrior_healths = row.select(&.is_a?(Warrior)).map(&.as(Warrior).to_s).join(", ")
        row_str += " #{warrior_healths}" unless warrior_healths.empty?
      end
      row_str
    end.join("\n")
  end

  def self.parse(input_lines : Array(String)) : Grid
    arr = input_lines.map do |row|
      row.chars.map do |cell|
        case cell
        when '#' then Wall.new
        when '.' then EmptySpace.new
        when 'G' then Warrior.new(Warrior::Team::Goblin)
        when 'E' then Warrior.new(Warrior::Team::Elf)
        else raise "Unrecognized character: '#{cell}'"
        end.not_nil!
      end
    end
    Grid.new(arr)
  end
end

class Day15
  @grid : Grid
	getter grid

  def initialize(input_lines : Array(String))
    @grid = Grid.parse(input_lines)
  end

  def part_a(run_sim : Bool = false)
    round_count = 0
		redraw_sim if run_sim
    loop do
      begin
        @grid.tick
      rescue Warrior::BattleIsOver
        winner = @grid.winning_side
        if winner
          puts "Winner found on round #{round_count}"
          total_hp_left = @grid.living_warriors.map(&.[0].hp).sum
          return (round_count) * total_hp_left
        end
      end
			redraw_sim if run_sim

      round_count += 1
    end
  end

	private def redraw_sim
    puts "\n\n"
		puts @grid.to_s(true)
	end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day15 = Day15.new(File.read_lines("input.txt"))
  puts "15A: #{day15.part_a(true)}"
end
