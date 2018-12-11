require "../day2"
require "spec"

describe Day2 do

    describe "#part_a" do
        it "works correctly for sample inputs" do
            input = <<-INPUT
                abcdef
                bababc
                abbcde
                abcccd
                aabcdd
                abcdee
                ababab
            INPUT
            Day2.new(input.lines).part_a.should eq 12
        end
    end

    describe "#part_b" do
        it "works correctly for sample inputs" do
            input = <<-INPUT
            abcde
            fghij
            klmno
            pqrst
            fguij
            axcye
            wvxyz
            INPUT
            Day2.new(input.lines).part_b.should eq ("fgij".chars)
        end
    end
end
