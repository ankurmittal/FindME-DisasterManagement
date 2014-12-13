#ifndef _DB_HPP
#define _DB_HPP

#include <vector>
#include <string>

using std::vector;
using std::string;

namespace findme
{

    class DB {

        public:
            void bulkInsert(const std::string &dirname, \
                    const std::string &dbfile);
            void getImageById(const std:: string &dbname, const int id, \
                    const std::string &filename, \
                    int &numBytes);
            void selectAllIds(const std::string &dbfile, \
                    std:: vector<int> &ids);
    };

}

#endif
