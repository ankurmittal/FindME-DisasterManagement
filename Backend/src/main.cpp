#include <iostream>
#include <cstdlib>

#include "common.hpp"
#include "DB.hpp"

using namespace std;
using namespace findme;

int main(int argc, char *argv[])
{
    DB db;
    //db.bulkInsert("../../Algo/data/images/lfw", "../db/facedb.litedb");
    int numBytes = 0;
    db.getImageById("../db/facedb.litedb", 19, "/Users/sourabhdaptardar/myfile.jpg", numBytes);
    cout << "Number of Bytes: " << numBytes << endl;
    db.getImageById("../db/facedb.litedb", 34, "/tmp/rdisk/myfile.jpg", numBytes);
    cout << "Number of Bytes: " << numBytes << endl;

    return 0;
}
