alias GuardId = Int32 # just for readability
class Day4
    @input : Array(String)

    # A mapping from GuardId to how long that guard slept
    @sleep_totals_by_guard : Hash(GuardId, Int32)
    # A mapping from GuardId to a "minutes array" of how many times that guard 
    # slept through that minute
    @sleep_log_by_guard : Hash(GuardId, Array(Int32))

    def initialize(input_str : Array(String))
        @input = input_str.sort # the file has loglines out-of-order
        @sleep_totals_by_guard = Hash(GuardId, Int32).new(default_value = 0)
        @sleep_log_by_guard = Hash(GuardId, Array(Int32)).new do
            # Provide the default value: an array where each index corresponds 
            # to a minute (so arr[32] is minute 32 of each hour), and the value
            # corresponds to how many times the guard slept through that minute.
            Array(Int32).new(60, 0) 
        end
        self.run_log_lines
    end

    # Problem statement: Find the guard who slept the longest, and the minute
    # they most often slept through, and multiply guard_id by minute.
    def part_a : Int32
        sleepiest_guard, _ = @sleep_totals_by_guard.max_by {|guard_id, sleep_time| sleep_time}
        sleep_times_for_guard : Array(Int32) = @sleep_log_by_guard[sleepiest_guard]
        most_often_slept_minute = sleep_times_for_guard.index(sleep_times_for_guard.max).not_nil!

        return sleepiest_guard * most_often_slept_minute
    end

    # Problem statement: Find the guard who most often slept on the same minute, 
    # and what that minute was, and multiply guard_id by minute.
    def part_b : Int32
        # Thankfully, with our "minutes array", this is easy: the sleep log 
        # tells us how many times each guard slept through each minute, so just
        # find the guard with the highest "sleep_count" for the same minute, and
        # then find that minute, and multiply!
        most_predictable_guard, _ = @sleep_log_by_guard.max_by {|guard_id, sleep_log| sleep_log.max}
        guard_sleep_log = @sleep_log_by_guard[most_predictable_guard]
        minute = guard_sleep_log.index(guard_sleep_log.max).not_nil!

        return most_predictable_guard * minute
    end

    private def run_log_lines
        current_guard = nil
        last_logged_time = nil # keep track of the last logged time so we can figure out sleep ranges
        @input.each do |log_line|
            time_str, msg = log_line.split("] ")
            # Parse out the timestamp on this log message
            current_time = Time.parse(
                time_str.lstrip('['),
                "%Y-%m-%d %H:%M",
                Time::Location.load("UTC")
            )

            case msg[0, 5]
            when "Guard" then current_guard = msg[/\d+/].to_i
            when "wakes" then
                # Thankfully, once sorted, "wakes" *always* comes after 
                # "falls asleep" and "begins duty", so we always have a guard, 
                # and they were always asleep before waking up. So we just need 
                # to update the guard's sleep log and sleep total.

                # First, figure out how long they slept and update their toal.
                sleep_span = current_time - (last_logged_time || current_time)
                @sleep_totals_by_guard[current_guard.not_nil!] += sleep_span.minutes

                # Now, update their sleep log, by first grabbing their log
                sleep_log = @sleep_log_by_guard[current_guard.not_nil!]
                # then "stepping through" the minutes between when they fell 
                # asleep and when they woke up, incrementing each minute for 
                # each time they slept through it.
                step_time = last_logged_time.not_nil!
                while step_time <= current_time
                    sleep_log[step_time.minute] += 1
                    step_time += Time::Span.new(0, 0, 1) # increment by one minute
                end
                @sleep_log_by_guard[current_guard.not_nil!] = sleep_log
            end

            last_logged_time = current_time
        end
    end

end

unless PROGRAM_NAME.includes?("crystal-run-spec")
    day4 = Day4.new(File.read_lines("input.txt"))
    puts "4A: #{day4.part_a}"
    puts "4B: #{day4.part_b}"
end
