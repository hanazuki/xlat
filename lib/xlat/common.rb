module Xlat
  module Common
    module_function

    def sum16be(buffer, offset = 0, count = (buffer.size - offset) / 2)
      sum = 0
      buffer.each(:U16, offset, count) do |_, x|
        sum += x
      end
      sum
    end
  end
end
