
require_relative 'attributes'
require_relative 'dsl'

module Woyo

class WorldObject

  #prepend Attributes
  include Attributes
  include DSL

  attr_reader :id, :context
  attr_accessor :_test

  def initialize id, context: nil, &block
    @id = id.to_s.downcase.to_sym
    @context = context
    super
    evaluate &block
  end

end

end

