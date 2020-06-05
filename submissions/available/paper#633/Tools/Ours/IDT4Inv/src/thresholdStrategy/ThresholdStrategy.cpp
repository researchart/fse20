#include "ThresholdStrategy.h"
#include "Log.h"
#include <cstdlib>
#include <cstring>

std::string ThresholdStrategy::ThresholdStrategyIntroduction(Helper* helper){
    std::string str = ThresholdStrategyName();
    if(helper == nullptr)
        return ThresholdStrategyIntroduction();
    std::string Introduction = helper->getTranslation(str);
    if (Introduction != "")
        return Introduction;
    return ThresholdStrategyIntroduction();
}

std::string ThresholdStrategy::ThresholdStrategyIntroduction(){
    std::string Introduction = ""; // TODO: add in future
    return Introduction;
}

void ThresholdStrategy::addParama(std::string name,std::string value){
    if(ThresholdStrategy::ThresholdStrategyParamas.find(name)==ThresholdStrategy::ThresholdStrategyParamas.end()){
        // Not found, normal
        ThresholdStrategy::ThresholdStrategyParamas[name]=value;
    }
    else{
        // Found duplicate value, warning
        Log::Warning("Duplicate parama in search strategy:'"+name+"'! The new one will be used.");
        ThresholdStrategy::ThresholdStrategyParamas[name]=value;
    }
}
std::string ThresholdStrategy::getParama(std::string name){
    if(ThresholdStrategy::ThresholdStrategyParamas.find(name)==ThresholdStrategy::ThresholdStrategyParamas.end()){
        // Not found, warning
        Log::Info("Parama in search strategy:'"+name+"' not found. Ignore this one using default.");
        return "NF"; // default not found value
    }
    else {
        return ThresholdStrategy::ThresholdStrategyParamas[name];
    }
}
// void ThresholdStrategy::setEnv(std::vector<int> DynamicLabelList,std::vector<int> DimensionType){
//     this->DynamicLabelList = &DynamicLabelList;
//     this->DimensionType = &DimensionType;
// }

DivisionResult ThresholdStrategy::DataListDivideByDimensionThresholdWithoutDivision(
    Data* DataList, int DataListLength, int Dimension, DataType Threshold){
    // Implications:
    DivisionResult Result;
    Result.SplitDimension = Dimension;
    Result.SplitThreshold = Threshold;
    Result.DataSatisfiedListLength = Result.DataUnsatisfiedListLength = 0;
    Result.DataSatisfiedList = new Data[DataListLength + 10];
    Result.DataUnsatisfiedList = new Data[DataListLength + 10];
    
    for (int i = 0; i < DataListLength; ++i) {
        if (DataList[i].Dimension[Dimension].LeftBound > Threshold &&
            DataList[i].Dimension[Dimension].RightBound > Threshold) {
            Result.DataSatisfiedList[Result.DataSatisfiedListLength] 
                = Data(DataList[i].Dimension, DataList[i].Label, DataList[i].Size);
#ifdef IMPLICATION
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].FromThis
                = DataList[i].FromThis;
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].FromThisLength
                = DataList[i].FromThisLength;
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].ToThis
                = DataList[i].ToThis;
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].ToThisLength
                = DataList[i].ToThisLength;
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].DynamicLabelIndex
                = DataList[i].DynamicLabelIndex;
#endif 
            ++Result.DataSatisfiedListLength;
        }
        else if (DataList[i].Dimension[Dimension].LeftBound <= Threshold &&
            DataList[i].Dimension[Dimension].RightBound <= Threshold) {
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength] 
                = Data(DataList[i].Dimension, DataList[i].Label, DataList[i].Size);
#ifdef IMPLICATION
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].FromThis
                = DataList[i].FromThis;
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].FromThisLength
                = DataList[i].FromThisLength;
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].ToThis
                = DataList[i].ToThis;
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].ToThisLength
                = DataList[i].ToThisLength;
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].DynamicLabelIndex
                = DataList[i].DynamicLabelIndex;
#endif 
            ++Result.DataUnsatisfiedListLength;
        }
        else {
            // printf("[Error] Should not exist divisions");
            // Program::stop();
            Log::Error("Should not exist divisions.");
            Program::stop();
        }
    }

    // Because of reuse, not need to fully release the space.
    
    delete[] DataList;
    
    ///FREE the Data Here (Own Func) and when only end-point. COPY FULLY and Release FULLY.

    return Result;
}


// DataListDivideByDimensionThresholdWithoutDivision here is an increasable implication
DivisionResult ThresholdStrategy::DataListDivideByDimensionThresholdWithDivision(
    Data* DataList, int DataListLength, int Dimension, DataType Threshold){
	// std::vector<int> DynamicLabelList = *(this->DynamicLabelList);
	// std::vector<int> DimensionType = *(this->DimensionType);
    // Implications:
    // TODO: Check the implications.
    DivisionResult Result;
    Result.SplitDimension = Dimension;
    Result.SplitThreshold = Threshold;
    Result.DataSatisfiedListLength = Result.DataUnsatisfiedListLength = 0;
    Result.DataSatisfiedList = new Data[DataListLength + 10];
    Result.DataUnsatisfiedList = new Data[DataListLength + 10];
    //todo
    for (int i = 0; i < DataListLength; ++i) {
        if (DataList[i].Dimension[Dimension].LeftBound > Threshold &&
            DataList[i].Dimension[Dimension].RightBound > Threshold) {
            Result.DataSatisfiedList[Result.DataSatisfiedListLength]
                = Data(DataList[i].Dimension, DataList[i].Label, DataList[i].Size);
#ifdef IMPLICATION
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].FromThis
                = DataList[i].FromThis;
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].FromThisLength
                = DataList[i].FromThisLength;
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].ToThis
                = DataList[i].ToThis;
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].ToThisLength
                = DataList[i].ToThisLength;
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].DynamicLabelIndex
                = DataList[i].DynamicLabelIndex;
#endif

            ++Result.DataSatisfiedListLength;
        }
        else if (DataList[i].Dimension[Dimension].LeftBound <= Threshold &&
            DataList[i].Dimension[Dimension].RightBound <= Threshold) {
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength]
                = Data(DataList[i].Dimension, DataList[i].Label, DataList[i].Size);
#ifdef IMPLICATION
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].FromThis
                = DataList[i].FromThis;
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].FromThisLength
                = DataList[i].FromThisLength;
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].ToThis
                = DataList[i].ToThis;
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].ToThisLength
                = DataList[i].ToThisLength;
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].DynamicLabelIndex
                = DataList[i].DynamicLabelIndex;
#endif
            ++Result.DataUnsatisfiedListLength;
        }
        else if (DataList[i].Dimension[Dimension].LeftBound <= Threshold &&
            DataList[i].Dimension[Dimension].RightBound > Threshold) {
            Interval *DimensionCopy = new Interval[DimensionCount + 10];
            memcpy(DimensionCopy, DataList[i].Dimension, sizeof(Interval)*DimensionCount);

            Result.DataSatisfiedList[Result.DataSatisfiedListLength]
                = Data(DataList[i].Dimension, DataList[i].Label, DataList[i].Size);
#ifdef IMPLICATION
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].DynamicLabelIndex
                = DataList[i].DynamicLabelIndex;
            /*
            std::vector<int>* NewFromSatisfiedList = new std::vector<int>;
            std::vector<int>* NewToSatisfiedList = new std::vector<int>;
            NewFromSatisfiedList[0] = DataList[i].FromThis[0];
            NewToSatisfiedList[0] = DataList[i].ToThis[0];
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].FromThis = NewFromSatisfiedList;
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].ToThis = NewToSatisfiedList;
            */
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].FromThis = DataList[i].FromThis;
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].ToThis = DataList[i].ToThis;
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].FromThisLength 
                = DataList[i].FromThisLength;
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].ToThisLength
                = DataList[i].ToThisLength;

#endif
            int DEBUGOLD0 = Result.DataSatisfiedList[Result.DataSatisfiedListLength].Size;
            Result.DataSatisfiedList[Result.DataSatisfiedListLength].Size =
                Result.DataSatisfiedList[Result.DataSatisfiedListLength].Size /
                Result.DataSatisfiedList[Result.DataSatisfiedListLength]
                .Dimension[Dimension].Length() * (
                    Result.DataSatisfiedList[Result.DataSatisfiedListLength]
                    .Dimension[Dimension].RightBound - Threshold);

            if(Result.DataSatisfiedList[Result.DataSatisfiedListLength].Size==0)
//            {
//                printf("Q%d,%d,%d,%d", DEBUGOLD0,
//                       Result.DataSatisfiedList[Result.DataSatisfiedListLength]
//                               .Dimension[Dimension].Length(), Result.DataSatisfiedList[Result.DataSatisfiedListLength]
//                               .Dimension[Dimension].LeftBound,Threshold
//                );
//                Program::stop();
//            }
                Result.DataSatisfiedList[Result.DataSatisfiedListLength].Size=1;

            Result.DataSatisfiedList[Result.DataSatisfiedListLength]
                .Dimension[Dimension].LeftBound = Threshold + 1;

            //ARTIFICIAL_DIMENSION re-calculate
            for (int AttributeIndex = 0; AttributeIndex < DimensionCount; ++AttributeIndex) {
                if (DimensionType[AttributeIndex] == ARTIFICIAL_DIMENSION) {
                    int LinerRelationSize = (int)Calculation[AttributeIndex].size();
                    if (LinerRelationSize == 0) {
                        Log::Error("No liner relation!");
                        Program::stop();
                    }
                    DataType LeftBound = 0, RightBound = 0;
                    for (int LinerRelationItem = 0;
                        LinerRelationItem < LinerRelationSize; ++LinerRelationItem) {
                        if (Calculation[AttributeIndex][LinerRelationItem].second >= 0) {
                            LeftBound +=
                                Calculation[AttributeIndex][LinerRelationItem].second *
                                Result.DataSatisfiedList[Result.DataSatisfiedListLength]
                                .Dimension[Calculation[AttributeIndex][LinerRelationItem].first].LeftBound;
                            RightBound +=
                                Calculation[AttributeIndex][LinerRelationItem].second *
                                Result.DataSatisfiedList[Result.DataSatisfiedListLength]
                                .Dimension[Calculation[AttributeIndex][LinerRelationItem].first].RightBound;
                        }
                        else {
                            LeftBound +=
                                Calculation[AttributeIndex][LinerRelationItem].second *
                                Result.DataSatisfiedList[Result.DataSatisfiedListLength]
                                .Dimension[Calculation[AttributeIndex][LinerRelationItem].first].RightBound;
                            RightBound +=
                                Calculation[AttributeIndex][LinerRelationItem].second *
                                Result.DataSatisfiedList[Result.DataSatisfiedListLength]
                                .Dimension[Calculation[AttributeIndex][LinerRelationItem].first].LeftBound;
                        }
                    }

                    Result.DataSatisfiedList[Result.DataSatisfiedListLength]
                        .Dimension[AttributeIndex] = Interval(LeftBound, RightBound);
                }
            }
            


            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength]
                = Data(DimensionCopy, DataList[i].Label, DataList[i].Size);
#ifdef IMPLICATION
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].DynamicLabelIndex
                = DataList[i].DynamicLabelIndex;
            std::vector<int>* NewFromUnsatisfiedList = new std::vector<int>;
            std::vector<int>* NewToUnsatisfiedList = new std::vector<int>;
            NewFromUnsatisfiedList[0] = DataList[i].FromThis[0];
            NewToUnsatisfiedList[0] = DataList[i].ToThis[0];
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].FromThis = NewFromUnsatisfiedList;
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].ToThis = NewToUnsatisfiedList;
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].FromThisLength
                = DataList[i].FromThisLength;
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].ToThisLength
                = DataList[i].ToThisLength;
#endif
            int DEBUGOLD = Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].Size;
            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].Size =
                Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].Size / 
                Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength]
                .Dimension[Dimension].Length() * (
                    Threshold + 1 - 
                    Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength]
                    .Dimension[Dimension].LeftBound);
            if(Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].Size==0)
//            {
//                    printf("%d,%d,%d", DEBUGOLD,
//                           Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength]
//                                   .Dimension[Dimension].Length(), Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength]
//                                   .Dimension[Dimension].RightBound, Threshold
//                    );
//                    Program::stop();
//                }
                Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength].Size=1;

            Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength]
                .Dimension[Dimension].RightBound = Threshold;

            //ARTIFICIAL_DIMENSION re-calculate
            for (int AttributeIndex = 0; AttributeIndex < DimensionCount; ++AttributeIndex) {
                if (DimensionType[AttributeIndex] == ARTIFICIAL_DIMENSION) {
                    int LinerRelationSize = (int)Calculation[AttributeIndex].size();
                    if (LinerRelationSize == 0) {
                        // printf("[ERROR] No liner relation!\n");
                        // Program::stop();
                        Log::Error("No liner relation!");
                        Program::stop();
                    }
                    DataType LeftBound = 0, RightBound = 0;
                    for (int LinerRelationItem = 0;
                        LinerRelationItem < LinerRelationSize; ++LinerRelationItem) {
                        if (Calculation[AttributeIndex][LinerRelationItem].second >= 0) {
                            LeftBound +=
                                Calculation[AttributeIndex][LinerRelationItem].second *
                                Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength]
                                .Dimension[Calculation[AttributeIndex][LinerRelationItem].first].LeftBound;
                            RightBound +=
                                Calculation[AttributeIndex][LinerRelationItem].second *
                                Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength]
                                .Dimension[Calculation[AttributeIndex][LinerRelationItem].first].RightBound;
                        }
                        else {
                            LeftBound +=
                                Calculation[AttributeIndex][LinerRelationItem].second *
                                Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength]
                                .Dimension[Calculation[AttributeIndex][LinerRelationItem].first].RightBound;
                            RightBound +=
                                Calculation[AttributeIndex][LinerRelationItem].second *
                                Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength]
                                .Dimension[Calculation[AttributeIndex][LinerRelationItem].first].LeftBound;
                        }
                    }

                    Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength]
                        .Dimension[AttributeIndex] = Interval(LeftBound, RightBound);
                }
            }
            ++Result.DataSatisfiedListLength;
            ++Result.DataUnsatisfiedListLength;
#ifdef IMPLICATION
            if (DynamicLabelList[DataList[i].DynamicLabelIndex]==LABEL_UNKNOWN) {
                /*
                DynamicLabelList.push_back(LABEL_UNKNOWN);
                Result.DataSatisfiedList[Result.DataSatisfiedListLength - 1]
                .DynamicLabelIndex = DynamicLabelList.size() - 1;
                
                Result.DataSatisfiedList[Result.DataSatisfiedListLength - 1].FromThis[0].push_back(
                    DataList[i].DynamicLabelIndex);
                ++Result.DataSatisfiedList[Result.DataSatisfiedListLength - 1].FromThisLength;
                Result.DataSatisfiedList[Result.DataSatisfiedListLength - 1].ToThis[0].push_back(
                    DataList[i].DynamicLabelIndex);
                ++Result.DataSatisfiedList[Result.DataSatisfiedListLength - 1].ToThisLength;

                Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength - 1].FromThis[0].push_back(
                    DynamicLabelList.size() - 1);
                ++Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength - 1].FromThisLength;
                Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength - 1].ToThis[0].push_back(
                    DynamicLabelList.size() - 1);
                ++Result.DataUnsatisfiedList[Result.DataUnsatisfiedListLength - 1].ToThisLength;
                */
            }
#endif 

            
        }
        else {
            // printf("[Error] Data bound error!");
            // Program::stop();
            Log::Error("Data bound error!");
            Program::stop();
        }
    }

    // Because of reuse, not need to fully release the space.
    // TODO: !!!! delete[] DataList;
    delete[] DataList;

    ///FREE the Data Here (Own Func) and when only end-point. COPY FULLY and Release FULLY.
    return Result;


}




// Constraction function of the result struct
SplitResult::SplitResult(int _Result, int _SplitDimension, 
	DataType _SplitPosition, FLOAT_TYPE _Entropy) {
	Result = _Result;
	SplitDimension = _SplitDimension;
	SplitPosition = _SplitPosition;
	Entropy = _Entropy;
#ifdef THRESHOLD_COST_ON
	TryTimes = 0;
#endif 
}

// Constraction function of the result struct
DivisionResult::DivisionResult(int _SplitDimension, DataType _SplitThreshold,
	Data* _DataSatisfiedList, Data* _DataUnsatisfiedList, 
	int _DataSatisfiedListLength, int _DataUnsatisfiedListLength) {
	SplitDimension = _SplitDimension;
	SplitThreshold = _SplitThreshold;// >Threshold is satisfied,<= is unsatisfied.
	DataSatisfiedList = _DataSatisfiedList;
	DataUnsatisfiedList = _DataUnsatisfiedList;
	DataSatisfiedListLength = _DataSatisfiedListLength;
	DataUnsatisfiedListLength = _DataUnsatisfiedListLength;
}

