##
# Advent of Code 2018 Day 1 solution.
# Problem statement:
#   Given a list of "adjustments" to your device's "frequency", apply those adjustments
#   by adding each adjustment to your device's current frequency, starting from 0.
# 
# Part A:
#   Starting with a frequency of zero, what is the resulting frequency after all of 
#   the changes in frequency have been applied?
#
# Part B:
#   Find the first frequency that your device reaches twice. Note that your device might 
#   need to repeat its list of frequency changes many times before a duplicate frequency 
#   is found, and that duplicates might be found while in the middle of processing the list.
##
class Day1
    @input : Array(Int32)

    def initialize(input_str : String)
        @input = input_str.lines.map {|x| x.to_i}
    end

    ## 
    # This part is easy: applying a change is just adding it to the current result, a.k.a. sum.
    ##
    def part_a : Int32
        @input.sum(0) 
    end

    ##
    # This part is almost as easy: cycle through the list, keeping track of each frequency we "see"
    # as we apply adjustments. Once we find a duplicated one, return it.
    ##
    def part_b : Int32
        dup_freq = nil
        current_freq = 0
        seen_frequencies = [current_freq].to_set # Keep track of which frequencies we've seen.
        i = 0
        until dup_freq != nil # Keep going until we've seen the same frequency twice
            current_freq += @input[i]
            if seen_frequencies.includes?(current_freq)
                dup_freq = current_freq
            end
            seen_frequencies << current_freq
            i = (i + 1) % @input.size # modulo by input size to keep looping over the list
        end
        dup_freq.not_nil! # There *will* be a dup_freq when finished, so .not_nil! is safe.
    end
end
        
day1 = Day1.new(File.read("input.txt"))
puts "1A: #{day1.part_a}"
puts "1B: #{day1.part_b}"
