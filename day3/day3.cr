# Some convenience aliases for dealing with the cloth: 
alias Cell = Set(Int32) # a cell is a set of claim ids (that is, who's claimed this inch of cloth),
alias Row = Array(Cell) # a row is an array of cells,
alias ClaimsMap = Array(Row) # the cloth "claims map" is an array of rows

# And a couple of convenience classes: 
# a "Point" to represent an individual x/y pair independent of the claims map array,
struct Point 
    getter x, y
    def initialize(@x : Int32, @y : Int32) end
end
# and a "Claim" to represent the region described by each claim.
class Claim 
    @_points : Set(Point)?
    getter top_left, bottom_right

    def initialize(@id : Int32, @top_left : Point, @bottom_right : Point)
    end

    # Generates a full set of the distinct points claimed by this, well, claim
    def points : Set(Point)
        if @_points == nil # lazy-initialization, yo
            xs = @top_left.x..@bottom_right.x
            ys = @top_left.y..@bottom_right.y
            @_points = xs.flat_map do |x|
                ys.map { |y| Point.new(x, y) }
            end.to_set
        end
        return @_points.not_nil!
    end

    # Applies the claim to the claims_map, by adding its id to the set of claims in 
    # the claimed cells, modifying the claims_map in-place
    def apply_to_claims_map(claims_map : ClaimsMap)
        self.points.each do |point|
            claims_map[point.y][point.x] << @id
        end
    end

    # Parses a string of the form "#1 @ x1,y1: WxH" into a Claim
    def self.parse(claim_string : String) : Claim
        pound_id, top_left_and_size = claim_string.split(" @ ")
        id = pound_id.sub("#", "").to_i

        top_left_coords, size = top_left_and_size.split(": ")
        x, y = top_left_coords.split(",").map {|coord| coord.to_i}
        top_left = Point.new(x, y)

        width, height = size.split("x").map {|size| size.to_i}
        bottom_right = Point.new(
            x + width - 1, # subtract one because the top-left cell is included 
            y + height - 1 # in the width/height of each claim
        )

        return Claim.new(id, top_left, bottom_right)
    end
end

# And now, the "solver" class
class Day3
    @input : Array(Claim)
    @claims_map : ClaimsMap

    def initialize(input_str : Array(String))
        # Parse input into claims
        @input = input_str.map {|line| Claim.parse(line)}

        # Build our 2D-array "claims map" that will list the distinct claims 
        # made on a given cell, since a finished "claims map" will be needed
        # by both part A and part B. Each cell is pre-populated with an empty 
        # set of claim ids.
        @claims_map = Array.new(1000) do 
            Array.new(1000) { Set(Int32).new }
        end

        # Now apply each claim to the claims map to "fill it out".
        @input.each {|region| region.apply_to_claims_map(@claims_map)}
    end

    # Part A problem statement: find how many cells are claimed at least twice
    def part_a : Int32
        return @claims_map.flat_map {|row| row} # get a flat array of every cell
            .select {|cell| cell.size > 1} # filter out ones that were only claimed once
            .size # and see how many are left
    end

    # Part B problem statement: find the ID of the only claim with no overlaps
    def part_b: Int32
        multi_claims, single_claims = @claims_map.flat_map {|row| row} # again, get a flat array of every cell
            .reject {|cell| cell.empty?} # filter out unclaimed cells
            .partition {|cell| cell.size > 1} # split into multi-claimed and single-claimed cells

        unshared_claim = 
            single_claims.map {|cell| cell.to_a[0]} # get the claim ids from all singly-claimed cells
                .uniq # dedupe
                .reject do |claim_id| # filter out any claims who have a multi-claimed cell
                    multi_claims.any? {|cell| cell.includes?(claim_id)}
                end.first # there should be exactly one
        return unshared_claim.not_nil!
    end
end

day3 = Day3.new(File.read_lines("input.txt"))
puts "3A: #{day3.part_a}"
puts "3B: #{day3.part_b}"
