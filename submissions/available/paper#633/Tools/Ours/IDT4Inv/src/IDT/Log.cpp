#include "Log.h"
#include <cassert>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <stdarg.h>  // For va_start, etc.
#include <memory>    // For std::unique_ptr

// ErrorLog will not assert false
void Log::Error(std::string message){
    if((int)Program::LOG_LEVEL<(int)LogLevel::ERROR) 
        return;
    Log::Cprintf("\x1b[97;41m[Error]\x1b[0m\x1b[91m ");
    std::cout<<message<<std::endl;
    Log::Cprintf("\x1b[0m");
}

void Log::Warning(std::string message){
    if((int)Program::LOG_LEVEL<(int)LogLevel::WARNING) 
        return;
    Log::Cprintf("\x1b[97;43m[Warning]\x1b[0m\x1b[93m ");
    std::cout<<message<<std::endl;
    Log::Cprintf("\x1b[0m");
}

void Log::Key(std::string message){
    if((int)Program::LOG_LEVEL<(int)LogLevel::INFO) 
        return;
    Log::Cprintf("\x1b[97;42m[Key]\x1b[0m\x1b[92m ");
    std::cout<<message<<std::endl;
    Log::Cprintf("\x1b[0m");
}

void Log::Info(std::string message){
    if((int)Program::LOG_LEVEL<(int)LogLevel::DETAIL) 
        return;
    Log::Cprintf("\x1b[97;46m[Info]\x1b[0m\x1b[96m ");
    std::cout<<message<<std::endl;
    Log::Cprintf("\x1b[0m");
}

void Log::Debug(std::string message){
    if((int)Program::VERSION_TYPE!=(int)VersionType::DEVELOPMENT) 
        return;
    Log::Cprintf("\x1b[97;100m[Debug]\x1b[0m\x1b[90m ");
    std::cout<<message<<std::endl;
    Log::Cprintf("\x1b[0m");
}

void Log::Text(std::string message){
    if((int)Program::LOG_LEVEL<(int)LogLevel::FINE) 
        return;    
    std::cout<<message<<std::endl;
}

std::string Format(const std::string fmt_str, ...){
    int final_n, n = ((int)fmt_str.size()) * 2; /* Reserve two times as much as the length of the fmt_str */
    std::unique_ptr<char[]> formatted;
    va_list ap;
    while(1) {
        formatted.reset(new char[n]); /* Wrap the plain char array into the unique_ptr */
        strcpy(&formatted[0], fmt_str.c_str());
        va_start(ap, fmt_str);
        final_n = vsnprintf(&formatted[0], n, fmt_str.c_str(), ap);
        va_end(ap);
        if (final_n < 0 || final_n >= n)
            n += abs(final_n - n + 1);
        else
            break;
    }
    return std::string(formatted.get());
}
bool Log::colorOn = true;
void Log::Cprintf(const char * str){
    if(Log::colorOn)
        printf(str);
}
