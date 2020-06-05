#ifndef LOG_H
#define LOG_H

#include "Program.h"
#include <string>
class Log{    
    public:
    static void Error(std::string message);    //Level>=Error
    static void Warning(std::string message);  //Level>=WARNING
    static void Key(std::string message);      //Level>=INFO
    static void Info(std::string message);     //Level>=DETAIL
    static void Text(std::string message);     //Level>=FINE
    static void Debug(std::string message);    //Debug runtime
    static void Cprintf(const char * str);
    static bool colorOn;
};

std::string Format(const std::string fmt_str, ...);
#endif