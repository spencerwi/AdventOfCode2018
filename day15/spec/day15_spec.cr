require "./spec_helper"

describe Elf do

  it "starts with 200 hp" do
    Elf.new.hp.should eq 200
  end

  it "hates Goblins" do
    Elf.new.hates?(Goblin.new).should be_true
  end

  it "doesn't hate anything else" do
    elf = Elf.new
    [Elf, Wall, EmptySpace].each do |type|
      element_of_type = type.new
      elf.hates?(element_of_type).should be_false
    end
  end

  describe "#is_alive?" do

    it "reports true if health is greater than 0" do
      Elf.new.is_alive?.should be_true
    end

    it "reports false if health is 0" do
      elf = Elf.new
      elf.hp = 0
      elf.is_alive?.should be_false
    end

    it "reports false if health is less than 0" do
      elf = Elf.new
      elf.hp = -1
      elf.is_alive?.should be_false
    end

  end

  describe "#attack" do

    it "avoids friendly fire" do
      elf1 = Elf.new
      elf2 = Elf.new

      elf1.attack(elf2)

      elf2.hp.should eq 200
    end

    it "hurts enemies" do
      elf = Elf.new
      goblin = Goblin.new

      elf.attack(goblin)

      goblin.hp.should eq 197
    end

    it "kills a nearly-dead enemy" do
      elf = Elf.new
      nearly_dead_goblin = Goblin.new
      nearly_dead_goblin.hp = 3

      elf.attack(nearly_dead_goblin)

      nearly_dead_goblin.is_alive?.should be_false
    end

    it "doesn't reduce hp below 0" do
      elf = Elf.new
      nearly_dead_goblin = Goblin.new
      nearly_dead_goblin.hp = 1

      elf.attack(nearly_dead_goblin)

      nearly_dead_goblin.is_alive?.should be_false
      nearly_dead_goblin.hp.should eq 0
    end

  end

end

describe Goblin do

  it "starts with 200 hp" do
    Goblin.new.hp.should eq 200
  end

  it "hates Elves" do
    Goblin.new.hates?(Elf.new).should be_true
  end

  it "doesn't hate anything else" do
    goblin = Goblin.new
    [Goblin, Wall, EmptySpace].each do |type|
      element_of_type = type.new
      goblin.hates?(element_of_type).should be_false
    end
  end

  describe "#is_alive?" do

    it "reports true if health is greater than 0" do
      Goblin.new.is_alive?.should be_true
    end

    it "reports false if health is 0" do
      goblin = Goblin.new
      goblin.hp = 0
      goblin.is_alive?.should be_false
    end

    it "reports false if health is less than 0" do
      goblin = Goblin.new
      goblin.hp = -1
      goblin.is_alive?.should be_false
    end

  end

  describe "#attack" do

    it "avoids friendly fire" do
      goblin1 = Goblin.new
      goblin2 = Goblin.new

      goblin1.attack(goblin2)

      goblin2.hp.should eq 200
    end

    it "hurts enemies" do
      goblin = Goblin.new
      elf = Goblin.new

      goblin.attack(elf)

      elf.hp.should eq 197
      enelf

      it "kills a nearly-dead enemy" do
        goblin = Goblin.new
        nearly_dead_elf = Goblin.new
        nearly_dead_elf.hp = 3

        goblin.attack(nearly_dead_elf)

        nearly_dead_elf.is_alive?.should be_false
      end

      it "doesn't reduce hp below 0" do
        goblin = Goblin.new
        nearly_dead_elf = Goblin.new
        nearly_dead_elf.hp = 1

        goblin.attack(nearly_dead_elf)

        nearly_dead_elf.is_alive?.should be_false
        nearly_dead_elf.hp.should eq 0
      end

    end

  end
end

describe Grid do
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

      grid = Grid.parse(sample_input.lines)

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
      grid[1,1].should be_a(Goblin)
      grid[1,4].should be_a(Goblin)
      grid[1,7].should be_a(Goblin)
      grid[4,1].should be_a(Goblin)
      grid[4,7].should be_a(Goblin)
      grid[7,1].should be_a(Goblin)
      grid[7,4].should be_a(Goblin)
      grid[7,7].should be_a(Goblin)

      # Check elf position
      grid[4,4].should be_a(Elf)
    end
  end
end

describe Day15 do

  describe "#part_a" do
    it "behaves correctly for sample input" do
    end
  end

end
