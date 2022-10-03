class Game
    attr_gtk
    attr_accessor :constructed, :hand, :event_handler


    @@id = 0
    @@max_timer = 600
    @@imperial_timer = 1200 
    @@text_width = 9.95


    def initialize(args: nil)
        @last_mouse = args.inputs.mouse
        @game_started = 0
        @fade_in = 0
        @fade_builder = 1
        @fade_ending = 255
        @fade_ending_state = 2
        @deck = []
        @hand = []
        @global_tiles = []
        @hand_size = 3
        @in_hand_size = 64
        @map = {}
        @tiling = {:w => 32, :h => 32}
        @tile_select = nil
        @tile_cost = 3
        @tick_offset = 0
        @actual_start_tick = 0
        @constructed = {}
        @producers = {}
        @floater_ui = []
        @imperail_tax = 0
        @imperail_tax_increase = 3
        @failure_limit = -20
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

        event_initialize(args: args)
        ui_initialize(args: args)
        load_level(args: args)
    end


    def event_initialize(args: nil)
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

        @event_handler.add_to_chain("Your first tax to the imperial regime will be #{@imperail_tax} Tier I goods when the blue bar fills.")
        @event_handler.add_to_chain("Do not incure a tax debt of less than #{@failure_limit}, or your charter will be revoked.")
    end


    def ui_initialize(args: nil)
        text_height = 15
        text_width = 8.5 

        start_text = "Click to Start"
        lose_text = "The Imperial Council Has Revoked Your Charter. Click to be Reinstated."

        @ui_events = []

        @ui_start_text = {
            :x => (args.grid.right / 2) - (start_text.length * (text_width - 2)),
            :y => (args.grid.top / 2),
            :size_enum => 4,
            :text => start_text
        }
        @ui_lose_text = {
            :x => (args.grid.right / 2) - (lose_text.length * (text_width - 2)),
            :y => (args.grid.top / 2),
            :size_enum => 4,
            :text => lose_text 
        }
        @ui_timer_bar = {
            :x => (args.grid.right / 2) - 150,
            :y => 105,
            :w => 0,
            :h => 20,
            :path => 'sprites/green_fill_bar.png'
        }
        @ui_imperial_bar = {
            :x => (args.grid.right / 2) - 150,
            :y => args.grid.top - 48, 
            :w => 0,
            :h => 20,
            :path => 'sprites/imperial_fill.png'
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
        @ui_imperial_taper = {
            :x => (args.grid.right / 2) - 160,
            :y => args.grid.top - 52,
            :w => 320,
            :h => 30,
            :path => 'sprites/taper.png'
        }
        @ui_resource_list = build_list_render(@resources, {:x => args.grid.left, :y => args.grid.top})
    end


    def load_level(args: nil)
        @map = args.gtk.deserialize_state('data/first_map.map')

        @map.values().each() do |tile|
            tile.sprite!()
        end
    end


    def tick_()
        if(@game_started == 2)
            inputs_()
            outputs_()
            logic_()
        elsif(@game_started == 1)
            animate_in_output()
        elsif(@game_started == 3)
            animate_out_output()
        elsif(@game_started == 4)
            lose_()
        else
            start_()
        end
    end


    def start_()
        if(inputs.mouse.button_left)
            @game_started = 1 
        end

        outputs.primitives << @ui_start_text
    end


    def lose_()
        @fade_in = 0
        @fade_builder = 1
        @fade_ending = 255
        @fade_ending_state = 2

        if(inputs.mouse.button_left)
            initialize(args: args)
            @game_started = 1 
        end

        outputs.primitives << @ui_lose_text
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

        render << @map.values()
        render << @constructed.values().flatten()
        render << @ui_deck
        render << @ui_deck_count
        render << @ui_timer_bar
        render << @ui_imperial_bar
        render << @ui_taper
        render << @ui_imperial_taper
        render << @ui_resource_list
        render << @event_handler.get_renders
        render << @floater_ui

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


    def animate_in_output()
        render = []
        screen_center = grid.right / 2
        hand_count = 0
        div = 64 + 16
        offset = ((@hand.length * div) / 2) - 9

        render << @map.values().map() do |tile| 
            tile.a = @fade_in 
            tile
        end
        render << @constructed.values().flatten().map() do |construct|
            construct.a
            construct
        end

        if(@tile_select != nil)
            render << @mouse_tile.merge(@tiling)
                .merge({path: @hand[@tile_select].path})
        end

        outputs.primitives << render

        if(@fade_in > @fade_ending)
            @game_started = @fade_ending_state
            @actual_start_tick = state.tick_count
        end

        @fade_in += @fade_builder
    end


    def animate_out_output()
        render = []
        screen_center = grid.right / 2
        hand_count = 0
        div = 64 + 16
        offset = ((@hand.length * div) / 2) - 9

        render << @map.values().map() do |tile| 
            tile.a = @fade_in 
            tile
        end
        render << @constructed.values().flatten().map() do |construct|
            construct.a
            construct
        end

        if(@tile_select != nil)
            render << @mouse_tile.merge(@tiling)
                .merge({path: @hand[@tile_select].path})
        end

        outputs.primitives << render

        if(@fade_in < @fade_ending)
            @game_started = @fade_ending_state
            @actual_start_tick = state.tick_count
            puts @actual_start_tick
        end

        @fade_in += @fade_builder
    end


    def logic_()
        workers_left = @resources.pop_housed.value
        tile_index = 0
        floater_index = 0
        did_interact = false
        producer_count = 0

        if(@resources.tier_one_resources.value < @failure_limit)
            @game_started = 3
            @fade_builder = -1 * @fade_builder
            @fade_in = 255
            @fade_ending = 0
            @fade_ending_state = 4
        end

        @ui_timer_bar.w = calc_timer_bar_width()
        @ui_deck_count.text = @deck.length()

        @ui_imperial_bar.w = calc_imperial_payment()

        # Updates of resources
        handle_housing_distribution()

        # Updates to the deck and hand
        if(timer_state() == 0 && @deck.length() > 0)
            @tile_select = nil
            @deck += @hand if(@hand.length() > 0)
            @hand = []
        end

        if(@hand.length == 0 && @deck.length() > 0)
            puts 'hello'
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

        @constructed.entries().each() do |key, tile|
            if(tile.is_a?(Producer) && workers_left > 0)
                producer_count += 1
                workers_left -= 1
                @resources = tile.producing(@resources, @map[key], state.tick_count)

                if(tile.produce_this_tick > 0)
                    floater = {
                        :x => tile.x + (tile.w / 2),
                        :y => tile.y + tile.h,
                        :delta_x => 0,
                        :delta_y => 1,
                        :death_tick => state.tick_count + 300,
                        :text => "+#{tile.produce_this_tick}"
                    }

                    @floater_ui << floater
                end
            end
        end

        if( !@constructed.has_key?(@mouse_tile) && 
            !@tile_select.nil? &&
            !did_interact &&
            input_ready(@input_manager.mouse.left) &&
            @hand[@tile_select].is_connected(@constructed, @tiling, @mouse_tile) &&
            @hand[@tile_select].can_place(@map, @mouse_tile)
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

        @floater_ui.delete_if() do |floater|
            floater.death_tick < state.tick_count
        end

        @floater_ui.each() do |floater|
            floater.x += floater.delta_x
            floater.y += floater.delta_y
        end


        @event_handler.create_event(state.tick_count)
        @resources = @event_handler.event_proceed(@resources, state.tick_count)

        @ui_resource_list = build_list_render(@resources, {:x => args.grid.left, :y => args.grid.top})

        if(imperial_timer_state() == 0)
            @resources.tier_one_resources.value -= @imperail_tax

            @event_handler.add_to_chain("You have paid the imperial regime #{@imperail_tax} Tier I goods.")
            @imperail_tax += @imperail_tax_increase * producer_count
            @event_handler.add_to_chain("Your next payment will be #{@imperail_tax} Tier I goods.")
        end
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
        return 0.5 * ((args.state.tick_count - @tick_offset - @actual_start_tick) % @@max_timer)
    end


    def calc_imperial_payment()
        filler = (((args.state.tick_count - @actual_start_tick) % @@imperial_timer) * @@max_timer) / @@imperial_timer

        return 0.5 * filler
    end


    def timer_state()
        return ((args.state.tick_count - @tick_offset - @actual_start_tick) % @@max_timer)
    end


    def imperial_timer_state()
        return ((args.state.tick_count - @actual_start_tick) % @@imperial_timer)
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