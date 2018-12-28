require "../day20"
require "spec"

# Custom expectation for checking doors
struct RoomHasDoorsExpectation
  @doors : Set(Direction)
  def initialize(*doors)
    @doors = Set(Direction).new
    doors.each {|d| @doors << d}
  end

  def match(actual_value : Room)
    @doors.each do |d|
      return false unless actual_value.has_door?(d)
    end
    return true
  end

  def failure_message(actual_value : Room)
    <<-EOF
    Expected doors: #{@doors.inspect}
      Actual doors: #{actual_value.doors}"
    EOF
  end

end
def have_doors(*doors)
  RoomHasDoorsExpectation.new(*doors)
end

describe Room do

  it "starts with no neighbor rooms" do
    room = Room.new
    Direction.values.each do |d|
      room.has_door?(d).should be_false # By default, no doors
    end
  end

  describe "#go" do

    it "adds a room in that direction (with reciprocal door) if no room exists" do
      room = Room.new
      Direction.values.each do |d|
        neighbor = room.go(d)
        room.has_door?(d).should be_true

        room[d].should eq neighbor
        neighbor[d.opposite].should eq room
        room[d][d.opposite].should eq room
      end
    end

    it "returns an existing room in that direction, if possible" do
      room = Room.new
      Direction.values.each do |d|
        existing_neighbor = room.go(d)
        neighbor_again = room.go(d)

        existing_neighbor.should eq neighbor_again
      end
    end
  end

  describe ".build_from_regex" do

    it "works for simple sample input" do
      simple_input = "^WNE$"

      # Output should look like
      #
      #   #####
      #   #.|.#
      #   #-###
      #   #.|.#
      #   #####

      all_rooms = Room.build_from_regex(simple_input)
      all_rooms.size.should eq 4
      top_left_room = all_rooms.find do |room|
        room.has_door?(Direction::South) && room.has_door?(Direction::East)
      end
      top_left_room.should_not be_nil

      bottom_left_room = top_left_room.not_nil![Direction::South]
      bottom_left_room.should have_doors(Direction::North, Direction::East)

      bottom_right_room = bottom_left_room.not_nil![Direction::East]
      bottom_right_room.should have_doors(Direction::West)

      top_right_room = top_left_room.not_nil![Direction::East]
      top_right_room.should have_doors(Direction::West)
    end

    it "works for one-deep branching sample input" do
      sample_input = "^N(E|W)N$"

      # Output should look like
      #
      #     ###
      #     #.#
      #   ###-###
      #   #.|.|.#
      #   ###-###
      #     #.#
      #     ###

      all_rooms = Room.build_from_regex(sample_input)
      all_rooms.size.should eq 5

      center_room = all_rooms.find do |room|
        Direction.values.all? {|d| room.has_door?(d)}
      end
      center_room.should_not be_nil

      top_room = center_room.not_nil![Direction::North]
      top_room.should have_doors(Direction::South)

      bottom_room = center_room.not_nil![Direction::South]
      bottom_room.should have_doors(Direction::North)

      left_room = center_room.not_nil![Direction::West]
      left_room.should have_doors(Direction::East)

      right_room = center_room.not_nil![Direction::East]
      right_room.should have_doors(Direction::West)
    end

    it "works for multiple-deep branching sample input" do
      sample_input = "^ENWWW(NEEE|SSE(EE|N))$"

      # Output should look like
      #
      #   #########
      #   #.|.|.|.#
      #   #-#######
      #   #.|.|.|.#
      #   #-#####-#
      #   #.#.#.|.#
      #   #-#-#####
      #   #.|.|.|.#
      #   #########
      all_rooms = Room.build_from_regex(sample_input)
      all_rooms.size.should eq 16
      top_left_room = all_rooms.find do |room|
        room.doors === Set(Direction).new([Direction::South, Direction::East])
      end
      top_left_room.should_not be_nil

      # Check top row
      top_left_room.not_nil![Direction::East].should have_doors(
        Direction::West,
        Direction::East
      )
      top_left_room.not_nil![Direction::East][Direction::East].should have_doors(
        Direction::West,
        Direction::East
      )
      top_left_room.not_nil![Direction::East][Direction::East][Direction::East].should have_doors(
        Direction::West,
      )

      # Check second row
      x0_y1 = top_left_room.not_nil![Direction::South]
      x0_y1.should have_doors(
        Direction::North,
        Direction::East,
        Direction::South
      )
      x0_y1[Direction::East].should have_doors(
        Direction::West,
        Direction::East
      )
      x0_y1[Direction::East][Direction::East].should have_doors(
        Direction::West,
        Direction::East
      )
      x0_y1[Direction::East][Direction::East][Direction::East].should have_doors(
        Direction::West,
        Direction::South
      )

      # Check third row
      x0_y2 = x0_y1[Direction::South]
      x0_y2.should have_doors(
        Direction::North,
        Direction::South
      )
      x3_y2 = x0_y1[Direction::East][Direction::East][Direction::East][Direction::South]
      x3_y2.should have_doors(
        Direction::North,
        Direction::West,
      )
      x3_y2[Direction::West].should have_doors(
        Direction::East
      )
      x2_y2 = all_rooms.find do |room|
        room.doors === Set(Direction).new([Direction::South])
      end
      x2_y2.should_not be_nil

      # Check bottom row
      bottom_left = x0_y2[Direction::South]
      bottom_left.should have_doors(
        Direction::North,
        Direction::East
      )
      bottom_left[Direction::East].should have_doors(
        Direction::West,
        Direction::North,
        Direction::East
      )
      bottom_left[Direction::East][Direction::East].should have_doors(
        Direction::West,
        Direction::East
      )
      bottom_left[Direction::East][Direction::East][Direction::East].should have_doors(
        Direction::West,
      )
    end

  end

end

describe Day20 do

  describe "#part_a" do
    it "behaves correctly for sample input" do
      samples = {
        "^WNE$" => 3,
        "^ENWWW(NEEE|SSE(EE|N))$" => 10,
        "^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$" => 18,
        "^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$" => 23,
        "^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$" => 31
      }

      samples.each do |input, output|
        Day20.new(input).part_a.should eq output
      end
    end
  end

end
