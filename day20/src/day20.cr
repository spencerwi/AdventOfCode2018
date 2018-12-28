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
  # Returns a tuple of starting location and a set of all rooms created.
  def self.build_from_regex(room_regex : String) : Tuple(Room, Set(Room))
    all_rooms = Set(Room).new
    # For branches, we'll want to "snap back" to where we were, so we keep a
    # "stack" of "snap-back" points. We assume based on reading the problem that
    # branches will *always* be wrapped in parens.
    room_stack = Deque(Room).new
    start_room = Room.new
    current_room = start_room
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

    return start_room, all_rooms
  end
end

class Day20
  @rooms : Set(Room)
  @start_room : Room

  def initialize(input_str : String)
    @start_room, @rooms = Room.build_from_regex(input_str)
  end

  def solve : Tuple(Int32, Int32)
    longest_rooms_path = 0
    over_1000_count = 0
    @rooms.each do |room|
      next if room == @start_room
      path = self.path_between(@start_room, room)
      if path
        longest_rooms_path = Math.max(longest_rooms_path, path.size)
        over_1000_count += 1 if path.size > 1000
      end
    end
    return {
      longest_rooms_path - 1, # You always see 1 less door than you do rooms,
      over_1000_count
    }
  end

  private def path_between(r1 : Room, r2 : Room) : Array(Room)?
    success = ->(r : Room){ r === r2}
    get_neighbors = ->(r : Room) { r.neighbors }
    return Pathfinding.bfs(r1, success, get_neighbors)
  end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
  day20 = Day20.new(File.read("input.txt"))
  part_a, part_b = day20.solve
  puts "20A: #{part_a}"
  puts "20B: #{part_b}"
end
