#include <iostream>
#include <cstdlib>

#include <boost/filesystem.hpp>

using namespace std;
using namespace boost::filesystem;

int main(int argc, char *argv[])
{
    if (argc < 2) {
        cerr << "Invalid arguments" << endl;
        return 1;
    }

    cout << argv[1] <<  " " << file_size(argv[1]) << endl;

    return 0;
}
