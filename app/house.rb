class House < Tile
    def initialize(**args)
        super

        @path = 'sprites/house_tile.png'
        @resources = {
            :housing => 4
        }
    end


    def clone()
        return House.new(
            x: @x,
            y: @y,
            w: @w,
            h: @h,
            path: @path
        )
    end
end