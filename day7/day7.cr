alias Step = Char

# A worker class, used by part B. Workers take a set amount of base time to 
# complete a step, along with additional time based on what the step is (its 
# ordinal position in the alphabet). They track whether they're ready for new
# work, and what step they're working on.
class Worker 
    @current_step : Step?
    getter current_step
    @work_time_left : Int32

    def initialize(@step_base_time : Int32)
        @current_step = nil
        @work_time_left = 0
    end

    def can_accept_new_work?
        return @work_time_left == 0
    end

    def give_work(step : Step?)
        @current_step = step
        @work_time_left = self.step_completion_time(step)
    end

    def tick
        @work_time_left -= 1 if @work_time_left > 0 # tick down the timer
    end

    private def step_completion_time(step : Step?) : Int32
        return 0 if step.nil?

        extra_time = ('A'..'Z').to_a.index(step).not_nil! + 1
        return @step_base_time + extra_time
    end
end

# A project class, used by parts A and B. The Project tracks which steps have
# been completed, which steps remain to be completed, the dependency graph of
# all steps in the project, and the total set of all steps in the project.
# Using this information, it can determine which step should be worked next,
# and when the whole project is complete.
class Project
    @completed_steps : Set(Step)
    getter completed_steps
    @incomplete_steps : Set(Step)

    def initialize(@dependencies : Hash(Step, Set(Step)), @all_steps : Set(Step))
        @completed_steps = Set(Step).new
        @incomplete_steps = @all_steps.clone
    end

    def completed?
        @completed_steps == @all_steps
    end

    def start_over
        @completed_steps = Set(Step).new
        @incomplete_steps = @all_steps.clone
    end

    # Looks for the next workable step, if any. Allows you to pass in a list of
    # steps to ignore, used in part_b to ensure we don't hand out steps that 
    # are already in progress.
    def find_next_step(ignore_list : Array(Step) = [] of Step) : Step?
        (@incomplete_steps - ignore_list)
            .select {|step| self.dependencies_are_satisfied?(step)}
            .min?
    end

    def mark_step_completed(step : Step)
        @completed_steps << step
        @incomplete_steps.delete(step)
    end

    # Utility method for debugging 
    def print_dependencies
        @all_steps.to_a.sort.each do |step|
            deps = @dependencies[step]?
            deps_str = deps == nil ? "nothing" : deps.not_nil!.join(", ")
            puts "#{step} depends on #{deps_str}"
        end
    end

    private def dependencies_are_satisfied?(step) : Bool
        deps = @dependencies[step]?
        return true if deps.nil? || deps.empty?

        # Now we're only dealing with steps that have dependencies.
        if @completed_steps.empty? 
            # if we haven't done anything, no deps can be satisfied.
            return false
        else
            return deps.all? {|dep| @completed_steps.includes?(dep) }
        end
    end

    # Parses a project from input lines of the form
    #   "Step <dependencey> must be finished before step <step> can begin."
    def self.parse_from_lines(input : Array(String))
        # Keep track of every step you've seen -- some steps will only appear as 
        # dependencies, while others will never appear as dependencies.
        all_steps = Set(Step).new 
        # Build a dependency graph (with each step defaulting to an empty set of
        # dependencies).
        deps = Hash(Step, Set(Step)).new do |hash, key| 
            hash[key] = Set(Step).new
        end
        input.each do |line|
            if /Step (?<dependency>[A-Z]) must be finished before step (?<step>[A-Z]) can begin./ =~ line
                step, dep = $~["step"].char_at(0), $~["dependency"].char_at(0)
                deps[step] << dep unless step == dep
                all_steps << step
                all_steps << dep
            else
                raise "Invalid line: '#{line}'!"
            end
        end
        return Project.new(deps, all_steps)
    end
end

# Finally, our solver class.
class Day7
    @project : Project

    def initialize(input_str : Array(String), @worker_count : Int32, @step_base_time : Int32)
        @project = Project.parse_from_lines(input_str)
    end

    # Part A problem statement: in what order do we complete the steps, without
    # any sort of "work time" or parallelization?
    def part_a : String
        @project.start_over
        until @project.completed?
            next_step = @project.find_next_step
            @project.mark_step_completed(next_step) unless next_step.nil?
        end
        return @project.completed_steps.join("")
    end

    # Part B problem statement: given 5 workers and a base completion time of 
    # 60 seconds plus the alphabet-position of the char, how long does it take
    # to complete all steps?
    def part_b : Int32
        @project.start_over
        # @project.print_dependencies

        workers = Array.new(@worker_count) { Worker.new(@step_base_time) }
        clock = 0

        until @project.completed?
            # Look for work that's just finished and mark it all completed.
            just_completed_work = 
                workers.select(&.can_accept_new_work?)
                    .map {|w| w.current_step}
                    .reject(&.nil?)
                    .map(&.not_nil!)
            just_completed_work.each {|step| @project.mark_step_completed(step)}

            # These steps are in progress, so when we ask for the next step, we 
            # should ignore them.
            steps_in_progress = 
                workers.reject(&.can_accept_new_work?)
                    .map(&.current_step)
                    .reject(&.nil?)
                    .map(&.not_nil!)

            # Look for anyone who's looking for work and give them work.
            available_workers = workers.select(&.can_accept_new_work?)
            available_workers.each do |worker|
                # If the worker just finished a step, mark it completed.
                just_finished_step = worker.current_step
                if just_finished_step
                    @project.mark_step_completed(just_finished_step)
                end

                # Now look for more work for them (or else "nothing", which means "wait")
                next_step = @project.find_next_step(ignore_list = steps_in_progress)
                worker.give_work(next_step) 
                if next_step
                    # If we gave them a step to work, then it should be marked 
                    # as "in progress" so nobody else tries to pick it up.
                    steps_in_progress << next_step
                end
            end

            # Debugging: print out the state of the world
            # workers_steps = workers.map {|w| w.current_step || '.'}
            # puts "#{clock}: #{workers_steps}, completed: #{@project.completed_steps}"


            # Check for project completion before advancing time, to avoid 
            # off-by-one errors caused by waiting until the second *after* we
            # actually finished to consider the project completed.
            unless @project.completed?
                clock += 1 # The clock ticks,
                workers.each(&.tick) # the workers work.
            end
        end

        return clock # Now return how long it took us to finish everything
    end
end

day7 = Day7.new(File.read_lines("input.txt"), workers = 5, step_base_time = 60)
puts "7A: #{day7.part_a}"
puts "7B: #{day7.part_b}"
