#include "FV.hpp"
#include "DB.hpp"
#include "common.hpp"

#include <dlib/image_processing.h>
#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing/render_face_detections.h>
#include <dlib/image_transforms/lbp_abstract.h>
#include <dlib/gui_widgets.h>
#include <dlib/image_io.h>
#include <dlib/image_transforms.h>
#include <iostream>
#include <cstdlib>
#include <string>
#include <vector>
#include <cassert>
#include <sstream>
#include <boost/filesystem.hpp>
#include <ctime>
#include <Python.h>
#include <abstract.h>


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


#if defined(DEBUG_PLOT_HIST)
    // Initialize python
    Py_Initialize();
    PyRun_SimpleString("import numpy as np");
    PyRun_SimpleString("import matplotlib as mpl");
    PyRun_SimpleString("import matplotlib.pyplot as plt");
#endif

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
        //pyramid_up(img);

        std::vector<rectangle> dets = detector(img);
        cout << "Number of faces detected: " << dets.size() << endl;

        //array2d<unsigned char> imgLbp;
        const unsigned int cell_size = 10;
        std::vector<unsigned char> imgLbp;
        extract_uniform_lbp_descriptors(img, imgLbp, cell_size); 
        DBG << "imgLbp size: " <<  imgLbp.size() << endl;
        DBG << "img dimensions: " << img.nr() << " " << img.nc() << " " << img.size() << endl;
        DBG << "img size: " << img.size() << endl; 
        //for (int x = 0 ; x < imgLbp.size(); x++)
        //    DBG << int(imgLbp[x]) << " ";


        //PyRun_SimpleString("pylab.plot(range(5))");
        //PyRun_SimpleString("plt.show()");

#if defined(DEBUG_PLOT_HIST)
        // Dump LBP to a file in RAM
        ostringstream plotDataFileName;
        plotDataFileName << TmpfsDirMntPt << "/" << "lbp_" << i+1 << ".txt";
        ofstream plotDataFile(plotDataFileName.str());
        if (!plotDataFile) {
            CERR << "could not open " << plotDataFileName.str() << endl;
        }

        for (int lbpCnt = 0 ; lbpCnt < int(imgLbp.size()) ; lbpCnt++) {
            plotDataFile << int(imgLbp[lbpCnt]) << endl;
        }

        plotDataFile.close();
        cerr << "Wrote file " << plotDataFileName.str() << endl;

        // Now, plot histogram

        ostringstream plotFileName;
        plotFileName << TmpfsDirMntPt << "/" << "plt_" << i+1 << ".png";

        ostringstream pyPlotCmd;
        //pyPlotCmd << "fig = plt.figure(); "

        pyPlotCmd << "lbp = np.genfromtxt('" << plotDataFileName.str() << "'); " \
                  << "plt.hist(lbp); " \
                  << "plt.savefig('" << plotFileName.str() << "')";
        PyRun_SimpleString(pyPlotCmd.str().c_str());
#endif

#if defined(DEBUG_LBP_VIS)
        ostringstream lbpImgFileName;
        lbpImgFileName << TmpfsDirMntPt << "/" << "lbpimg_" << i+1 << ".png";
        createLBPVisualization(imgLbp, img.nr() / cell_size, img.nc() / cell_size, lbpImgFileName.str());
#endif

        shape_predictor sp;
        deserialize(LandmarksFile) >> sp;

        std::vector<full_object_detection> shapes;
        for (unsigned long j = 0; j < dets.size(); ++j) {
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


#if defined(DEBUG_PLOT_HIST)
    // Exit python
    Py_Exit(0);
#endif

    clock_t cEnd = clock();
    time_t tEnd = time(NULL);

    int procTimeElapsed = (cEnd - cStart) / CLOCKS_PER_SEC;
    int wallTimeElapsed = tEnd - tStart;
    cout << "Time taken : " << "processor time: " << procTimeElapsed << " sec "
        << "wall time: " << wallTimeElapsed << " sec" << endl;

}


void FV::createLBPVisualization(const std::vector<unsigned char> &imgLbp, const int imgH, const int imgW, \
        const string &outFilename)
{
    try
    {
        //for (int lbpCnt = 0 ; lbpCnt < int(imgLbp.size()) ; lbpCnt++) {
        //    cout << int(imgLbp[lbpCnt]) << " ";
        //}

        const int cellSize = 10;
        array2d<unsigned char> img;
        img.set_size(cellSize*imgH, cellSize*imgW);
        assign_all_pixels(img, 0);
        int cellCnt = 0;
        for (int i = 0 ; i <  cellSize * imgH ; i += cellSize) {
            for (int j = 0 ; j < cellSize * imgW ; j += cellSize) {
                int startX = i + 1;
                int startY = j + 1;
                int cnt = 0;
                bool breakFlag = false;
                for (int ii = startX; ii < startX + cellSize - 2; ii++) {
                    for (int jj = startY; jj < startY + cellSize - 2; jj++) {
                        // cout << int(imgLbp[cellCnt*LBPBinNum+cnt]) << " ";
                        //cout << cellCnt * LBPBinNum + cnt << " ";
                        assign_pixel_intensity(img[ii][jj],
                                int(imgLbp[cellCnt*LBPBinNum+cnt]));
                        if (cnt >= LBPBinNum) {
                            breakFlag = true;
                            break;
                        }
                        if (breakFlag) {
                            break;
                        }
                        cnt++;
                    }
                }
                cellCnt++;
            }
        }
        image_window lbp_win(heatmap(img), "LBP");
        cout << "Hit enter to continue ..." << endl;
        cin.get();
    }
    catch (exception &e)
    {
        CERR << "createLBPVisualization error: " << e.what() << endl;
    }

}

