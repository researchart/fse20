#ifndef DEFAULT_HELPER_H
#define DEFAULT_HELPER_H

#include "Helper.h"
#include <unordered_map>
#include <string>
class DefaultHelper: public Helper{
    std::unordered_map<std::string,std::string> _translator;
    public:
    std::string HelperName()override;
    bool isLanguage(std::string language)override;
    std::string getTranslation(std::string str)override;
    void addTranslation(std::string str,std::string introduction);
    DefaultHelper();
};

#endif