#include <iostream>
#include <cstdlib>

#include "common.hpp"
#include "DB.hpp"

using namespace std;
using namespace findme;

int main(int argc, char *argv[])
{
    if (argc < 2) {
        cerr << "Invalid arguments" << endl;
        return 1;
    }

    DB db;
    db.bulkInsert("../../Algo/data/images/lfw", argv[1]);

    return 0;
}
