#include "DefaultHelper.h"
/*
DefaultHelper accept all language name, 
so it should be registered at the end of Recorder.
*/
bool DefaultHelper::isLanguage(std::string str){
    return true;
}
std::string DefaultHelper::HelperName(){
    return "Default";
}
std::string DefaultHelper::getTranslation(std::string str){
    return _translator[str];
}
void DefaultHelper::addTranslation(std::string str,std::string introduction){
    _translator[str] = introduction;
}
/*
contractor will initialize translations
*/
DefaultHelper::DefaultHelper(){
    // addTranslation(KEY,VALUE)
    addTranslation("HelperName","Default");
    addTranslation("Welcome","Welcome!");
}
