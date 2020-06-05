# CMakelists.txt for project IDT4Inv
cmake_minimum_required (VERSION 3.1)

project (IDT4Inv)

SET(CMAKE_C_COMPILER "gcc")

SET(CMAKE_CXX_COMPILER "g++")

set(CMAKE_CXX_STANDARD 11)

set (CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

set (CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    add_definitions(-DCLANG)
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    add_definitions(-DGNU)
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    add_definitions(-DMSVC)
endif()

aux_source_directory (src DIR_SRCS)

include_directories (src/include src/include/api)

add_subdirectory (src/helper)

add_subdirectory (src/IDT)

add_subdirectory (src/treePrinter)

add_subdirectory (src/searchStrategy)

add_subdirectory (src/thresholdStrategy)

add_executable (${PROJECT_NAME} ${DIR_SRCS})

target_link_libraries (${PROJECT_NAME} IDT)

target_link_libraries (${PROJECT_NAME} Helper)

target_link_libraries (${PROJECT_NAME} TreePrinter)

target_link_libraries (${PROJECT_NAME} SearchStrategy)

target_link_libraries (${PROJECT_NAME} ThresholdStrategy)

set (_CRT_SECURE_NO_WARNINGS)

set (CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} -std=c++11")

# set (CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} /EHsc")

#set (CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} -g") 

set (CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} -O3 -DNDEBUG " )
