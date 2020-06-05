#include "SearchStrategyServer.h"
#include "Program.h"
#include "SearchStrategy_Default.h"

bool SearchStrategyServer::_isInitialized = false;

void SearchStrategyServer::serve(std::vector<class SearchStrategy *> &searchStrategyRecorder){
    if(SearchStrategyServer::_isInitialized){
        // Avoid running the serve twice
        return;
    }
    SearchStrategyServer::_isInitialized = true;
    /*
    ** Add no-default search strategies
    ** This is the start position to add custom search strategies
    */

    /*
    ** Custom search strategies end here.
    */
    // Add default search strategy
    searchStrategyRecorder.push_back(new SearchStrategy_Default());
}
