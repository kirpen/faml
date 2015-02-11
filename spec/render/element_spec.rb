require 'spec_helper'

RSpec.describe 'Element rendering', type: :render do
  it 'parses one-line element' do
    expect(render_string('%span hello')).to eq("<span>hello</span>\n")
  end

  it 'parses multi-line element' do
    expect(render_string(<<HAML)).to eq("<span>\nhello\n</span>\n")
%span
  hello
HAML
  end

  it 'parses nested elements' do
    expect(render_string(<<HAML)).to eq("<span>\n<b>\nhello\n</b>\n<i>\n<small>world</small>\n</i>\n</span>\n")
%span
  %b
    hello
  %i
    %small world
HAML
  end

  it 'parses multi-line texts' do
    expect(render_string(<<HAML)).to eq("<span>\n<b>\nhello\nworld\n</b>\n</span>\n")
%span
  %b
    hello
    world
HAML
  end

  it 'skips empty lines' do
    expect(render_string(<<HAML)).to eq("<span>\n<b>\nhello\n</b>\n</span>\n")
%span

  %b

    hello

HAML
  end

  it 'raises error if indent is wrong' do
    expect { render_string(<<HAML) }.to raise_error(FastHaml::IndentTracker::IndentMismatch)
%div
    %div
      %div
  %div
HAML
  end

  it 'parses classes' do
    expect(render_string('%span.foo.bar hello')).to eq(%Q{<span class='foo bar'>hello</span>\n})
  end

  it 'parses id' do
    expect(render_string('%span#foo-bar hello')).to eq(%Q{<span id='foo-bar'>hello</span>\n})
  end

  it 'parses classes and id' do
    expect(render_string('%span.foo#foo-bar.bar hello')).to eq(%Q{<span class='foo bar' id='foo-bar'>hello</span>\n})
  end

  context 'with invalid tag name' do
    it 'raises error' do
      expect { render_string('%.foo') }.to raise_error(FastHaml::SyntaxError)
    end
  end

  it 'parses #' do
    expect(render_string('#main')).to eq(%Q{<div id='main'></div>\n})
  end

  it 'parses .' do
    expect(render_string('.wrapper.main')).to eq(%Q{<div class='wrapper main'></div>\n})
  end

  it 'parses Ruby multiline' do
    expect(render_string(<<HAML)).to eq("<div>\n<span>2+3i</span>\n</div>\n")
%div
  %span= Complex(2,
3)
HAML
  end

  it 'parses string interpolation' do
    expect(render_string(%q|%span hello <span> #{'</span>'} </span>|)).to eq("<span>hello <span> &lt;/span&gt; </span></span>\n")
    expect(render_string(<<'HAML')).to eq("<span>\nhello <span> &lt;/span&gt; </span>\n</span>\n")
%span
  hello <span> #{{text: '</span>'}[:text]} </span>
HAML
    expect(render_string(<<'HAML')).to eq("<span>\nhello <span> &lt;/span&gt; </span>\n</span>\n")
- @var = '</span>'
%span
  hello <span> #@var </span>
HAML
  end

  it 'recognized escaped string interpolation' do
    expect(render_string(%q|%p hello \#{1 + 2}|)).to eq("<p>hello \#{1 + 2}</p>\n")
  end

  it 'parses self-closing tag' do
    expect(render_string('%p/')).to eq("<p>\n")
  end

  it 'parses nuke-inner-whitespace (<)' do
    expect(render_string(<<HAML)).to eq("<blockquote><div>\nFoo!\n</div></blockquote>\n")
%blockquote<
  %div
    Foo!
HAML
  end

  it 'parses nuke-outer-whitespace (>)' do
    expect(render_string(<<HAML)).to eq("<img></img><img></img><img></img>\n")
%img
%img>
%img
HAML
  end

  it 'parses nuke-whitespaces' do
    expect(render_string(<<HAML)).to eq("<img></img><pre>foo\nbar</pre><img></img>\n")
%img
%pre><
  foo
  bar
%img
HAML
  end

  it 'raises error if self-closing tag have text' do
    expect { render_string('%p/ hello') }.to raise_error(FastHaml::SyntaxError)
  end

  it 'raises error if self-closing tag have children' do
    expect { render_string(<<HAML) }.to raise_error(FastHaml::SyntaxError)
%p/
  hello
HAML
  end
end
