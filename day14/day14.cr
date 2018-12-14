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
        return (input_int..input_int + 9).map {|idx| @scoreboard[idx]}.map(&.to_s).join("")
    end

    # Part B problem statement: how many recipes precede the input int as a 
    # sequence of scores?
    def part_b : Int32
        # Since we only ever tack new stuff onto the end of the scoreboard, we 
        # only need to search through the whole scoreboard once. After that, we
        # can just slice a hunk off the end big enough that it could possibly be
        # the digit sequence we need, and check that.
        input_digits = @input.chars.map(&.to_i)
        index_of_chars = @scoreboard.each_cons(@input.size).index(input_digits)
        while index_of_chars.nil?
            self.tick

            unless @scoreboard.size < @input.size
                slice_start = @scoreboard.size - @input.size
                slice_off_end = (slice_start...@scoreboard.size).map {|idx| @scoreboard[idx]}.to_a

                if slice_off_end == input_digits
                    index_of_chars = slice_start
                end
            end
        end
        return index_of_chars.not_nil!
    end

    def tick
        # Get the elves' combined recipe score
        elf1, elf2 = @elf_indexes
        recipe1, recipe2 = {
            @scoreboard[elf1],
            @scoreboard[elf2]
        }
        elf_score = recipe1 + recipe2

        # Tack the digits of the elves' score onto the end of the scoreboard.
        if elf_score >= 10
            first_digit, second_digit = elf_score.divmod(10)
            @scoreboard << first_digit
            @scoreboard << second_digit
        else 
            @scoreboard << elf_score
        end

        # Move the elves
        @elf_indexes = {
            (elf1 + recipe1 + 1) % @scoreboard.size,
            (elf2 + recipe2 + 1) % @scoreboard.size
        }
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
    # day14 = Day14.new("890691")
    day14 = Day14.new("2018")
    puts "14A: #{day14.part_a}"
    puts "14B: #{day14.part_b}"
end
