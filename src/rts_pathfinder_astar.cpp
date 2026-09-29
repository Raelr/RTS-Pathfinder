#include "rts_pathfinder_astar.h"
#include "godot_cpp/core/print_string.hpp"
#include "godot_cpp/variant/packed_vector2_array.hpp"
#include "rts_grid_data.h"
#include "rts_pathfinder_astar_context.h"
#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <functional>

namespace godot
{
    struct Neighbour
    {
        Vector2i pos;
        int32_t cost;
    };

    std::array<Neighbour, MAX_NEIGHBOURS> get_neighbours(Vector2i cell)
    {
        return std::array<Neighbour, MAX_NEIGHBOURS> {{
            { {cell.x + 1, cell.y},     G_COST_ADJACENT },
            { {cell.x + 1, cell.y + 1}, G_COST_DIAGONAL },
            { {cell.x + 1, cell.y - 1}, G_COST_DIAGONAL },
            { {cell.x,     cell.y + 1}, G_COST_ADJACENT },
            { {cell.x - 1, cell.y + 1}, G_COST_DIAGONAL },
            { {cell.x - 1, cell.y},     G_COST_ADJACENT },
            { {cell.x - 1, cell.y - 1}, G_COST_DIAGONAL },
            { {cell.x,     cell.y - 1}, G_COST_ADJACENT }
        }};
    }

    PackedVector2Array find_path_astar(Vector2i source, Vector2i destination, Ref<RTSGridData> grid, AStarContext& context) {
        if (grid.is_null())
        {
            ERR_PRINT("RTSPathFinder::find_path: Grid is null!");
            return PackedVector2Array();
        }

        PackedVector2Array path;

        int32_t start_index = grid->get_cell_index(source);
        int32_t dest_index = grid->get_cell_index(destination);

        if (start_index == INVALID_INDEX ||!grid->is_cell_walkable(source)
            || dest_index == INVALID_INDEX || !grid->is_cell_walkable(destination)) return path;

        context.g_costs[start_index] = 0;
        context.parent_indices[start_index] = -1;
        context.visited_search_ids[start_index] = context.current_search_id;

        int32_t h_cost = calculate_h_cost(source, destination);
        push_cell_to_heap(context, start_index, h_cost);

        int32_t current_index = -1;

        bool path_found = false;

        while (!context.open_list.empty()) {

            OpenListEntry entry = pop_cell_from_heap(context);
            current_index = entry.cell_index;

            int32_t current_g_cost = context.g_costs[current_index];
            Vector2i current_cell = grid->index_to_cell(current_index);
            int32_t current_h_cost = calculate_h_cost(current_cell, destination);

            if (entry.f_cost > current_g_cost + current_h_cost) continue;

            if (current_index == dest_index)
            {
                path_found = true;
                break;
            }

            auto neighbours = get_neighbours(current_cell);

            for (const auto& neighbour : neighbours)
            {
                if (!grid->is_in_bounds(neighbour.pos) || !grid->is_cell_walkable(neighbour.pos)) continue;

                int32_t delta_x = neighbour.pos.x - current_cell.x;
                int32_t delta_y = neighbour.pos.y - current_cell.y;

                int64_t new_index = grid->get_cell_index(neighbour.pos);
                int32_t new_g_cost = current_g_cost + neighbour.cost;

                if (delta_x != 0 && delta_y != 0)
                {
                        bool walkable_x = grid->is_cell_walkable(Vector2i(current_cell.x + delta_x, current_cell.y));
                        bool walkable_y = grid->is_cell_walkable(Vector2i(current_cell.x, current_cell.y + delta_y));

                        // if (!walkable_x || !walkable_y) continue;
                        if (!walkable_x && !walkable_y) continue;
                }

                bool is_unvisited = context.visited_search_ids[new_index] != context.current_search_id;

                if (!is_unvisited && new_g_cost >= context.g_costs[new_index]) continue;

                context.g_costs[new_index] = new_g_cost;
                context.parent_indices[new_index] = current_index;
                context.visited_search_ids[new_index] = context.current_search_id;

                int32_t h_cost = calculate_h_cost(neighbour.pos, destination);
                push_cell_to_heap(context, new_index, new_g_cost + h_cost);

            }
        }

        if (!path_found) return path;

        // Retrace path

        current_index = dest_index;

        while(current_index != start_index)
        {
            path.append(grid->index_to_cell(current_index));
            current_index = context.parent_indices[current_index];
        }

        path.append(source);
        path.reverse();

        return path;
    }

    void push_cell_to_heap(AStarContext& context, int32_t cell_index, int32_t f_cost)
    {
        if (cell_index < 0 || f_cost < 0 || context.capacity <= 0 || cell_index >= context.capacity) return;

        OpenListEntry entry = { f_cost, cell_index };

        context.open_list.push_back(entry);
        std::push_heap(context.open_list.begin(), context.open_list.end(), std::greater<OpenListEntry>{});
    }

    OpenListEntry pop_cell_from_heap(AStarContext& context)
    {
        OpenListEntry entry = context.open_list.front();

        std::pop_heap(context.open_list.begin(), context.open_list.end(), std::greater<OpenListEntry>{});

        context.open_list.pop_back();

        return entry;
    }

    int32_t calculate_h_cost(Vector2i start_pos, Vector2i end_pos)
    {
        Vector2i delta = end_pos - start_pos;
        int32_t x = std::abs(delta.x);
        int32_t y = std::abs(delta.y);

        return 10 * std::max(x, y) + 4 * std::min(x, y);
    }
}
