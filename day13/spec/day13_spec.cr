require "../day13"
require "spec"

describe Directions::Turn do
    it "cycles correctly" do
        cases_and_expected_results = {
            Directions::Turn::Left => Directions::Turn::Straight,
            Directions::Turn::Straight => Directions::Turn::Right,
            Directions::Turn::Right => Directions::Turn::Left,
        }
        cases_and_expected_results.each do |input, expected_output|
            input.next.should eq expected_output
        end
    end
end

describe Day13 do

    sample_input = <<-'INPUT'
    /->-\        
    |   |  /----\
    | /-+--+-\  |
    | | |  | v  |
    \-+-/  \-+--/
      \------/   
    INPUT

    it "parses the grid correctly" do
        day13 = Day13.new(sample_input.lines)

        sample_input.lines.each_with_index do |row, y|
            row.chars.each_with_index do |char, x|
                parsed_cell_value = day13.grid[y][x]
                if ['>', '^', 'v', '<'].includes?(char)
                    cart_at_location = day13.carts.find {|c| c.x == x && c.y == y}
                    cart_at_location.should_not be_nil
                    cart_at_location.not_nil!.direction.should eq Directions::Compass.of_char(char)

                    parsed_cell_value.should eq (
                        cart_at_location.not_nil!.direction.replacement_track_char
                    )
                else
                    parsed_cell_value.should eq char
                end
            end
        end
    end

    describe "#tick" do 

        it "should work right for ReportFirst crash behavior" do
            day13 = Day13.new(sample_input.lines)

            expected_result = <<-'OUTPUT'
            /-->\        
            |   |  /----\
            | /-+--+-\  |
            | | |  | |  |
            \-+-/  \-v--/
              \------/   
            OUTPUT

            day13.tick(Day13::CrashBehavior::ReportFirst)
            day13.to_s.should eq expected_result

            # Intersection should've been handled correctly
            expected_result = <<-'OUTPUT'
            /--->        
            |   |  /----\
            | /-+--+-\  |
            | | |  | |  |
            \-+-/  \-+>-/
              \------/   
            OUTPUT
            day13.tick(Day13::CrashBehavior::ReportFirst)
            day13.to_s.should eq expected_result

            # Curve should've been handled correctly
            expected_result = <<-'OUTPUT'
            /---\        
            |   v  /----\
            | /-+--+-\  |
            | | |  | |  |
            \-+-/  \-+->/
              \------/   
            OUTPUT
            day13.tick(Day13::CrashBehavior::ReportFirst)
            day13.to_s.should eq expected_result

            expected_result = <<-'OUTPUT'
            /---\        
            |   |  /----\
            | /-v--+-\  |
            | | |  | |  |
            \-+-/  \-+-->
              \------/   
            OUTPUT
            day13.tick(Day13::CrashBehavior::ReportFirst)
            day13.to_s.should eq expected_result

            # Another curve and another intersection should've been handled 
            # correctly
            expected_result = <<-'OUTPUT'
            /---\        
            |   |  /----\
            | /-+>-+-\  |
            | | |  | |  ^
            \-+-/  \-+--/
              \------/   
            OUTPUT
            day13.tick(Day13::CrashBehavior::ReportFirst)
            day13.to_s.should eq expected_result

            # skip some steps
            2.times { day13.tick(Day13::CrashBehavior::ReportFirst) }

            # A second-intersection-for-cart should've been handled correctly
            expected_result = <<-'OUTPUT'
            /---\        
            |   |  /---<\
            | /-+--+>\  |
            | | |  | |  |
            \-+-/  \-+--/
              \------/   
            OUTPUT
            day13.tick(Day13::CrashBehavior::ReportFirst)
            day13.to_s.should eq expected_result

            # skip some steps
            3.times { day13.tick(Day13::CrashBehavior::ReportFirst) }

            # A third-intersection-for-cart should've been handled correctly
            expected_result = <<-'OUTPUT'
            /---\        
            |   |  <----\
            | /-+--+-\  |
            | | |  | |  |
            \-+-/  \<+--/
              \------/   
            OUTPUT
            day13.tick(Day13::CrashBehavior::ReportFirst)
            day13.to_s.should eq expected_result
        end

    end

    describe "#part_a" do 
        it "behaves correctly for sample input" do
            day13 = Day13.new(sample_input.lines)

            day13.part_a.should eq({7,3})
        end
    end

    describe "#part_b" do 
        it "behaves correctly for sample input" do
			sample_input = <<-'INPUT'
			/>-<\  
			|   |  
			| /<+-\
			| | | v
			\>+</ |
			  |   ^
			  \<->/
			INPUT

            day13 = Day13.new(sample_input.lines)

            day13.part_b(true).should eq({6,4})
        end
    end

end
