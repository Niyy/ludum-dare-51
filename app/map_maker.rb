class Map_Maker
    attr_gtk
    attr_accessor :map, :hand


    def initialize(args: nil)
        @tiling = {:w => 32, :h => 32}
        @map = {}
        @tile_select = nil
        @input_manager = {
            :mouse => {
                :left => -1,
                :right => -1
            }
        }
        @map_max_position = 0

        @mouse_tile = screen_to_tile_screen(args.inputs.mouse.point)

        initialize_hand()
    end


    def initialize_hand()
        @hand = []

        river_tile = Wang_Tile.new()
        fertial_plane = Wang_Tile.new(
            base: 'fertial_plane.png'
        )
        mountain_tile = Wang_Tile.new(
            base: 'mountain.png'
        )

        river_tile.generate_wang_position(@map, @tiling, @mouse_tile, -1)
        fertial_plane.generate_wang_position(@map, @tiling, @mouse_tile, -1)
        mountain_tile.generate_wang_position(@map, @tiling, @mouse_tile, -1)

        @hand << river_tile
        @hand << fertial_plane
        @hand << mountain_tile

        puts "this is the starting hand: #{@hand}"
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
        renders = []
        hand_count = 0
        div = 64 + 16
        screen_center = grid.right / 2
        offset = ((@hand.length * div) / 2) - 9

        renders << @map.values()
        renders << {
            path: 'sprites/tile_back.png', 
            a: 100
        }.merge(@mouse_tile).merge(@tiling)

        @hand.each() do |tile|
            tile.x = (screen_center + div * hand_count) - offset
            tile.y = 16 

            renders << tile

            hand_count += 1
        end

        outputs.primitives << renders
    end


    def logic_()
        tile_index = 0
        did_interact = false

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
            !@tile_select.nil? && !did_interact
        )
            placed_tile = @hand[@tile_select].clone()

            placed_tile.x = @mouse_tile.x
            placed_tile.y = @mouse_tile.y
            placed_tile.w = @tiling.w
            placed_tile.h = @tiling.h
            @map = placed_tile.generate_wang_position(@map, @tiling, @mouse_tile)
        end

        if( input_ready(@input_manager.mouse.right) && @map.has_key?(@mouse_tile))
            _north = @m

            @map.delete(@mouse_tile)
        end
    end


    def input_management()
        @input_manager.mouse.left = state.tick_count if(inputs.mouse.button_left)
        @input_manager.mouse.right = state.tick_count if(inputs.mouse.button_right)
    end


    def input_ready(input_tick)
        return input_tick == (state.tick_count)
    end


    def screen_to_tile_screen(mouse)
        x = (mouse.x / @tiling.w).floor()
        y = (mouse.y / @tiling.h).floor()

        return {
            :x => x * @tiling.w,
            :y => y * @tiling.h
        }
    end
end


def tick(args)
    $map_maker ||= Map_Maker.new(args: args)

    $map_maker.args = args
    $map_maker.tick_()
end