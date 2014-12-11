#
# Face Recognition backend  
#


cmake_minimum_required(VERSION 2.6)

PROJECT(Backend)

set(BOOST_ROOT libraries/boost_install)
set(Boost_USE_STATIC_LIBS ON)
set(Boost_USE_MULTITHREADED ON)
#set(Boost_INCLUDE_DIR libraries/boost_install/include)
#set(Boost_LIBRARY_DIR libraries/boost_install/lib)
find_package(Boost COMPONENTS system filesystem REQUIRED)
include_directories(${Boost_INCLUDE_DIR})
link_directories(${Boost_LIBRARY_DIR})

include(libraries/dlib-18.11/dlib/cmake)

MACRO(add_example name)
    ADD_EXECUTABLE(${name} src/${name}.cpp)
   TARGET_LINK_LIBRARIES(${name} dlib )
ENDMACRO()


add_example(face_detection_ex)
#add_example(face_landmark_detection_ex)
add_executable(main src/main.cpp)
target_link_libraries(main ${Boost_FILESYSTEM_LIBRARY} ${Boost_SYSTEM_LIBRARY} )
