#ifndef THRESHOLD_STRATEGY_H
#define THRESHOLD_STRATEGY_H

#include <string>
#include "Data.h"
#include "Helper.h"

// Universal object for the normal splite result, in which there is no interval will be divided.
struct SplitResult {
    int Result;
    int SplitDimension;
    DataType SplitPosition;// >Threshold is satisfied,<= is unsatisfied.
    FLOAT_TYPE Entropy;
    // TODO: THRESHOLD_COST_ON option in compilation or running?
#ifdef THRESHOLD_COST_ON
    int TryTimes;
    int Distance;
#endif 
    SplitResult(int _Result,int _SplitDimension, 
    DataType _SplitPosition, FLOAT_TYPE _Entropy);
};

// Type of node kind. TODO: change to enumeration object
#define SPLIT_WITH_DIVISION 3
#define ONE_CLASS_LEFT 2
#define SPLIT_SUCCESS 1
#define SPLIT_NOT_FOUND 0

// Alias of valable SplitDimension in order to save space in the leaf nodes
#define OneClassKind SplitDimension 

// Universal object for the splite result in interval-divided situations
struct DivisionResult {
    int SplitDimension;
    DataType SplitThreshold; // >Threshold is satisfied,<=Threshold is unsatisfied.
    Data* DataSatisfiedList, *DataUnsatisfiedList;
    int DataSatisfiedListLength, DataUnsatisfiedListLength;
    DivisionResult() {};
    DivisionResult(int _SplitDimension, DataType _SplitThreshold, Data* _DataSatisfiedList,
    Data* _DataUnsatisfiedList,int _DataSatisfiedListLength,int _DataUnsatisfiedListLength);
};


class ThresholdStrategy{
    public:
        virtual std::string ThresholdStrategyName() = 0;
        virtual std::string ThresholdStrategyIntroduction();
        virtual bool isStrategy(std::string name) = 0;
        virtual std::string ThresholdStrategyIntroduction(Helper* helper);
        
        void addParama(std::string name,std::string value);
        std::string getParama(std::string name);

        virtual SplitResult FindBestThreshold(Data* DataList, int DataListLength) = 0;
        // DataListDivideByDimensionThresholdWithoutDivision here is a strategy-unrelated and real implication
        // Notice a strategy-related implication still can override the interface if needed
        virtual DivisionResult DataListDivideByDimensionThresholdWithoutDivision(
        Data* DataList, int DataListLength, int Dimension, DataType Threshold);
        // DataListDivideByDimensionThresholdWithDivision here is a strategy-unrelated and real implication
        // Notice a strategy-related implication still can override the interface if needed
        virtual DivisionResult DataListDivideByDimensionThresholdWithDivision(
        Data* DataList, int DataListLength, int Dimension, DataType Threshold);

        // void setEnv(std::vector<int> DynamicLabelList,std::vector<int> DimensionType);
    private:
        std::map<std::string, std::string> ThresholdStrategyParamas;
    // protected:
    //     std::vector<int> *DynamicLabelList;
    //     std::vector<int> *DimensionType;
};

#endif