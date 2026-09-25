#!/usr/bin/env python

import os
import subprocess
import shutil

GODOT_CPP_VERSION = "10.0.0-stable"
ROOT_DIR = Dir("#").abspath
VENDOR_DIR = os.path.join(ROOT_DIR, "vendor")
GODOT_CPP_PATH = os.path.join(VENDOR_DIR, "godot-cpp")
ADDON_DIR = os.path.join(ROOT_DIR, "rts_pathfinder")
PROJECT_DIR = os.path.join(f"{ROOT_DIR}", "RTS_Pathfinder_Demo", "addons")

def sync_to_project(target, source, env):
    shutil.copytree(ADDON_DIR, os.path.join(PROJECT_DIR, "RTS_pathfinder"), dirs_exist_ok=True)
    return 0

if not os.path.exists(os.path.join(GODOT_CPP_PATH, ".git")):
    print("Godot-cpp not initialised. Initialising now...")
    subprocess.run(["git", "submodule", "update", "--init", "--recursive", "--depth", "0"], check=True)

subprocess.run(["git", "checkout", GODOT_CPP_VERSION], cwd=GODOT_CPP_PATH, capture_output=True, check=True)

env = SConscript(f"{GODOT_CPP_PATH}/SConstruct", {"api_version": "4.7"})

env.Append(CPPPATH=["src/"])
sources = Glob("src/*.cpp")

lib_name = "{}/bin/rts_grid{}{}".format(ADDON_DIR, env["suffix"], env["SHLIBSUFFIX"])
library = env.SharedLibrary(target=lib_name, source=sources)

Default(library)

env.AddPostAction(library, sync_to_project)
