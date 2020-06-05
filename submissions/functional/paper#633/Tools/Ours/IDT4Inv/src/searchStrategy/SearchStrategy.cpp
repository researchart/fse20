#include "SearchStrategy.h"
#include "Log.h"
/*
Introduction first to choose from the helper, if find none, then to choose from Strategy
*/
std::string SearchStrategy::SearchStrategyIntroduction(Helper* helper){
    std::string str = SearchStrategyName();
    if(helper == nullptr)
        return SearchStrategyIntroduction();
    std::string Introduction = helper->getTranslation(str);
    if (Introduction != "")
        return Introduction;
    return SearchStrategyIntroduction();
}

std::string SearchStrategy::SearchStrategyIntroduction(){
    std::string Introduction = ""; // TODO: add in future
    return Introduction;
}

void SearchStrategy::addParama(std::string name,std::string value){
    if(SearchStrategy::SearchStrategyParamas.find(name)==SearchStrategy::SearchStrategyParamas.end()){
        // Not found, normal
        SearchStrategy::SearchStrategyParamas[name]=value;
    }
    else{
        // Found duplicate value, warning
        Log::Warning("Duplicate parama in search strategy:'"+name+"'! The new one will be used.");
        SearchStrategy::SearchStrategyParamas[name]=value;
    }
}
std::string SearchStrategy::getParama(std::string name){
    if(SearchStrategy::SearchStrategyParamas.find(name)==SearchStrategy::SearchStrategyParamas.end()){
        // Not found, warning
        Log::Info("Parama in search strategy:'"+name+"' not found. Ignore this one using default.");
        return "NF"; // default not found value
    }
    else {
        return SearchStrategy::SearchStrategyParamas[name];
    }
}

void SearchStrategy::setThresholdStrategy(ThresholdStrategy* activeThresholdStrategy){
    this->activeThresholdStrategy = activeThresholdStrategy;
}