include_guard(GLOBAL)

function(project_name_enable_docs)
  find_package(Doxygen REQUIRED)
  set(DOXYGEN_PROJECT_NAME "${PROJECT_NAME}")
  set(DOXYGEN_PROJECT_NUMBER "${PROJECT_VERSION}")
  set(DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/docs")
  set(DOXYGEN_INPUT "${PROJECT_SOURCE_DIR}/include ${PROJECT_SOURCE_DIR}/src")
  configure_file("${PROJECT_SOURCE_DIR}/docs/Doxyfile.in" "${CMAKE_BINARY_DIR}/Doxyfile" @ONLY)
  add_custom_target(docs
    COMMAND "${DOXYGEN_EXECUTABLE}" "${CMAKE_BINARY_DIR}/Doxyfile"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Generating C++ API documentation")
endfunction()
