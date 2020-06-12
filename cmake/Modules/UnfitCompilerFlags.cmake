set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
endif()
if(CMAKE_BUILD_TYPE STREQUAL "Release")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -s")
endif()

if(Unfit_COVERAGE)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage")
endif()

string(CONCAT CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Weffc++ -Wextra "
    "-pedantic -Winit-self -Wmissing-declarations -Wmissing-include-dirs "
    "-Wundef -Wredundant-decls -Wfloat-equal -Wmain -Wunreachable-code "
    "-Wshadow -Wcast-align -Wswitch-enum")
