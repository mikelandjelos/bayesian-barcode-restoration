add_executable(project_cli main.cpp)
target_link_libraries(project_cli PRIVATE project::core)
project_name_configure_target(project_cli)
