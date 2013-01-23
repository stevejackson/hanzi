# encoding: utf-8

require 'helper'

class TestHanzi < Test::Unit::TestCase

  def test_should_init_data
    Hanzi.load_data
    assert Hanzi.data.count > 0
  end

  def test_convert_with_tones
    result = Hanzi.to_pinyin('为什么')
    assert_equal 'wei4shen2me5', result
  end

  def test_second_word
    result = Hanzi.to_pinyin('走红')
    assert_equal 'zou3hong2', result
  end

  def test_can_convert_traditional
    result = Hanzi.to_pinyin('簡單')
    assert_equal 'jian3dan1', result
  end

  def test_can_convert_with_surrounding_english
    result = Hanzi.to_pinyin('no! 为什么！')
    assert_equal 'no! wei4shen2me5！', result
  end

  def test_can_convert_sentence_of_hanzi
    result = Hanzi.to_pinyin('你好， 我是康昱辰。')
    assert_equal 'ni3hao3， wo3shi4kang1yu4chen2。', result
  end

  def test_can_find_all_matching_entries
    results = Hanzi.matching_entries('着')
    assert results.find { |entry| entry[:pinyin].include?('zhe5') } != nil
    assert results.find { |entry| entry[:pinyin].include?('zhao2') } != nil
    assert results.find { |entry| entry[:english].include?('in progress') } != nil
  end

  def test_can_return_english_translation
    result = Hanzi.to_english('你好')
    assert result.downcase.include?('hello')
  end

  def test_returns_nil_for_not_found_english_translation
    result = Hanzi.to_english('老子你好')
    assert_equal nil, result
  end

  def test_can_convert_from_simplified_to_traditional
    result = Hanzi.to_traditional('拉萨')
    assert_equal '拉薩', result
  end

  def test_can_convert_traditional_to_traditional
    result = Hanzi.to_traditional('拉薩')
    assert_equal '拉薩', result
  end

  def test_can_convert_traditional_to_simplified
    result = Hanzi.to_simplified('拉薩')
    assert_equal '拉萨', result
  end

  def test_cannot_convert_non_exact_words_simplified
    result = Hanzi.to_simplified('拉萨喜欢')
    assert_equal nil, result
  end

end
