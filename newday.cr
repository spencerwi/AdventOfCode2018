def generate_day(day : Int32)
    if Dir.exists?("day#{day}")
        puts "Day #{day} already exists!"
        exit 1
    end

    Dir.mkdir("day#{day}")

    # Write solution file 
    File.write(
        "day#{day}/day#{day}.cr", 
        <<-CONTENT
        class Day#{day}
            def initialize(input_str : String)
                # TODO: this!
            end

            def part_a
                # TODO: this!
            end
        end

        unless PROGRAM_NAME.includes?("crystal-run-spec")
            day#{day} = Day#{day}.new(File.read("input.txt"))
            puts "#{day}A: \#{day#{day}.part_a}"
        end
        CONTENT
      )

    Dir.mkdir("day#{day}/spec")

    # Write spec file 
    File.write(
        "day#{day}/spec/day#{day}_spec.cr", 
        <<-CONTENT
        require "../day#{day}"
        require "spec"

        describe Day#{day} do

            describe "#part_a" do 
                it "behaves correctly for sample input" do
                end
            end

        end
        CONTENT
      )
end

if ARGV.size == 1
    generate_day(ARGV[0].to_i)
else
    puts "Usage: newday.cr DAYNUMBER"
    exit 1
end
