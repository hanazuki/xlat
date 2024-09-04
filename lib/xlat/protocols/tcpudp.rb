# frozen_string_literal: true

# This file is based on the source code available at https://github.com/kazuho/rat under MIT License
# 
# Copyright (c) 2022 Kazuho Oku
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


require 'xlat/common'
require 'xlat/protocols/icmp'

module Xlat
  module Protocols
    class Tcpudp
      include Xlat::Common

      attr_accessor :bytes, :offset
      attr_reader :src_port, :dest_port

      def initialize(packet, icmp_payload:)
        @packet = packet
        @icmp_payload = icmp_payload
      end

      def reset(bytes, offset)
        @bytes = bytes
        @offset = offset
        @src_port = nil
        @dest_port = nil
        @orig_checksum = nil
        self
      end

      def _parse
        packet = @packet
        bytes = packet.l4_bytes
        offset = packet.l4_bytes_offset

        @src_port, @dest_port = bytes.get_values([:U16, :U16], offset)
        @orig_checksum = @src_port + @dest_port

        self
      end

      def parse(...)
        reset(...)._parse
      end

      def src_port=(n)
        @src_port = n
        @bytes.set_value(:U16, @offset, n)
      end

      def dest_port=(n)
        @dest_port = n
        @bytes.set_value(:U16, @offset + 2, n)
      end

      def tuple
        @bytes.slice(@offset, 4)
      end

      def _adjust_checksum(checksum, cs_delta)
        Ip.checksum_adjust(checksum, cs_delta + @src_port + @dest_port - @orig_checksum)
      end
    end
  end
end
