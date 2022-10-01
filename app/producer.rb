class Producer < Tile
    def initialize(**args)
        super

        @path = 'sprites/producer_tile.png'

        @time_to_produce = 600 # 10 seconds in ticks
        @produces = {
            :tier_one_resources => 1
        }
    end


    def add_resources(resources)
        return resources
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


    def clone()
        return Producer.new(
            x: @x,
            y: @y,
            w: @w,
            h: @h,
            path: @path
        )
    end


    def serialize()
    end


    def to_s()
        serialize().to_s()
    end


    def inspect()
        serialize().inspect()
    end
end