require 'curses'

require_relative 'rick_tac_toe/board'

include Curses

class RickTacToe
  class Quit < StandardError; end

  PLAYERS = %w(X O)

  def initialize
    @board = RickTacToe::Board.new
    @player = PLAYERS[0]
  end

  def play
    @board.draw

    @board.write_status("Welcome to Rick Tac Toe. Player #{@player} - click on a box to begin")

    until game_over?
      @board.get_input_for_player @player

      if @board.valid_move?
        if @board.had_a_winning_move?
          @board.write_status("Player #{@player} wins!")
          @board.refresh
          sleep(2)
          break
        else
          @player = next_player
          @board.write_status("Player #{@player} - click on a box")
        end
      end


    end
  rescue Quit
    @board.close
    puts 'Goodbye'
  end

  def game_over?
    false
  end

  def next_player
    @player == PLAYERS[0] ? PLAYERS[1] : PLAYERS[0]
  end
end
