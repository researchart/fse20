#include "Env.h"

void EnvInit(){
    //Windows color enable START
#ifdef WINDOWS
    const auto handle = GetStdHandle(STD_OUTPUT_HANDLE);
    DWORD mode;
    GetConsoleMode(handle, &mode);
    mode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
    SetConsoleMode(handle, mode);
#endif
    //Windows color enable END

}