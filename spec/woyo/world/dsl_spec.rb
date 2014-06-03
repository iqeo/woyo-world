require 'woyo/world/world'

describe 'DSL' do

  context 'world' do

    context 'location' do 

      it 'new without block' do
        world = Woyo::World.new do
          location :home
          location :away
          location :lost
        end
        world.should be_instance_of Woyo::World
        world.locations.count.should eq 3
      end

      it 'new with empty block' do
        world = Woyo::World.new do
          location :home do ; end
          location :away do ; end
          location :lost do ; end
        end
        world.should be_instance_of Woyo::World
        world.locations.count.should eq 3
      end

      it 'new with attributes' do
        world = Woyo::World.new do
          location :home do
            name 'Home'
            description 'Sweet'
          end
        end
        world.should be_instance_of Woyo::World
        world.locations.count.should eq 1
        home = world.locations[:home]
        home.id.should eq :home
        home.name.should eq 'Home'
        home.description.should eq 'Sweet'
      end

      it 'existing with attributes' do
        world = Woyo::World.new do
          location :home do
            name 'Home'
            description 'Okay'
          end
          location :home do
            description 'Sweet'
          end
        end
        world.should be_instance_of Woyo::World
        world.locations.count.should eq 1
        home = world.locations[:home]
        home.id.should eq :home
        home.name.should eq 'Home'
        home.description.should eq 'Sweet'
      end

      it 'multiple with attributes' do
        world = Woyo::World.new do
          location :home do
            name 'Home'
            description 'Sweet'
          end
          location :away do
            name 'Away'
            description 'Okay'
          end
        end
        world.should be_instance_of Woyo::World
        world.locations.count.should eq 2
        home = world.locations[:home]
        home.id.should eq :home
        home.name.should eq 'Home'
        home.description.should eq 'Sweet'
        away = world.locations[:away]
        away.id.should eq :away
        away.name.should eq 'Away'
        away.description.should eq 'Okay'
      end

      context 'ways' do

        context 'new way' do

          it 'to new location' do
            world = Woyo::World.new do
              location :home do
                way :door do
                  name 'Large Wooden Door'
                  to :away
                end
              end
            end
            home = world.locations[:home]
            home.ways.count.should eq 1
            door = home.ways[:door]
            door.should be_instance_of Woyo::Way
            door.name.should eq 'Large Wooden Door'
            door.to.should be_instance_of Woyo::Location
            door.to.id.should eq :away
            away = world.locations[:away]
            away.ways.count.should eq 0
            door.to.should eq away
          end

          it 'to existing location' do
            world = Woyo::World.new do
              location :away do
              end
              location :home do
                way :door do
                  name 'Large Wooden Door'
                  to :away
                end
              end
            end
            home = world.locations[:home]
            home.ways.count.should eq 1
            door = home.ways[:door]
            door.should be_instance_of Woyo::Way
            door.name.should eq 'Large Wooden Door'
            door.to.should be_instance_of Woyo::Location
            door.to.id.should eq :away
            away = world.locations[:away]
            away.ways.count.should eq 0
            door.to.should eq away
          end

          it 'to same location' do
            world = Woyo::World.new do
              location :home do
                way :door do
                  name 'Large Wooden Door'
                  to :home
                end
              end
            end
            home = world.locations[:home]
            home.ways.count.should eq 1
            door = home.ways[:door]
            door.should be_instance_of Woyo::Way
            door.name.should eq 'Large Wooden Door'
            door.to.should be_instance_of Woyo::Location
            door.to.id.should eq :home
            door.to.should eq home
          end

        end

        context 'existing way' do

          it 'to new location' do
            world = Woyo::World.new do
              location :home do
                way :door do
                  name 'Large Wooden Door'
                  description "Big, real big!"
                end
                way :door do
                  description 'Nicer'
                  to :away
                end
              end
            end
            home = world.locations[:home]
            home.ways.count.should eq 1
            door = home.ways[:door]
            door.name.should eq 'Large Wooden Door'
            door.description.should eq "Nicer"
            door.to.should be_instance_of Woyo::Location
            door.to.id.should eq :away
            away = world.locations[:away]
            away.ways.count.should eq 0
            door.to.should eq away
          end

          it 'to existing location' do
            world = Woyo::World.new do
              location :away do
              end
              location :home do
                way :door do
                  name 'Large Wooden Door'
                  description "Big, real big!"
                end
                way :door do
                  description 'Nicer'
                  to :away
                end
              end
            end
            home = world.locations[:home]
            home.ways.count.should eq 1
            door = home.ways[:door]
            door.name.should eq 'Large Wooden Door'
            door.description.should eq "Nicer"
            door.to.should be_instance_of Woyo::Location
            door.to.id.should eq :away
            away = world.locations[:away]
            away.ways.count.should eq 0
            door.to.should eq away
          end

          it 'to same location' do
            world = Woyo::World.new do
              location :home do
                way :door do
                  name 'Large Wooden Door'
                  description "Big, real big!"
                end
                way :door do
                  description 'Nicer'
                  to :home
                end
              end
            end
            home = world.locations[:home]
            home.ways.count.should eq 1
            door = home.ways[:door]
            door.name.should eq 'Large Wooden Door'
            door.description.should eq "Nicer"
            door.to.should be_instance_of Woyo::Location
            door.to.id.should eq :home
            door.to.should eq home
          end

        end

        context 'going' do

          before :all do
            @world = Woyo::World.new do
              location :room do
                way :stairs do
                  to :cellar
                  description   open: 'Rickety stairs lead down into darkness.',
                              closed: 'Broken stairs end in darkness.'
                  going         open: 'Creaky steps lead uncertainly downwards...',
                              closed: 'The dangerous stairs are impassable.'
                end
              end
              location :cellar do
                description 'Dark and damp, as expected.'
              end
            end
          end

          it 'an open way' do
            room = @world.locations[:room]
            stairs = room.ways[:stairs]
            stairs.to.id.should eq :cellar
            stairs.should be_open
            stairs.description.should eq 'Rickety stairs lead down into darkness.'
            stairs.go.should eq ( { go: true, going: 'Creaky steps lead uncertainly downwards...' } )
          end

          it 'a closed way' do
            room = @world.locations[:room]
            stairs = room.ways[:stairs]
            stairs.to.id.should eq :cellar
            stairs.close!
            stairs.should be_closed
            stairs.description.should eq 'Broken stairs end in darkness.'
            stairs.go.should eq ( { go: false, going: 'The dangerous stairs are impassable.' } )
          end

        end

      end

      it 'new character' do
        world = Woyo::World.new do
          location :home do
            character :jim do
            end
          end
        end
        home = world.locations[:home]
        home.characters.count.should eq 1
        jim = home.characters[:jim]
        jim.location.should be home
      end

      it 'existing character' do
        world = Woyo::World.new do
          location :home do
            character :jim do
              name 'James'
              description 'Jolly'
            end
            character :jim do
              description 'Jovial'
            end
          end
        end
        home = world.locations[:home]
        home.characters.count.should eq 1
        jim = home.characters[:jim]
        jim.location.should be home
        jim.name.should eq 'James'
        jim.description.should eq 'Jovial'
      end

    end

    context 'character' do

      it 'new' do
        world = Woyo::World.new do
          character :jim do
            name 'James'
            description 'Jolly'
          end
        end
        world.characters.count.should eq 1
        world.characters[:jim].should be_instance_of Woyo::Character
        jim = world.characters[:jim]
        jim.location.should be_nil
        jim.name.should eq 'James'
        jim.description.should eq 'Jolly'
      end

      it 'existing' do
        world = Woyo::World.new do
          character :jim do
            name 'James'
            description 'Jolly'
          end
          character :jim do
            description 'Jovial'
          end
        end
        world.characters.count.should eq 1
        world.characters[:jim].should be_instance_of Woyo::Character
        jim = world.characters[:jim]
        jim.location.should be_nil
        jim.name.should eq 'James'
        jim.description.should eq 'Jovial'
      end

    end

  end

end
