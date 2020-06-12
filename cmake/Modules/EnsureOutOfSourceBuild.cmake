macro(ensure_out_of_source_build)
  get_filename_component(srcdir "${CMAKE_SOURCE_DIR}" REALPATH)
  get_filename_component(bindir "${CMAKE_BINARY_DIR}" REALPATH)

  if("${srcdir}" STREQUAL "${bindir}")
    message("****************************************************************")
    message("* Please build outside the source directory. For example:      *")
    message("*   mkdir ~/tmp/build")
    message("*   cd ~/tmp/build")
    message("*   cmake ${CMAKE_SOURCE_DIR}")
    message("*                                                              *")
    message("* Please remove the following files:")
    message("*   ${CMAKE_SOURCE_DIR}/CMakeCache.txt")
    message("*   ${CMAKE_SOURCE_DIR}/CMakeFiles/*")
    message("*                                                              *")
    message("* before the next configuration attempt to avoid this message. *")
    message("****************************************************************")
    message(FATAL_ERROR "Quitting configuration")
  endif()
endmacro(ensure_out_of_source_build)
