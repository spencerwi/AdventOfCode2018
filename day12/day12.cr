class Garden
    getter pots, rules, leftmost_1
    @position_of_original_0 : Int32

    def initialize(
        @pots : UInt32,
        @rules : Hash(UInt32, Bool), 
    ) 
        @position_of_original_0 = @pots.to_s(2).index('1').not_nil!
    end

    def self.parse(input_lines : Array(String)) : Garden
        if /^initial state: (?<pots>[\.#]+)$/ =~ input_lines[0]
            pots = $~["pots"].gsub("#", "1").gsub(".", "0").to_u32(base = 2)
        else 
            raise "Invalid initial state line: '#{input_lines[0]}'"
        end

        rules = self.parse_rules(input_lines.skip(2))
        return Garden.new(pots, rules)
    end

    private def self.parse_rules(rule_strs : Array(String))
        rules = Hash(UInt32, Bool).new(false)
        rule_strs.each do |str|
            if /^(?<pots>[\.#]{5}) => (?<result>[\.#])$/ =~ str
                int_value = $~["pots"].gsub("#", "1").gsub(".", 0).to_u32(2)
                results_in_plant = case $~["result"]
                                   when "." then false
                                   when "#" then true
                                   else raise "Invalid rule: #{str}"
                                   end
                rules[int_value] = results_in_plant
            else
                raise "Invalid rule string: '#{str}'"
            end
        end
        return rules
    end

    def tick : Void
        bitstring = @pots.to_s(base = 2)

        # We can only ever get a new plant in a pot that's 2 spaces away from
        # the farthest-out "plant-filled" pot.
        leftmost_filled_pot = bitstring.index('1').not_nil!
        rightmost_filled_pot = bitstring.rindex('1').not_nil!
        new_pots_size = (rightmost_filled_pot + 2) - (leftmost_filled_pot - 2)

        padded_bitstring = ("00" + bitstring[leftmost_filled_pot..rightmost_filled_pot] + "00").chars
        new_bitstring = padded_bitstring.dup

        middle_index = 0
        padded_bitstring.each_cons(size = 5) do |slice|
            slice_as_uint = slice.join("").to_u32(2)
            plant_in_middle = @rules[slice_as_uint]

            new_bitstring[middle_index + 2] = plant_in_middle ? '1' : '0'
            middle_index += 1
        end
        @pots = new_bitstring.join("").to_u32(2)
        @leftmost_1 = @pots
    end

    def to_s : String
        @pots.to_s(2).gsub("1", "#").gsub("0", ".")
        # smallest_seen_pot, largest_seen_pot = @pots.keys.minmax
        # return (smallest_seen_pot..largest_seen_pot).map {|idx| @pots[idx]}.join("")
    end
end

class Day12
    @garden : Garden

    def initialize(input_lines : Array(String))
        @garden = Garden.parse(input_lines)
    end

    def solve(generation_count : Int64)
        generation_count.times do
            @garden.tick
        end
        @garden.pots.to_s(2).reverse.chars.map_with_index do |char, idx|
            if char == '1'
                idx - @garden.offset
            else
                0
            end
        end.sum
        #return @garden.pots.each_with_index.select(&.[0]).map(&.[1]).sum
    end

end

unless PROGRAM_NAME.includes?("crystal-run-spec")
    day12 = Day12.new(File.read_lines("input.txt"))
    puts "12A: #{day12.solve(20)}"
    day12 = Day12.new(File.read_lines("input.txt"))
    puts "12A: #{day12.solve(50_000_000_000)}"
end
