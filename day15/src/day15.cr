require "pathfinding" # Pull in a BFS lib to do pathfinding on the grid

alias X = Int32
alias Y = Int32
alias Coords = Tuple(X, Y)

abstract class GameWorldElement
  abstract def to_char : Char
end

class EmptySpace < GameWorldElement
  def to_char
    '.'
  end
end

class Wall < GameWorldElement
  def to_char
    '#'
  end
end

class Warrior < GameWorldElement
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
  def tick(grid : GameWorld, own_coords : Coords, verbose : Bool = false) : Coords
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
  def move(grid : GameWorld, own_coords : Coords) : Coords
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
      first_step_x, first_step_y = path.not_nil![1]
      {path.not_nil!.size, first_step_y, first_step_x}
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

  def hates?(other : GameWorldElement)
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

  private def find_targets(grid : GameWorld) : Array(Tuple(Coords, Warrior))
    grid.cells.select {|coords, cell| self.hates?(cell) }
      .map {|coords, cell| {coords, cell.as(Warrior)} }
      .select {|coords, cell| cell.is_alive?}
  end

	private def find_enemies_in_attack_range(grid : GameWorld, own_coords : Coords) : Array(Warrior)
		grid.neighbors(own_coords)
			.select {|coords, other| self.hates?(other)}
      .map {|coords, other_element| {coords, other_element.as(Warrior)}}
      .select {|coords, enemy| enemy.is_alive?}
      .sort_by do |coords, enemy|
        # Choose the lowest-hp target, with reading-order-position as the tiebreaker
        enemy_x, enemy_y = coords
        {enemy.hp, enemy_y, enemy_x}
      end.map {|coords, enemy| enemy}
	end

end
class GameWorld
  def initialize(@arr : Array(Array(GameWorldElement)))
  end

  # Parse input lines into a grid
  def self.parse(input_lines : Array(String)) : GameWorld
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
    GameWorld.new(arr)
  end

  # Convenience getters and setters
  def [](x : X, y : Y)
    @arr[y][x]
  end

  def []=(x : X, y : Y, value : GameWorldElement)
    @arr[y][x] = value
  end

  def height
    @arr.size
  end

  def width
    @arr[0].size
  end

  def cells : Array(Tuple(Coords, GameWorldElement))
    result = [] of Tuple(Coords, GameWorldElement)
    @arr.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        result << { {x, y}, cell }
      end
    end
    return result
  end

  # "Score" the map by summing the hp of any living warriors
  def score : Int32?
    self.living_warriors.map {|warrior, coords| warrior.hp}.sum
  end

  # Get all living warriors
  def living_warriors : Array(Tuple(Warrior, Coords))
    warriors = [] of Tuple(Warrior, Coords)

    # "Turn order" happens from top to bottom, left to right
    @arr.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        if cell.is_a?(Warrior) && cell.is_alive?
          warriors << {cell.as(Warrior), {x, y}}
        end
      end
    end

    return warriors
  end

  def neighbors(coords : Coords) : Array(Tuple(Coords, GameWorldElement))
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

  # Determine the winning side, if any
  def winning_side : Warrior::Team?
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


  # Use BFS from the pathfinding lib to find the best path between two points,
  # if any.
  def path_between(a : Coords, b : Coords) : Array(Coords)?
    a_x, a_y = a
    b_x, b_y = b
    success = ->(c : Coords) { c == b }
    find_neighbors = ->(c : Coords) do
      self.neighbors(c)
        .select {|coords, elem| elem.is_a?(EmptySpace)} # you can only walk through empty spaces
        .map {|coords, elem| coords}
    end
    return Pathfinding.bfs(a, success, find_neighbors)
  end

  # Returns true if a complete round finished, false otherwise
  def tick(verbose : Bool = false) : Bool
    # Do an "initial sweep" to sweep away dead warriors from the battlefield
    self.sweep_away_dead_warriors

    warriors_who_need_to_move = self.living_warriors.sort_by do |warrior, coords|
      x, y = coords
      {y, x} # turn order is reading order
    end
    warriors_who_did_move = 0
    warriors_who_need_to_move.each do |warrior, coords|
      warriors_who_did_move += 1
      unless warrior.is_alive?
        # The warrior might have died before we "got to them". If so, remove
        # them from the board.
        self.remove_dead_warrior(coords)
        next
      end

      # Tick
      new_location = warrior.tick(self, coords, verbose)

      # If they're moving,
      if new_location != coords
        x, y = coords
        # put an empty space where they're moving from
        self[x, y] = EmptySpace.new
        # then move them to their destination (which may be the same as their
        # current location).
        new_x, new_y = new_location
        self[new_x, new_y] = warrior
      end
    end
    # Do another sweep just in case a warrior got killed after it moved
    self.sweep_away_dead_warriors


    everyone_moved = (warriors_who_did_move == warriors_who_need_to_move.size)
    return everyone_moved
  end

  private def is_in_bounds?(x_y : Coords)
    x, y = x_y
    return false if x < 0 || y < 0
    return false if y >= self.height
    return false if x >= self.width
    return true
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

  def sweep_away_dead_warriors
    self.cells.select {|coords, cell| cell.is_a?(Warrior)}
      .map {|coords, warrior| {coords, warrior.as(Warrior)} }
      .reject {|coords, warrior| warrior.is_alive?}
      .map {|coords, dead_warrior| coords}
      .each {|coords| self.remove_dead_warrior(coords)}
  end

  private def remove_dead_warrior(warrior_coords : Coords)
    x, y = warrior_coords
    self[x, y] = EmptySpace.new
  end
end

class Day15
  @grid : GameWorld
	getter grid

  def initialize(input_lines : Array(String))
    @grid = GameWorld.parse(input_lines)
  end

  def part_a(run_sim : Bool = false)
    complete_round_count = 0
		redraw_sim if run_sim
    loop do
      begin
        round_was_complete = @grid.tick
        complete_round_count += 1 if round_was_complete
      rescue Warrior::BattleIsOver
        grid.sweep_away_dead_warriors # Just in case anything was left over
        winner = @grid.winning_side.not_nil!
        # puts "Winner found on round #{complete_round_count}, score is #{@grid.score}"
        total_hp_left = @grid.score
        return complete_round_count * total_hp_left
      end
			redraw_sim if run_sim

    end
  end

	private def redraw_sim
    puts "\n\n"
		puts @grid.to_s(true)
	end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day15 = Day15.new(File.read_lines("input.txt"))
  puts "15A: #{day15.part_a}"
end
