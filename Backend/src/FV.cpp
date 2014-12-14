#include "FV.hpp"
#include "DB.hpp"

#include <dlib/image_processing/frontal_face_detector.h>
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

void findme::FV::createCodebook(const std::string &dbname)
{

    frontal_face_detector detector = get_frontal_face_detector();
    image_window win;
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
        if(fs::exists(imgPath))
            fs::remove(imgPath);
        pyramid_up(img);

        // Now tell the face detector to give us a list of bounding boxes
        // around all the faces it can find in the image.
        std::vector<rectangle> dets = detector(img);

        cout << "Number of faces detected: " << dets.size() << endl;
        // Now we show the image on the screen and the face detections as
        // red overlay boxes.
        win.clear_overlay();
        win.set_image(img);
        win.add_overlay(dets, rgb_pixel(255,0,0));

            cout << "Hit enter to process the next image..." << endl;
            cin.get();
    }
    
    clock_t cEnd = clock();
    time_t tEnd = time(NULL);

    int procTimeElapsed = (cEnd - cStart) / CLOCKS_PER_SEC;
    int wallTimeElapsed = tEnd - tStart;
    cout << "Time taken : " << "processor time: " << procTimeElapsed << " sec "
        << "wall time: " << wallTimeElapsed << " sec" << endl;

}
