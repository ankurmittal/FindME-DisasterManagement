

# Face Recognition backend  
#


cmake_minimum_required(VERSION 2.6)

PROJECT(Backend)

set(PYTHON_LIBRARIES /Users/sourabhdaptardar/anaconda/envs/py27/lib/libpython2.7.dylib)
set(PYTHON_INCLUDE_DIRS /Users/sourabhdaptardar/anaconda/envs/py27/include/python2.7/Python.h)

set(BOOST_ROOT libraries/boost_install)
set(Boost_USE_STATIC_LIBS ON)
set(Boost_USE_MULTITHREADED ON)
set(sqlite3_ROOT libraries/sqlite_install)
set(sqlite3_INCLUDE_DIR ${sqlite3_ROOT}/include)
set(sqlite3_LIBRARY_DIR ${sqlite3_ROOT}/lib)
set(sqlite3_LIBRARY sqlite3)

find_package(PythonLibs REQUIRED)
find_package(Boost COMPONENTS system filesystem iostreams REQUIRED)

include_directories(${Boost_INCLUDE_DIR} ${sqlite3_INCLUDE_DIR} ${PYTHON_INCLUDE_DIRS})
link_directories(${Boost_LIBRARY_DIR} ${sqlite3_LIBRARY_DIR})

include(libraries/dlib-18.11/dlib/cmake)

MACRO(add_example name)
    ADD_EXECUTABLE(${name} src/${name}.cpp)
   TARGET_LINK_LIBRARIES(${name} dlib )
ENDMACRO()


add_example(face_detection_ex)
#add_example(face_landmark_detection_ex)
add_executable(main src/DB.cpp src/FV.cpp src/main.cpp)
target_link_libraries(main 
    ${Boost_FILESYSTEM_LIBRARY} ${Boost_SYSTEM_LIBRARY} 
    ${Boost_IOSTREAMS_LIBRARY}
    ${sqlite3_LIBRARY}
    ${PYTHON_LIBRARIES}
    dlib
    )


#DLIB for python
#include(libraries/dlib-18.11/dlib/add_python_module)
#
#set(psrc libraries/dlib-18.11/tools/python/src)
## Tell cmake to compile all these cpp files into a dlib python module.
#add_python_module(dlib 
#   ${psrc}/dlib.cpp 
#   ${psrc}/matrix.cpp 
#   ${psrc}/vector.cpp
#   ${psrc}/svm_c_trainer.cpp
#   ${psrc}/svm_rank_trainer.cpp
#   ${psrc}/decision_functions.cpp
#   ${psrc}/other.cpp
#   ${psrc}/basic.cpp
#   ${psrc}/cca.cpp
#   ${psrc}/sequence_segmenter.cpp
#   ${psrc}/svm_struct.cpp
#   ${psrc}/object_detection.cpp
#   )
#
## When you run "make install" we will copy the compiled dlib.so (or dlib.pyd) 
## library file to the python_examples folder.
#install_dlib_to(src/python)

