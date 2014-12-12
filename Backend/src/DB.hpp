#ifndef _DB_HPP
#define _DB_HPP

#include <string>

using namespace std;

namespace findme
{

    class DB {

        public:
            void bulkInsert(const string &dirname, const string &dbfile);
            void getImageById(const string &dbname, const int id, \
                    const string &filename, \
                    int &numBytes);
    };

}

#endif
