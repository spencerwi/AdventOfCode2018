require "../day22"
require "spec"

describe Cave do

    cave = Cave.new(510, {10, 10})

    describe "#geologic_index" do 
        
        it "returns 0 at 0,0" do
            cave.geologic_index(0, 0).should eq 0
        end

        it "returns 0 at the target" do
            cave.geologic_index(*cave.target).should eq 0
        end

        it "returns x * 16807 if y is 0" do
            cave.geologic_index(5, 0).should eq (5 * 16807)
        end

        it "returns y * 48271 if x is 0" do
            cave.geologic_index(0, 5).should eq (5 * 48271)
        end

        it "works correctly at any other spot on the grid" do
            cave.geologic_index(1, 1).should eq 145722555
        end

    end

    describe "#erosion_level" do
        it "works correctly for sample data" do
            cases = {
                {0,0} => 510,
                {1,0} => 17317,
                {0,1} => 8415,
                {1,1} => 1805,
                {10, 10} => 510
            }
            cases.each do |(x,y), expected_result|
                cave.erosion_level(x, y).should eq expected_result
            end
        end
    end

    describe "#cell_type" do
        it "works correctly for sample data" do
            cases = {
                {0,0} => CellType::Rocky,
                {1,0} => CellType::Wet,
                {0,1} => CellType::Rocky,
                {1,1} => CellType::Narrow,
                {10, 10} => CellType::Rocky
            }
            cases.each do |(x,y), expected_result|
                cave.cell_type(x, y).should eq expected_result
            end
        end
    end

    describe "#total_risk_level" do
        it "works correctly for sample data" do
            cave.total_risk_level(cave.target).should eq 114
        end
    end

    describe "#new" do
        it "generates the cave correctly" do
			expected_output_cave = <<-'CAVE'
			.=.|=.|.|=.
			.|=|=|||..|
			.==|....||=
			=.|....|.==
			=|..==...=.
			=||.=.=||=|
			|.=.===|||.
			|..==||=.|=
			.=..===..=|
			.======|||=
			.===|=|===.
			CAVE

            cave.to_s.should eq expected_output_cave
        end
    end

end

describe Day22 do

    describe "#part_a" do 
        it "behaves correctly for sample input" do
			sample_input = <<-'INPUT'
			depth: 510
			target: 10,10
			INPUT

			Day22.new(sample_input.lines).part_a.should eq 114
        end
    end

end
