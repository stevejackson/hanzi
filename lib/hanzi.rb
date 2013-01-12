# encoding: utf-8

class Hanzi
  class << self
    attr_accessor :data

    def load_data
      return if @data
      @data = []

      file_path = File.expand_path('../../lib/data/cedict_ts.u8', __FILE__)
      File.open(file_path).each_line do |line|
        next if line.start_with?('#')
        line = line.force_encoding('utf-8')

        # CC-CEDICT format:
        # Traditional Simplified [pin1 yin1] /English equivalent 1/equivalent 2/
        line_data = {}
        line_data[:traditional] = line[0, line.index(' ')]

        line = line[line.index(' ') + 1, line.length]
        line_data[:simplified] = line[0, line.index(' ')]

        line = line[line.index('['), line.length]
        line_data[:pinyin] = line[1, line.index(']') - 1].downcase

        line = line[line.index('/'), line.rindex('/')]
        line_data[:english] = line[1, line.rindex('/') - 1]

        @data << line_data
      end

    end

    def to_pinyin(text, options={})
      load_data if @data.nil?

      result = ''
      pos = 0

      loop do
        char = text[pos]
        break if !char

        if char.ord < 0x4E00 || char.ord > 0x9FFF
          # it's not a chinese character.
          result << char
          pos += 1
        else
          # it's a chinese character. start by trying to find a long word match,
          # and if it fails, all the way down to a single hanzi.
          match = nil
          match_length = 0
          4.downto(1) do |length|
            match = find_hanzi_match(text[pos, length])
            match_length = length
            break if match
          end

          if match
            result << match[:pinyin].gsub("\s", '')
            pos += match_length
          else
            result << char
            pos += 1
          end
        end
      end

      result
    end

    def to_english(text)
      load_data if @data.nil?

      entry = find_hanzi_match(text)
      entry[:english] if entry && entry[:english]
    end

    def to_simplified(text)
      load_data if @data.nil?

      entry = find_hanzi_match(text)
      entry[:simplified] if entry && entry[:simplified]
    end

    def to_traditional(text)
      load_data if @data.nil?

      entry = find_hanzi_match(text)
      entry[:traditional] if entry && entry[:traditional]
    end

    private
    def find_hanzi_match(text)
      entry = @data.find do |word|
        word[:simplified] == text || word[:traditional] == text
      end
    end

  end
end