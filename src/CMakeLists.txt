add_library(project_core)
add_library(project::core ALIAS project_core)

target_sources(project_core
  PRIVATE
    project_core.cpp
)

target_include_directories(project_core
  PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

project_name_configure_target(project_core)
