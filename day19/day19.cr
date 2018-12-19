# There's a lot of macro stuff in here to reduce duplication. For docs, check out https://crystal-lang.org/docs/syntax_and_semantics/macros.html

class Memory 
    @iptr : Int32
    @registers : Array(Int32)
    getter iptr_index, registers
    property iptr

    def initialize(@iptr_index : Int32, initial_values : Array(Int32)? = nil)
        @iptr = 0
        if initial_values
            raise ArgumentError.new("Registers must be of size 6") unless initial_values.size == 6
            @registers = initial_values
        else
            @registers = Array(Int32).new(size = 6, value = 0)
        end
    end

    def [](index : Int32) : Int32
        if (index == @iptr_index)
            @iptr
        else
            @registers[index]
        end
    end
    def []=(index : Int32, value : Int32)
        if (index == @iptr_index)
            @iptr = value
        else
            @registers[index] = value
        end
    end

    def get_real_register_value(index : Int32) : Int32
        @registers[index]
    end

    def reset
        @registers.fill(0)
        @iptr = 0
    end

    def to_s
        "iptr: #{@iptr}, registers: #{@registers}, iptr_index: #{@iptr_index}"
    end
end

struct Instruction
    getter operation, inputs, dest
    def initialize(@operation : String, @inputs : Tuple(Int32, Int32), @dest : Int32)
    end

    def self.parse(instruction_str : String)
        segments = instruction_str.split
        operation = segments[0]
        inputs = {segments[1].to_i, segments[2].to_i}
        dest = segments[3].to_i
        return Instruction.new(operation, inputs, dest)
    end

    def to_s
        "#{@operation} #{@inputs[0]} #{@inputs[1]} #{@dest}"
    end
end

class AlreadyHaltedError < Exception
end

class Program
    @memory : Memory
    getter memory
    def initialize(@code : Array(Instruction), @memory : Memory)
    end

    def step(verbose : Bool = false)
        raise AlreadyHaltedError.new if self.has_halted?

        current_instruction = @code[@memory.iptr] 
        puts current_instruction.to_s if verbose
        KnownOperations.exec(current_instruction, @memory)
        @memory.iptr += 1
        puts @memory.to_s if verbose

    end

    def has_halted?
        @memory.iptr < 0 || @memory.iptr >= @code.size
    end

    def run(verbose : Bool = false)
        until self.has_halted?
            self.step(verbose)
        end
    end

    def self.parse(input_lines : Array(String)) : Program
        if /#ip (?<iptr_index>\d)/ =~ input_lines[0]
            iptr_index = $~["iptr_index"].to_i
        else 
            raise "Invalid input at line 0: #{input_lines[0]}"
        end
        memory = Memory.new(iptr_index)

        code = input_lines.skip(1).map {|line| Instruction.parse(line)}
        return Program.new(code, memory)
    end
end

module KnownOperations

    def self.exec(instr : Instruction, memory : Memory)
        {% for method_name in [
            "addr", "addi", "mulr", "muli", "banr", "bani", "borr", "bori",
            "setr", "seti", "gtir", "gtrr", "gtri", "eqir", "eqrr", "eqri"
        ] %}
            return self.{{method_name.id}}(instr, memory) if instr.operation == {{method_name}} 
        {% end %}
        raise "Unknown method: #{instr.operation}"
    end

    # Use macros to define binary operators
    {% for name, operation in { 
        "add" => "+", 
        "mul" => "*", 
        "ban" => "&", 
        "bor" => "|" 
    } %}

    def self.{{name.id}}r(instr : Instruction, memory : Memory)
        self.do_rr(instr, memory) do |a, b| 
            a {{operation.id}} b 
        end
    end

    def self.{{name.id}}i(instr : Instruction, memory : Memory)
        self.do_ri(instr, memory) do |a, b| 
            a {{operation.id}} b
        end
    end

    {% end %}

    # These are simple enough to be defined themselves
    def self.setr(instr : Instruction, memory : Memory)
        memory[instr.dest] = memory[instr.inputs[0]]
    end
    def self.seti(instr : Instruction, memory : Memory) 
        memory[instr.dest] = instr.inputs[0]
    end

    # Use macros to define comparison operators
    {% for name, op in {
            "gt" => ">", 
            "eq" => "==" 
    } %}
        {% for source in ["ir", "rr", "ri"] %}
            def self.{{name.id}}{{source.id}}(instr : Instruction, memory : Memory) 
                self.do_{{source.id}}(instr, memory) do |a, b|
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
    private def self.do_r(instr : Instruction, memory : Memory, &operation)
    end
    private def self.do_rr(instr : Instruction, memory : Memory, &operation)
        a,b = instr.inputs.map {|i| memory[i]}
        memory[instr.dest] = yield a,b
    end
    private def self.do_ri(instr : Instruction, memory : Memory, &operation)
        a = memory[instr.inputs[0]]
        b = instr.inputs[1]
        memory[instr.dest] = yield a,b
    end
    private def self.do_ir(instr : Instruction, memory : Memory, &operation)
        a = instr.inputs[0]
        b = memory[instr.inputs[1]]
        memory[instr.dest] = yield a,b
    end
end

class Day19
    @program : Program

    def initialize(input_lines : Array(String))
        @program = Program.parse(input_lines)
    end

    def part_a : Int32
        @program.memory.reset
        @program.run
        return @program.memory.get_real_register_value(0)
    end

    def part_b : Int32
        @program.memory.reset
        @program.memory[0] = 1
        @program.run(true)
        return @program.memory.get_real_register_value(0)
    end

end

unless PROGRAM_NAME.includes?("crystal-run-spec")
    day19 = Day19.new(File.read_lines("input.txt"))
    puts "19A: #{day19.part_a}"
    puts "19B: #{day19.part_b}"
end
