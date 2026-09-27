#ifndef RTS_PATHFINDER_GRID_DATA_H
#define RTS_PATHFINDER_GRID_DATA_H

#include "godot_cpp/variant/packed_byte_array.hpp"
#include "godot_cpp/variant/rect2.hpp"
#include "godot_cpp/variant/vector2i.hpp"
#include <godot_cpp/classes/resource.hpp>

namespace godot
{
    constexpr uint16_t MAX_CELLS_PER_DIMENSION = 1024;
    constexpr godot::Vector2i INVALID_CELL = godot::Vector2i(-1,-1);
    constexpr uint64_t INVALID_INDEX = -1;
    constexpr uint8_t DEFAULT_CELL = 1; // 0000 0001

    class RTSGridData: public Resource
    {
        GDCLASS(RTSGridData, Resource)

        public:
            enum CELL_MASKS { WALKABLE = 1 << 0 };
            RTSGridData(const godot::PackedByteArray& buffer, godot::Vector2i dims, float cell_size);
            RTSGridData(const godot::PackedByteArray& buffer, godot::Vector2i dims) : RTSGridData(buffer, dims, 1) {};
            RTSGridData(const godot::PackedByteArray& buffer) : RTSGridData(buffer, godot::Vector2i(32, 32), 1) {};

            RTSGridData() : RTSGridData(godot::PackedByteArray(), godot::Vector2i(32, 32), 1) {}

            static void _bind_methods();

            void set_grid_buffer(const godot::PackedByteArray& buffer);
            godot::PackedByteArray get_grid_buffer() const;

            void set_grid_dimensions(const godot::Vector2i& dims);
            godot::Vector2i get_grid_dimensions() const;

            void set_cell_size(float size);
            float get_cell_size() const;

            bool is_in_bounds(Vector2i coordinate);
            bool is_cell_walkable(Vector2i coordinate);
            void set_cell_walkable(Vector2i coordinate, bool walkable);
            godot::Vector2i world_to_grid(Vector2i world_coords);

        private:
            void resize(godot::Vector2i new_dims);
            void resize_bounds(godot::Vector2i new_dims, float new_cell_size);
            bool is_coord_in_bounds(Vector2i coordinate);
            int64_t coord_to_index(Vector2i coordinate);
            int64_t get_cell_index(Vector2i coordinate);
            bool dimensions_valid(godot::Vector2i dims);
            godot::PackedByteArray grid_buffer;
            godot::Vector2i grid_dimensions;
            godot::Rect2 bounds;
            float cell_size;
    };

}

#endif // RTS_PATHFINDER_GRID_DATA_H
