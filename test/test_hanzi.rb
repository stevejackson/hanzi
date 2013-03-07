# encoding: utf-8

require 'helper'
require 'benchmark'

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
    assert_equal "Hello!/Hi!/How are you?", result
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

  def test_speed
    entries = words = ["果断", "过度", "过渡", "过奖", "过滤", "过失", "过问", "过瘾", "过于", "嗨", "海拔",
      "海滨", "含糊", "寒暄", "含义", "罕见", "捍卫", "航空", "行列", "航天", "航行", "豪迈", "毫米",
      "毫无", "耗费", "好客", "号召", "呵", "和蔼", "合并", "合成", "合乎", "合伙", "和解", "和睦", "和气",
      "合身", "合算", "和谐", "嘿", "痕迹", "狠心", "恨不得", "哼", "哄", "烘", "轰动", "红包", "宏观",
      "洪水", "宏伟", "喉咙", "吼", "后代", "后顾之忧", "后勤", "候选", "忽略", "呼啸", "呼吁", "胡乱",
      "湖泊", "互联网", "华丽", "华侨", "化肥", "划分", "画蛇添足", "化石", "话筒", "化验", "化妆", "怀孕",
      "欢乐", "环节", "还原", "缓和", "患者", "荒凉", "慌忙", "荒谬", "荒唐", "黄昏", "恍然大悟", "辉煌",
      "挥霍", "回报", "回避", "回顾", "回收", "悔恨", "毁灭", "汇报", "贿赂", "会晤", "昏迷", "浑身", "混合",
      "混乱", "混淆", "混浊", "活该", "活力", "火箭", "火焰", "火药", "货币", "或许", "基地", "机动", "饥饿",
      "激发", "机构", "机关", "基金", "激励", "机灵", "机密", "激情", "讥笑", "机械", "基因", "机遇", "机智",
      "即便", "级别", "疾病", "嫉妒", "极端", "急功近利", "籍贯", "即将", "急剧", "急切", "集团", "极限",
      "吉祥", "急于求成", "及早", "急躁", "给予", "继承", "季度", "忌讳", "计较", "寂静", "季军", "技能",
      "技巧", "寄托", "继往开来", "迹象", "记性", "纪要", "记载", "家常", "加工", "家伙", "加剧", "家属",
      "空虚", "孔", "恐吓", "恐惧", "空白", "空隙", "口气", "口腔", "口头", "口音", "枯竭", "枯燥", "苦尽甘来"]

    Hanzi.load_data

    time = Benchmark.realtime {
      entries.each do |word|
        Hanzi.matching_entries(word)
      end
    }

    assert time < 0.01, "Lookups took #{time}s, should be less than 0.01s"
  end

  def test_determine_word_from_surroundings
    assert_equal Hanzi.determine_word('喜欢', 0), (0..1)
    assert_equal Hanzi.determine_word('喜欢', 1), (0..1)
    assert_equal Hanzi.determine_word('喜欢', 2), nil
    assert_equal Hanzi.determine_word('我喜欢吃牛肉', 0), (0..0)
    assert_equal Hanzi.determine_word('我喜欢吃牛肉', 1), (1..2)
    assert_equal Hanzi.determine_word('我喜欢吃牛肉', 2), (1..2)
    assert_equal Hanzi.determine_word('我喜欢吃牛肉', 3), (3..3)
    assert_equal Hanzi.determine_word('我喜欢吃牛肉', 4), (4..5)
    assert_equal Hanzi.determine_word('我喜欢吃牛肉', 5), (4..5)
    assert_equal Hanzi.determine_word('我晕', 0), (0..0)
    assert_equal Hanzi.determine_word('我晕', 1), (1..1)
  end

end
