Spork.prefork do
  module Tableish
    # Creates an array of array representation of an HTML table
    # If column length varies among rows, normalizes all rows to lowest common
    # number of columns to assure diffs with cucumber pass smoothly.
    # * rows: CSS selector for row elements
    # * cols: CSS selector for column elements
    def tableish( rows, cols )
      out = all(rows).map { |r| r.all(cols).map { |c| c.text.strip } }
      row_length = out.map(&:length).sort.first
      out.map { |r| r.length == row_length ? r : r[0..(row_length-1)] }
    end
  end

  World(Tableish)
end

