alias X = Int32
alias Y = Int32
alias Coords = Tuple(X, Y)

enum Cell
    Open,
    Trees,
    Lumberyard

    def to_char
        case self
        when Open then '.'
        when Trees then '|'
        when Lumberyard then '#'
        end
    end

    def self.parse(c : Char)
        case c
        when '.' then Open
        when '|' then Trees
        when '#' then Lumberyard
        else raise "Unrecognized char: '#{c}'"
        end
    end
end

class Forest
    @grid : Array(Array(Cell))
    @lumberyard_count : Int32
    @wooded_acres : Int32

    def initialize(lines : Array(String))
        @grid = lines.map do |row|
            row.chars.map {|c| Cell.parse(c)}
        end
        @lumberyard_count = 0
        @wooded_acres = 0
        @grid.each do |row|
            row.each do |cell| 
                @wooded_acres += 1 if cell.trees?
                @lumberyard_count += 1 if cell.lumberyard?
            end
        end
    end

    def tick
        new_grid_state = @grid.map_with_index do |row, y|
            row.map_with_index do |cell, x|
                neighbors = self.neighbors({x, y})
                neighbor_type_counts = neighbors.group_by {|x, y| @grid[y][x]}
                    .map do |type, occurrences|
                        {type, occurrences.size}
                    end.to_h

                if cell.open? && neighbor_type_counts.fetch(Cell::Trees, 0) >= 3
                    @wooded_acres += 1
                    Cell::Trees
                elsif cell.trees? && neighbor_type_counts.fetch(Cell::Lumberyard, 0) >= 3
                    @wooded_acres -= 1
                    @lumberyard_count += 1
                    Cell::Lumberyard
                elsif cell.lumberyard?
                    nearby_lumberyards = neighbor_type_counts.fetch(Cell::Lumberyard, 0) 
                    nearby_trees = neighbor_type_counts.fetch(Cell::Trees, 0)
                    if nearby_trees >= 1 && nearby_lumberyards >= 1
                        Cell::Lumberyard
                    else
                        @lumberyard_count -= 1
                        Cell::Open
                    end
                else
                    @grid[y][x]
                end
            end
        end
        @grid = new_grid_state
    end

    def score : Int32
        @wooded_acres * @lumberyard_count
    end

    def to_s : String
        @grid.map do |row|
            row.map(&.to_char).join("")
        end.join("\n")
    end

    private def neighbors(coords : Coords) : Array(Coords)
        x, y = coords
        return [
            {x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1}, # top row
            {x - 1, y    },             {x + 1, y    }, # left and right
            {x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}, # bottom row
        ].select {|coord| self.is_in_bounds?(coord)}
    end

    private def is_in_bounds?(coords : Coords)
        x, y = coords

        return false if x < 0 || y < 0
        return false if x >= @grid[0].size
        return false if y >= @grid.size

        return true
    end
end

class Day18
    @forest : Forest

    def initialize(lines : Array(String))
        @forest = Forest.new(lines)
    end

    def part_a : Int32
        10.times { @forest.tick }
        @forest.score
    end

    def part_b : Int32?
        scores_seen = [@forest.score]
        repeat_count = 0 # to rule out false-positive repeats
        (1..1_000_000_000).each do |minute|
            @forest.tick 
            if scores_seen.includes?(@forest.score)
                seen_minute = scores_seen.index(@forest.score)
                repeat_count += 1
            else
                repeat_count = 0
            end
            scores_seen << @forest.score

            if repeat_count > 5 # the odds of this happening outside of a "true" loop are low
                print "We're looping! " 
                current_loop_start = minute - 4
                loop_first_element = scores_seen[current_loop_start]
                last_complete_loop_start = scores_seen.index(loop_first_element).not_nil!
                last_complete_loop_end = current_loop_start - 1
                score_loop =  scores_seen[last_complete_loop_start..last_complete_loop_end]
                loop_size = score_loop.size
                puts "The last complete loop started at minute #{last_complete_loop_start} and ended at minute #{last_complete_loop_end}."
                print "The complete loop is: #{score_loop}, "
                puts "for a loop size of #{loop_size}."

                # Now we extrapolate.
                # Figure out the remaining minutes from when the loop started until the end
                minutes_from_loop_start_until_end_of_time = 1_000_000_000 - last_complete_loop_start

                # Then get the position in the loop we would have ended at
                ending_step = minutes_from_loop_start_until_end_of_time % loop_size

                # Then get the loop element at that position
                return score_loop[ending_step]
            end
        end
    end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
    day18 = Day18.new(File.read_lines("input.txt"))
    puts "18A: #{day18.part_a}"
    day18 = Day18.new(File.read_lines("input.txt")) # reset state by re-reading input
    puts "18B: #{day18.part_b}"
end
