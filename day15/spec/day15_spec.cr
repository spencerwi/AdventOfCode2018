require "./spec_helper"

describe Warrior do

  it "starts with 200 hp" do
    Warrior.new(Warrior::Team::Elf).hp.should eq 200
  end

  it "hates the other team" do
		elf = Warrior.new(Warrior::Team::Elf)
		goblin = Warrior.new(Warrior::Team::Goblin)
		elf.hates?(goblin).should be_true
		goblin.hates?(elf).should be_true
  end

  describe "#is_alive?" do

    it "reports true if health is greater than 0" do
      Warrior.new(Warrior::Team::Elf).is_alive?.should be_true
    end

    it "reports false if health is 0" do
      elf = Warrior.new(Warrior::Team::Elf)
      elf.hp = 0
      elf.is_alive?.should be_false
    end

    it "reports false if health is less than 0" do
      elf = Warrior.new(Warrior::Team::Elf)
      elf.hp = -1
      elf.is_alive?.should be_false
    end

  end

  describe "#attack" do

    it "avoids friendly fire" do
      elf1 = Warrior.new(Warrior::Team::Elf)
      elf2 = Warrior.new(Warrior::Team::Elf)

      elf1.attack(elf2)

      elf2.hp.should eq 200
    end

    it "hurts enemies" do
      elf = Warrior.new(Warrior::Team::Elf)
      goblin = Warrior.new(Warrior::Team::Goblin)

      elf.attack(goblin)

      goblin.hp.should eq 197

			goblin.attack(elf)

			elf.hp.should eq 197
    end

    it "kills a nearly-dead enemy" do
      elf = Warrior.new(Warrior::Team::Elf)
      nearly_dead_goblin = Warrior.new(Warrior::Team::Goblin)
      nearly_dead_goblin.hp = 3

      elf.attack(nearly_dead_goblin)

      nearly_dead_goblin.is_alive?.should be_false


			goblin = Warrior.new(Warrior::Team::Goblin)
			nearly_dead_elf = Warrior.new(Warrior::Team::Elf)
			nearly_dead_elf.hp = 3

      goblin.attack(nearly_dead_elf)

      nearly_dead_elf.is_alive?.should be_false
    end

    it "doesn't reduce hp below 0" do
      elf = Warrior.new(Warrior::Team::Elf)
      nearly_dead_goblin = Warrior.new(Warrior::Team::Goblin)
      nearly_dead_goblin.hp = 1

      elf.attack(nearly_dead_goblin)

      nearly_dead_goblin.is_alive?.should be_false
      nearly_dead_goblin.hp.should eq 0


			goblin = Warrior.new(Warrior::Team::Goblin)
			nearly_dead_elf = Warrior.new(Warrior::Team::Elf)
			nearly_dead_elf.hp = 1

      goblin.attack(nearly_dead_elf)

      nearly_dead_elf.is_alive?.should be_false
      nearly_dead_elf.hp.should eq 0
    end

  end

end

describe GameWorld do
  describe ".parse" do
    it "parses correctly" do
      sample_input = <<-INPUT
      #########
      #G..G..G#
      #.......#
      #.......#
      #G..E..G#
      #.......#
      #.......#
      #G..G..G#
      #########
      INPUT

      grid = GameWorld.parse(sample_input.lines)

      grid.to_s.should eq sample_input

      # Top and bottom rows should be all walls
      (0...grid.width).each do |x|
        grid[x, 0].should be_a(Wall)
        grid[x, grid.height - 1].should be_a(Wall)
      end

      # The left and right sides should be walls too
      (0...grid.height).each do |y|
        grid[0, y].should be_a(Wall)
        grid[grid.width - 1, y].should be_a(Wall)
      end

      # Check goblin positions
      grid[1,1].as(Warrior).team.should eq Warrior::Team::Goblin
      grid[1,4].as(Warrior).team.should eq Warrior::Team::Goblin
      grid[1,7].as(Warrior).team.should eq Warrior::Team::Goblin
      grid[4,1].as(Warrior).team.should eq Warrior::Team::Goblin
      grid[4,7].as(Warrior).team.should eq Warrior::Team::Goblin
      grid[7,1].as(Warrior).team.should eq Warrior::Team::Goblin
      grid[7,4].as(Warrior).team.should eq Warrior::Team::Goblin
      grid[7,7].as(Warrior).team.should eq Warrior::Team::Goblin

      # Check elf position
      grid[4,4].as(Warrior).team.should eq Warrior::Team::Elf
    end
  end

	describe "#winning_side" do

		it "correctly identifies a no-winner-yet situation" do
      sample_input = <<-INPUT
      #######
      #.G...#
      #...EG#
      #.#.#G#
      #..G#E#
      #.....#
      #######
      INPUT
      grid = GameWorld.parse(sample_input.lines)

			grid.winning_side.should be_nil
		end

		it "correctly identifies a Goblins-win situation" do
      sample_input = <<-INPUT
      #######
      #.G...#
      #....G#
      #.#.#G#
      #..G#.#
      #.....#
      #######
      INPUT
      grid = GameWorld.parse(sample_input.lines)

			grid.winning_side.should eq Warrior::Team::Goblin
		end

		it "correctly identifies an Elves-win situation" do
      sample_input = <<-INPUT
      #######
      #.....#
      #...E.#
      #.#.#.#
      #...#E#
      #.....#
      #######
      INPUT
      grid = GameWorld.parse(sample_input.lines)

			grid.winning_side.should eq Warrior::Team::Elf
		end

	end

  describe "#tick" do

    it "behaves correctly for sample input" do
      round_count = 0
      sample_input = <<-INPUT
      #######
      #.G...#
      #...EG#
      #.#.#G#
      #..G#E#
      #.....#
      #######
      INPUT

      grid = GameWorld.parse(sample_input.lines)

      grid.tick
      round_count += 1
      grid.to_s(true).should eq <<-OUTPUT
      #######
      #..G..# G(200)
      #...EG# E(197), G(197)
      #.#G#G# G(200), G(197)
      #...#E# E(197)
      #.....#
      #######
      OUTPUT

      grid.tick
      round_count += 1
      grid.to_s(true).should eq <<-OUTPUT
      #######
      #...G.# G(200)
      #..GEG# G(200), E(188), G(194)
      #.#.#G# G(194)
      #...#E# E(194)
      #.....#
      #######
      OUTPUT

      21.times do
        grid.tick
        round_count += 1
      end
      grid.to_s.should eq <<-OUTPUT
      #######
      #...G.#
      #..G.G#
      #.#.#G#
      #...#E#
      #.....#
      #######
      OUTPUT

      grid.tick
      round_count += 1
			grid.to_s.should eq <<-OUTPUT
			#######
			#..G..#
			#...G.#
			#.#G#G#
			#...#E#
			#.....#
			#######
			OUTPUT

      grid.tick
      round_count += 1
			grid.to_s.should eq <<-OUTPUT
			#######
			#.G...#
			#..G..#
			#.#.#G#
			#..G#E#
			#.....#
			#######
			OUTPUT

      grid.tick
      round_count += 1
			grid.to_s.should eq <<-OUTPUT
			#######
			#G....#
			#.G...#
			#.#.#G#
			#...#E#
			#..G..#
			#######
			OUTPUT

      grid.tick
      round_count += 1
			grid.to_s.should eq <<-OUTPUT
			#######
			#G....#
			#.G...#
			#.#.#G#
			#...#E#
			#...G.#
			#######
			OUTPUT

      grid.tick
      round_count += 1
			grid.to_s.should eq <<-OUTPUT
			#######
			#G....#
			#.G...#
			#.#.#G#
			#...#E#
			#....G#
			#######
			OUTPUT

			(41 - 22).times do
        grid.tick
        round_count += 1
      end
			grid.to_s(true).should eq <<-OUTPUT
			#######
			#G....# G(200)
			#.G...# G(131)
			#.#.#G# G(59)
			#...#.#
			#....G# G(200)
			#######
			OUTPUT

      # When a warrior notices that there are no more targets, then it should
      # raise the alarm that the battle is over, and that should bubble up
      # through grid.tick
      expect_raises(Warrior::BattleIsOver) { grid.tick }

    end

    it "works for problematic inputs" do

      input = <<-INPUT
      #######
      #######
      #.E..G#
      #.#####
      #G#####
      #######
      #######
      INPUT

      grid = GameWorld.parse(input.lines)
      grid.tick
      grid.to_s.should eq <<-OUTPUT
      #######
      #######
      #E..G.#
      #G#####
      #.#####
      #######
      #######
      OUTPUT

      input = <<-INPUT
      ####
      #.G#
      #GE#
      ####
      INPUT

      grid = GameWorld.parse(input.lines)
      grid.tick
      grid.to_s.should eq input
      grid[2,1].as(Warrior).hp.should eq 197 # elf should attack top goblin
      grid[2,2].as(Warrior).hp.should eq 194 # elf should get attacked twice


      input = <<-INPUT
      ########
      #..E..G#
      #G######
      ########
      INPUT

      grid = GameWorld.parse(input.lines)
      grid.tick
      grid.to_s.should eq <<-OUTPUT
      ########
      #GE..G.#
      #.######
      ########
      OUTPUT

    end
  end
end

describe Day15 do

  describe "#part_a" do

    it "behaves correctly for sample input 1 " do
      sample_input = <<-INPUT
      #######
      #G..#E#
      #E#E.E#
      #G.##.#
      #...#E#
      #...E.#
      #######
      INPUT

      expected_final_grid_state = <<-OUTPUT
      #######
      #...#E# E(200)
      #E#...# E(197)
      #.E##.# E(185)
      #E..#E# E(200), E(200)
      #.....#
      #######
      OUTPUT

      day15 = Day15.new(sample_input.lines)
      result = day15.part_a
      day15.grid.to_s(true).should eq expected_final_grid_state
			result.should eq 36334
    end

    it "behaves correctly for sample input 2 " do
      sample_input = <<-INPUT
      #######
      #E..EG#
      #.#G.E#
      #E.##E#
      #G..#.#
      #..E#.#
      #######
      INPUT

      expected_final_grid_state = <<-OUTPUT
      #######
      #.E.E.# E(164), E(197)
      #.#E..# E(200)
      #E.##.# E(98)
      #.E.#.# E(200)
      #...#.#
      #######
      OUTPUT

      day15 = Day15.new(sample_input.lines)
      result = day15.part_a
      day15.grid.to_s(true).should eq expected_final_grid_state
			result.should eq 39514
    end

    it "behaves correctly for sample input 3 " do
      sample_input = <<-INPUT
      #######
      #E.G#.#
      #.#G..#
      #G.#.G#
      #G..#.#
      #...E.#
      #######
      INPUT

      expected_final_grid_state = <<-OUTPUT
      #######
      #G.G#.# G(200), G(98)
      #.#G..# G(200)
      #..#..#
      #...#G# G(95)
      #...G.# G(200)
      #######
      OUTPUT

      day15 = Day15.new(sample_input.lines)
      result = day15.part_a
      day15.grid.to_s(true).should eq expected_final_grid_state
			result.should eq 27755
    end

    it "behaves correctly for sample input 4 " do
      sample_input = <<-INPUT
      #######
      #.E...#
      #.#..G#
      #.###.#
      #E#G#G#
      #...#G#
      #######
      INPUT

      expected_final_grid_state = <<-OUTPUT
      #######
      #.....#
      #.#G..# G(200)
      #.###.#
      #.#.#.#
      #G.G#G# G(98), G(38), G(200)
      #######
      OUTPUT

      day15 = Day15.new(sample_input.lines)
      result = day15.part_a
      day15.grid.to_s(true).should eq expected_final_grid_state
			result.should eq 28944
    end

    it "behaves correctly for sample input 4 " do
      sample_input = <<-INPUT
      #########
      #G......#
      #.E.#...#
      #..##..G#
      #...##..#
      #...#...#
      #.G...G.#
      #.....G.#
      #########
      INPUT

      expected_final_grid_state = <<-OUTPUT
      #########
      #.G.....# G(137)
      #G.G#...# G(200), G(200)
      #.G##...# G(200)
      #...##..#
      #.G.#...# G(200)
      #.......#
      #.......#
      #########
      OUTPUT

      day15 = Day15.new(sample_input.lines)
      result = day15.part_a
      day15.grid.to_s(true).should eq expected_final_grid_state
			result.should eq 18740
    end

  end

end
