#ifndef DATA_H
#define DATA_H

#include "Config.h"
#include <vector>
#include <string>
#include <unordered_set>
#include <queue>
#include <map>

typedef int DataType;

#define LABEL_TRUE 1
#define LABEL_FALSE 2
#define LABEL_UNKNOWN 0

struct Interval {
	DataType LeftBound, RightBound;
	Interval() {}
	Interval(DataType _LeftBound, DataType _RightBound);
	DataType Length();
};


#define ActualDimension(X) X.Dimension
#define ArtificialDimension(X) (X.Dimension+ActualDimensionCount)
#define CharacterIsInName(X) (X>='a'&&X<='z')||(X>='A'&&X<='Z')||(X>='0'&&X<='9')||X=='$'||X=='+'||X=='-'||X=='_'

struct Data {
	Interval *Dimension;
	int Label;
	DataType Size;
	int LoopBelong;
#ifdef IMPLICATION
	int DynamicLabelIndex;
	std::vector<int> *FromThis, *ToThis;
	int FromThisLength, ToThisLength;
#endif
	Data() {}

	// Pointer Copy Straightly
	Data(Interval *_Dimension, int _Label, DataType _Size);
	Data(Interval *_Dimension, int _Label);
#ifdef IMPLICATION
	Data(Interval *_Dimension, int _Label, DataType _Size, int _DynamicLabelIndex);
	Data(int _Label, int _DynamicLabelIndex, Interval *_Dimension);
#endif
	void IntervalFree();
	~Data();
};

extern int DataCompareDimension;

// Before the comparision, remember to set DataCompareDimension!
bool DataCompare(Data x, Data y);

extern int DimensionCount;
// From 0 to ActualDimensionCount-1
extern int ActualDimensionCount;

// From ActualDimensionCount to ActualDimensionCount+ArtificialDimensionCount-1
extern int ArtificialDimensionCount;

#define INITIAL_STATE -1
#define END_POINT -2

struct IntervalDecisionTreeNode
{
	IntervalDecisionTreeNode *SatisfiedNode, *UnsatisfiedNode;
	int FeatureSplit; // END_POINT -2,INITIAL_STATE -1
	DataType SplitThreshold; // >Threshold is satisfied,<= is unsatisfied.
	int ClassDivided;
};

extern IntervalDecisionTreeNode *IntervalDecisionTree;


extern std::vector<std::string> Index2Name;
extern std::map<std::string, int> Name2Index;

#define ACTUAL_DIMENSION 1
#define ARTIFICIAL_DIMENSION 0
extern std::vector<int> DimensionType;

typedef int DimensionIndex;
typedef int DimensionValue;
typedef std::pair<DimensionIndex, DimensionValue> DimensionCalculationItem;
typedef std::vector<DimensionCalculationItem> DimensionCalculation;
extern std::vector<DimensionCalculation> Calculation;

extern int SampleCount;
extern std::vector<Data> DataListSaved;

Data* DataListCopyVector2Array(std::vector<Data> DataVector);


typedef std::pair<int, int> Implication;

#ifdef IMPLICATION
extern int ImplicationCount;
struct MyHash {
	size_t operator()(const std::pair<int, int> & v) const {
		return v.first ^ ~v.second;
	}
};
extern std::unordered_set<Implication, MyHash> ImplicationSet;

typedef int IMPLICATION_PREPROCESS_STATE;
#define PREPROCESS_SUCCESS 0
#define PREPROCESS_FAILED 1

IMPLICATION_PREPROCESS_STATE ImplicationPreprocess();


extern std::vector<int> DynamicLabelList;

#endif // IMPLICATION


// To support more loops
extern std::vector<std::string> LoopIndex2Name;
extern std::map<std::string,int> LoopName2Index;

extern int NowProcessingLoopIndex;
extern int LoopCount;

extern std::vector<int> DimensionBelongToLoopIndex;

#endif