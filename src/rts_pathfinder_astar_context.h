#ifndef RTS_PATHFINDER_ASTAR_CONTEXT
#define RTS_PATHFINDER_ASTAR_CONTEXT

#include <cstdint>
#include <vector>

namespace godot
{
    struct OpenListEntry
    {
        int32_t f_cost {-1};
        int32_t cell_index {-1};

        bool operator>(const OpenListEntry& other) const;
    };

    struct AStarContext
    {
        int32_t* parent_indices {nullptr};
        int32_t* g_costs {nullptr};
        uint32_t* visited_search_ids {nullptr};
        uint32_t current_search_id {0};
        uint32_t capacity {0};
        std::vector<OpenListEntry> open_list;
    };

    void init_context(AStarContext& context, uint32_t total_cells);
    void destroy_context(AStarContext& context);
}

#endif // RTS_PATHFINDER_ASTAR_CONTEXT
