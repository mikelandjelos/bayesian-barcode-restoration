include_guard(GLOBAL)

function(project_name_configure_static_analyzers)
  if(PROJECT_ENABLE_CLANG_TIDY)
    find_program(CLANG_TIDY_EXE NAMES clang-tidy REQUIRED)
    set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE};--config-file=${CMAKE_SOURCE_DIR}/.clang-tidy"
        CACHE STRING "clang-tidy command" FORCE)
  endif()
  if(PROJECT_ENABLE_CPPCHECK)
    find_program(CPPCHECK_EXE NAMES cppcheck REQUIRED)
    set(CMAKE_CXX_CPPCHECK "${CPPCHECK_EXE};--enable=warning,style;--error-exitcode=2"
        CACHE STRING "cppcheck command" FORCE)
  endif()
endfunction()
