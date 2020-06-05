#ifndef INFOMATION_ENTROPY_H
#define INFOMATION_ENTROPY_H

#include <vector>
#include <cassert>
#include <cmath>
#include "Data.h"

// typedef double FLOAT_TYPE; // move to config.h

FLOAT_TYPE CalculateInfomationEntropy(Data *DataList, int DataListLength);
FLOAT_TYPE CalculateInfomationEntropyByCount(DataType PositiveCount, DataType NegativeCount);

#endif