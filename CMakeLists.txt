cmake_minimum_required(VERSION 3.10)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)
include(EnsureOutOfSourceBuild)
ensure_out_of_source_build()
project(Unfit)

#######################################################################
# Set up compiler and build type
#######################################################################
include(UnfitCompilerFlags)
option(Unfit_ENABLE_TESTING "Enable Unfit Testing" OFF)
option(Unfit_COVERAGE "Build Unfit with coverage information" OFF)

if(Unfit_COVERAGE)
  set(Unfit_ENABLE_TESTING ON)
  set(CMAKE_BUILD_TYPE "Debug")
endif()

#######################################################################
# Find libraries
#######################################################################
set(Unfit_INCLUDES include examples)
set(Unfit_LINK_LIBRARIES "")

# Check prereqs
if(Unfit_COVERAGE)
  find_program(GCOV_PATH gcov)
  find_program(LCOV_PATH lcov)
  find_program(GENHTML_PATH genhtml)
  find_program(GCOVR_PATH gcovr PATHS ${CMAKE_SOURCE_DIR}/unittests)

  if(NOT GCOV_PATH)
    message(FATAL_ERROR "gcov not found! Aborting...")
  endif()

  if(NOT LCOV_PATH)
    message(FATAL_ERROR "lcov not found! Aborting...")
  endif()

  if(NOT GENHTML_PATH)
    message(FATAL_ERROR "genhtml not found! Aborting...")
  endif()
endif()

if(Unfit_ENABLE_TESTING)
  list(APPEND Unfit_INCLUDES
      "${Unfit_SOURCE_DIR}/UnitTest-cpp"
      "${Unfit_SOURCE_DIR}/UnitTest-cpp/UnitTest++/src")
  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    list(APPEND Unfit_LINK_LIBRARIES
        "${Unfit_SOURCE_DIR}/UnitTest-cpp/lib/Debug/libUnitTest++.a")
  else()
    list(APPEND Unfit_LINK_LIBRARIES
        "${Unfit_SOURCE_DIR}/UnitTest-cpp/lib/Release/libUnitTest++.a")
  endif()
endif()

#######################################################################
# Find pthread
#######################################################################
set(THREADS_PREFER_PTHREAD_FLAG_ON)
find_package(Threads REQUIRED)
list(APPEND Unfit_LINK_LIBRARIES Threads::Threads)

#######################################################################
# Configure build
#######################################################################
file(GLOB SOURCES "src/*.cpp")
if(Unfit_ENABLE_TESTING)
  file(GLOB TEST_SOURCES "examples/*.cpp" "unittests/*.cpp")
  file(COPY "${Unfit_SOURCE_DIR}/examples/data"
      DESTINATION "${Unfit_BINARY_DIR}/examples")
  file(COPY "${Unfit_SOURCE_DIR}/unittests/data"
      DESTINATION "${Unfit_BINARY_DIR}/unittests")

  set(target_name ${PROJECT_NAME}Test)
  list(FILTER SOURCES EXCLUDE REGEX "main.cpp$")
  add_executable(${target_name} ${SOURCES} ${TEST_SOURCES})
  target_include_directories(${target_name} PUBLIC ${Unfit_INCLUDES})
  target_link_libraries(${target_name} ${Unfit_LINK_LIBRARIES})
else()
  set(target_name ${PROJECT_NAME}Example)
  list(FILTER SOURCES EXCLUDE REGEX ".*-test.cpp$")
  add_executable(${target_name} ${SOURCES} "examples/ParabolicModel.hpp")
  target_include_directories(${target_name} PUBLIC include PUBLIC examples)
  target_link_libraries(${target_name} ${Unfit_LINK_LIBRARIES})
endif()

if(Unfit_COVERAGE)
  # Run test with low priority (+15)
  set(NICE_COMMAND nice)
  set(NICENESS -15)
  set(_output_name coverage)
  add_custom_target(coverage
      # Cleanup lcov
      ${LCOV_PATH} --directory . --zerocounters

      # Run tests
      COMMAND ${NICE_COMMAND} ${NICENESS} "./${target_name}"

      # Capture lcov counters
      COMMAND ${LCOV_PATH} --directory . --capture --output-file ${_output_name}.info
      COMMAND ${LCOV_PATH} --remove ${_output_name}.info /usr/* */UnitTest-cpp/* */unittests/* */examples/Test*.cpp --output-file ${_output_name}.info.cleaned
      set(_page_title "\"Unfit Coverage Results\"")
      COMMAND ${GENHTML_PATH} --title "${_page_title}" --no-function-coverage -o ${_output_name} ${_output_name}.info.cleaned
      COMMAND ${CMAKE_COMMAND} -E remove ${_output_name}.info
      COMMAND ${LCOV_PATH} --list ${_output_name}.info.cleaned

      WORKING_DIRECTORY ${Chaste_BINARY_DIR}
      COMMENT "Resetting code coverage counters to zero.\nProcessing code coverage counters and generating report."
      VERBATIM)
endif()
