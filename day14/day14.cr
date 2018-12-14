class Day14
    getter elf_indexes
    @scoreboard : Deque(Int32)
    @elf_indexes : Tuple(Int32, Int32)

    def initialize(@input : String)
        @scoreboard = Deque(Int32).new([3, 7])
        @elf_indexes = {0, 1}
    end

    # Part A problem statement: what are scores of the ten recipes starting from
    # the input index?
    def part_a : String
        input_int = @input.to_i64
        (input_int.to_i64 + 10).times do
            self.tick
            # puts self.to_s
        end
        return (input_int..input_int+9).map {|idx| @scoreboard[idx]}.map(&.to_s).join("")
    end

    # Part B problem statement: how many recipes precede the input int as a 
    # sequence of scores?
    def part_b : Int32
        stringified = @scoreboard.map(&.to_s).join("")
        until stringified.includes?(@input)
            self.tick
            stringified = @scoreboard.map(&.to_s).join("")
        end
        return stringified.index(@input).not_nil!
    end

    def tick
        # Get the elves' combined recipe score
        elf_recipes = @elf_indexes.map {|idx| @scoreboard[idx]}
        elf_score = elf_recipes.sum

        # Tack the digits of the elves' score onto the end of the scoreboard.
        if elf_score >= 10
            first_digit, second_digit = elf_score.divmod(10)
            @scoreboard << first_digit
            @scoreboard << second_digit
        else 
            @scoreboard << elf_score
        end

        @elf_indexes = elf_recipes.map_with_index do |recipe_value, elf_number| 
            # Each elf steps forward from their current position by their
            # recipe value plus 1, wrapping around as needed.
            (@elf_indexes[elf_number] + recipe_value + 1) % @scoreboard.size 
        end
    end

    def to_s : String
        elf1, elf2 = @elf_indexes
        scores = @scoreboard.map(&.to_s)
        scores[elf2] = "[#{scores[elf2]}]"
        scores[elf1] = "(#{scores[elf1]})"
        scores.join(" ")
    end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
    day14 = Day14.new("890691")
    puts "14A: #{day14.part_a}"
    puts "14B: #{day14.part_b}"
end
