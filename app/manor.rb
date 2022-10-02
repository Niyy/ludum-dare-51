class Manor < Tile
    def initialize(**args)
        super

        @path = 'sprites/manor_refined.png'

        @create_tiles = [
            House.new(),
            House.new(),
            Producer.new(),
            Producer.new(),
            Producer.new()
        ]
        @global_additions = [
            House.new(),
            Producer.new()
        ]

        puts @create_tiles
        puts @global_additions
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