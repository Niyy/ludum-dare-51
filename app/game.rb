class Game
    attr_gtk
    attr_accessor :constructed, :hand, :event_handler


    @@id = 0
    @@max_timer = 600
    @@text_width = 9.95


    def initialize(args: nil)
        @last_mouse = args.inputs.mouse
        @deck = []
        @hand = []
        @global_tiles = []
        @hand_size = 3
        @in_hand_size = 64
        @tiling = {:w => 32, :h => 32}
        @tile_select = nil
        @tile_cost = 5
        @tick_offset = 0
        @constructed = {}
        @producers = {}
        @input_manager = {
            :mouse => {
                :left => -1
            }
        }

        ## Initializing 
        @hand << Manor.new(
            :x => 0,
            :y => 0,
            :w => 64,
            :h => 64,
            :path => 'sprites/manor.png'
        )

        @resources = {
            :pop_housed => {
                :text => 'Housed',
                :value => 0
            },
            :pop_homeless => {
                :text => 'Homeless',
                :value => 0
            },
            :jobs => {
                :text => 'Available Jobs',
                :value => 0
            },
            :housing => {
                :text => 'Available Housing',
                :value => 0
            },
            :tier_one_resources => {
                :text => 'Tier I',
                :value => 0
            }
        }

        even_initialize(args: args)
        ui_initialize(args: args)
    end


    def even_initialize(args: nil)
        @event_migrants = Event.new(
            start_text: 'New peasants will arrive any moment. Prepare for their arrival.',
            end_text: "#{2} peasents have arrived!",
            resources: {
                :pop_homeless => 2
            }
        )

        @event_handler = Event_Handler.new(
            events: [@event_migrants]
        )
    end


    def ui_initialize(args: nil)
        text_height = 15
        text_width = 8.5 

        @ui_events = []

        @ui_timer_bar = {
            :x => (args.grid.right / 2) - 150,
            :y => 105,
            :w => 0,
            :h => 20,
            :path => 'sprites/green_fill_bar.png'
        }
        @ui_deck_count = {
            :x => (args.grid.right) - 82 + (text_width * 3),
            :y => 16 + (text_height * 3),
            :size_enum => 3,
            :r => 255,
            :g => 255,
            :b => 255,
            :text => @deck.length()
        }.label!()
        @ui_deck = {
            :x => (args.grid.right) - 82,
            :y => 16,
            :w => 64,
            :h => 64,
            :path => 'sprites/tile_back.png'
        }
        @ui_taper = {
            :x => (args.grid.right / 2) - 160,
            :y => 100,
            :w => 320,
            :h => 30,
            :path => 'sprites/taper.png'
        }
        @ui_resource_list = build_list_render(@resources, {:x => args.grid.left, :y => args.grid.top})
    end


    def tick_()
        inputs_()
        outputs_()
        logic_()
    end


    def inputs_()
        input_management()

        @last_mouse = inputs.mouse
        @mouse_tile = screen_to_tile_screen(inputs.mouse.point)
    end


    def outputs_()
        render = []
        screen_center = grid.right / 2
        hand_count = 0
        div = 64 + 16
        offset = ((@hand.length * div) / 2) - 9

        render << @constructed.values().flatten()
        render << @ui_deck
        render << @ui_deck_count
        render << @ui_taper
        render << @ui_timer_bar
        render << @ui_resource_list
        render << @event_handler.get_renders

        @hand.each() do |tile|
            tile.x = (screen_center + div * hand_count) - offset
            tile.y = 16 

            render << tile

            hand_count += 1
        end

        if(@tile_select != nil)
            render << @mouse_tile.merge(@tiling)
                .merge({path: @hand[@tile_select].path})
        end

        outputs.primitives << render
    end


    def logic_()
        workers_left = @resources.pop_housed.value
        tile_index = 0
        did_interact = false

        @ui_timer_bar.w = calc_timer_bar_width()
        @ui_deck_count.text = @deck.length()

        # Updates of resources
        handle_housing_distribution()

        # Updates to the deck and hand
        if(timer_state() == 0)
            @tile_select = nil
            @deck += @hand if(@hand.length() > 0)
            @hand = []
        end

        if(@hand.length == 0)
            @tick_offset = state.tick_count
            add_cards_to_hand()
        end

        @hand.each() do |tile|
            if( input_ready(@input_manager.mouse.left) && 
                geometry.inside_rect?(inputs.mouse.point, tile)
            )
                @tile_select = tile_index
                did_interact = true
            end

            tile_index += 1
        end

        if( input_ready(@input_manager.mouse.left) && 
            geometry.inside_rect?(inputs.mouse.point, @ui_deck) &&
            @resources.tier_one_resources.value - @tile_cost >= 0 &&
            @global_tiles.length() > 0
        )
            @resources.tier_one_resources.value -= @tile_cost
            @deck << @global_tiles.sample().clone()

            did_interact = true
        end

        @constructed.values().each() do |tile|
            if(tile.is_a?(Producer) && workers_left > 0)
                workers_left -= 1
                @resources = tile.producing(@resources, state.tick_count)
            end
        end

        if( !@constructed.has_key?(@mouse_tile) && 
            !@tile_select.nil? &&
            !did_interact &&
            input_ready(@input_manager.mouse.left) &&
            @hand[@tile_select].is_connected(@constructed, @tiling, @mouse_tile)
        )
            @constructed[@mouse_tile] = @hand[@tile_select].clone()
            @constructed[@mouse_tile].x = @mouse_tile.x
            @constructed[@mouse_tile].y = @mouse_tile.y
            @constructed[@mouse_tile].w = @tiling.w
            @constructed[@mouse_tile].h = @tiling.h

            puts @constructed[@mouse_tile]
            @producers[@mouse_tile] = @constructed[@mouse_tile] if(@constructed[@mouse_tile].is_a?(Producer))

            @global_tiles = @hand[@tile_select].inject_into_global(@global_tiles)
            @deck = @hand[@tile_select].inject_into_deck(@deck)
            @resources = @hand[@tile_select].add_resources(@resources)

            @deck = @deck.shuffle()

            @hand.delete_at(@tile_select)

            @tile_select = nil
        end

        @event_handler.create_event(state.tick_count)
        @resources = @event_handler.event_proceed(@resources, state.tick_count)

        @ui_resource_list = build_list_render(@resources, {:x => args.grid.left, :y => args.grid.top})
    end


    def input_management()
        @input_manager.mouse.left = state.tick_count if(inputs.mouse.button_left)
    end


    def input_ready(input_tick)
        return input_tick == (state.tick_count - 1)
    end


    def screen_to_tile_screen(mouse)
        x = (mouse.x / @tiling.w).floor()
        y = (mouse.y / @tiling.h).floor()

        return {
            :x => x * @tiling.w,
            :y => y * @tiling.h
        }
    end


    def calc_timer_bar_width()
        return 0.5 * ((args.state.tick_count - @tick_offset) % @@max_timer)
    end


    def timer_state()
        return ((args.state.tick_count - @tick_offset) % @@max_timer)
    end


    def build_list_render(list, position)
        list_render = []
        list_index = 0

        list.entries().each() do |key, value|
            next if(value.has_key?(:children))

            text = "#{value.text}: #{value.value}"
            list_render << {
                :x => position.x,
                :y => position.y - (list_index * 17),
                :size_enum => 0,
                :text => text
            }.label!()

            list_index += 1
        end

        return list_render
    end


    def add_cards_to_hand()
        @hand_size.times do |index|
            break if(@deck.size() == 0)

            hand_addition = @deck.shift

            hand_addition.w = @in_hand_size
            hand_addition.h = @in_hand_size

            @hand << hand_addition
        end
    end


    def handle_housing_distribution()
        if(@resources.housing.value > 0 && @resources.pop_homeless.value > 0)
            @resources.housing.value -= 1
            @resources.pop_homeless.value -= 1
            @resources.pop_housed.value += 1
        end
    end


    def clone(obj)
        new_obj = {}

        for key, value in obj
            new_obj[key] = value
        end

        return new_obj
    end


    def serialize()
        {
            hand: @hand,
            deck: @deck,
            resources: @resources,
            constructed: @constructed,
            global_tiles: @global_tiles
        }
    end

    
    def inspect()
        serialize().to_s()
    end


    def to_s()
        serialize().to_s()
    end
end


def tick(args)
    $game ||= Game.new(args: args)

    $game.args = args
    $game.tick_()
end