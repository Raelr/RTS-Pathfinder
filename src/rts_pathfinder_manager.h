#ifndef RTS_PATHFINDER_MANAGER_H
#define RTS_PATHFINDER_MANAGER_H

#include "godot_cpp/classes/ref_counted.hpp"
#include "godot_cpp/classes/worker_thread_pool.hpp"
#include "rts_grid_data.h"

namespace godot
{
    class RTSPathfinderManager: public RefCounted
    {
        GDCLASS(RTSPathfinderManager, RefCounted)

        protected:
            static void _bind_methods();

        public:
            RTSPathfinderManager();
            ~RTSPathfinderManager() {}
            void request_astar_path_async(Vector2i start_pos, Vector2i end_pos, Ref<RTSGridData> grid, Callable callback);
        private:
            void _process_astar_path_task(Vector2i start_pos, Vector2i end_pos, Ref<RTSGridData> grid, Callable callback);

    };
}

#endif // RTS_PATHFINDER_MANAGER_H
