class Tile
    attr_sprite
    attr_accessor


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


    def is_connected(constructed, tiling, mouse_tile)
        north = {:x => mouse_tile.x, :y => mouse_tile.y + tiling.h}
        south = {:x => mouse_tile.x, :y => mouse_tile.y - tiling.h}
        east = {:x => mouse_tile.x + tiling.w, :y => mouse_tile.y}
        west = {:x => mouse_tile.x - tiling.w, :y => mouse_tile.y}

        return  constructed.has_key?(north) || constructed.has_key?(south) ||
                constructed.has_key?(east) || constructed.has_key?(west) ||
                self.is_a?(Manor)
    end


    def clone()
        return Tile.new(
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