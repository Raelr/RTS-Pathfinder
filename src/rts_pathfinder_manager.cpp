#include "rts_pathfinder_manager.h"
#include "godot_cpp/classes/worker_thread_pool.hpp"
#include "godot_cpp/variant/packed_vector2_array.hpp"
#include "rts_pathfinder_astar.h"
#include "rts_pathfinder_astar_context.h"

namespace godot
{
    void RTSPathfinderManager::_bind_methods()
    {
        ClassDB::bind_method(D_METHOD("request_astar_path_async", "start_pos", "end_pos", "grid", "callback"), &RTSPathfinderManager::request_astar_path_async);
    }

    RTSPathfinderManager::RTSPathfinderManager() {}

    void RTSPathfinderManager::request_astar_path_async(Vector2i start_pos, Vector2i end_pos, Ref<RTSGridData> grid, Callable callback)
    {
        if (grid.is_null()) return;

        Callable task = callable_mp(this, &RTSPathfinderManager::_process_astar_path_task).bind(start_pos, end_pos, grid, callback);

        WorkerThreadPool::get_singleton()->add_task(task);
    }

    void RTSPathfinderManager::_process_astar_path_task(Vector2i start_pos, Vector2i end_pos, Ref<RTSGridData> grid, Callable callback)
    {
        thread_local AStarContext context;

        Vector2i grid_dims = grid->get_grid_dimensions();
        uint32_t total_size = grid_dims.x * grid_dims.y;
        total_size = total_size * 1.25;

        init_context(context, total_size);

        PackedVector2Array final_path = find_path_astar(start_pos, end_pos, grid, context);

        callback.call_deferred(final_path);
    }
}
