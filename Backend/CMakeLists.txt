#
# Face Recognition backend  
#


cmake_minimum_required(VERSION 2.6)

PROJECT(Backend)

include(libraries/dlib-18.11/dlib/cmake)
set(CODE_DIR, 'src')

MACRO(add_example name)
    ADD_EXECUTABLE(${name} src/${name}.cpp)
   TARGET_LINK_LIBRARIES(${name} dlib )
ENDMACRO()


add_example(face_detection_ex)
#add_example(face_landmark_detection_ex)
