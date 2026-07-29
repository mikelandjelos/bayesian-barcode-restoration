include_guard(GLOBAL)

function(project_name_find_gtest)
  find_package(GTest CONFIG REQUIRED)
endfunction()

function(project_name_find_benchmark)
  find_package(benchmark CONFIG REQUIRED)
endfunction()
