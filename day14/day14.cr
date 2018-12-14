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
    # sequence of digits?
    def part_b : Int32

        # Since we only ever tack new stuff onto the end of the scoreboard, we 
        # only need to search through the whole scoreboard once. After that, we
        # can just slice a hunk off the end big enough that it could possibly be
        # the digit sequence we need, and check that.
        input_digits = @input.chars.map(&.to_i)
        index_of_chars = @scoreboard.each_cons(@input.size).index(input_digits)
        return index_of_chars unless index_of_chars.nil?

        loop do
            # If it wasn't already found, we keep on ticking until one of the 
            # "tails" of the scoreboard matches the input
            tails = self.tick

            # This is a little hairy, but it is so because `self.tick` returns
            # either one tail if we only added one recipe, or two tails if we 
            # added two. 
            case tails.size
            when 2 then # if we got back two tails, we added two recipes.
                if tails[0] == input_digits # if the first tail matches, 
                    return @scoreboard.size - @input.size - 1 # the second-to-last 5 characters match.
                elsif tails[1] == input_digits # if the second tail matches,
                    return @scoreboard.size - @input.size # the last 5 characters match.
                end
            when 1 then # if we only got back 1 tail, we added one recipe.
                if tails[0] == input_digits
                    return @scoreboard.size - @input.size # the last 5 characters match
                end
            end
        end
    end

    # Does the recipes, updates the scoreboard, and moves the elves. 
    # When finished, it returns each "tail-end" of the scoreboard that we've 
    # seen. If we added just one recipe to the scoreboard, you get a single
    # `@input.size`-digit array. If we added two, you get both.
    def tick : Array(Array(Int32))
        # Get the elves' combined recipe score
        elf1, elf2 = @elf_indexes
        recipe1, recipe2 = {
            @scoreboard[elf1],
            @scoreboard[elf2]
        }
        elf_score = recipe1 + recipe2

        # Tack the digits of the elves' score onto the end of the scoreboard.
        scoreboard_tails = [] of Array(Int32)
        if elf_score >= 10
            first_digit, second_digit = elf_score.divmod(10)
            @scoreboard << first_digit
            scoreboard_tails << self.get_scoreboard_tail
            @scoreboard << second_digit
        else 
            @scoreboard << elf_score
        end
        scoreboard_tails << self.get_scoreboard_tail

        # Move the elves
        @elf_indexes = {
            (elf1 + recipe1 + 1) % @scoreboard.size,
            (elf2 + recipe2 + 1) % @scoreboard.size
        }
        return scoreboard_tails
    end

    # Gets the last `@input.size` digits of the scoreboard.
    private def get_scoreboard_tail : Array(Int32)
        slice_start = (@scoreboard.size - @input.size)
        return (slice_start...@scoreboard.size).map {|idx| @scoreboard[idx]}.to_a
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
