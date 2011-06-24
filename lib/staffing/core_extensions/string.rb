module Staffing
  module CoreExtensions
    module String

      LOCAL_AREA_CODE = 607

      def to_phone(style=nil)
        normal = gsub /[^0-9]/, ''
        normal = "#{LOCAL_AREA_CODE}#{normal}" if normal.length == 7
        case style
        when :dotty
          return self unless normal.length == 10
          "#{normal[0..2]}.#{normal[3..5]}.#{normal[6..9]}"
        when :pretty
          return self unless normal.length == 10
          "(#{normal[0..2]}) #{normal[3..5]}-#{normal[6..9]}"
        when :normal
          normal
        else
          self
        end

      end
    end
  end
end

class String
  include Staffing::CoreExtensions::String
end

