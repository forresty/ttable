# coding: utf-8

require "spec_helper"

module Terminal
  describe Table do
    it { should respond_to :to_s }

    describe '#to_s' do
      context 'when empty' do
        subject { Table.new }
        its(:to_s) { should == "++\n++\n" }
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
  end
end
