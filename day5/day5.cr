##
# Given an input string, we need to examine the lengths of "fully-reacted" 
# versions of that string. Reactions occur when an uppercase and lowercase
# version of the same letter occur side-by-side, and result in both chars
# being eliminated from the string. "Fully reacting" a string means repeating
# this process until you reach an equilibrium point where no more reactions
# will occur. 
##
class Day5
    def initialize(@input : String)
    end

	# Part A problem statement: Find the length of the input when fully reacted.
    def part_a : Int32
		react_fully(@input)
    end

	# Part B problem statement: Find the shortest length attainable by removing
	# all occurences of a single letter (uppercase or lowercase) and then fully
	# reacting the result.
	def part_b : Int32
		('A'..'Z').min_of do |letter| 
			without_letter = @input.gsub(letter.upcase, "").gsub(letter.downcase, "")
			react_fully(without_letter)
		end
	end

	private def react_fully(word_to_reduce)
        result, reactions_occurred = self.run_reactions(word_to_reduce)
        while reactions_occurred # stop once we've hit equilibrium
			result, reaction_count = self.run_reactions(result)
        end
        return result.size
	end

    private def run_reactions(word : String) : Tuple(String, Bool)
		# For every letter in the alphabet, remove all reactive pairs (adjacent 
		# uppercase+lowercase and lowercase+uppercase
		new_word = ('A'..'Z').map(&.to_s).reduce(word) do |word, char|
			word.gsub(char + char.downcase, "")
				.gsub(char.downcase + char, "")
		end
		reactions_occurred = (word.size != new_word.size)
        return {new_word, reactions_occurred}
    end
end

day5 = Day5.new(File.read("input.txt").gsub("\n", ""))
puts "5A: #{day5.part_a}"
puts "5B: #{day5.part_b}"
