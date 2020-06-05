#include "HelperServer.h"
#include "Program.h"
#include "DefaultHelper.h"

bool HelperServer::_isInitialized = false;

void HelperServer::serve(std::vector<class Helper *> &helperRecorder){
    if(HelperServer::_isInitialized){
        // Avoid running the serve twice
        return;
    }
    HelperServer::_isInitialized = true;
    /*
    ** Add no-default helpers
    ** This is the start position to add custom helpers
    */

    /*
    ** Custom helpers end here.
    */
    // Add default helper
    helperRecorder.push_back(new DefaultHelper());
}
