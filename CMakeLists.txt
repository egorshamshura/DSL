cmake_minimum_required(VERSION 3.22 FATAL_ERROR)

project(protea)

find_package(Ruby 3.4.8 EXACT REQUIRED)

include(cmake/Bundler.cmake)
include(cmake/CompilerOptions.cmake)
include(cmake/CPM.cmake)
include(cmake/dependencies.cmake)

add_subdirectory(lib)
add_subdirectory(sim_lib)
add_subdirectory(sim_gen)
