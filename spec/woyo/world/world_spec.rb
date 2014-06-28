require 'spec_helper'
require 'woyo/world/world'

describe Woyo::World do

  let(:world) { Woyo::World.new }

  it 'has attributes :name, :description, :start', gf: "works" do
    expect(world.attributes).to be_instance_of Woyo::Attributes::AttributesHash
    expect(world.attributes.names.sort).to eq [:description,:name,:start]
  end

  it 'can have locations' do
    expect(world.locations).to be_empty
  end

  it 'can have characters' do
    expect(world.characters).to be_empty
  end

  it 'can have items' do
    expect(world.items).to be_empty
  end

end

