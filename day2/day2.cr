class Day2

    def initialize(@input : Array(String))
    end

    def part_a : Int32
        two_rep_count, three_rep_count = 0, 0
        @input.each do |word|
            if self.has_a_letter_exactly_n_times(word, 2)
                two_rep_count += 1
            end
            if self.has_a_letter_exactly_n_times(word, 3)
                three_rep_count += 1
            end
        end
        return two_rep_count * three_rep_count
    end

    def part_b : Array(Char)
        word1, word2 = nil, nil
        @input.each_combination(size = 2) do |combination|
            possible_word1, possible_word2 = combination
            if self.words_match(possible_word1, possible_word2)
                word1 = possible_word1
                word2 = possible_word2
                break
            end
        end
        if word1 != nil && word2 != nil
            return self.find_common_letters(word1.not_nil!, word2.not_nil!)
        else
            raise "No matching words found! Something must be wrong with the input."
        end
    end

    private def has_a_letter_exactly_n_times(word : String, n : Int32) : Bool
        word.chars
            .group_by {|itself| itself}
            .any? {|char, occurrences| occurrences.size == n}
    end

    private def words_match(word1 : String, word2 : String) : Bool
        return false if word1.size != word2.size 
        difference_counter = 0
        word1.chars.zip(word2.chars) do |c1, c2|
            difference_counter += 1 if c2 != c1
            break if difference_counter > 1
        end
        return difference_counter <= 1
    end

    private def find_common_letters(word1 : String, word2 : String) : Array(Char)
        common_letters = [] of Char
        word1.chars.zip(word2.chars) do |c1, c2|
            common_letters << c1 if c1 == c2
        end
        return common_letters
    end
end
        
    

day2 = Day2.new(File.read_lines("input.txt"))
puts "2A: #{day2.part_a}"
puts "2B: #{day2.part_b.join}"
