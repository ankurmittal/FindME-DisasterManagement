#include "FV.hpp"
#include "DB.hpp"

#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing/render_face_detections.h>
#include <dlib/image_processing.h>
#include <dlib/gui_widgets.h>
#include <dlib/image_io.h>
#include <iostream>
#include <cstdlib>
#include <string>
#include <vector>
#include <cassert>
#include <sstream>
#include <boost/filesystem.hpp>
#include <ctime>

using namespace std;
using namespace findme;
using namespace dlib;
namespace fs = boost::filesystem;

const string TmpfsDirMntPt = "/tmp/rdisk";
const string LandmarksFile = "../db/shape_predictor_68_face_landmarks.dat";

void findme::FV::createCodebook(const std::string &dbname)
{

    frontal_face_detector detector = get_frontal_face_detector();
    image_window win, win_faces;
    clock_t cStart = clock();
    time_t tStart = time(NULL);
    DB db;
    std::vector<int> ids;
    db.selectAllIds(dbname, ids);
    int numIds = ids.size();
    for (int i = 0 ; i < numIds ; i++) {
        cout << ids[i] << endl;
        ostringstream oss;
        oss << TmpfsDirMntPt << "/" << ids[i] << ".jpg";
        fs::path imgPath = fs::path(oss.str());
        string imgFile = imgPath.string();
        int numBytes = 0;
        db.getImageById(dbname, ids[i], imgFile, numBytes);
        cout << "processing image " << imgFile << " : " \
            << numBytes << endl;
        array2d<unsigned char> img;
        load_image(img, imgFile);
        pyramid_up(img);

        std::vector<rectangle> dets = detector(img);
        cout << "Number of faces detected: " << dets.size() << endl;

        shape_predictor sp;
        deserialize(LandmarksFile) >> sp;

        std::vector<full_object_detection> shapes;
        for (unsigned long j = 0; j < dets.size(); ++j)
        {
            full_object_detection shape = sp(img, dets[j]);
            cout << "number of parts: "<< shape.num_parts() << endl;
            cout << "pixel position of first part:  " << shape.part(0) << endl;
            cout << "pixel position of second part: " << shape.part(1) << endl;
            shapes.push_back(shape);
        }

        win.clear_overlay();
        win.set_image(img);
        win.add_overlay(dets, rgb_pixel(255,0,0));

        win.add_overlay(render_face_detections(shapes));

        dlib::array<array2d<rgb_pixel> > face_chips;
        extract_image_chips(img, get_face_chip_details(shapes), face_chips);
        win_faces.set_image(tile_images(face_chips));

        cout << "Hit enter to process the next image..." << endl;
        cin.get();
        if(fs::exists(imgPath))
            fs::remove(imgPath);
    }

    clock_t cEnd = clock();
    time_t tEnd = time(NULL);

    int procTimeElapsed = (cEnd - cStart) / CLOCKS_PER_SEC;
    int wallTimeElapsed = tEnd - tStart;
    cout << "Time taken : " << "processor time: " << procTimeElapsed << " sec "
        << "wall time: " << wallTimeElapsed << " sec" << endl;

}
