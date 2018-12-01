class Day1
    @input : Array(Int32)

    def initialize(input_str : String)
        @input = input_str.lines.map {|x| x.to_i}
    end

    def part_a : Int32
        @input.sum(0)
    end

    def part_b : Int32
        seen_frequencies = [0].to_set
        dup_freq = nil
        current_freq = 0
        i = 0
        until dup_freq != nil
            current_freq += @input[i]
            if seen_frequencies.includes?(current_freq)
                dup_freq = current_freq
            end
            seen_frequencies << current_freq
            i = (i + 1) % @input.size # we modulo by input size so that we can keep looping over the list
        end
        dup_freq.not_nil! # We know there *will* be a dup_freq when we're done, so .not_nil! is safe.
    end
end
        
    

day1 = Day1.new(File.read("input.txt"))
puts "1A: #{day1.part_a}"
puts "1B: #{day1.part_b}"