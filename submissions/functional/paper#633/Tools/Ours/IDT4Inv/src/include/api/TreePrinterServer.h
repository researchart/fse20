#ifndef TREE_PRINTER_SERVER_H
#define TREE_PRINTER_SERVER_H

#include "TreePrinter.h"
#include "Program.h"

class TreePrinterServer{
    public:
    static bool _isInitialized;
    static void serve(std::vector<class TreePrinter *> &treePrinterRecorder);
};

#endif