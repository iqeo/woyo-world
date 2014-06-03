require 'woyo/world/character'
require 'woyo/world/world'
require 'woyo/world/location'

describe Woyo::Character do

  let(:char) { Woyo::Character.new :boss }

  it 'has attributes' do
    char.attributes.should be_instance_of Woyo::Attributes::AttributesHash
    char.attributes.names.sort.should eq [:description,:name]
  end

  it 'name attribute defaults to id' do
    char.name.should eq 'Boss'
  end

  it 'accepts world for parameter context:' do
    wo = nil
    expect { wo = Woyo::Character.new(:my_id, context: Woyo::World.new) }.to_not raise_error
    wo.context.should be_instance_of Woyo::World
  end

  it 'accepts location for parameter context:' do
    wo = nil
    expect { wo = Woyo::Character.new(:my_id, context: Woyo::Location.new(:here)) }.to_not raise_error
    wo.context.should be_instance_of Woyo::Location
    wo.context.id.should eq :here
  end

  it 'can go way' do
    world = Woyo::World.new do
      location :home do
        way :out do
          to :away
        end
        character :tom
      end
      location :away do
      end
    end
    home = world.locations[:home]
    away = world.locations[:away]
    tom = home.characters[:tom]
    tom.location.should be home
    tom.go :out
    tom.location.should be away
    home.characters[:tom].should be_nil
    away.characters[:tom].should eq tom
  end

end

