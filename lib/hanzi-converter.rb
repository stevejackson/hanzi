# encoding: utf-8

class HanziConverter
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
        line_data[:pinyin] = line[1, line.index(']') - 1]

        line = line[line.index('/'), line.rindex('/')]
        line_data[:english] = line[1, line.rindex('/') - 1]

        @data << line_data
      end

    end

    def to_pinyin(text, options={})
      load_data if @data.nil?
      entry = @data.find do |word|
        word[:simplified] == text || word[:traditional] == text
      end
      entry[:pinyin].gsub("\s", '') if entry
    end
  end
end