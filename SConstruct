#!/usr/bin/env python

from SCons.Script import *
import os
import subprocess
import shutil
import zipfile

env = Environment()

GODOT_CPP_VERSION = "10.0.0-stable"
ROOT_DIR = env.Dir("#").abspath
VENDOR_DIR = os.path.join(ROOT_DIR, "vendor")
GODOT_CPP_PATH = os.path.join(VENDOR_DIR, "godot-cpp")
ADDON_DIR = os.path.join(ROOT_DIR, "rts_pathfinder")
PROJECT_DIR = os.path.join(f"{ROOT_DIR}", "rts_pathfinder_demo", "addons")

def sync_to_project(target, source, env):

    target_link = os.path.join(PROJECT_DIR, "rts_pathfinder")

    if not os.path.exists(PROJECT_DIR):
        os.makedirs(PROJECT_DIR)

    if os.path.islink(target_link):
        return

    if os.path.exists(target_link):
        print(f"WARNING: A physical folder exists at {target_link}.")
        print("Delete the physical folder first so SCons can create the symlink.")
        return

    os.symlink(ADDON_DIR, target_link, target_is_directory=True)

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

if "package" in COMMAND_LINE_TARGETS:
    archive_name = "rts_pathfinder_release"
    print(f"Packaging addon into {archive_name}.zip...")

    source_dir = os.path.join(ROOT_DIR, "rts_pathfinder")
    zip_filename = f"{archive_name}.zip"

    ignored_bin_extensions = (".exp", ".lib", ".pdb", ".ilk", ".obj")

    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(source_dir):
            for file in files:

                if "bin" in root.split(os.sep) and file.endswith(ignored_bin_extensions):
                    print(f"  Skipping build artifact: {file}")
                    continue

                file_path = os.path.join(root, file)

                rel_path = os.path.relpath(file_path, ROOT_DIR)
                arcname = os.path.join("addons", rel_path)

                zipf.write(file_path, arcname=arcname)
                print(f"  Added to archive: {arcname}")

    print("Packaging complete!")
    sys.exit(0)

env.Default(library)

env.AddPostAction(library, sync_to_project)
