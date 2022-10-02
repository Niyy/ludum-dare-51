class Producer < Tile
    def initialize(**args)
        super

        @path = 'sprites/field.png'

        @time_to_produce = 600 # 10 seconds in ticks
        @resources = {
            :jobs => 1
        }
        @produces = {
            :tier_one_resources => 1
        }
    end


    def producing(resources, tick_count)
        relative_tick_count = tick_count - @created_on

        if(relative_tick_count % @time_to_produce == 0)
            @produces.entries().each do |key, value|
                puts key
                puts value

                resources[key].value += value
            end
        end

        return resources
    end


    def is_connected(constructed, tiling, mouse_tile)
        north = {:x => mouse_tile.x, :y => mouse_tile.y + tiling.h}
        south = {:x => mouse_tile.x, :y => mouse_tile.y - tiling.h}
        east = {:x => mouse_tile.x + tiling.w, :y => mouse_tile.y}
        west = {:x => mouse_tile.x - tiling.w, :y => mouse_tile.y}

        north_type = constructed.has_key?(north) && (constructed[north].is_a?(House) || constructed[north].is_a?(Producer))
        south_type = constructed.has_key?(south) && (constructed[south].is_a?(House) || constructed[south].is_a?(Producer))
        east_type = constructed.has_key?(east) && (constructed[east].is_a?(House) || constructed[east].is_a?(Producer))
        west_type = constructed.has_key?(west) && (constructed[west].is_a?(House) || constructed[west].is_a?(Producer))

        return  (constructed.has_key?(north) || constructed.has_key?(south) ||
                constructed.has_key?(east) || constructed.has_key?(west)) &&
                (north_type || south_type || east_type || west_type)
    end


    def clone()
        return Producer.new(
            x: @x,
            y: @y,
            w: @w,
            h: @h,
            path: @path
        )
    end


#    def serialize()
#    end
#
#
#    def to_s()
#        serialize().to_s()
#    end
#
#
#    def inspect()
#        serialize().inspect()
#    end
end