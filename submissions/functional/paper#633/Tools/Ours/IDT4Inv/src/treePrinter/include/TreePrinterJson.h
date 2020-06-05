#ifndef TREE_PRINTER_JSON_H
#define TREE_PRINTER_JSON_H

#include "TreePrinter.h"
class TreePrinterJson: public TreePrinter{
    public:
    std::string TreePrinterName() override;
    bool isTreePrinter(std::string name) override;
    void writeFile(IntervalDecisionTreeNode** IDTreeList, char* fileName) override;
    void TreeDFS(IntervalDecisionTreeNode* IDTree, FILE* File);
};

#endif