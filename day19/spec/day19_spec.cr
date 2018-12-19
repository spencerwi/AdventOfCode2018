require "../day19"
require "spec"

describe Day19 do

    describe "#part_a" do 
        it "behaves correctly for sample input" do
            sample_input = <<-INPUT
            #ip 0
            seti 5 0 1
            seti 6 0 2
            addi 0 1 0
            addr 1 2 3
            setr 1 0 0
            seti 8 0 4
            seti 9 0 5
            INPUT

            day19 = Day19.new(sample_input.lines)

            day19.part_a.should eq 0
        end
    end

end
