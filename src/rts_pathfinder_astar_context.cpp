#include "rts_pathfinder_astar_context.h"
#include <cstdlib>

namespace godot
{
    bool OpenListEntry::operator>(const OpenListEntry& other) const
    {
        return f_cost > other.f_cost;
    }

    void init_context(AStarContext& context, uint32_t total_cells)
    {
        if (total_cells == 0) return;

        context.current_search_id += 1;
        context.open_list.clear();

        if (total_cells <= context.capacity) return;

        destroy_context(context);

        context.g_costs = (int32_t*)malloc(sizeof(int32_t) * total_cells);
        context.parent_indices = (int32_t*)malloc(sizeof(int32_t) * total_cells);
        context.visited_search_ids = (uint32_t*)calloc(total_cells, sizeof(uint32_t));
        context.capacity = total_cells;
        context.open_list.reserve(total_cells);
    }

    void destroy_context(AStarContext& context)
    {
        free(context.g_costs);
        free(context.parent_indices);
        free(context.visited_search_ids);

        context.g_costs = nullptr;
        context.parent_indices = nullptr;
        context.visited_search_ids = nullptr;
        context.capacity = 0;
    }
}
