require "gosu"

class GameWindow < Gosu::Window
  def initialize
    super 1400, 800
    self.caption = "A basic maze"
    @start_x = nil
    @start_y = nil
    @width = 40
    @height = 40
    @size = 15
    @color = Gosu::Color.argb(0xff_0099FF)
  end

  def update
    get_start_point
  end

  def draw
    draw_mouse_pointer
    if should_draw?
      grid = Backtracker.new(width, height).run
      draw_grid(grid)
      sleep(3)
    end
  end

  def draw_grid(grid)
    height.times do |y|
      width.times do |x|
        grid[y][x].walls.each do |wall|
          case wall
          when :north
            x_start = x * size
            x_end = (x * size) + size
            y_start = y * size
            y_end = y * size
          when :east
            x_start = (x * size) + size
            x_end = (x * size) + size
            y_start = y * size
            y_end = (y * size) + size
          when :south
            x_start = x * size
            x_end = (x * size) + size
            y_start = (y * size) + size
            y_end = (y * size) + size
          when :west
            x_start = x * size
            x_end = x * size
            y_start = y * size
            y_end = (y * size) + size
          end
          Gosu.draw_line(start_x + x_start, start_y + y_start, color, start_x + x_end, start_y + y_end, color)
        end
      end
    end
  end

  def get_start_point
    if Gosu::button_down? Gosu::MsLeft
      @start_x = mouse_x
      @start_y = mouse_y
    end
  end

  def draw_mouse_pointer
    color = Gosu::Color::WHITE
    draw_quad(
      mouse_x - 5,
      mouse_y - 5,
      color,
      mouse_x + 5,
      mouse_y - 5,
      color,
      mouse_x + 5,
      mouse_y + 5,
      color,
      mouse_x - 5,
      mouse_y + 5,
      color
    )
  end

  def should_draw?
    @start_x && @start_y
  end

  private

  attr_reader :width, :height, :start_x, :start_y, :size, :color
end

class Backtracker
  OFFSETS = {
    north: {
      x_offset: 0,
      y_offset: -1
    },
    east: {
      x_offset: 1,
      y_offset: 0
    },
    south: {
      x_offset: 0,
      y_offset: 1
    },
    west: {
      x_offset: -1,
      y_offset: 0
    }
  }

  OPPOSITES = {
    north: :south,
    east: :west,
    south: :north,
    west: :east
  }

  def initialize(width, height)
    @grid = Array.new(height) { Array.new(width) { GridSquare.new } }
    @width = width
    @height = height
  end

  def run
    try_square(0, 0)
    grid
  end

  private

  attr_reader :width, :height, :grid

  def try_square(x_coordinate, y_coordinate)
    current_square = grid[y_coordinate][x_coordinate]
    current_square.visit

    OFFSETS.keys.shuffle.each do |wall|
      new_x_coordinate = x_coordinate + OFFSETS[wall][:x_offset]
      new_y_coordinate = y_coordinate + OFFSETS[wall][:y_offset]

      if eligible?(new_x_coordinate, new_y_coordinate)
        current_square.remove_wall(wall)
        grid[new_y_coordinate][new_x_coordinate].remove_opposite_wall(wall)
        try_square(new_x_coordinate, new_y_coordinate)
      end
    end
  end

  def eligible?(x_coordinate, y_coordinate)
    x_coordinate >= 0 &&
    x_coordinate < width &&
    y_coordinate >= 0 &&
    y_coordinate < height &&
    grid[y_coordinate][x_coordinate].not_visited?
  end
end

class GridSquare
  attr_reader :walls

  def initialize
    @visited = false
    @walls = [
      :north,
      :east,
      :south,
      :west
    ]
  end

  def not_visited?
    visited == false
  end

  def visit
    @visited = true
  end

  def remove_wall(wall)
    walls.delete(wall)
  end

  def remove_opposite_wall(wall)
    remove_wall(Backtracker::OPPOSITES[wall])
  end

  private

  attr_reader :visited
end

GameWindow.new.show
