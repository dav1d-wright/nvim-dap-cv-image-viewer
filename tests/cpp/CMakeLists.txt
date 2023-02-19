cmake_minimum_required(VERSION 2.8)

project(nvim-dap-cv-mat-viewer-test)

find_package(OpenCV REQUIRED)

include_directories(${OpenCV_INCLUDE_DIRS})

add_executable(nvim-dap-cv-mat-viewer-test main.cpp)

target_link_libraries(nvim-dap-cv-mat-viewer-test ${OpenCV_LIBS})
