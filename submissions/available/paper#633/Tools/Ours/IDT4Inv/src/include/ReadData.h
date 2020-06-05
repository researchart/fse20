#ifndef READ_DATA_H
#define READ_DATA_H

#include "Data.h"
#include <cstring>
#include <cstdio>
#include <cassert>

typedef int ReadState;
#define READ_SUCCESS 0
#define READ_ERROR -1

#define USELESS_DIMENSION 0X80000000

bool CanReadNamesStop(char* StoppedFlag, char* Line, int Length);

int String2int(std::string);

ReadState LoadNames(char* FilePrefix);

ReadState LoadData(char* FilePrefix);

#ifdef IMPLICATION
ReadState LoadImplications(char* FilePrefix);
#endif

#endif