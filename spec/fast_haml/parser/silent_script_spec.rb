require 'spec_helper'

RSpec.describe FastHaml::Parser, type: :parser do
  describe 'silent script' do
    it 'parses silent script' do
      expect(render_string(<<HAML)).to eq("<span>0</span>\n<span>1</span>")
- 2.times do |i|
  %span= i
HAML
    end

    it 'parses if' do
      expect(render_string(<<HAML)).to eq("<div>\neven\n</div>")
%div
  - if 2.even?
    even
HAML
    end

    it 'parses if and text' do
      expect(render_string(<<HAML)).to eq("<div>\neven\nok\n</div>")
%div
  - if 2.even?
    even
  ok
HAML
    end

    it 'parses if and else' do
      expect(render_string(<<HAML)).to eq("<div>\nodd\n</div>")
%div
  - if 1.even?
    even
  - else
    odd
HAML
    end

    it 'parses if and elsif' do
      expect(render_string(<<HAML)).to eq("<div>\n2\neven\n</div>")
%div
  - if 1.even?
    even
  - elsif 2.even?
    2
    even
  - else
    odd
HAML
    end

    it 'parses case-when' do
      expect(render_string(<<HAML)).to eq("<div>\n2\neven\n</div>")
%div
  - case
  - when 1.even?
    even
  - when 2.even?
    2
    even
  - else
    else
HAML
    end
  end
end