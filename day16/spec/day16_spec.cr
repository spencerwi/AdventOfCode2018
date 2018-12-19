require "../day16"
require "spec"

describe "array_to_registers" do

    it "handles 4-element arrays correctly" do
        array_to_registers([1,2,3,4]).should eq({1,2,3,4})
        array_to_registers([1,1,1,1]).should eq({1,1,1,1})
    end

    it "errors on n-element arrays, where n is not 4" do
        error_cases = [
            [] of Int32,
            [1],
            [1,2],
            [1,2,3],
            [1,2,3,4,5]
        ]
        error_cases.each do |error_case|
            expect_raises(ArgumentError, "Registers must have 4 elements!") do 
                array_to_registers(error_case) 
            end
        end
    end
end

describe Instruction do
    
    describe "#parse" do
        it "behaves correctly for sample input" do
            instruction = Instruction.parse("9 2 1 2")
            instruction.opcode.should eq 9
            instruction.inputs.should eq({2, 1})
            instruction.dest.should eq 2
        end
    end
end

describe KnownOperations do

    describe "#addr" do
        it "behaves correctly" do
            instr = Instruction.new(9, {2, 1}, 2)
            registers = {0, 1, 1, 0}
            result = KnownOperations.addr(instr, registers)
            result.should eq ({0, 1, 2, 0})
        end
    end

    describe "#addi" do
        it "behaves correctly" do
            instr = Instruction.new(9, {2, 7}, 2)
            registers = {0, 1, 1, 0}
            result = KnownOperations.addi(instr, registers)
            result.should eq ({0, 1, 8, 0})
        end
    end

    describe "#mulr" do
        it "behaves correctly" do
            instr = Instruction.new(9, {2, 1}, 2)
            registers = {0, 2, 2, 0}
            result = KnownOperations.mulr(instr, registers)
            result.should eq ({0, 2, 4, 0})
        end
    end

    describe "#muli" do
        it "behaves correctly" do
            instr = Instruction.new(9, {2, 7}, 2)
            registers = {0, 1, 2, 0}
            result = KnownOperations.muli(instr, registers)
            result.should eq ({0, 1, 14, 0})
        end
    end

    describe "#banr" do
        it "behaves correctly" do
            instr = Instruction.new(9, {2, 1}, 2)
            registers = {0, 2, 2, 0}
            result = KnownOperations.banr(instr, registers)
            result.should eq ({0, 2, 2 & 2, 0})
        end
    end

    describe "#bani" do
        it "behaves correctly" do
            instr = Instruction.new(9, {2, 7}, 2)
            registers = {0, 1, 2, 0}
            result = KnownOperations.bani(instr, registers)
            result.should eq ({0, 1, 2 & 7, 0})
        end
    end

    describe "#borr" do
        it "behaves correctly" do
            instr = Instruction.new(9, {2, 1}, 2)
            registers = {0, 2, 2, 0}
            result = KnownOperations.borr(instr, registers)
            result.should eq ({0, 2, 2 | 2, 0})
        end
    end

    describe "#bori" do
        it "behaves correctly" do
            instr = Instruction.new(9, {2, 7}, 2)
            registers = {0, 1, 2, 0}
            result = KnownOperations.bori(instr, registers)
            result.should eq ({0, 1, 2 | 7, 0})
        end
    end

    # TODO: set, gt, eq

end

describe Clue do

    describe ".parse" do 

        it "handles valid input correctly" do
            input = <<-INPUT
            Before: [3, 2, 1, 1]
            9 2 1 2
            After: [3, 2, 2, 1]
            INPUT
            attempt = Clue.parse(input.lines)

            attempt.before.should eq({3, 2, 1, 1})
            attempt.instruction.should eq Instruction.new(9, {2, 1}, 2)
            attempt.after.should eq({3, 2, 2, 1})
        end

    end

    describe "#count_matched_opcodes" do 
        
        it "works for sample input" do
            input = <<-INPUT
            Before: [3, 2, 1, 1]
            9 2 1 2
            After: [3, 2, 2, 1]
            INPUT
            attempt = Clue.parse(input.lines)


            attempt.count_matched_opcodes.should eq 3
        end

    end

end

# describe Day16 do

#     describe "#part_a" do 
#         it "behaves correctly for sample input" do
#         end
#     end

# end
