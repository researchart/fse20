#ifndef TREE_PRINTER_H
#define TREE_PRINTER_H

#include <string>
#include "Data.h"
class TreePrinter{
    public:
    virtual std::string TreePrinterName()=0;
    virtual bool isTreePrinter(std::string name)=0;
    virtual void writeFile(IntervalDecisionTreeNode** IDTreeList, char* fileName)=0;
    virtual std::string writeConsole(IntervalDecisionTreeNode** IDTreeList);
};

#endif