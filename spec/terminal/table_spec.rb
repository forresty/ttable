# coding: utf-8

require "spec_helper"

class Dummy
  attr_accessor :foo

  def to_hash
    { foo: @foo }
  end
end

class Dummy2
  attr_accessor :foo1, :foo2, :foo3

  def to_hash
    { foo1: @foo1, foo2: @foo2, foo3: @foo3 }
  end
end

module Terminal
  describe Table do
    describe 'class methods' do
      subject { Table }
      it { should respond_to :special_tokens }
    end

    it { should respond_to :to_s }

    describe 'initialize with array of array' do
      let(:array) { [%w{ hello 1 }, %w{ world 2 } ] }
      subject { Table.new(array) }

      expected = <<END
      +-------+---+
      | hello | 1 |
      | world | 2 |
      +-------+---+
END
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
    end

    describe 'initialize with hash' do
      let(:hash) { { foo: 'bar' } }

      subject { Table.new(hash) }

      expected = <<END
      +-----+
      | foo |
      +-----+
      | bar |
      +-----+
END
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
    end

    describe 'initialize with array of hashes' do
      let(:hash1) { { foo: 'bar1' } }
      let(:hash2) { { foo: 'bar2' } }

      subject { Table.new([hash1, hash2]) }

      expected = <<END
      +------+
      | foo  |
      +------+
      | bar1 |
      | bar2 |
      +------+
END
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
    end

    describe 'initialize with object#to_hash' do
      let(:object) { Dummy.new.tap { |d| d.foo = 'bar' } }
      subject { Table.new(object) }

      expected = <<END
      +-----+
      | foo |
      +-----+
      | bar |
      +-----+
END
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
    end

    describe 'initialize with objects' do
      let(:object1) { Dummy.new.tap { |d| d.foo = 'bar1' } }
      let(:object2) { Dummy.new.tap { |d| d.foo = 'bar2' } }

      subject { Table.new([object1, object2]) }

      expected = <<END
      +------+
      | foo  |
      +------+
      | bar1 |
      | bar2 |
      +------+
END
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
    end

    describe 'initialize with object#to_hash and :only option' do
      let(:object) { Dummy2.new.tap { |d| d.foo1 = 'bar1'; d.foo2 = 'bar2'; d.foo3 = 'bar3' } }
      subject { Table.new(object, only: [:foo1, :foo2]) }

      expected = <<END
      +------+------+
      | foo1 | foo2 |
      +------+------+
      | bar1 | bar2 |
      +------+------+
END
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
    end

    describe 'initialize with object#to_hash and :only option' do
      let(:object) { Dummy2.new.tap { |d| d.foo1 = 'bar1'; d.foo2 = 'bar2'; d.foo3 = 'bar3' } }
      subject { Table.new(object, only: %w{ foo1 foo2 }) }

      expected = <<END
      +------+------+
      | foo1 | foo2 |
      +------+------+
      | bar1 | bar2 |
      +------+------+
END
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
    end

    describe 'initialize with object#to_hash and :except option' do
      let(:object) { Dummy2.new.tap { |d| d.foo1 = 'bar1'; d.foo2 = 'bar2'; d.foo3 = 'bar3' } }
      subject { Table.new(object, except: [:foo1, :foo3]) }

      expected = <<END
      +------+
      | foo2 |
      +------+
      | bar2 |
      +------+
END
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
    end

    describe '#to_s' do
      context 'when empty' do
        subject { Table.new }
        its(:to_s) { should == "++\n++\n" }
      end

      context 'new lines \n' do
        subject { Table.new { |t| t.rows = [["a\nb"]] } }

        expected = <<END
        +-----+
        | a b |
        +-----+
END
        its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
      end

      context 'new lines \n when <<' do
        subject { Table.new { |t| t.rows << ["a\nb"] } }

        expected = <<END
        +-----+
        | a b |
        +-----+
END
        its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
      end

      context 'new lines \r' do
        subject { Table.new { |t| t.rows = [["a\rb"]] } }

        expected = <<END
        +-----+
        | a b |
        +-----+
END
        its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
      end

      context 'new line symbol' do
        subject { Table.new(nil, use_new_line_symbol: true).tap { |t| t.rows = [["a\rb"]] } }

        expected = <<END
        +-----+
        | a⏎b |
        +-----+
END
        its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
      end

      context 'mutli calls to <<' do
        it 'works as well' do
          table = Table.new
          table.rows << %w{ a }
          table.rows << %w{ b }

          expected = <<END
          +---+
          | a |
          | b |
          +---+
END

          table.to_s.should == expected.gsub(/^(\s+)/, '')
        end
      end

      context 'when only heading' do
        subject { Table.new { |t| t.headings = %w{ head } } }
        its(:to_s) { should == "+------+\n| head |\n+------+\n+------+\n" }
      end

      context 'when set contents after' do
        subject { Table.new.tap { |t| t.headings = %w{ head } } }
        its(:to_s) { should == "+------+\n| head |\n+------+\n+------+\n" }
      end

      context 'with nil values' do
        subject { Table.new { |t| t.headings = %w{ head }; t.rows = [ [ nil ] ] } }
        its(:to_s) { should == "+------+\n| head |\n+------+\n|      |\n+------+\n" }
      end

      context 'with nil values' do
        subject { Table.new { |t| t.headings = %w{ head1 head2 }; t.rows = [ [ nil, nil ] ] } }
        expected = <<END
        +-------+-------+
        | head1 | head2 |
        +-------+-------+
        |       |       |
        +-------+-------+
END
        its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
      end
    end
  end
end

describe String do
  describe '#twidth' do
    context 'Ｃ' do
      subject { 'Ｃ' }
      its(:twidth) { should == 2 }
    end

    context 'ě' do
      subject { 'ě' }
      its(:twidth) { should == 1 }
    end

    context 'ｌ' do
      subject { 'ｌ' }
      its(:twidth) { should == 2 }
    end

    context 'ì' do
      subject { 'ì' }
      its(:twidth) { should == 1 }
    end

    context '☺️' do
      subject { '☺️' }
      its(:twidth) { should == 1 }
    end

    context '☺️☺️' do
      subject { '☺️☺️' }
      its(:twidth) { should == 2 }
    end

    context '❤️' do
      subject { '❤️' }
      its(:twidth) { should == 1 }
    end

    context '√' do
      subject { '√' }
      its(:twidth) { should == 1 }
    end

    context '”' do
      subject { '”' }
      its(:twidth) { should == 1 }
    end

    context '“' do
      subject { '“' }
      its(:twidth) { should == 1 }
    end

    context '♍️' do
      subject { '♍️' }
      its(:twidth) { should == 1 }
    end

    context '♍️♍️' do
      subject { '♍️♍️' }
      its(:twidth) { should == 2 }
    end

    context '☻' do
      subject { '☻' }
      its(:twidth) { should == 1 }
    end

    context '※' do
      subject { '※' }
      its(:twidth) { should == 1 }
    end

    context '◎' do
      subject { '◎' }
      its(:twidth) { should == 1 }
    end

    context '◆' do
      subject { '◆' }
      its(:twidth) { should == 1 }
    end

    context '‘' do
      subject { '‘' }
      its(:twidth) { should == 1 }
    end

    context '★ ’' do
      subject { '★ ’' }
      its(:twidth) { should == 3 }
    end

    context '—' do
      subject { '—' }
      its(:twidth) { should == 1 }
    end

    context 'special whitespace' do
      subject { ' ' }
      its(:twidth) { should == 1 }
    end

    context ' ͡° ͜ʖ ͡°' do
      subject { ' ͡° ͜ʖ ͡°' }
      its(:twidth) { should == 6 }
    end

    context '（¯﹃¯）' do
      subject { '（¯﹃¯）' }
      its(:twidth) { should == 8 }
    end

    context '（）' do
      subject { '（）' }
      its(:twidth) { should == 4 }
    end

    context '≥≤' do
      subject { '≥≤' }
      its(:twidth) { should == 2 }
    end

    context '（≧∇≦）' do
      subject { '（≧∇≦）' }
      its(:twidth) { should == 7 }
    end

    context '' do
      subject { '' }
      its(:twidth) { should == 1 }
    end

    context '❤' do
      subject { '❤' }
      its(:twidth) { should == 1 }
    end

    context '☺' do
      subject { '☺' }
      its(:twidth) { should == 1 }
    end

    context '╭(╯ε╰)╮' do
      subject { '╭(╯ε╰)╮' }
      its(:twidth) { should == 7 }
    end

    context '_(:з)∠)_' do
      subject { '_(:з)∠)_' }
      its(:twidth) { should == 8 }
    end

    context '→_→' do
      subject { '→_→' }
      its(:twidth) { should == 3 }
    end

    context '☞' do
      subject { '☞' }
      its(:twidth) { should == 1 }
    end

    context 'ë' do
      subject { 'ë' }
      its(:twidth) { should == 1 }
    end

    context '☔️' do
      subject { '☔️' }
      its(:twidth) { should == 1 }
    end

    context "ϵ( 'Θ' )϶" do
      subject { "ϵ( 'Θ' )϶" }
      its(:twidth) { should == 9 }
    end

    context 'にΟΙ' do
      subject { 'にΟΙ' }
      its(:twidth) { should == 4 }
    end

    context ' ̫' do
      subject { ' ̫' }
      its(:twidth) { should == 1 }
    end

    context '　' do
      subject { '　' }
      its(:twidth) { should == 2 }
    end

    context '←' do
      subject { '←' }
      its(:twidth) { should == 1 }
    end

    context '¥' do
      subject { '¥' }
      its(:twidth) { should == 1 }
    end

    context 'ó' do
      subject { 'ó' }
      its(:twidth) { should == 1 }
    end

    context '(˶‾᷄ ⁻̫ ‾᷅˵)' do
      subject { '(˶‾᷄ ⁻̫ ‾᷅˵)' }
      its(:twidth) { should == 9 }
    end

    context '╥' do
      subject { '╥' }
      its(:twidth) { should == 1 }
    end

    context '⊙' do
      subject { '⊙' }
      its(:twidth) { should == 1 }
    end

    context '(｡･ω･｡)ﾉ♡' do
      pending 'not finished yet'
    end

    context '' do
      subject { '' }
      its(:twidth) { should == 1 }
    end

    context '👋' do
      subject { '👋' }
      its(:twidth) { should == 1 }
    end

    context '↓↓' do
      subject { '↓↓' }
      its(:twidth) { should == 2 }
    end

    context '℃' do
      subject { '℃' }
      its(:twidth) { should == 1 }
    end

    context '(●✿∀✿●)' do
      pending
    end

    context 'Д' do
      subject { 'Д' }
      its(:twidth) { should == 1 }
    end

    context '(´•̥̥̥ω•̥̥̥`)' do
      pending
    end

    context ' ᷄' do
      subject { ' ᷄' }
      its(:twidth) { should == 1 }
    end

    context '‾' do
      subject { '‾' }
      its(:twidth) { should == 1 }
    end

    context '༼蛇精༽༄ ' do
      pending
    end

    context '✌' do
      subject { '✌' }
      its(:twidth) { should == 1 }
    end

    context '(´Д` )' do
      subject { '(´Д` )' }
      its(:twidth) { should == 6 }
    end

    context '゜∀)ノ' do
      subject { '゜∀)ノ' }
      its(:twidth) { should == 6 }
    end

    context '⬇⬇⬇⬇' do
      subject { '⬇⬇⬇⬇' }
      its(:twidth) { should == 4 }
    end

    context 'ヽ(#`Д´)ﾉ' do
      subject { 'ヽ(#`Д´)ﾉ' }
      its(:twidth) { should == 9 }
    end

    context '～٩(๑ᵒ̴̶̷͈᷄ᗨᵒ̴̶̷͈᷅)و' do
      pending
    end

    context '😂' do
      subject { '😂' }
      its(:twidth) { should == 1 }
    end

    context '⊙▽⊙' do
      subject { '⊙▽⊙' }
      its(:twidth) { should == 3 }
    end

    context '✖️✖️' do
      subject { '✖️✖️' }
      its(:twidth) { should == 2 }
    end

    context '☁' do
      subject { '☁' }
      its(:twidth) { should == 1 }
    end

    context '( ・᷄ ᵌ・᷅ )' do
      subject { '( ・᷄ ᵌ・᷅ )' }
      its(:twidth) { should == 10 }
    end

    context '(☆_☆)Y(^_^)Y ♪─Ｏ（≧∇≦）Ｏ─♪' do
      pending
    end

    context '12～★ 今天新换的 (๑¯ิε ¯ิ๑）' do
      pending
    end

    context '☀' do
      subject { '☀' }
      its(:twidth) { should == 1 }
    end

    context '☀︎' do
      subject { '☀︎' }
      its(:twidth) { should == 1 }
    end

    context '(´･_･`)' do
      subject { '(´･_･`)' }
      its(:twidth) { should == 7 }
    end

    context '୧⃛(๑⃙⃘◡̈๑⃙⃘)୨⃛' do
      pending
    end

    context '❓⁉️' do
      subject { '❓⁉️' }
      its(:twidth) { should == 2 }
    end

    context '⬇️⬇️⬇️⬇️⬇️…🌚！！！😰😤😤' do
      pending
    end

    context '！' do
      subject { '！' }
      its(:twidth) { should == 2 }
    end

    context '～' do
      subject { '～' }
      its(:twidth) { should == 2 }
    end

    context '(˘̩̩̩ε˘̩ƪ)' do
      pending
    end

    context 'ʕ •ᴥ•ʔ' do
      pending
    end

    context '´●＿●`' do
      subject { '´●＿●`' }
      its(:twidth) { should == 6 }
    end

    context '＿' do
      subject { '＿' }
      its(:twidth) { should == 2 }
    end

    context '`' do
      subject { '`' }
      its(:twidth) { should == 1 }
    end

    context '´' do
      subject { '´' }
      its(:twidth) { should == 1 }
    end

    context '☆ゝ' do
      subject { '☆ゝ' }
      its(:twidth) { should == 3 }
    end

    context '(͏ ˉ ꈊ ˉ)✧˖°' do
      pending
    end

    context '₍₍ (̨̡ ᗣ )̧̢ ₎₎' do
      pending
    end

    context '♚' do
      subject { '♚' }
      its(:twidth) { should == 1 }
    end

    context '(●°u°●)​ 」' do
      pending
    end

    context 'ಥ_ಥ' do
      pending
    end

    context '♪٩(´▽｀๑)۶ ' do
      pending
    end

    context 'ಠ_ಠ' do
      pending
    end

    context '(ᵒ̤̑ ₀̑ ᵒ̤̑)' do
      pending
    end

    context '눈_눈' do
      pending
    end

    context '' do
      pending
    end

    context '((((；ﾟДﾟ)))))))' do
      pending
    end

    context '（∮∧∮）' do
      pending
    end

    context 'ヽ(￣д￣;)ノ' do
      pending
    end

    context '(Ծ‸ Ծ )' do
      pending
    end

    context '(۶ૈ ۜ ᵒ̌▱๋ᵒ̌ )۶ૈ=͟͟͞͞ ⌨' do
      pending
    end

    context '(๑˃̵ᴗ˂̵)و ' do
      pending
    end

    context '嘤ू(ʚ̴̶̷́ .̠ ʚ̴̶̷̥̀ ू) ' do
      pending
    end

    context '⁽⁽٩(๑˃̶͈̀  ˂̶͈́)۶⁾⁾' do
      pending
    end

    context '(ᵒ̤̑ ₀̑ ᵒ̤̑)' do
      pending
    end

    context 'AÏcha' do
      pending
    end

    context '(ᵒ̤̑ ₀̑ ᵒ̤̑)' do
      pending
    end

    context '(╯°Д°)╯︵ ┻━┻ ' do
      pending
    end

    context '┭┮﹏┭┮' do
      pending
    end

    context '=△=' do
      pending
    end

    context ' (ؓؒؒؑؑؖؔؓؒؐؐ⁼̴̀ωؘؙؖؕؔؓؒؑؐؕ⁼̴̀ )✧' do
      pending
    end

    context '(¦3[____]' do
      pending
    end

    context '( •̥́ ˍ •̀ू )' do
      pending
    end

    context 'Σ（ﾟдﾟlll） ' do
      pending
    end

    context '☁︎' do
      pending
    end

    context '▀ ▄ ‖ █ ‖▌‖' do
      pending
    end

    context 'にこにー♡' do
      pending
    end

    context 'Наташа' do
      pending
    end

    context '(╯°□°）╯︵' do
      pending
    end

    context 'Facebig(((o(*ﾟ▽ﾟ*)o)))' do
      pending
    end
  end
end
