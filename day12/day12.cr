class Garden
    getter pots, rules

    # Rather than having an array where I have to keep growing it and
    # keeping track of where the original "0" was, I instead use a Hash
    # from index to char, which defaults to '.' for any index I haven't
    # touched yet. That allows me to reach into negative or greater-than-max 
    # indexes at will, providing automatic "growing" in both directions 
    # without me having to do it manually.
    def initialize(@pots : Hash(Int64, Char), @rules : Hash(String, Char)) 
    end

    def self.parse(input_lines : Array(String)) : Garden
        pots = Hash(Int64, Char).new('.')
        if /^initial state: (?<pots>[\.#]+)$/ =~ input_lines[0]
            $~["pots"].chars.each_with_index do |c, idx|
                pots[idx.to_i64] = c
            end
        else 
            raise "Invalid initial state line: '#{input_lines[0]}'"
        end

        rules = self.parse_rules(input_lines.skip(2))
        return Garden.new(pots, rules)
    end

    # Rules, as it turns out, are just a mapping from each 5-pot "slice" of the
    # whole garden to the resulting character that should be in the middle pot
    # of the slice. If no rule matches, no plant should be in the middle pot,
    # which maps really nicely to a hash with a default value of '.'
    private def self.parse_rules(rule_lines : Array(String)) : Hash(String, Char)
        rules = Hash(String, Char).new('.')
        
        rule_lines.each do |str|
            if /^(?<pots>[\.#]+) => (?<result>[\.#])$/ =~ str
                match_value = $~["pots"]
                result = $~["result"].char_at(0)
                rules[match_value] = result
            else
                raise "Invalid rule string: '#{str}'"
            end
        end

        return rules
    end

    # Update the garden state by one step.
    def tick : Void
        # Create a "working copy" so that we're not reading from and updating 
        # the same data structure.
        new_pot_state = @pots.dup

        # We can only ever get a new plant in a pot that's 2 spaces away from
        # the farthest-out "plant-filled" pot. So we don't need to look further 
        # in either direction than that.
        leftmost_filled_pot, rightmost_filled_pot = @pots.select{|idx, c| c == '#'}.keys.minmax
        range_to_examine = (leftmost_filled_pot - 2)..(rightmost_filled_pot + 2)

        range_to_examine.each do |center_pot_index|
            first_pot = center_pot_index - 2
            last_pot = center_pot_index + 2
            pot_group = (first_pot..last_pot).map {|idx| @pots.fetch(idx, '.')}.join("")

            new_pot_state[center_pot_index] = @rules[pot_group]
        end

        @pots = new_pot_state
    end

    # "Scoring" a garden is actually pretty easy with the hash:
    # find all the hash-keys that correspond to a '#', and you've got
    # all your indexes (positive, negative, whatever). Then just sum them!
    def score : Int64
        @pots.select {|idx, c| c == '#'}
            .keys
            .map(&.to_i64).sum
    end

    # Convenience method used for TDD'ing my way to make sure that "tick" 
    # behaves right by allowing me to compare my garden state to the sample.
    def to_s : String
        smallest_seen_pot, largest_seen_pot = @pots.keys.minmax
        # We do the whole "range" trick to ensure a contiguous increase from 
        # leftmost pot to rightmost pot, since we may have gaps due to our use
        # of a hash rather than an array.
        return (smallest_seen_pot..largest_seen_pot).map {|idx| @pots[idx]}.join("")
    end
end

class Day12
    @garden : Garden

    def initialize(input_lines : Array(String))
        @garden = Garden.parse(input_lines)
    end

    def solve(generation_count : Int64, verbose = false)
        previous_score = 0
        last_score_change = 0
        generation_count.times do |current_gen|
            @garden.tick

            # As it turns out, eventually the "rate of score change" stabilizes, 
            # probably due to repeating patterns like in Conway's Game of Life.
            # So if we watch for the point where the score change "stabilizes",
            # then we can just extrapolate the rest from there.
            score_change = @garden.score - previous_score
            puts "#{current_gen + 1}: #{@garden.score}, score change of #{score_change}" if verbose
            if score_change == last_score_change
                if verbose
                    puts "The score is now constantly increasing by #{score_change}. We can extrapolate from here."
                end

                # If we've reached the point of constant increase, then we can 
                # now extrapolate the results by just figuring out the number of
                # generations left to simulate, and adding 
                #   (rate * generations_left)
                # to the our current score.
                generations_left = generation_count - (current_gen + 1) # since current_gen is 0-indexed
                amount_that_will_be_added_by_the_end = (generations_left * score_change)
                return @garden.score + amount_that_will_be_added_by_the_end
            end

            previous_score = @garden.score
            last_score_change = score_change
        end
        return @garden.score
    end

end

unless PROGRAM_NAME.includes?("crystal-run-spec")
    day12 = Day12.new(File.read_lines("input.txt"))
    puts "12A: #{day12.solve(20)}"
    puts "12B: #{day12.solve(50_000_000_000 - 20)}"
end
