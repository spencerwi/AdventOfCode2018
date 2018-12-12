class Rule
    getter pattern
    getter? results_in_plant
    def_equals @pattern, @results_in_plant

    def initialize(@pattern : String, @results_in_plant : Bool)
    end

    def self.parse(str : String) : Rule
        if /^(?<pots>[\.#]+) => (?<result>[\.#])$/ =~ str
            pattern = $~["pots"]
            results_in_plant = case $~["result"]
                               when "." then false
                               when "#" then true
                               else raise "Invalid rule: #{str}"
                               end
            return Rule.new(pattern, results_in_plant)
        else
            raise "Invalid rule string: '#{str}'"
        end
    end

    def matches?(pots : String) : Bool
        return pots == @pattern
    end
end


class Garden
    getter pots, rules

    def initialize(
        @pots : Hash(Int32, Char),
        @rules : Array(Rule), 
    ) 
    end

    def self.parse(input_lines : Array(String)) : Garden
        pots = Hash(Int32, Char).new('.')
        if /^initial state: (?<pots>[\.#]+)$/ =~ input_lines[0]
            $~["pots"].chars.each_with_index do |c, idx|
                pots[idx] = c
            end
        else 
            raise "Invalid initial state line: '#{input_lines[0]}'"
        end

        rules = input_lines.skip(2).map {|line| Rule.parse(line)}
        return Garden.new(pots, rules)
    end

    def tick : Void
        current_pot_state = @pots.clone
        leftmost_filled_pot, rightmost_filled_pot = @pots.select{|idx, c| c == '#'}.keys.minmax

        # We can only ever get a new plant in a pot that's 2 spaces away from
        # the farthest-out "plant-filled" pot.
        range_to_examine = (leftmost_filled_pot - 2)..(rightmost_filled_pot + 2)
        range_to_examine.each do |center_pot_index|
            first_pot = center_pot_index - 2
            last_pot = center_pot_index + 2
            pot_group = (first_pot..last_pot).map {|idx| current_pot_state.fetch(idx, '.')}.join("")

            matching_rule = @rules.find(&.matches?(pot_group))
            new_plant_state = if matching_rule && matching_rule.results_in_plant?
                                  '#'
                              else
                                  '.'
                              end

            @pots[center_pot_index] = new_plant_state
        end
    end

    def to_s : String
        smallest_seen_pot, largest_seen_pot = @pots.keys.minmax
        return (smallest_seen_pot..largest_seen_pot).map {|idx| @pots[idx]}.join("")
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
        return @garden.pots.select {|idx, c| c == '#'}.keys.sum
    end

end

unless PROGRAM_NAME.includes?("crystal-run-spec")
    day12 = Day12.new(File.read_lines("input.txt"))
    puts "12A: #{day12.solve(20)}"
    day12 = Day12.new(File.read_lines("input.txt"))
    puts "12A: #{day12.solve(50_000_000_000)}"
end
