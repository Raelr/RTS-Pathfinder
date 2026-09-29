#include "rts_grid_data.h"
#include "godot_cpp/core/print_string.hpp"
#include "godot_cpp/variant/vector2i.hpp"
#include "rts_grid_data.h"
#include "rts_grid_data.h"
#include <cmath>
#include <cstdint>
#include <cstring>
#include <godot_cpp/variant/utility_functions.hpp>

namespace godot
{
    RTSGridData::RTSGridData(const godot::PackedByteArray& buffer, godot::Vector2i dims, float cell_size)
        : grid_dimensions {dims}, cell_size {cell_size}
    {
        if (dims.x > MAX_CELLS_PER_DIMENSION || dims.y > MAX_CELLS_PER_DIMENSION)
        {
            print_error("GRIDDATA - exceeded maximum number of allowable cells");
            return;
        }

        grid_buffer.resize(MAX_CELLS_PER_DIMENSION * MAX_CELLS_PER_DIMENSION);
        grid_buffer.fill(1);

        resize_bounds(dims, cell_size);

        if (buffer.is_empty()) return;

        uint64_t copy_size = std::min(buffer.size(), grid_buffer.size());
        std::memcpy(grid_buffer.ptrw(), buffer.ptr(), copy_size);
        emit_changed();
    }

    void RTSGridData::_bind_methods()
    {
        // Bind dimensions
            ClassDB::bind_method(D_METHOD("set_grid_dimensions", "dims"), &RTSGridData::set_grid_dimensions);
            ClassDB::bind_method(D_METHOD("get_grid_dimensions"), &RTSGridData::get_grid_dimensions);
            ClassDB::add_property("RTSGridData", PropertyInfo(Variant::VECTOR2I, "grid_dimensions"), "set_grid_dimensions", "get_grid_dimensions");

            // Bind cell size
            ClassDB::bind_method(D_METHOD("set_cell_size", "size"), &RTSGridData::set_cell_size);
            ClassDB::bind_method(D_METHOD("get_cell_size"), &RTSGridData::get_cell_size);
            ClassDB::add_property("RTSGridData", PropertyInfo(Variant::FLOAT, "cell_size"), "set_cell_size", "get_cell_size");

            // Bind grid buffer (hidden from UI inspector via STORAGE flag to prevent freezing)
            ClassDB::bind_method(D_METHOD("set_grid_buffer", "buffer"), &RTSGridData::set_grid_buffer);
            ClassDB::bind_method(D_METHOD("get_grid_buffer"), &RTSGridData::get_grid_buffer);
            ClassDB::add_property("RTSGridData", PropertyInfo(Variant::PACKED_BYTE_ARRAY, "grid_buffer", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE), "set_grid_buffer", "get_grid_buffer");

            ClassDB::bind_method(D_METHOD("is_in_bounds", "world_coords"), &RTSGridData::is_in_bounds);
            ClassDB::bind_method(D_METHOD("world_to_grid", "coordinate"), &RTSGridData::world_to_grid);
            ClassDB::bind_method(D_METHOD("index_to_cell", "index"), &RTSGridData::index_to_cell);
            ClassDB::bind_method(D_METHOD("is_cell_walkable", "coordinate"), &RTSGridData::is_cell_walkable);
            ClassDB::bind_method(D_METHOD("set_cell_walkable", "coordinate", "walkable"), &RTSGridData::set_cell_walkable);

    }

    void RTSGridData::set_grid_buffer(const godot::PackedByteArray& buffer)
    {
        if (buffer.size() > grid_buffer.size())
        {
            print_error("GRIDDATA - provided size is greater than max allowable size");
            return;
        }

        if (buffer.is_empty()) return;

        int64_t target_size = grid_dimensions.x * grid_dimensions.y;

        target_size = target_size <= 0 ? MAX_CELLS_PER_DIMENSION * MAX_CELLS_PER_DIMENSION : target_size;

        int64_t copy_size = std::min(buffer.size(), target_size);
        std::memcpy(grid_buffer.ptrw(), buffer.ptr(), copy_size);

        emit_changed();
    }

    godot::PackedByteArray RTSGridData::get_grid_buffer() const
    {
        return grid_buffer;
    }

    void RTSGridData::set_grid_dimensions(const godot::Vector2i& dims)
    {
        if (dims.x > MAX_CELLS_PER_DIMENSION || dims.y > MAX_CELLS_PER_DIMENSION)
        {
            print_error("GRIDDATA - Provided cell range exceeds maximum allowable row/column size");
            return;
        }

        resize(dims);
        resize_bounds(dims, cell_size);

        emit_changed();
    }

    godot::Vector2i RTSGridData::get_grid_dimensions() const
    {
        return grid_dimensions;
    }

    void RTSGridData::set_cell_size(float size)
    {
        cell_size = size;
        resize_bounds(grid_dimensions, size);
        emit_changed();
    }

    float RTSGridData::get_cell_size() const
    {
        return cell_size;
    }

    void RTSGridData::resize(godot::Vector2i new_dims)
    {
        if (new_dims == grid_dimensions) return;
        if (!dimensions_valid(new_dims))
        {
            print_error("GRIDDATA - Provided cell range either exceeds maximum allowable row/column size, or is zero");
            return;
        }
        godot::Vector2i old_dims = grid_dimensions;
        uint8_t* ptr = grid_buffer.ptrw();

        int min_x = std::min(old_dims.x, new_dims.x);
        int min_y = std::min(old_dims.y, new_dims.y);

        if (new_dims.x > old_dims.x)
        {
            for (int y = 0; y < min_y; ++y)
            {
                int old_start = y * old_dims.x;
                int new_start = y * new_dims.x;

                std::memmove(ptr + new_start, ptr + old_start, min_x);
                std::memset(ptr + new_start + min_x, 1, new_dims.x - min_x);
            }
        }

        if (new_dims.x < old_dims.x)
        {
            for (int y = min_y-1; y >= 0; --y)
            {
                int old_start = y * old_dims.x;
                int new_start = y * new_dims.x;
                std::memmove(ptr + new_start, ptr + old_start, min_x);
            }
        }

        if (new_dims.y > old_dims.y)
        {
            int old_content_size = old_dims.y * new_dims.x;
            int new_total_size = new_dims.y * new_dims.x;
            std::memset(ptr + old_content_size, 1, new_total_size - old_content_size);
        }

        grid_dimensions = new_dims;
        emit_changed();
    }

    void RTSGridData::resize_bounds(godot::Vector2i new_dims, float new_cell_size)
    {
        bounds = Rect2(godot::Vector2i(0,0), new_dims * new_cell_size);
    }

    bool RTSGridData::dimensions_valid(godot::Vector2i dims)
    {
        return dims.x > 0 && dims.y > 0 && dims.x <= MAX_CELLS_PER_DIMENSION && dims.y <= MAX_CELLS_PER_DIMENSION;
    }

    bool RTSGridData::is_in_bounds(Vector2i coordinate)
    {
        return bounds.has_point(coordinate);
    }

    int64_t RTSGridData::coord_to_index(Vector2i coordinate)
    {
        if (!is_coord_in_bounds(coordinate)) return INVALID_INDEX;

        return coordinate.y * grid_dimensions.x + coordinate.x;
    }

    int32_t RTSGridData::get_cell_index(Vector2i coordinate)
    {
        if (!is_in_bounds(coordinate)) return INVALID_INDEX;

        Vector2i grid_coords = world_to_grid(coordinate);

        return coord_to_index(grid_coords);
    }

    Vector2i RTSGridData::index_to_cell(int32_t index)
    {
        if (index < 0 || index >= grid_dimensions.x * grid_dimensions.y) return INVALID_CELL;

        return Vector2i(index % grid_dimensions.x, index / grid_dimensions.x);
    }

    bool RTSGridData::is_cell_walkable(Vector2i coordinate)
    {
        int32_t index = coord_to_index(coordinate);

        if (index == INVALID_INDEX) return false;

        return grid_buffer[index] & CELL_MASKS::WALKABLE;
    }

    void RTSGridData::set_cell_walkable(Vector2i coordinate, bool walkable)
    {
        int32_t index = coord_to_index(coordinate);

        if (index == INVALID_INDEX) return;

        if (walkable) grid_buffer[index] |= CELL_MASKS::WALKABLE;
        else grid_buffer[index] &= ~CELL_MASKS::WALKABLE;
        emit_changed();
    }

    bool RTSGridData::is_coord_in_bounds(Vector2i coordinate)
    {
        return coordinate.x >= 0 && coordinate.y >= 0 && coordinate.x < grid_dimensions.x && coordinate.y < grid_dimensions.y;
    }

    godot::Vector2i RTSGridData::world_to_grid(Vector2i world_coords)
    {
        int32_t x = std::floor(world_coords.x / cell_size);
        int32_t y = std::floor(world_coords.y / cell_size);

        return godot::Vector2i(x, y);
    }
}
