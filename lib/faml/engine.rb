require 'temple'
require 'faml/compiler'
require 'faml/html'
require 'faml/newline'
require 'faml/parser'

module Faml
  class Engine < Temple::Engine
    define_options(
      generator: Temple::Generators::ArrayBuffer,
    )

    DEFAULT_OPTIONS = {
        format: :html,
        attr_quote: "'",
    }.freeze

    def initialize(opts = {})
      super(DEFAULT_OPTIONS.merge(opts))
    end

    use Parser
    use Compiler
    use Html
    filter :Escapable
    filter :ControlFlow
    filter :MultiFlattener
    use Newline
    filter :StaticMerger
    use :Generator do
      options[:generator].new(options.to_hash.reject {|k,v| !options[:generator].options.valid_key?(k) })
    end
  end
end
