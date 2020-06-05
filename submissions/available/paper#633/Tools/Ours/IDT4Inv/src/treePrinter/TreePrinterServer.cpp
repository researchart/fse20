#include "TreePrinterServer.h"
#include "Program.h"
#include "TreePrinterJson.h"

bool TreePrinterServer::_isInitialized = false;

void TreePrinterServer::serve(std::vector<class TreePrinter *> &treePrinterRecorder){
    if(TreePrinterServer::_isInitialized){
        // Avoid running the serve twice
        return;
    }
    TreePrinterServer::_isInitialized = true;
    /*
    ** Add no-default threshold strategies
    ** This is the start position to add custom threshold strategies
    */

    /*
    ** Custom threshold strategies end here.
    */
    // Add default threshold strategy
    treePrinterRecorder.push_back(new TreePrinterJson());
}
