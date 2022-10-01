class Manor < Tile
    def initialize(**args)
        super

        @create_tiles = [
            House.new(),
            House.new(),
            Producer.new(),
            Producer.new(),
            Producer.new()
        ]
    end


    def clone()
        return Manor.new(
            x: @x,
            y: @y,
            w: @w,
            h: @h,
            path: @path
        )
    end
end