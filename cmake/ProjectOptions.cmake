include_guard(GLOBAL)

function(project_name_setup_options)
  option(PROJECT_BUILD_TESTS "Build tests" ${BUILD_TESTING})
  option(PROJECT_BUILD_BENCHMARKS "Build benchmarks" OFF)
  option(PROJECT_BUILD_EXAMPLES "Build examples" OFF)
  option(PROJECT_BUILD_DOCS "Build documentation" OFF)
  option(PROJECT_BUILD_PYTHON_BINDINGS "Reserved extension point for Python bindings" OFF)

  option(PROJECT_ENABLE_WARNINGS "Enable project compiler warnings" ON)
  option(PROJECT_WARNINGS_AS_ERRORS "Treat project warnings as errors" OFF)
  option(PROJECT_ENABLE_CLANG_TIDY "Enable clang-tidy during compilation" OFF)
  option(PROJECT_ENABLE_CPPCHECK "Enable cppcheck during compilation" OFF)
  option(PROJECT_ENABLE_IPO "Enable interprocedural optimization" OFF)

  option(PROJECT_ENABLE_ASAN "Enable AddressSanitizer" OFF)
  option(PROJECT_ENABLE_UBSAN "Enable UndefinedBehaviorSanitizer" OFF)
  option(PROJECT_ENABLE_TSAN "Enable ThreadSanitizer" OFF)
  option(PROJECT_ENABLE_MSAN "Enable MemorySanitizer" OFF)
  option(PROJECT_ENABLE_COVERAGE "Enable coverage instrumentation" OFF)

  include(CompilerWarnings)
  include(Sanitizers)
  include(StaticAnalyzers)
  include(Coverage)

  project_name_validate_sanitizers()
  project_name_configure_static_analyzers()
endfunction()

function(project_name_configure_target target)
  target_compile_features(${target} PUBLIC cxx_std_20)

  if(PROJECT_ENABLE_WARNINGS)
    project_name_set_warnings(${target})
  endif()

  project_name_enable_sanitizers(${target})
  project_name_enable_coverage(${target})
endfunction()
