#ifndef HELPER_H
#define HELPER_H
/*
The Class Helper is used to internationalize help information
*/
#include <string>
class Helper{
    public:
    virtual std::string HelperName()=0;
    virtual bool isLanguage(std::string language)=0;
    virtual std::string getTranslation(std::string str)=0;
};

#endif