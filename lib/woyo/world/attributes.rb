require_relative 'group'

class Hash
  alias_method :names, :keys
end

module Woyo

module Attributes

  class AttributesHash < Hash

    alias_method :names, :keys
    alias_method :set, :[]=

    attr_reader :listeners

    def initialize
      @listeners = {}
    end

    def add_listener attr, listener
      @listeners[attr] ||= []
      @listeners[attr] << listener
    end
    
    def []= attr, value
      old_value = self[attr]
      super
      if value != old_value
        @listeners[attr].each { |listener| listener.notify attr, value } if @listeners[attr]  # attribute listeners (groups, etc..)
        @listeners[:*].each   { |listener| listener.notify attr, value } if @listeners[:*]    # wildcard listeners (trackers)
      end
    end

  end

  class Tracker

    attr_accessor :changed

    def initialize
      clear
    end

    def clear
      @changed = {} 
    end

    def notify attr, value
      @changed[attr] = value  
    end

  end

  def track
    @tracker = Tracker.new
    @attributes ||= Woyo::Attributes::AttributesHash.new
    @attributes.add_listener :*, @tracker  # :* indicates tracker listens to all attributes
  end

  def tracker
    @tracker
  end

  def attribute *attrs, &block
    attributes *attrs, &block
  end

  def attributes *attrs, &block
    @attributes ||= Woyo::Attributes::AttributesHash.new 
    return @attributes if attrs.empty?
    attrs.each do |attr|
      case
      when attr.kind_of?( Hash )
        attr.each do |attr_sym,default|
          define_attr_methods attr_sym, default
          @attributes[attr_sym] = send "#{attr_sym}_default"
        end
      when block
        define_attr_methods attr, block
        @attributes[attr] = send "#{attr}_default"
      else
        unless @attributes.include? attr
          define_attr_methods attr
          @attributes[attr] = nil
        end
      end
    end
  end

  def define_attr_methods attr, default = nil
    define_attr_default attr, default
    define_attr_equals attr
    define_attr attr
    if default == true || default == false    # boolean convenience methods
      define_attr? attr
      define_attr! attr
    end
  end

  def define_attr_default attr, default
    define_singleton_method "#{attr}_default" do
      default
    end
  end

  def define_attr_equals attr
    define_singleton_method "#{attr}=" do |arg|
      @attributes[attr] = arg
    end
  end

  def define_attr attr
    define_singleton_method attr do |arg = nil|
      return @attributes[attr] = arg unless arg.nil?
      case
      when @attributes[attr].kind_of?( Hash )
        truthy_matches = @attributes[attr].collect do |name,value|
          truthy = if @attributes[name].respond_to?( :call )
            @attributes[name].arity == 0 ? @attributes[name].call : @attributes[name].call(self)
          else
            @attributes[name]
          end
          truthy ? value : nil
        end.compact
        truthy_matches = truthy_matches.count == 1 ? truthy_matches[0] : truthy_matches
        return truthy_matches
      when @attributes[attr].respond_to?( :call )
        return @attributes[attr].arity == 0 ? @attributes[attr].call : @attributes[attr].call(self)
      else
        @attributes[attr]
      end
    end
  end

  def define_attr? attr
    define_singleton_method "#{attr}?" do
      ( send attr ) ? true : false
    end
  end

  def define_attr! attr
    define_singleton_method "#{attr}!" do
      send "#{attr}=", true
    end
  end

  def is? attr
    send "#{attr}?"
  end

  def is attr
    send "#{attr}=", true
  end

  def notify attr, value
    raise '#notify not implemented'
  end

end

end

