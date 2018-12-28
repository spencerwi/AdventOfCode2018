require "pathfinding"

alias Coords = Tuple(Int32, Int32)

enum Direction
  North,
  South,
  East,
  West

  def opposite : Direction
    case self
    when North then South
    when South then North
    when East then West
    when West then East
    end.not_nil!
  end

  def self.is_direction_char?(c : Char) : Bool
    "NSEW".includes?(c)
  end

  def self.from_char(c : Char) : Direction
    raise "Invalid Direction char: '#{c}'" unless self.is_direction_char?(c)

    Direction.from_value("NSEW".index(c))
  end
end

class Room
  @neighbors : Hash(Direction, Room)
  getter neighbors

  def initialize(@neighbors : Hash(Direction, Room) = Hash(Direction, Room).new)
  end

  def [](dir : Direction) : Room
    @neighbors[dir]
  end

  def has_door?(dir : Direction)
    @neighbors.has_key?(dir)
  end

  def doors : Set(Direction)
    Set(Direction).new(@neighbors.keys)
  end

  def go(dir : Direction)
    unless self.has_door?(dir)
      @neighbors[dir] = Room.new({
        dir.opposite => self
      })
    end
    return @neighbors[dir]
  end

  def neighbors : Array(Room)
    @neighbors.values
  end

  # Builds out the full "room map" as a graph from the given regex.
  # Returns a set of all rooms created.
  def self.build_from_regex(room_regex : String) : Set(Room)
    all_rooms = Set(Room).new
    # For branches, we'll want to "snap back" to where we were, so we keep a
    # "stack" of "snap-back" points. We assume based on reading the problem that
    # branches will *always* be wrapped in parens.
    room_stack = Deque(Room).new
    current_room = Room.new
    all_rooms << current_room
    room_regex.chars.skip(1).each do |c|
      case c
      when 'N', 'S', 'E', 'W' then
        dir = Direction.from_char(c)
        current_room = current_room.go(dir)
      when '(' then
        room_stack.push(current_room)
      when '|' then
        current_room = room_stack.last # this is basically "peek" -- get, but don't remove
      when ')' then
        current_room = room_stack.pop
      end

      all_rooms << current_room
    end

    return all_rooms
  end
end

class Day20
  @rooms : Set(Room)

  def initialize(input_str : String)
    @rooms = Room.build_from_regex(input_str)
  end

  def part_a
    longest_rooms_path =
      @rooms.to_a.each_combination(2).compact_map do |(r1, r2)|
        success = ->(r : Room){ r === r2}
        get_neighbors = ->(r : Room) { r.neighbors }
        Pathfinding.bfs(r1, success, get_neighbors)
      end.max_of(&.size)
    return longest_rooms_path - 1 # You always see 1 less door than you do rooms
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day20 = Day20.new(File.read("input.txt"))
  puts "20A: #{day20.part_a}"
end
