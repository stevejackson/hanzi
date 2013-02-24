# encoding: utf-8
require 'trie'

class Hanzi
  class << self
    attr_accessor :data
    attr_accessor :data_trie

    def load_data
      return if @data
      @data = []
      @data_trie = Trie.new

      file_path = File.expand_path('../../lib/data/cedict_ts.u8', __FILE__)
      index = 0
      File.open(file_path).each_line do |line|
        next if line.start_with?('#')
        line = line.force_encoding('utf-8')

        # CC-CEDICT format:
        # Traditional Simplified [pin1 yin1] /English equivalent 1/equivalent 2/
        line_data = {}
        line_data[:traditional], line_data[:simplified], line = line.split(" ", 3)

        line_data[:pinyin], line = line[1..-1].split("]", 2)
        line_data[:pinyin] = line_data[:pinyin].downcase

        line_data[:english] = line[line.index('/') + 1, line.rindex('/') - 2]

        existing_count_simplified = 0
        if find_first_hanzi_match(line_data[:simplified])
          existing_count_simplified = matching_entries(line_data[:simplified]).count
        end
        @data_trie.add(line_data[:simplified] + existing_count_simplified.to_s, index)

        if line_data[:simplified] != line_data[:traditional]
          existing_count_traditional = 0
          if find_first_hanzi_match(line_data[:traditional])
            existing_count_traditional = matching_entries(line_data[:traditional]).count
          end

          @data_trie.add(line_data[:traditional] + existing_count_traditional.to_s, index)
        end

        @data << line_data


        index += 1
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
            match = find_first_hanzi_match(text[pos, length])
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

      entry = find_first_hanzi_match(text)
      entry[:english] if entry && entry[:english]
    end

    def to_simplified(text)
      load_data if @data.nil?

      entry = find_first_hanzi_match(text)
      entry[:simplified] if entry && entry[:simplified]
    end

    def to_traditional(text)
      load_data if @data.nil?

      entry = find_first_hanzi_match(text)
      entry[:traditional] if entry && entry[:traditional]
    end

    def matching_entries(text)
      load_data if @data.nil?

      results = []
      index = 0
      loop do
        id = @data_trie.get(text + index.to_s)
        break if !id

        results << @data[id]
        index += 1
      end

      results
    end

    private
    def find_first_hanzi_match(text)
      id = @data_trie.get(text + "0")
      @data[id] if id
    end

  end
end
