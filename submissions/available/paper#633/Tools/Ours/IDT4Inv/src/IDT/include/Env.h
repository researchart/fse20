#ifndef ENV_H
#define ENV_H

#if defined(__linux) || defined(__linux__) || defined(linux)
# define LINUX
  
#elif defined(__APPLE__)
# define MACOS
  
#elif defined(_WIN32) || defined(__WIN32__) || defined(WIN32) || defined(_WIN64)
# define WINDOWS
  
#endif

#if defined WINDOWS
#include <Windows.h>

#ifndef ENABLE_VIRTUAL_TERMINAL_PROCESSING
#define ENABLE_VIRTUAL_TERMINAL_PROCESSING 0x0004
#endif

#endif

void EnvInit();

#endif