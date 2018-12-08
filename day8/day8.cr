# A "cursor" class to keep track of where we are in the input. This structure
# is basically what some parser-combinator libs (like OCaml's Angstrom or 
# Haskell's Parsec) call the "state". In angstrom, this is (int * 'a) state
class ParseCursor
    def initialize(@input : Array(Int32), @offset : Int32 = 0)
    end

    def has_next? : Bool
        @offset < @input.size
    end

    def next : Int32
        current = @input[@offset]
        @offset += 1
        return current
    end
end

class Node
    def initialize(@children : Array(Node), @metadata : Array(Int32))
    end

    # Recursively sum the metadata of yourself and all children.
    def metadata_sum : Int32
        self_sum = @metadata.sum(0)
        child_sum = @children.reduce(0) {|total, child| total + child.metadata_sum}
        return self_sum + child_sum
    end

    # The "value" of a node, as defined in the problem. 
    def value : Int32
        if @children.empty? 
            # If a node has no children, its value is the sum of its metadata
            @metadata.sum(0)
        else
            # If a node has children, each metadata entry is an index-pointer 
            # to one of its children, and the value of the node is the sum
            # of the values of its children.
            @metadata.compact_map {|entry| @children[entry - 1]?}
                .map {|entry| entry.value.as(Int32)} # Crystal compiler needed help here
                .sum(0)
        end
    end

    # Parsing is a recursive algorithm that requires keeping track of our 
    # position scanning through the input array, so we make that part private
    # and expose a "friendlier" API for parsing a node.
    def self.parse(input : Array(Int32))
        node = Node.parse_helper(ParseCursor.new(input, 0))
        return node
    end

    # This is the ugly part: recursive parsing, where we continually pass 
    # through our "cursor" into the input array. 
    #
    # Basically, you advance through the input *strictly forward*, pulling off 
    # the child count and metadata count (since you know those will always be 
    # present), then parsing each of the children recursively, then pull off 
    # what's left as the metadata entries. 
    # 
    # We pass through the same instance of the ParseCursor class (which is
    # just {current_index, input} in pass-by-reference form) to keep track of
    # our "scan position" when we call this same method recursively to parse 
    # children, so that we can tell each "child call" where to start and know
    # where to resume back in the "parent call". That's more or less how 
    # parser-combinator libraries like OCaml's Angstrom (or more famously 
    # Haskell's Parsec) work.    
    # 
    # Originally I thought about bringing in a parser-combinator lib, but then
    # I figured I'd rather keep "lightweight" by avoiding dependencies. So I 
    # just read up on how Angstrom works and read a Crystal port of Parsec and 
    # went from there.
    protected def self.parse_helper(cursor : ParseCursor) : Node?
        return nil unless cursor.has_next? # handle end-of-input gracefully

        # We're always going to have children_count and metadata_count, so grab
        # those first.
        children_count = cursor.next
        metadata_count = cursor.next
        children = [] of Node
        metadata = [] of Int32

        # Parse all the children *first* (if there are any), then grab metadata 
        # afterwards. It's the only way to ensure that you're grabbing the 
        # correct elements as metadata.
        children_count.times do 
            child = Node.parse_helper(cursor)
            children << child unless child.nil?
        end

        # Now grab the metadata, since the children are safely out of the way.
        metadata_count.times do 
            metadata << cursor.next
        end

        # Et voila! Our tree is parsed! If that seems too simple, start from
        # the base case (no children) and work your way up. 
        # If 0 children, then no iteration through either of the .times loops. 
        # If 1 child, grab headers, then grab child, then grab metadata, and done. 
        # This holds true for N > 1 too. Recursion!
        return Node.new(children, metadata)
    end
end

class Day8
    @root : Node?

    def initialize(input : Array(Int32))
        @root = Node.parse(input)
    end

    # Part A problem statement: find the sum of all metadata elements
    def part_a
        @root.not_nil!.metadata_sum
    end

    # Part B problem statement: find the value of the root node.
    # see `Node#value` for how that's defined.
    def part_b
        @root.not_nil!.value
    end
end

day8 = Day8.new(File.read("input.txt").split.map(&.to_i))
puts "8A: #{day8.part_a}"
puts "8B: #{day8.part_b}"
