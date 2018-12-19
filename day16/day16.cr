# There's a lot of macro stuff in here to reduce duplication. For docs, check out https://crystal-lang.org/docs/syntax_and_semantics/macros.html

alias Registers = Tuple(Int32, Int32, Int32, Int32)
def array_to_registers(arr : Array(Int32)) : Registers
    raise ArgumentError.new("Registers must have 4 elements!") unless arr.size == 4
    return {arr[0], arr[1], arr[2], arr[3]}
end

struct Instruction
    getter opcode, inputs, dest
    def initialize(@opcode : Int32, @inputs : Tuple(Int32, Int32), @dest : Int32)
    end

    def self.parse(opcode_str : String)
        segments = opcode_str.split.map(&.to_i)
        return Instruction.new(segments[0], {segments[1], segments[2]}, segments[3])
    end
end

class Clue 
    getter before, instruction, after
    def initialize(@before : Registers, @instruction : Instruction, @after : Registers)
    end

    def get_matched_operations
        matched_operations = [] of String
        # Macros make this stuff a lot quicker
        {% for method_name in [
            "addr", "addi", "mulr", "muli", "banr", "bani", "borr", "bori",
            "setr", "seti", "gtir", "gtrr", "gtri", "eqir", "eqrr", "eqri"
        ] %}
             matched_operations << {{method_name}} if KnownOperations.{{method_name.id}}(@instruction, @before) == @after
        {% end %}

        return matched_operations
    end

    def self.parse(lines : Array(String))
        before = array_to_registers(
            lines[0].gsub(/Before:\s+\[/, "").gsub("]", "").split(", ").map(&.to_i)
        )
        instruction = Instruction.parse(lines[1])
        after = array_to_registers(
            lines[2].gsub(/After:\s+\[/, "").gsub("]", "").split(", ").map(&.to_i)
        )
        return Clue.new(before, instruction, after)
    end
end

module KnownOperations

    def self.call_method(method_name : String, instr : Instruction, registers : Registers) : Registers
        {% for method_name in [
            "addr", "addi", "mulr", "muli", "banr", "bani", "borr", "bori",
            "setr", "seti", "gtir", "gtrr", "gtri", "eqir", "eqrr", "eqri"
        ] %}
            return self.{{method_name.id}}(instr, registers) if method_name == {{method_name}} 
        {% end %}
        raise "Unknown method: #{method_name}"
    end

    # Use macros to define binary operators
    {% for name, operation in { 
        "add" => "+", 
        "mul" => "*", 
        "ban" => "&", 
        "bor" => "|" 
    } %}

    def self.{{name.id}}r(instr : Instruction, register_state : Registers) : Registers
        self.do_register(instr, register_state) do |a, b| 
            a {{operation.id}} b 
        end
    end

    def self.{{name.id}}i(instr : Instruction, register_state : Registers) : Registers
        self.do_immediate(instr, register_state) do |a, b| 
            a {{operation.id}} b
        end
    end

    {% end %}

    # These are simple enough to define themselves
    def self.setr(instr : Instruction, register_state : Registers) : Registers
        self.do_register(instr, register_state) {|a, _| a}
    end

    def self.seti(instr : Instruction, register_state : Registers) : Registers
        self.do_ir(instr, register_state) {|a, _| a}
    end

    # Use macros to define comparison operators
    {% for name, op in {"gt" => ">", "eq" => "==" } %}
        {% for source in ["ir", "rr", "ri"] %}
            def self.{{name.id}}{{source.id}}(instr : Instruction, reg : Registers) : Registers
                self.do_{{source.id}}(instr, reg) do |a, b|
                    if a {{op.id}} b
                        1
                    else
                        0
                    end
                end
            end
        {% end %}
    {% end %}

    # Helper methods to do things with register/value combinations
    private def self.do_register(instr : Instruction, registers : Registers, &operation)
        result = registers.to_a
        result[instr.dest] = yield registers[instr.inputs[0]], registers[instr.inputs[1]]
        return array_to_registers(result)
    end
    private def self.do_immediate(instr : Instruction, registers : Registers, &operation)
        result = registers.to_a
        result[instr.dest] = yield registers[instr.inputs[0]], instr.inputs[1]
        return array_to_registers(result)
    end
    private def self.do_rr(instr : Instruction, registers : Registers, &operation)
        result = registers.to_a
        result[instr.dest] = yield registers[instr.inputs[0]], registers[instr.inputs[1]]
        return array_to_registers(result)
    end
    private def self.do_ri(instr : Instruction, registers : Registers, &operation)
        result = registers.to_a
        result[instr.dest] = yield registers[instr.inputs[0]], instr.inputs[1]
        return array_to_registers(result)
    end
    private def self.do_ir(instr : Instruction, registers : Registers, &operation)
        result = registers.to_a
        result[instr.dest] = yield instr.inputs[0], registers[instr.inputs[1]]
        return array_to_registers(result)
    end

end

class Day16
    @clues : Array(Clue)
    @program : Array(Instruction)

    def initialize(input_lines : Array(String))
        @clues = input_lines.reject {|line| line.empty?} # remove empty spacer lines
            .in_groups_of(3)
            .take_while {|line_group| line_group[0] && line_group[0].not_nil!.starts_with?("Before:")}
            .map {|line_group| line_group.map(&.not_nil!)}
            .map {|line_group| Clue.parse(line_group)}

        @program = input_lines.reject {|line| line.empty?} # remove empty spacer lines
            .skip(@clues.size * 3)
            .map {|line| Instruction.parse(line)}
    end

    # Part A problem statement: How many samples behave like 3 or more opcodes?
    def part_a : Int32
        @clues.select {|clue| clue.get_matched_operations.size >= 3 }.size
    end

    # Part B problem statement: Figure out the opcodes, then execute the test program,
    # then return the value of register 0
    def part_b : Int32
        opcodes = @clues.map(&.instruction).map(&.opcode).uniq

        known_opcodes = Hash(Int32, String).new
        unknown_opcodes = Set(Int32).new

        # Keep looping, identifying opcodes and whittling down the list of 
        # unknowns until we have them all identified.
        while known_opcodes.size < opcodes.size
            @clues.each do |clue|
                opcode_for_clue = clue.instruction.opcode
                # If we already know this opcode, move on
                next if known_opcodes.has_key?(opcode_for_clue)

                # Look for every operation that this opcode matches that isn't 
                # already "claimed" by another opcode. First time through, 
                # that'll just be the opcodes that match only one operation.
                # Then that'll whittle more down, and more, and so on.
                matches = clue.get_matched_operations
                unclaimed_matches = matches.reject {|operation| known_opcodes.has_value?(operation)}
                if unclaimed_matches.size == 1
                    known_opcodes[opcode_for_clue] = unclaimed_matches[0]
                end
            end
        end

        # Now, run the program starting from zeroed-out registers
        final_registers = @program.reduce({0, 0, 0, 0}) do |regs, instruction|
            opcode = instruction.opcode
            operation = known_opcodes[opcode]
            KnownOperations.call_method(operation, instruction, regs)
        end

        # Finally, return the contents of register 0.
        return final_registers.not_nil![0]
    end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
    day16 = Day16.new(File.read_lines("input.txt"))
    puts "16A: #{day16.part_a}"
    puts "16B: #{day16.part_b}"
end
