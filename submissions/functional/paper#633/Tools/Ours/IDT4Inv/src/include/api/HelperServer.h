#ifndef HELPER_SERVER_H
#define HELPER_SERVER_H

#include "Helper.h"
#include <vector>

class HelperServer{
    public:
    static bool _isInitialized;
    static void serve(std::vector<class Helper *> &helperRecorder);
};

#endif