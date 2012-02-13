require 'tilt'

module Ehaml
  def self.compile(name, string)
    result = []
    result.push 'window.T || (window.T = {});'
    result.push "T['#{name}'] = "
    result.push string.split("\n").map {|l| "\"#{l.gsub('"', '\"').strip}\""}.join('+')
    result.push ';'
    result.join
  end
end

module Sprockets
  class EhamlTemplate < Tilt::Template

    def self.engine_initialized?
      defined? ::Haml
    end

    def initialize_engine
      require_template_library 'haml'
    end

    def prepare
    end

    def evaluate(scope, locals, &block)
      name = scope.logical_path
      Ehaml::compile(name, Haml::Engine.new(data).render)
    end
  end

  # Custom Cooked engines
  register_engine '.ehaml',    EhamlTemplate

end
