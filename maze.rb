require 'gosu'

$dimension = 800
$line_limit = 70

class Maze
  SIDES = {
    left: 0,
    top: 1,
    right: 2,
    bottom: 3
  }

  def initialize(start_x, start_y)
    @start_x = start_x
    @start_y = start_y
    @previous_side = nil
    @box_data = {}
    @size = 10
    @color = Gosu::Color.argb(0xff_0099FF)
    @boxes = 0
  end

  def draw
    draw_box(start_x, start_y, SIDES[:top])

    sleep(3)
  end

  private

  attr_reader :start_x, :start_y, :previous_side, :size, :box_data, :color, :boxes

  def draw_box(center_point_x, center_point_y, open_side)
    return if boxes > 7000
    @boxes += 1
    @box_data["#{center_point_x} #{center_point_y}"] = true
    sides_to_draw = SIDES.values.select { |side| side != open_side && no_box_exists?(side, center_point_x, center_point_y)}
    return if sides_to_draw.empty?
    new_open_side = sides_to_draw[rand(sides_to_draw.size)]
    new_sides = sides_to_draw.select { |side| side != new_open_side }
    new_new_side = nil
    if new_sides.size > 1 && [:heads, :tails][rand(2)] == :heads
      new_new_side = new_sides[rand(new_sides.size)]
      new_sides = new_sides.select { |side| side != new_new_side }
    end
    new_sides.each do |side|
      draw_side(side, center_point_x, center_point_y)
    end

    case new_open_side
    when SIDES[:left]
      x_coord = center_point_x - size
      y_coord = center_point_y
    when SIDES[:top]
      x_coord = center_point_x
      y_coord = center_point_y + size
    when SIDES[:right]
      x_coord = center_point_x + size
      y_coord = center_point_y
    when SIDES[:bottom]
      x_coord = center_point_x
      y_coord = center_point_y - size
    end
    draw_box(x_coord, y_coord, (new_open_side + 2) % 4)

    if !new_new_side.nil?
      case new_new_side
      when SIDES[:left]
        x_coord = center_point_x - size
        y_coord = center_point_y
      when SIDES[:top]
        x_coord = center_point_x
        y_coord = center_point_y + size
      when SIDES[:right]
        x_coord = center_point_x + size
        y_coord = center_point_y
      when SIDES[:bottom]
        x_coord = center_point_x
        y_coord = center_point_y - size
      end
      draw_box(x_coord, y_coord, (new_new_side + 2) % 4)
    end
  end

  def draw_side(side, center_point_x, center_point_y)
    new_size = size / 2
    case side
    when SIDES[:left]
      Gosu.draw_line(center_point_x - new_size, center_point_y - new_size, color, center_point_x - new_size, center_point_y + new_size, color)
    when SIDES[:top]
      Gosu.draw_line(center_point_x - new_size, center_point_y + new_size, color, center_point_x + new_size, center_point_y + new_size, color)
    when SIDES[:right]
      Gosu.draw_line(center_point_x + new_size, center_point_y + new_size, color, center_point_x + new_size, center_point_y - new_size, color)
    when SIDES[:bottom]
      Gosu.draw_line(center_point_x - new_size, center_point_y - new_size, color, center_point_x + new_size, center_point_y - new_size, color)
    end
  end

  def no_box_exists?(side, center_point_x, center_point_y)
    case side
    when SIDES[:left]
      x_coord = center_point_x - size
      y_coord = center_point_y
    when SIDES[:top]
      x_coord = center_point_x
      y_coord = center_point_y + size
    when SIDES[:right]
      x_coord = center_point_x + size
      y_coord = center_point_y
    when SIDES[:bottom]
      x_coord = center_point_x
      y_coord = center_point_y - size
    end
    box_data["#{x_coord} #{y_coord}"].nil?
  end
end

class GameWindow < Gosu::Window
  def initialize
    super 1400, 800
    self.caption = "A basic maze"
    @start_x = nil
    @start_y = nil
  end

  def update
    get_start_point
  end

  def draw
    draw_mouse_pointer
    if should_draw?
      Maze.new(@start_x, @start_y).draw
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

end
GameWindow.new.show
