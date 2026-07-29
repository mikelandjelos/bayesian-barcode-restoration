cmake_minimum_required(VERSION 3.28)

project(project_name VERSION 0.1.0 LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(CTest)
include(ProjectOptions)
include(Dependencies)

project_name_setup_options()

add_subdirectory(src)
add_subdirectory(apps)

if(PROJECT_BUILD_TESTS)
  add_subdirectory(tests)
endif()

if(PROJECT_BUILD_BENCHMARKS)
  add_subdirectory(benchmarks)
endif()

if(PROJECT_BUILD_EXAMPLES)
  add_subdirectory(examples)
endif()

if(PROJECT_BUILD_DOCS)
  include(Documentation)
  project_name_enable_docs()
endif()
