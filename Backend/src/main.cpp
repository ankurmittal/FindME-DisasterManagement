#include <iostream>
#include <cstdlib>

#include "common.hpp"
#include "DB.hpp"

using namespace std;
using namespace findme;

int main(int argc, char *argv[])
{
    DB db;
    db.bulkInsert("../../Algo/data/images/lfw", "../db/facedb.litedb");

    return 0;
}
