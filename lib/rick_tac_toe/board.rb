require_relative 'board/cell'

class RickTacToe
  class Board
    # Size of our boxes in px
    GRID_WIDTH  = 15
    GRID_HEIGHT = 5
    BORDER_WIDTH = 5
    BORDER_HEIGHT = 2

    # Constants to make accessing cells easier
    TOP_LEFT = 0
    TOP_CENTER = 1
    TOP_RIGHT = 2
    MIDDLE_LEFT = 3
    MIDDLE_CENTER = 4
    MIDDLE_RIGHT = 5
    BOTTOM_LEFT = 6
    BOTTOM_CENTER = 7
    BOTTOM_RIGHT = 8

    # Where our status line will be displayed
    STATUS_LINE_PS1 = '> '
    STATUS_LINE_Y = (GRID_HEIGHT * 3) + (BORDER_HEIGHT * 2)
    STATUS_LINE_X = BORDER_WIDTH

    def initialize
      curses_setup!
      @window = Curses.stdscr
      @player = nil
      draw_window
    end

    def write_status(text)
      clear_status_line

      move_to_status_line
      @window.addstr(text)
    end

    def clear_status_line
      move_to_status_line
      @window.addstr(' ' * (@window.maxx - (BORDER_WIDTH + 1)))
    end

    def move_to_status_line
      @window.setpos(STATUS_LINE_Y, STATUS_LINE_X)
    end

    def draw
      @cells = create_cells
      @window.refresh
    end

    def close
      close_screen
    end

    def get_input_for_player(player)
      mousemask(BUTTON1_CLICKED|REPORT_MOUSE_POSITION)
      @player = player

      c = getch
      case c
      when KEY_MOUSE
       event = getmouse
       process_click(event) if event
      when 'q'
        raise RickTacToe::Quit
      end
    end

    def refresh
      @window.refresh
    end

    # TODO Good candidate to refactor
    # This method is getting a bit big, has a high ABC, and starting to violate SRP
    def process_click(event)
      @valid_move = false

      clicked_on_cell = cell_clicked_on(event.y, event.x)
      if clicked_on_cell
        if clicked_on_cell.empty?
          @valid_move = true
          clicked_on_cell.fill_with letter: @player
        else
          write_status('Please click on an empty cell')
        end
      else
        write_status('Please click on a cell')
      end
    end

    # Returns the +RickTacToe::Board::Cell+ the user has clicked on
    # or nil if none were clicked
    def cell_clicked_on(y, x)
      @cells.each do |cell|
        return cell if cell.point_in_cell?(y, x)
      end
      nil
    end

    def valid_move?
      @valid_move
    end

    def had_a_winning_move?
      horizontal_win? || vertical_win? || diagonal_win?
    end

    private

    def draw_window
      @window.box('#', '#', '#')
    end

    def curses_setup!
      init_screen
      start_color
      crmode
      noecho
      stdscr.keypad(true)
      curs_set(0)

      init_pair(COLOR_RED,COLOR_RED,COLOR_BLACK)
      init_pair(COLOR_BLUE,COLOR_BLUE,COLOR_BLACK)
      init_pair(COLOR_YELLOW,COLOR_YELLOW,COLOR_BLACK)
    end

    def create_cells
      [0, GRID_HEIGHT, (GRID_HEIGHT * 2)].collect { |i| create_row(i) }.flatten
    end

    def create_row(y)
      cells = []
      cells << Cell.new(window: @window, height: GRID_HEIGHT, width: GRID_WIDTH, y: y + BORDER_HEIGHT, x: BORDER_WIDTH).create
      cells << Cell.new(window: @window, height: GRID_HEIGHT, width: GRID_WIDTH, y: y + BORDER_HEIGHT, x: GRID_WIDTH + BORDER_WIDTH).create
      cells << Cell.new(window: @window, height: GRID_HEIGHT, width: GRID_WIDTH, y: y + BORDER_HEIGHT, x: GRID_WIDTH * 2 + BORDER_WIDTH).create
      cells
    end

    def horizontal_win?
      [:top, :middle, :bottom].each { |location| return true if check_row_at location }
      return false
    end

    def vertical_win?
      [:left, :center, :right].each { |location| return true if check_vertical_at location }
      return false
    end

    # TODO Make this work
    def diagonal_win?
      return false
    end

    def check_row_at(location)
      left = self.class.const_get("#{location.upcase}_LEFT")
      center = self.class.const_get("#{location.upcase}_CENTER")
      right = self.class.const_get("#{location.upcase}_RIGHT")

      return false if @cells[left].empty? || @cells[center].empty? || @cells[right].empty?
      return true if @cells[left].value == @cells[center].value && @cells[center].value == @cells[right].value
    end

    def check_vertical_at(location)
      top = self.class.const_get("TOP_#{location.upcase}")
      middle = self.class.const_get("MIDDLE_#{location.upcase}")
      bottom = self.class.const_get("BOTTOM_#{location.upcase}")

      return false if @cells[top].empty? || @cells[middle].empty? || @cells[bottom].empty?
      return true if @cells[top].value == @cells[middle].value && @cells[middle].value == @cells[bottom].value
    end
  end
end
