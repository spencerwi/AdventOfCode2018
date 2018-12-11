class Game
    getter last_marble
    # Looking up "rotate" in crystal docs lead me to "deque", which was pretty
    # educational, as I didn't have much experience with them before. Now I do.
    # Thanks, AoC! The index-0 marble is the "current marble".
    @marbles : Deque(Int32) 
    @player_scores : Array(Int64)

    def initialize(@last_marble : Int32, player_count : Int32)
        @marbles = Deque(Int32).new([0])
        @player_scores = Array(Int64).new(player_count, 0)
    end

    def self.parse(input : String)
        if /(?<players>\d+) players; last marble is worth (?<score>\d+)/ =~ input
            player_count = $~["players"].to_i
            last_marble = $~["score"].to_i
            return Game.new(last_marble, player_count)
        else
            raise "Invalid input: " + input
        end
    end

    def player_count 
        @player_scores.size
    end

    # Runs the whole game, and returns the winner's score
    def run : Int64
        (1..@last_marble).each do |marble_in_hand|
            if marble_in_hand.divisible_by?(23)
                self.remove_marbles(marble_in_hand)
            else 
                self.place_marble(marble_in_hand)
            end
        end
        return @player_scores.max
    end

    # On turns where we remove marbles (that is, for marbles whose values are
    # divisible by 23), we remove the marble seven places "counterclockwise",
    # and set the marble immediately "clockwise" as the current marble. 
    # Trial-and-error with the sample input lead me to determine that positive 
    # rotation was "counterclockwise" and negative was "clockwise".
    private def remove_marbles(marble_in_hand : Int32) 
        @marbles.rotate!(7) # shift seven places counterclockwise to grab that marble
        score = @marbles.shift + marble_in_hand # pull it out and add it to the in-hand value
        player = marble_in_hand % @player_scores.size # which player are we?
        @player_scores[player] += score # update this player's score
        @marbles.rotate!(-1) # rotate again to set the marble clockwise of the 
                             # one we removed as the "current marble"
    end

    # Placing a marble is easy, since we place it one spot clockwise of the 
    # current marble (but boy were they roundabout in their phrasing).
    private def place_marble(marble_to_place : Int32) 
        @marbles.rotate!(-1)
        @marbles.unshift(marble_to_place)
    end
end

class Day9
    @game : Game

    def initialize(input : String)
        @game = Game.parse(input)
    end

    # Part A problem statement: what's the highest score seen in the game?
    # Since scores monotonically increase, this amounts to "what's the winner's
    # score?"
    def part_a : Int64
        @game.run
    end

    # Part B problem statement: same thing, but with a much longer game (last 
    # marble is 100 times larger, so 100 times as many turns).
    def part_b : Int64
        # Clone the existing game, but with a 100-times-larger last-marble
        longer_game = Game.new(@game.last_marble * 100, @game.player_count)
        longer_game.run
    end
end

unless PROGRAM_NAME.includes?("crystal-run-spec")
    day9 = Day9.new(File.read("input.txt"))
    puts "9A: #{day9.part_a}"
    puts "9B: #{day9.part_b}"
end
