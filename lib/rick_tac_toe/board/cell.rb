class RickTacToe
  class Board
    class Cell
      attr_reader :value

      def initialize(window:, height:, width:, y:, x:)
        @window = window
        @height = height
        @width  = width
        @y = y
        @x = x
        @value = nil
      end

      def create
        @subwindow = @window.subwin(@height, @width, @y, @x)
        attron(color_pair(COLOR_YELLOW)|A_NORMAL){ @subwindow.box('|', '-') }
        self
      end

      def point_in_cell?(y, x)
        true if(y < max_y && y > min_y && x > min_x && x < max_x)
      end

      def fill_with(letter:)
        @value = letter
        @subwindow.setpos(@subwindow.maxy / 2, @subwindow.maxx / 2)
        @subwindow.addstr(letter)
        @subwindow.refresh
      end

      def empty?
        @value.nil?
      end

      private

      def center
        { y: max_y / 2, x: max_x / 2 }
      end

      def min_x
        @x
      end

      def max_x
        @x + @width
      end

      def min_y
        @y
      end

      def max_y
        @y + @height
      end
    end
  end
end
