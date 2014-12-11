#include "DB.hpp"
#include "common.hpp"
extern "C" {
#include <sqlite3.h>
}

#include <iostream>
#include <cstdlib>
#include <exception>
#include <string>

using namespace std;
using namespace findme;

static int callback(void *NotUsed, int argc, char **argv, char **azColName) {
    int i;
    for (i = 0 ; i < argc ; i++) {
        cout << azColName[i] << " = " << (argv[i] ? argv[i] : "NULL") << endl;
    }
    cout << endl;
    return 0;
}

void findme::DB::bulkInsert(const string &dirname, const string &dbfile)
{
    try {

        sqlite3 *db;
        char *zErrMsg = 0;
        int rc;

        rc = sqlite3_open(dbfile.c_str(), &db);
        if (rc) {
            CERR << "Can not open database " << dbfile.c_str() << endl;   
            CERR << "Error code: " << rc << endl;
            sqlite3_close(db);
            return;
        }

        string sql = \
            "insert into images values(1,'Sourabh', 'sourabh.jpg', -1, NULL);"\
            "insert into images values(1,'Ankit', 'ankit.jpg', -1, NULL);" \
            "insert into images values(1,'Ankur', 'ankur.jpg', -1, NULL);" \
            "insert into images values(1,'Udit', 'udit.jpg', -1, NULL);" \
            "insert into images values(1,'Rajesh', 'rajesh.jpg', -1, NULL);";

        rc = sqlite3_exec(db, sql.c_str(), callback, 0, &zErrMsg);
        if (rc != SQLITE_OK) {
            CERR << "SQL Error: " << zErrMsg << endl;
            sqlite3_free(zErrMsg);
        } else {
            cout << "Records entered successfully" << endl;
        }


        sqlite3_close(db);

    } catch(exception &e) {
        CERR << e.what() << endl;
    }
}
