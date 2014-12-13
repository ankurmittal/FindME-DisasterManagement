#include "FV.hpp"
#include "DB.hpp"

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
namespace fs = boost::filesystem;

const string TmpfsDirMntPt = "/tmp/rdisk";

void findme::FV::createCodebook(const std::string &dbname)
{
    clock_t cStart = clock();
    time_t tStart = time(NULL);
    DB db;
    vector<int> ids;
    db.selectAllIds(dbname, ids);
    int numIds = ids.size();
    for (int i = 0 ; i < numIds ; i++) {
        cout << ids[i] << endl;
        ostringstream oss;
        oss << TmpfsDirMntPt << "/" << i << ".jpg";
        fs::path imgPath = fs::path(oss.str());
        string imgFile = imgPath.string();
        int numBytes = 0;
        db.getImageById(dbname, i, imgFile, numBytes);
        cout << imgFile << " : "<< numBytes << endl;
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
