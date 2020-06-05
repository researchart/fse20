#include "Data.h"
#include "Program.h"
#include <cassert>
#include <cstdlib>
#include <cstring>
#include <cmath>
#include "Log.h"

Interval::Interval(DataType _LeftBound, DataType _RightBound) {
	LeftBound = _LeftBound;
	RightBound = _RightBound;
}

DataType Interval::Length() {
	return RightBound - LeftBound + 1;
}



Data::Data(Interval *_Dimension, int _Label, DataType _Size) {
	Dimension = _Dimension;
	Label = _Label;
	Size = _Size;
}


Data::Data(Interval *_Dimension, int _Label) {
	Dimension = _Dimension;
	Label = _Label;
	Size = 1;
	for (int i = 0; i < DimensionCount; i++) {
		if (DimensionType[i] == ACTUAL_DIMENSION){
            if(((long long) Size) * Dimension[i].Length() > 300){
                Size = 300;
                break;
            }
        Size *= Dimension[i].Length();}
	}
    Size = sqrt(Size);
    if(Size == 0) Size = 1;
}


#ifdef IMPLICATION
Data::Data(Interval *_Dimension, int _Label, DataType _Size, int _DynamicLabelIndex) {
	Dimension = _Dimension;
	Label = _Label;
	Size = _Size;
	DynamicLabelIndex = _DynamicLabelIndex;
}
Data::Data(int _Label, int _DynamicLabelIndex, Interval *_Dimension) {
	Dimension = _Dimension;
	Label = _Label;
	DynamicLabelIndex = _DynamicLabelIndex;
	Size = 1;
	for (int i = 0; i < DimensionCount; i++) {
		if (DimensionType[i] == ACTUAL_DIMENSION){ // SET Up bound value
			if(((long long) Size) * Dimension[i].Length() > 300){
			    Size = 300;
                break;
			}
            Size *= Dimension[i].Length();
        }
	}
	Size = sqrt(Size);
	if(Size == 0) Size = 1;
}
#endif


void Data::IntervalFree() {
	if (Dimension != nullptr)
		delete[]Dimension;
}

Data::~Data() {
	//delete[]Dimension;
}

int DataCompareDimension = 0;

bool DataCompare(Data x, Data y) {
	// choose one kind of cmp

	
	if (x.Dimension[DataCompareDimension].LeftBound !=
		y.Dimension[DataCompareDimension].LeftBound) {
		return x.Dimension[DataCompareDimension].LeftBound
			< y.Dimension[DataCompareDimension].LeftBound;
	}
	else {
		return x.Dimension[DataCompareDimension].RightBound
			> y.Dimension[DataCompareDimension].RightBound;
	}
	/*
	return x.Dimension[DataCompareDimension].LeftBound <
		y.Dimension[DataCompareDimension].LeftBound;
	*/
}

int DimensionCount = 0;
int ActualDimensionCount = 0;
int ArtificialDimensionCount = 0;

std::vector<std::string> Index2Name;
std::map<std::string, int> Name2Index;
std::vector<int> DimensionType;

std::vector<DimensionCalculation> Calculation;

int SampleCount = 0;
std::vector<Data> DataListSaved;


Data* DataListCopyVector2Array(std::vector<Data> DataVector) {
	int VectorSize = (int) DataVector.size();
	Data* DataArray = new Data[VectorSize + 10];
	for (int i = 0; i < VectorSize; ++i) {
		DataArray[i].Label = DataVector[i].Label;
		DataArray[i].Size = DataVector[i].Size;
#ifdef IMPLICATION
		DataArray[i].DynamicLabelIndex = DataVector[i].DynamicLabelIndex;
		DataArray[i].FromThis = DataVector[i].FromThis;
		DataArray[i].FromThisLength = DataVector[i].FromThisLength;
		DataArray[i].ToThis = DataVector[i].ToThis;
		DataArray[i].ToThisLength = DataVector[i].ToThisLength;
#endif
		DataArray[i].LoopBelong = DataVector[i].LoopBelong;
		Interval* ArrayInterval = new Interval[DimensionCount + 10];
		memcpy(ArrayInterval, DataVector[i].Dimension, sizeof(Interval)*DimensionCount);
		DataArray[i].Dimension = ArrayInterval;
	}
	return DataArray;
}


#ifdef IMPLICATION
int ImplicationCount = 0;
std::unordered_set<Implication, MyHash> ImplicationSet;

// TODO: Logic is complex and need to re-check!
IMPLICATION_PREPROCESS_STATE ImplicationPreprocess() {
	std::queue<int> DataToProcess;

	for (int i = 0; i < SampleCount; ++i) {
		if (DynamicLabelList[DataListSaved[i].DynamicLabelIndex] == LABEL_UNKNOWN)
			continue;
		if (DynamicLabelList[DataListSaved[i].DynamicLabelIndex] == LABEL_TRUE) {
			for (int j = 0; j < DataListSaved[i].FromThisLength; ++j) {
				if (ImplicationSet.count(std::make_pair(
					DataListSaved[i].DynamicLabelIndex,
					DataListSaved[DataListSaved[i].FromThis[0][j]]
					.DynamicLabelIndex)) == 0)
					continue;
				if (DynamicLabelList[DataListSaved[DataListSaved[i].FromThis[0][j]]
					.DynamicLabelIndex]
					== LABEL_TRUE) {
					ImplicationSet.erase(std::make_pair(
						DataListSaved[i].DynamicLabelIndex,
						DataListSaved[DataListSaved[i].FromThis[0][j]]
						.DynamicLabelIndex));
				}
				else if (DynamicLabelList[DataListSaved[DataListSaved[i].FromThis[0][j]]
					.DynamicLabelIndex] == LABEL_FALSE) {
					return PREPROCESS_FAILED;
				}
				else {
					DataToProcess.push(DataListSaved[i].FromThis[0][j]);
					DynamicLabelList[DataListSaved[DataListSaved[i].FromThis[0][j]]
						.DynamicLabelIndex] = LABEL_TRUE;
					ImplicationSet.erase(std::make_pair(
						DataListSaved[i].DynamicLabelIndex, 
						DataListSaved[DataListSaved[i].FromThis[0][j]]
						.DynamicLabelIndex));
				}
			}
			
			for (int j = 0; j < DataListSaved[i].ToThisLength; ++j) {
				if (ImplicationSet.count(std::make_pair(
					DataListSaved[DataListSaved[i].ToThis[0][j]].DynamicLabelIndex,
					DataListSaved[i].DynamicLabelIndex)) == 0)
					continue;
				ImplicationSet.erase(std::make_pair(
					DataListSaved[DataListSaved[i].ToThis[0][j]].DynamicLabelIndex,
					DataListSaved[i].DynamicLabelIndex));
			}
		}
		else if (DynamicLabelList[DataListSaved[i].DynamicLabelIndex] == LABEL_FALSE) {
			for (int j = 0; j < DataListSaved[i].FromThisLength; ++j) {
				if (ImplicationSet.count(std::make_pair(
					DataListSaved[i].DynamicLabelIndex,
					DataListSaved[DataListSaved[i].FromThis[0][j]]
					.DynamicLabelIndex)) == 0)
					continue;
				ImplicationSet.erase(std::make_pair(
					DataListSaved[i].DynamicLabelIndex,
					DataListSaved[DataListSaved[i].FromThis[0][j]]
					.DynamicLabelIndex));
			}
			for (int j = 0; j < DataListSaved[i].ToThisLength; ++j) {
				if (ImplicationSet.count(std::make_pair(
					DataListSaved[DataListSaved[i].ToThis[0][j]].DynamicLabelIndex,
					DataListSaved[i].DynamicLabelIndex)) == 0)
					continue;
				if (DynamicLabelList[DataListSaved[DataListSaved[i]
					.ToThis[0][j]].DynamicLabelIndex] == LABEL_TRUE) {
					return PREPROCESS_FAILED;
				}
				else if (DynamicLabelList[DataListSaved[DataListSaved[i]
					.ToThis[0][j]].DynamicLabelIndex] == LABEL_FALSE) {
					ImplicationSet.erase(std::make_pair(
						DataListSaved[DataListSaved[i].ToThis[0][j]].DynamicLabelIndex,
						DataListSaved[i].DynamicLabelIndex));
				}
				else {
					DataToProcess.push(DataListSaved[i].ToThis[0][j]);
					DynamicLabelList[DataListSaved[DataListSaved[i].ToThis[0][j]]
						.DynamicLabelIndex] = LABEL_FALSE;
					ImplicationSet.erase(std::make_pair(
						DataListSaved[DataListSaved[i].ToThis[0][j]].DynamicLabelIndex,
						DataListSaved[i].DynamicLabelIndex));
				}
			}
		}
		else {
			Program::stop();
		}
	}
	
	while (!DataToProcess.empty()) {
		int DataFront = DataToProcess.front();
		DataToProcess.pop();

		if (DynamicLabelList[DataListSaved[DataFront]
			.DynamicLabelIndex] == LABEL_TRUE) {
			for (int j = 0; j < DataListSaved[DataFront].FromThisLength; ++j) {
				if (ImplicationSet.count(std::make_pair(
					DataListSaved[DataFront].DynamicLabelIndex,
					DataListSaved[DataListSaved[DataFront].FromThis[0][j]]
					.DynamicLabelIndex)) == 0)
					continue;
				if (DynamicLabelList[DataListSaved[DataListSaved[DataFront].FromThis[0][j]]
					.DynamicLabelIndex]
					== LABEL_TRUE) {
					ImplicationSet.erase(std::make_pair(
						DataListSaved[DataFront].DynamicLabelIndex,
						DataListSaved[DataListSaved[DataFront].FromThis[0][j]]
						.DynamicLabelIndex));
				}
				else if (DynamicLabelList[DataListSaved[DataListSaved[DataFront].FromThis[0][j]]
					.DynamicLabelIndex] == LABEL_FALSE) {
					return PREPROCESS_FAILED;
				}
				else {
					DataToProcess.push(DataListSaved[DataFront].FromThis[0][j]);
					DynamicLabelList[DataListSaved[DataListSaved[DataFront].FromThis[0][j]]
						.DynamicLabelIndex] = LABEL_TRUE;
					ImplicationSet.erase(std::make_pair(
						DataListSaved[DataFront].DynamicLabelIndex,
						DataListSaved[DataListSaved[DataFront].FromThis[0][j]]
						.DynamicLabelIndex));
				}
			}

			for (int j = 0; j < DataListSaved[DataFront].ToThisLength; ++j) {
				if (ImplicationSet.count(std::make_pair(
					DataListSaved[DataListSaved[DataFront].ToThis[0][j]].DynamicLabelIndex,
					DataListSaved[DataFront].DynamicLabelIndex)) == 0)
					continue;
				ImplicationSet.erase(std::make_pair(
					DataListSaved[DataListSaved[DataFront].ToThis[0][j]].DynamicLabelIndex,
					DataListSaved[DataFront].DynamicLabelIndex));
			}
		}
		else if (DynamicLabelList[DataListSaved[DataFront]
			.DynamicLabelIndex] == LABEL_FALSE) {
			for (int j = 0; j < DataListSaved[DataFront].FromThisLength; ++j) {
				if (ImplicationSet.count(std::make_pair(
					DataListSaved[DataFront].DynamicLabelIndex,
					DataListSaved[DataListSaved[DataFront].FromThis[0][j]]
					.DynamicLabelIndex)) == 0)
					continue;
				ImplicationSet.erase(std::make_pair(
					DataListSaved[DataFront].DynamicLabelIndex,
					DataListSaved[DataListSaved[DataFront].FromThis[0][j]]
					.DynamicLabelIndex));
			}
			for (int j = 0; j < DataListSaved[DataFront].ToThisLength; ++j) {
				if (ImplicationSet.count(std::make_pair(
					DataListSaved[DataListSaved[DataFront].ToThis[0][j]].DynamicLabelIndex,
					DataListSaved[DataFront].DynamicLabelIndex)) == 0)
					continue;
				if (DynamicLabelList[DataListSaved[DataListSaved[DataFront]
					.ToThis[0][j]].DynamicLabelIndex] == LABEL_TRUE) {
					return PREPROCESS_FAILED;
				}
				else if (DynamicLabelList[DataListSaved[DataListSaved[DataFront]
					.ToThis[0][j]].DynamicLabelIndex] == LABEL_FALSE) {
					ImplicationSet.erase(std::make_pair(
						DataListSaved[DataListSaved[DataFront].ToThis[0][j]].DynamicLabelIndex,
						DataListSaved[DataFront].DynamicLabelIndex));
				}
				else {
					DataToProcess.push(DataListSaved[DataFront].ToThis[0][j]);
					DynamicLabelList[DataListSaved[DataListSaved[DataFront].ToThis[0][j]]
						.DynamicLabelIndex] = LABEL_FALSE;
					ImplicationSet.erase(std::make_pair(
						DataListSaved[DataListSaved[DataFront].ToThis[0][j]].DynamicLabelIndex,
						DataListSaved[DataFront].DynamicLabelIndex));
				}
			}
		}
		else if (DynamicLabelList[DataListSaved[DataFront].DynamicLabelIndex]
			== LABEL_UNKNOWN) {
			Log::Error("Should not exist unknown label!");
			Program::stop();
		}
		else {
			Log::Error("Label error!");
			Program::stop();
		}


	}
	return PREPROCESS_SUCCESS;
}

std::vector<int> DynamicLabelList;




#endif // IMPLICATION


// To support more loops
std::vector<std::string> LoopIndex2Name;
std::map<std::string, int> LoopName2Index;

int NowProcessingLoopIndex;
int LoopCount = 0;

std::vector<int> DimensionBelongToLoopIndex;

