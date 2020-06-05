#include "ThresholdStrategyServer.h"
#include "Program.h"
#include "ThresholdStrategy_Default.h"

bool ThresholdStrategyServer::_isInitialized = false;

void ThresholdStrategyServer::serve(std::vector<class ThresholdStrategy *> &thresholdStrategyRecorder){
    if(ThresholdStrategyServer::_isInitialized){
        // Avoid running the serve twice
        return;
    }
    ThresholdStrategyServer::_isInitialized = true;
    /*
    ** Add no-default threshold strategies
    ** This is the start position to add custom threshold strategies
    */

    /*
    ** Custom threshold strategies end here.
    */
    // Add default threshold strategy
    thresholdStrategyRecorder.push_back(new ThresholdStrategy_Default());
}
