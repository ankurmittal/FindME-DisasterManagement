#include <iostream>
#include <cstdlib>

#include "common.hpp"
#include "DB.hpp"
#include "FV.hpp"

using namespace std;
using namespace findme;

int main(int argc, char *argv[])
{
#if 0
    DB db;
    //db.bulkInsert("../../Algo/data/images/lfw", "../db/facedb.litedb");
    int numBytes = 0;
    db.getImageById("../db/facedb.litedb", 19, "/Users/sourabhdaptardar/myfile.jpg", numBytes);
    cout << "Number of Bytes: " << numBytes << endl;
    db.getImageById("../db/facedb.litedb", 34, "/tmp/rdisk/myfile.jpg", numBytes);
    cout << "Number of Bytes: " << numBytes << endl;
#endif

    FV fv;
    fv.createCodebook("../db/facedb.litedb");

    return 0;
}
