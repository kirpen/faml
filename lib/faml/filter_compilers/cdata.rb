require 'faml/filter_compilers/base'

module Faml
  module FilterCompilers
    class Cdata < Base
      def compile(texts)
        temple = [:multi, [:static, "<![CDATA[\n"], [:newline]]
        compile_texts(temple, texts, tab_width: 4)
        temple << [:static, "\n]]>"]
      end
    end

    register(:cdata, Cdata)
  end
end
