#ifndef SEARCH_STRATEGY_H
#define SEARCH_STRATEGY_H

#include "Data.h"
#include <string>
#include "Helper.h"
#include "ThresholdStrategy.h"
// Interface for search strategy
class SearchStrategy{
    public:
        virtual IntervalDecisionTreeNode* BuildIDT(Data* DataList,int DataListLength) = 0;
        virtual std::string SearchStrategyName() = 0;
        virtual std::string SearchStrategyIntroduction();
		virtual bool isStrategy(std::string name) = 0;
        virtual std::string SearchStrategyIntroduction(Helper* helper);
		
		void addParama(std::string name,std::string value);
		std::string getParama(std::string name);

        void setThresholdStrategy(ThresholdStrategy* activeThresholdStrategy);
	private:
		std::map<std::string, std::string> SearchStrategyParamas;
    protected:
        ThresholdStrategy* activeThresholdStrategy;
};

#endif