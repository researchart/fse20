/*
    This is the implication of default search strategy.
    The strategy includes the features:
    (1) DFS first search
    (2) Unsatisfied advancing 
    (3) TODO: check half or left
    (4) TODO: check the penalty
    (5) TODO: Others?
*/
#ifndef SEARCH_STRATEGY_DEFAULT_H
#define SEARCH_STRATEGY_DEFAULT_H

#include "SearchStrategy.h"

class SearchStrategy_Default: public SearchStrategy {
    public:
    IntervalDecisionTreeNode* BuildIDT(Data* DataList,int DataListLength) override;
    bool isStrategy(std::string name) override;
    std::string SearchStrategyName() override;
    std::string SearchStrategyIntroduction() override;
    // std::string SearchStrategyIntroduction(Helper* helper) override;
};

#endif