#include "InformationEntropy.h"
#include "Program.h"
#include "Log.h"

FLOAT_TYPE CalculateInfomationEntropy(Data *DataList, int DataListLength) {
	DataType PositiveCount = 0, NegativeCount = 0;
	for (int i = 0; i < DataListLength; ++i) {
		if (DataList[i].Label == LABEL_TRUE)
			PositiveCount += DataList[i].Size;
		else if (DataList[i].Label == LABEL_FALSE)
			NegativeCount += DataList[i].Size;
		else if (DataList[i].Label == LABEL_UNKNOWN) {
			Log::Error("Label type is unknown.");
			Program::stop();
		}
		else {
			Log::Error("Label type is error.");
			Program::stop();
		}
	}
	DataType TotalCount = PositiveCount + NegativeCount;
	FLOAT_TYPE PossibilityPositive = PositiveCount * 1.0 / TotalCount;
	FLOAT_TYPE PossibilityNegative = NegativeCount * 1.0 / TotalCount;

	FLOAT_TYPE Entropy;
	if (PositiveCount != 0 && NegativeCount != 0)
		Entropy = -PossibilityPositive * log2(PossibilityPositive)
		- PossibilityNegative * log2(PossibilityNegative);
	else if (PositiveCount == 0 && NegativeCount !=0 ) {
		Entropy = -PossibilityNegative * log2(PossibilityNegative);
	}
	else if (PositiveCount != 0 && NegativeCount == 0) {
		Entropy = -PossibilityPositive * log2(PossibilityPositive);
	}
	else {
		Entropy = 0;
	}
	return Entropy;
}


FLOAT_TYPE CalculateInfomationEntropyByCount(DataType PositiveCount, DataType NegativeCount) {
	DataType TotalCount = PositiveCount + NegativeCount;
	FLOAT_TYPE PossibilityPositive = PositiveCount * 1.0 / TotalCount;
	FLOAT_TYPE PossibilityNegative = NegativeCount * 1.0 / TotalCount;

	FLOAT_TYPE Entropy;
	if (PositiveCount != 0 && NegativeCount != 0)
		Entropy = -PossibilityPositive * log2(PossibilityPositive)
		- PossibilityNegative * log2(PossibilityNegative);
	else if (PositiveCount == 0) {
		Entropy = - PossibilityNegative * log2(PossibilityNegative);
	}
	else {
		Entropy = -PossibilityPositive * log2(PossibilityPositive);
	}
	return Entropy;
}


