#include "DB.hpp"
#include "common.hpp"
extern "C" {
#include <sqlite3.h>
}

#include <iostream>
#include <cstdlib>
#include <exception>
#include <string>
#include <cstring>
#include <sstream>
#include <cassert>
#include <boost/filesystem.hpp>
#include <boost/iostreams/device/mapped_file.hpp>

using namespace std;
using namespace findme;
namespace fs = boost::filesystem;
namespace bio = boost::iostreams;

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

        // Get the list of folder names 

        fs::path p(dirname);

        if (fs::exists(p) && fs::is_directory(p)) {

            // Make connection to database
            sqlite3 *db;
            char *zErrMsg;
            int rc;
            char zSql[] = "insert into "\
                           "images(id,person_id,filename,numfaces,image) "\
                           "values (?, ?, ?, -1, ?);";

            //            char zSql[] = "select * from images;";


            rc = sqlite3_open(dbfile.c_str(), &db);
            if (rc) {
                CERR << "Can not open database " << dbfile.c_str() << endl;   
                CERR << "Error code: " << rc << endl;
                sqlite3_close(db);
                return;
            }

            rc = sqlite3_exec(db, "BEGIN TRANSACTION;", NULL, NULL, &zErrMsg);
            if (rc != SQLITE_OK) {
                CERR << "Cannot start transaction " << dbfile.c_str() << endl;   
                CERR << "Error code: " << rc << endl;
                CERR << "Error :" << zErrMsg << endl;
                sqlite3_close(db);
                return;
            }

            sqlite3_stmt *ppStmt = 0;
            const char **pzTail;
            rc = sqlite3_prepare_v2(db, zSql, strlen(zSql)+1, \
                    &ppStmt, NULL);
            if (rc != SQLITE_OK) {
                CERR << "Error preparing statement " << endl;
                CERR << "SQL Error: " << rc << endl;
                sqlite3_close(db);
                return;
            }

            int id_counter = 0;
            fs::directory_iterator end_itr;
            for (fs::directory_iterator dir_itr(p) ; \
                    dir_itr != end_itr ; \
                    ++dir_itr) {

                string person_id = dir_itr->path().filename().string();
                if (fs::is_directory(dir_itr->path())) {


                    fs::directory_iterator end_itr_q;
                    for (fs::directory_iterator dir_itr_q(dir_itr->path()) ; \
                            dir_itr_q != end_itr_q; \
                            ++dir_itr_q) {
                        fs::path qpath(dir_itr_q->path());
                        if (fs::is_regular_file(qpath)) {
                            string q = qpath.filename().string();

                           // cout << person_id << " " << q << endl;
                            id_counter++;

                            bio::mapped_file qfile(qpath);

                            cout << person_id << " : " << q << " : " \
                                << qfile.size() << endl;

                            if (ppStmt) {

                                rc = sqlite3_bind_int(ppStmt, 1, id_counter);
                                if (rc != SQLITE_OK) {
                                    CERR << "Failed to bind id_counter " \
                                        << id_counter << endl;
                                    CERR << "SQL Error: " << rc << endl;
                                    sqlite3_close(db);
                                    return;
                                }


                                rc = sqlite3_bind_text (ppStmt, 2,\
                                        person_id.c_str(), \
                                        person_id.length()+1,\
                                        SQLITE_TRANSIENT);
                                if (rc != SQLITE_OK) {
                                    CERR << "Failed to bind person_id " \
                                        << person_id << endl;
                                    CERR << "SQL Error: " << rc << endl;
                                    sqlite3_close(db);
                                    return;
                                }


                                rc = sqlite3_bind_text (ppStmt, 3,\
                                        q.c_str(), \
                                        q.length()+1,\
                                        SQLITE_TRANSIENT);
                                if (rc != SQLITE_OK) {
                                    CERR << "Failed to bind q " \
                                        << q << endl;
                                    CERR << "SQL Error: " << rc << endl;
                                    sqlite3_close(db);
                                    return;
                                }

                                sqlite3_bind_blob(ppStmt, 4, qfile.data(),\
                                        qfile.size(),\
                                        SQLITE_TRANSIENT);
                                rc = sqlite3_step(ppStmt);
                                if (rc != SQLITE_DONE) {
                                    CERR << "sqlite3_step: " << rc << endl;
                                    CERR << "SQL Error: " << rc << endl;
                                    sqlite3_close(db);
                                    return;
                                }
                                
                                sqlite3_reset(ppStmt);

                            } else {
                                CERR << "Error: ppStmt is NULL" << endl;
                                sqlite3_close(db);
                                return;
                            }


                        }  // end of if 
                    } // end of for q 

                } // end of if (fs::is_directory( ...
            } // end of for p

            sqlite3_finalize(ppStmt);
            sqlite3_exec(db, "COMMIT;", NULL, NULL, &zErrMsg);

            if ((rc != SQLITE_OK) && (rc != SQLITE_DONE) ) {
                CERR << "Commit failure " << dbfile.c_str() << endl;   
                CERR << "Error code: " << rc << endl;
                CERR << "Error :" << zErrMsg << endl;
                sqlite3_close(db);
                return;
            }
            sqlite3_close(db);

        } else {
            CERR << "Invalid directory " << dirname.c_str() << endl;
            return;
        }

    } catch(exception &e) {
        CERR << e.what() << endl;
    }
}
