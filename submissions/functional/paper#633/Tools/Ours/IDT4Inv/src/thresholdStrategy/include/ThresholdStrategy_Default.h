#ifndef THRESHOLD_STRATEGY_DEFAULT_H
#define THRESHOLD_STRATEGY_DEFAULT_H

#include "ThresholdStrategy.h"

class ThresholdStrategy_Default:public ThresholdStrategy{
    public:
    std::string ThresholdStrategyName() override;
    std::string ThresholdStrategyIntroduction() override;
    bool isStrategy(std::string name) override;
    // std::string ThresholdStrategyIntroduction(Helper* helper);// override if needed
    SplitResult FindBestThreshold(Data* DataList, int DataListLength) override;

    SplitResult FindBestThresholdInDimensionWithoutDivision(
        int SplitDimension, Data *SortedDataList, int DataListLength,
        DataType PositiveCount, DataType NegativeCount);

    SplitResult FindBestThresholdInDimensionWithDivision(
        int SplitDimension,	Data *SortedDataList, int DataListLength,
	    DataType PositiveCount, DataType NegativeCount);
    

    // DataListDivideByDimensionThresholdWithoutDivision using the original implication
    // DivisionResult DataListDivideByDimensionThresholdWithoutDivision(
	// 	Data* DataList, int DataListLength, int Dimension, DataType Threshold);
    
    // DataListDivideByDimensionThresholdWithoutDivision using the original implication
    // DivisionResult DataListDivideByDimensionThresholdWithDivision(
	// 	Data* DataList, int DataListLength, int Dimension, DataType Threshold) override;


};



struct DataItemInPriorityQueue {
	int Label;
	DataType RightBound;
	DataType Density;// index if Label is Unknown
	DataItemInPriorityQueue(int _Label , DataType _RightBound, DataType _Density);
};

bool operator < (DataItemInPriorityQueue x, DataItemInPriorityQueue y);

#endif