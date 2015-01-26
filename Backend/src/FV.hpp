#ifndef _FV_HPP
#define _FV_HPP

#include <string>
#include <vector>
#include <utility>
#include <map>
#include <dlib/image_processing/full_object_detection.h>

using std::string;
using std::vector;
using dlib::full_object_detection;
using std::pair;
using std::map;

namespace findme
{
    // Constants
    const int LBPBinNum = 59;

    // Typedefs
    typedef std::vector<dlib::full_object_detection> shapes_t;
    typedef std::vector<shapes_t> vshapes_t;
    typedef std::pair<int, int> pair_t;
    typedef std::map<int, pair_t> map_int_pair_t;
    typedef std::map<pair_t, int> map_pair_int_t;

    class FV
    {
        public:
            void createCodebook(const std::string &dbname, vshapes_t &vshapes,
                    map_int_pair_t &detections,
                    map_pair_int_t &detections_r,
                    std::vector<std::vector<int> > &FV);
            void createLBPVisualization(const std::vector<unsigned char> &imgLbp, const int imgH, const int imgW, \
                    const string &outFilename);
    };
}

#endif
