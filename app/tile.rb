class Tile
    attr_sprite
    attr_accessor :type


    def initialize(x: 0, y: 0, w: 32, h: 32, path: 'sprites/tile_back.png', resources: {},
        create_tiles: [], created_on: 0, type: :tile
    )
        @x = x
        @y = y
        @w = w
        @h = h
        @path = path

        @_x = x
        @_y = y
        @_w = w
        @_h = h
        @_path = path

        @type = type
        @created_on = created_on
        @create_tiles = create_tiles 
        @resources = resources
        @global_additions = {}
    end


    def inject_into_deck(deck)
        deck += @create_tiles

        return deck
    end


    def add_resources(resources)
        @resources.entries().each do |key, value|
            resources[key].value += value
        end

        return resources
    end


    def clone()
        return Tile.new(
            x: @x,
            y: @y,
            w: @w,
            h: @h,
            path: @path,
            type: @type
        )
    end


    def serialize()
        {type: @type}
    end


    def to_s()
        serialize().to_s()
    end


    def inspect()
        serialize().inspect()
    end
end