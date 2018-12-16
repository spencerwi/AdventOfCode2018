require "../src/a-star"
require "colorize"

# Search path in a grid
# Path => 'X', Obstacle => '#', Opening => '.', Known (Visited Nodes) => 'O'
# Only possible directions to move is top, right, bottom, left
# Note: Obstacles are placed randomly, therefore the grid may not be solvable.

enum Type
  Opening
  Obstacle
  Path
  Known
end

obstacle_count = 120
grid_size = 20
grid = Array.new(grid_size ** 2) { |i| AStar::Node.new({:x => i % grid_size, :y => i / grid_size, :type => Type::Opening}) }

# Create obstacles
obstacles = grid.sample obstacle_count
obstacles.map! do |obstacle|
  obstacle.data[:type] = Type::Obstacle
  obstacle
end

# grid[5].data[:type] = Type::Obstacle
# grid[51].data[:type] = Type::Obstacle

# Set start and end node
grid.first.data[:type] = Type::Opening
grid.last.data[:type] = Type::Opening

# Connect grid elements
grid.each do |node|
  next if node.data[:type].as(Type).obstacle?
  x = node.data[:x].as(Int32)
  y = node.data[:y].as(Int32)

  # right
  if x < grid_size - 1 && (other = grid[(x + 1) + (grid_size*y)]).data[:type].as(Type).opening?
    node.connect other.not_nil!, 5
  end
  # left
  if x > 0 && (other = grid[(x - 1) + grid_size*y]).data[:type].as(Type).opening?
    node.connect other.not_nil!, 5
  end
  # bottom
  if y > 0 && (other = grid[x + grid_size*(y - 1)]).data[:type].as(Type).opening?
    node.connect other.not_nil!, 5
  end
  # top
  if y < grid_size - 1 && (other = grid[x + grid_size*(y + 1)]).data[:type].as(Type).opening?
    node.connect other.not_nil!, 5
  end
end

# Search for path
path = AStar.search grid.first, grid.last do |node1, node2|
  puts "\e[H\e[2J"
  node1.data[:type] = Type::Known
  draw grid, AStar.reconstruct_path(node1)
  sleep 0.1
  Math.sqrt(((node1.data[:x].as(Int32) - node2.data[:x].as(Int32))**2) + ((node1.data[:y].as(Int32) - node2.data[:y].as(Int32))**2)) * 10
end

# Draw grid to console
def draw(grid, path)
  path.map! do |path_point|
    path_point.data[:type] = Type::Path
    path_point
  end

  grid.each do |node|
    case node.data[:type]
    when Type::Opening
      print '.'
    when Type::Obstacle
      print '#'.colorize(:light_yellow)
    when Type::Path
      print 'X'.colorize(:green)
    else
      print 'O'.colorize(:red)
    end
    puts if node.data[:x] == Math.sqrt(grid.size) - 1
  end
  # Reset path nodes after drawing
  path.map! do |path_point|
    path_point.data[:type] = Type::Known
    path_point
  end
end

if path
  puts "\e[H\e[2J"
  draw grid, path
  puts "Path found!"
else
  puts "No path found!"
end
