require 'strscan'
require 'faml/parser_utils'

module Faml
  class TextCompiler
    class InvalidInterpolation < StandardError
    end

    def initialize(escape_html: true)
      @escape_html = escape_html
    end

    def compile(text, escape_html: @escape_html)
      if self.class.contains_interpolation?(text)
        compile_interpolation(text, escape_html: escape_html)
      else
        [:static, text]
      end
    end

    INTERPOLATION_BEGIN = /(\\*)(#[\{$@])/o

    def self.contains_interpolation?(text)
      INTERPOLATION_BEGIN === text
    end

    private

    def compile_interpolation(text, escape_html: @escape_html)
      s = StringScanner.new(text)
      temple = [:multi]
      pos = s.pos
      while s.scan_until(INTERPOLATION_BEGIN)
        escapes = s[1].size
        pre = s.string.byteslice(pos ... (s.pos - s.matched.size))
        temple << [:static, pre] << [:static, "\\" * (escapes/2)]
        if escapes % 2 == 0
          # perform interpolation
          if s[2] == '#{'
            temple << [:escape, escape_html, [:dynamic, find_close_brace(s)]]
          else
            var = s[2][-1]
            s.scan(/\w+/)
            var << s.matched
            temple << [:escape, escape_html, [:dynamic, var]]
          end
        else
          # escaped
          temple << [:static, s[2]]
        end
        pos = s.pos
      end
      temple << [:static, s.rest]
      temple
    end

    INTERPOLATION_BRACE = /[\{\}]/o

    def find_close_brace(scanner)
      pos = scanner.pos
      depth = ParserUtils.balance(scanner, '{', '}')
      if depth != 0
        raise InvalidInterpolation.new(scanner.string)
      else
        scanner.string.byteslice(pos ... (scanner.pos-1))
      end
    end
  end
end
