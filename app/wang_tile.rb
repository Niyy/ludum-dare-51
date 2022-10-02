class Wang_Tile < Tile
    def initialize(base: 'river.png', map: {}, tiling: {}, **args)
        super

        @wang_position = 0
        @base = base
        @to_path = 'sprites/map/'
    end


    def generate_wang_position(map, tiling, mouse_tile, depth = 1)
        _north = north(tiling, mouse_tile)
        _south = south(tiling, mouse_tile)
        _west = west(tiling, mouse_tile)
        _east = east(tiling, mouse_tile)

        has_north = (map.has_key?(_north) && depth != -1) ? 8 : 0
        has_south = (map.has_key?(_south) && depth != -1) ? 2 : 0
        has_west = (map.has_key?(_west) && depth != -1) ? 4 : 0
        has_east = (map.has_key?(_east) && depth != -1) ? 1 : 0

        map[mouse_tile] = self

        if(depth > 0)
            map[_north].generate_wang_position(map, tiling, _north, 0) if(has_north > 0)
            map[_south].generate_wang_position(map, tiling, _south, 0) if(has_south > 0)
            map[_west].generate_wang_position(map, tiling, _west, 0) if(has_west > 0)
            map[_east].generate_wang_position(map, tiling, _east, 0) if(has_east > 0)
        end

        @wang_position = has_north + has_south + has_west + has_east

        @path = @to_path + ("%04b_" % @wang_position) + @base

        puts @wang_position
        puts @path

        return map
    end


    def clone()
        return Wang_Tile.new(
            x: @x,
            y: @y,
            w: @w,
            h: @h,
            base: @base
        )
    end
end