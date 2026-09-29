#ifndef RTS_PATHFINDER_ASTAR_H
#define RTS_PATHFINDER_ASTAR_H

#include "godot_cpp/variant/packed_vector2_array.hpp"
#include "rts_grid_data.h"
#include "rts_pathfinder_astar_context.h"

namespace godot
{
    static constexpr uint8_t MAX_NEIGHBOURS = 8;
    static constexpr uint8_t G_COST_ADJACENT = 10;
    static constexpr uint8_t G_COST_DIAGONAL = 14;

    PackedVector2Array find_path_astar(Vector2i source, Vector2i destination, Ref<RTSGridData> grid, AStarContext& context);
    static void push_cell_to_heap(AStarContext& context, int32_t cell_index, int32_t f_cost);
    static OpenListEntry pop_cell_from_heap(AStarContext& context);
    static int32_t calculate_h_cost(Vector2i start_pos, Vector2i end_pos);
}

#endif
