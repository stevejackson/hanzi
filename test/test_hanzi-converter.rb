# encoding: utf-8

require 'helper'

class TestHanziConverter < Test::Unit::TestCase

  def test_should_init_data
    HanziConverter.load_data
    assert HanziConverter.data.count > 0
  end

  def test_convert_with_tones
    result = HanziConverter.to_pinyin('为什么')
    assert_equal 'wei4shen2me5', result
  end

  def test_second_word
    result = HanziConverter.to_pinyin('走红')
    assert_equal 'zou3hong2', result
  end

  def test_can_convert_traditional
    result = HanziConverter.to_pinyin('簡單')
    assert_equal 'jian3dan1', result
  end

  def test_can_convert_with_surrounding_english
    result = HanziConverter.to_pinyin('no! 为什么！')
    assert_equal 'no! wei4shen2me5！', result
  end

  def test_can_convert_sentence_of_hanzi
    result = HanziConverter.to_pinyin('你好， 我是康昱辰。')
    assert_equal 'ni3hao3， wo3shi4kang1yu4chen2。', result
  end

end
