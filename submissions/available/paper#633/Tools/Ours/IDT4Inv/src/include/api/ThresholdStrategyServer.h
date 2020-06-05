#ifndef THRESHOLD_STRATEGY_SERVER_H
#define THRESHOLD_STRATEGY_SERVER_H

#include "ThresholdStrategy.h"
#include "Program.h"

class ThresholdStrategyServer{
    public:
    static bool _isInitialized;
    static void serve(std::vector<class ThresholdStrategy *> &thresholdStrategyRecorder);
};

#endif