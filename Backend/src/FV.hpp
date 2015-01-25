#ifndef _FV_HPP
#define _FV_HPP

#include <string>
#include <vector>

using std::string;
using std::vector;

namespace findme
{
    const int LBPBinNum = 59;

    class FV
    {
        public:
            void createCodebook(const std::string &dbname);
            void createLBPVisualization(const std::vector<unsigned char> &imgLbp, const int imgH, const int imgW, \
                    const string &outFilename);
    };
}

#endif
