class Game
    attr_gtk


    def initialize(args: nil)
        @last_mouse = args.inputs.mouse
        @deck = []
        @tiling = {:w => 32, :h => 32}
        @tile_select = nil
    end


    def tick_()
        inputs_()
        outputs_()
        logic_()
    end


    def inputs_()
        @last_mouse = inputs.mouse
        @mouse_tile = screen_to_tile(inputs.mouse.point)
    end


    def outputs_()
        render = []
        screen_center = grid.right / 2
        deck_count = 0
        div = 64 + 16
        offset = (@deck.length * div) / 2

        for tile in @deck
            tile.x = (screen_center + div * deck_count) - offset
            tile.y = 32

            render << tile

            deck_count += 1
        end

        if(@tile_select != nil)
            render << @mouse_tile.merge!(@tiling)
                .merge!({path: @deck[@tile_select].path})
        end

        outputs.primitives << render
    end


    def logic_()
        tile_index = 0

        if(@deck.size < 3)
            @deck << {
                :x => 0,
                :y => 0,
                :w => 64,
                :h => 64,
                :path => 'sprites/house_tile.png'
            }
        end

        for tile in @deck
            if(inputs.mouse.button_left && geometry.inside_rect?(inputs.mouse.click, tile))
                @tile_select = tile_index
                puts @tile_select
            end

            tile_index += 1
        end
    end


    def screen_to_tile(mouse)
        x = (mouse.x / @tiling.w).floor()
        y = (mouse.y / @tiling.h).floor()

        return {
            :x => x * @tiling.w,
            :y => y * @tiling.h
        }
    end


    def serialize()
        {
            deck: @deck
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