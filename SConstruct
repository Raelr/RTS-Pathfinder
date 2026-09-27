#!/usr/bin/env python

from SCons.Script import *
import os
import subprocess
import shutil

env = Environment()

GODOT_CPP_VERSION = "10.0.0-stable"
ROOT_DIR = env.Dir("#").abspath
VENDOR_DIR = os.path.join(ROOT_DIR, "vendor")
GODOT_CPP_PATH = os.path.join(VENDOR_DIR, "godot-cpp")
ADDON_DIR = os.path.join(ROOT_DIR, "rts_pathfinder")
PROJECT_DIR = os.path.join(f"{ROOT_DIR}", "RTS_Pathfinder_Demo", "addons")

def sync_to_project(target, source, env):
    _ = shutil.copytree(ADDON_DIR, os.path.join(PROJECT_DIR, "rts_pathfinder"), dirs_exist_ok=True)
    return 0

if not os.path.exists(os.path.join(GODOT_CPP_PATH, ".git")):
    print("Godot-cpp not initialised. Initialising now...")
    _ = subprocess.run(["git", "submodule", "update", "--init", "--recursive", "--depth", "0"], check=True)

_ = subprocess.run(["git", "checkout", GODOT_CPP_VERSION], cwd=GODOT_CPP_PATH, capture_output=True, check=True)

env = SConscript(f"{GODOT_CPP_PATH}/SConstruct", {"api_version": "4.7"})

env.Append(CPPPATH=[
    "src/",
    os.path.join(GODOT_CPP_PATH, "include"),
    os.path.join(GODOT_CPP_PATH, "gen", "include"),
    os.path.join(GODOT_CPP_PATH, "gdextension")
])
sources = env.Glob("src/*.cpp")

lib_name = "{}/bin/rts_pathfinder{}{}".format(ADDON_DIR, env["suffix"], env["SHLIBSUFFIX"])
library = env.SharedLibrary(target=lib_name, source=sources)

env.Tool('compilation_db')
env.Alias('compiledb', env.CompilationDatabase('compile_commands.json'))

env.Default(library)

env.AddPostAction(library, sync_to_project)
