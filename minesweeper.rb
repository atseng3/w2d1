#require 'debugger'
class Board
  attr_accessor :no_rows, :no_columns, :no_bombs, :board_map

  def initialize(num_rows, num_columns, num_bombs)
    @random_bombs = create_bombs(num_rows, num_columns, num_bombs)
    @board_map = create_tiles(num_rows, num_columns)
    @tiles_to_reveal, @revealed_tiles = [], []
    num_adder
    pretty_board
    @game_over = false
  end

  def pretty_board
    @board_map.each do |row|
      row.each do |tile|
        print tile.cover
      end
      puts
    end
  end

  def user_input_to_coordinates(response)
    x = response[0].to_i
    y = response[-1].to_i
    return [x,y]
  end

  def play
    until @game_over
      puts "click a tile or flag a tile? c to click, f to flag"
      response = gets.chomp.downcase
      case response
        when "c"
          puts "Select your coodinates. Please write in this format: x,y"
          response = gets.chomp
          response = [response[0].to_i, response[-1].to_i]
          reveal(@board_map[response[0]][response[1]])
        when "f"
          puts "Select your coodinates. Please write in this format: x,y"
          response = gets.chomp
          response = [response[0].to_i, response[-1].to_i]
          flag(@board_map[response[0]][response[1]])
      end
      pretty_board
    end
    p "Done"
  end

  def flag(tile)
    tile.cover = " F "
  end

  def over?
    #flag is placed on all bombs
    #player selects bomb
    #return true if tile.number == -1
  end

  def reveal(tile)
    #debugger
    @revealed_tiles << tile
    p tile
    if tile.number == -1
      @game_over = true
      return
    elsif tile.number == 0
      tile.cover = "[#{tile.number.to_s}]"
      @tiles_to_reveal += adjacent_tiles(tile).select {|found_tile| reveal_does_not_loop?(found_tile)}
    else
      tile.cover = "[#{tile.number.to_s}]"
    end
    until @tiles_to_reveal.empty?
      single_tile = @tiles_to_reveal.shift
      reveal(single_tile)
    end
  end

  def reveal_does_not_loop?(found_tile)
    return true if !@revealed_tiles.include?(found_tile) and !@tiles_to_reveal.include?(found_tile)
    return false
  end
  # def search_for(pos)
  #   @board_map.each do |row|
  #     row.each { |tile| reveal(tile) if tile.pos == pos }
  #   end
  # end

  def num_adder
    bomb_arr = []
    @board_map.each do |row|
      row.each do |tile|
        bomb_arr += row.select { |tile| tile.number == -1}
      end
    end
    bomb_arr.uniq!.each do |each_bomb|
      bomb_neighbors = adjacent_tiles(each_bomb)
      bomb_neighbors.each do |each_neighbor|
        each_neighbor.number += 1 unless each_neighbor.number == -1
      end
    end
  end

  def create_bombs(num_rows, num_columns, num_bombs)
    random_bombs = [-1] * num_bombs
    random_bombs += [0] * (num_rows * num_columns - num_bombs)
    random_bombs.shuffle!
  end

  def create_tiles(num_rows, num_columns)
    board_map = []
    (0...num_rows).each do |x|
      row_arr = []
      (0...num_columns).each do |y|
        new_tile = Tile.new([x,y],@random_bombs.shift)
        row_arr << new_tile
      end
      board_map << row_arr
    end
    board_map
  end

  def valid_pos?(tile) #check if location is legal
    #debugger
    if tile.pos[0] >= 0 and tile.pos[0] <= @board_map.length
      if tile.pos[1] >= 0 and tile.pos[1] <= @board_map.first.length
        return true
      end
    end
    false
  end

  def adjacent_tiles(tile)
    adjacent_tiles = []
    @board_map.each do |row|
      row.each do |square|
        if valid_pos?(square) and square.pos != tile.pos and near_tile?(tile, square)
          adjacent_tiles << square
        end
      end
    end
    adjacent_tiles
  end

  def near_tile?(tile, neighbor)
    tile_row = tile.pos.first
    tile_col = tile.pos.last
    n_row = neighbor.pos.first
    n_col = neighbor.pos.last
    if (tile_row-1..tile_row+1).include?(n_row) and (tile_col-1..tile_col+1).include?(n_col)
      return true
    end
    return false
  end
end

class Tile
  attr_accessor :pos, :number, :cover

  def initialize(pos, number)
    @pos = pos
    @number = number
    @cover = "[ ]"
  end
end
