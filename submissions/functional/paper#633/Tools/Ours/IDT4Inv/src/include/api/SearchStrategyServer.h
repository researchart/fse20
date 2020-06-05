#ifndef SEARCH_STRATEGY_SERVER_H
#define SEARCH_STRATEGY_SERVER_H

#include "SearchStrategy.h"
#include "Program.h"

class SearchStrategyServer{
    public:
    static bool _isInitialized;
    static void serve(std::vector<class SearchStrategy *> &searchStrategyRecorder);
};

#endif