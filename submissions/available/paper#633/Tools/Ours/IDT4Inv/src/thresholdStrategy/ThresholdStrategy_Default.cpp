#include "ThresholdStrategy_Default.h"
#include "Program.h"
#include "Log.h"
#include <map>
#include <unordered_map>
#include <queue>
#include "InformationEntropy.h"
#include <algorithm>

#include <assert.h> // TODO: Temperarily use

// Basic infomation of implications
std::string ThresholdStrategy_Default::ThresholdStrategyName(){
	return "Default threshold strategy";// TODO: Add name if needed
}

std::string ThresholdStrategy_Default::ThresholdStrategyIntroduction(){
	return "This is default threshold strategy";// TODO: Add Introduction if needed
}

bool ThresholdStrategy_Default::isStrategy(std::string name) {
	// Default strategy always match every name
	return true;
}


SplitResult ThresholdStrategy_Default::FindBestThreshold(Data* DataList, int DataListLength){
	// check all label is same
	bool AllIsSame = true;
	// std::vector<int> DynamicLabelList = *(this->DynamicLabelList);
	// DataList[0];
	// std::vector<int> DimensionType = *(this->DimensionType);
#ifndef IMPLICATION
	for (int i = 1; i < DataListLength; ++i) {
		if (DataList[i].Label != DataList[0].Label) {
			AllIsSame = false;
			break;
		}
	}
#else
	int LabelType = LABEL_UNKNOWN;
	//int *UnknownLabelList = new int[DataListLength];
	//int UnknownLabelListLength = 0;
	int k = 0;
	while (k < DataListLength && DynamicLabelList[DataList[k].DynamicLabelIndex] == LABEL_UNKNOWN) {
		//UnknownLabelList[UnknownLabelListLength] = k;
		++k;
	}
	if (k == DataListLength) {
		//Program::stop();
		--k;
	}
	if(k>=0 && k<DataListLength)
		LabelType = DynamicLabelList[DataList[k].DynamicLabelIndex];
	++k;
	for (; k < DataListLength; ++k) {
		if (DynamicLabelList[DataList[k].DynamicLabelIndex] == LABEL_UNKNOWN)
			continue;
		if (DynamicLabelList[DataList[k].DynamicLabelIndex] != LabelType) {
			AllIsSame = false;
			break;
		}
	}
#endif


	if (AllIsSame) {
#ifndef IMPLICATION
		SplitResult Result = SplitResult(ONE_CLASS_LEFT, DataList[0].Label, 0, 0);
#else
		SplitResult Result = SplitResult(ONE_CLASS_LEFT, LabelType, 0, 0);
#endif


		return Result;
	}

	// count
	DataType PositiveCount = 0, NegativeCount = 0;
#ifndef IMPLICATION
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
		}
	}
#else
	for (int i = 0; i < DataListLength; ++i) {
		if (DynamicLabelList[DataList[i].DynamicLabelIndex] == LABEL_TRUE)
			PositiveCount += DataList[i].Size;
		else if (DynamicLabelList[DataList[i].DynamicLabelIndex] == LABEL_FALSE)
			NegativeCount += DataList[i].Size;
		else if (DynamicLabelList[DataList[i].DynamicLabelIndex] == LABEL_UNKNOWN) {
			// No thing to do.
		}
		else {
			Log::Error("Label type is error.");
		}
	}
#endif
	SplitResult NowBestResult = SplitResult(SPLIT_NOT_FOUND, -1, 0, 0);

#ifndef MULTI_THREAD_ON
	// Try to avoid division

	for (int DimensionItem = 0; DimensionItem < DimensionCount; ++DimensionItem) {
		if (DimensionBelongToLoopIndex[DimensionItem] != NowProcessingLoopIndex) {
			continue;
		}
		DataCompareDimension = DimensionItem;
		std::sort(DataList, DataList + DataListLength, DataCompare);


		/*
		if(DataListLength >=3)
		std::sort(DataList, DataList + DataListLength, DataCompare);
		else if (DataListLength == 2) {
		if (DataList[0].Dimension[DimensionItem].LeftBound
		> DataList[1].Dimension[DimensionItem].LeftBound) {
		Data Tmp = DataList[0];
		DataList[0] = DataList[1];
		DataList[1] = Tmp;
		}
		}
		*/

		SplitResult DimensionResult = ThresholdStrategy_Default::FindBestThresholdInDimensionWithoutDivision(
			DimensionItem, DataList, DataListLength, PositiveCount, NegativeCount);

		// XRC_Debug_CODE
//        printf("<Debug-Start>\n");
//        printf("DimensionResult = %d\n",DimensionResult.Result);
//        printf("<Debug-End>\n");

#ifdef THRESHOLD_COST_ON
		// This should be checked if it is useful
		double LeftMost = DataList[0].Dimension[DimensionItem].LeftBound;
		double RightMost = DataList[DataListLength - 1].Dimension[DimensionItem].RightBound;
		for (int i = 0; i < DataListLength; i++) {
			if (DataList[i].Dimension[DimensionItem].RightBound > RightMost)
				RightMost = DataList[i].Dimension[DimensionItem].RightBound;
		}
		double ThreshCost = 0;


		double IntervalCost = 1.0 * (RightMost - LeftMost) /
			(DimensionResult.Distance);
		ThreshCost = (IntervalCost < DimensionResult.TryTimes ?
			log2(IntervalCost) : log2(DimensionResult.TryTimes))
			/ (PositiveCount+NegativeCount);
#ifdef SHOW_MORE_INFO
		Log::Text(Format("LM=%.3f;RM=%.3f;Distance=%d;IntervalCost=%.8f;Tries=%d;",
			LeftMost, RightMost, DimensionResult.Distance, IntervalCost, DimensionResult.TryTimes));
		Log::Text(Format("ThreshCost=%.8f", ThreshCost));
#endif // SHOW_MORE_INFO
		DimensionResult.Entropy += ThreshCost;
		FLOAT_TYPE Oldentropy = CalculateInfomationEntropyByCount(PositiveCount, NegativeCount);
		printf("**entropygain=%.8f\n",
			Oldentropy - DimensionResult.Entropy);
#endif 

#ifndef TIME_TEST
		if (DimensionResult.Result == SPLIT_NOT_FOUND) {
			printf("**Splite not found @ %s\n", Index2Name[DimensionItem].c_str());
		}
		else
			printf("**The entropy is: %.8f @ %s : Pos= %d\n",
				DimensionResult.Entropy, Index2Name[DimensionItem].c_str(),
				DimensionResult.SplitPosition);
#endif

		if (NowBestResult.Result == SPLIT_NOT_FOUND
			|| (DimensionResult.Result == SPLIT_SUCCESS && NowBestResult.Entropy > DimensionResult.Entropy)) {
			NowBestResult = DimensionResult;
#ifdef ADVANCE_BREAK
			if (NowBestResult.Entropy < 1e-5) break;
#endif

		}
	}

#else
	//std::thread *t = new std::thread(DimensionCount);
	std::thread t[20];
	for (int DimensionItem = 0; DimensionItem < DimensionCount; ++DimensionItem) {
		t[DimensionItem] = std::thread(FindBestThresholdInDimensionWithoutDivisionMultiThread,
			DimensionItem, DataList, DataListLength, PositiveCount, NegativeCount, NowBestResult);
	}
	for (int DimensionItem = 0; DimensionItem < DimensionCount; ++DimensionItem) {
		t[DimensionItem].join();
	}
#endif

    // XRC_Debug_CODE
//    printf("<Debug-Start>\n");
//    printf("NowBestResult = %d\n",NowBestResult.Result);
//    printf("<Debug-End>\n");



	// Failed to avoid division
//    if (true) // always search...
        if (NowBestResult.Result == SPLIT_NOT_FOUND)
        {
#ifndef TIME_TEST

#endif
		for (int DimensionItem = 0; DimensionItem < DimensionCount; ++DimensionItem) {
			if (DimensionBelongToLoopIndex[DimensionItem] != NowProcessingLoopIndex) {
				continue;
			}
			if (DimensionType[DimensionItem] == ARTIFICIAL_DIMENSION)
				continue;
			DataCompareDimension = DimensionItem;
			std::sort(DataList, DataList + DataListLength, DataCompare);
			SplitResult DimensionResult = ThresholdStrategy_Default::FindBestThresholdInDimensionWithDivision(
				DimensionItem, DataList, DataListLength, PositiveCount, NegativeCount);
#ifndef TIME_TEST
			printf(">>[D]");
			printf("**The entropy is: %.8f @ %s : Pos= %d\n",
				DimensionResult.Entropy, Index2Name[DimensionItem].c_str(),
				DimensionResult.SplitPosition);
#endif

#ifdef THRESHOLD_COST_ON
			// This should be checked if it is useful
			double LeftMost = DataList[0].Dimension[DimensionItem].LeftBound;
			double RightMost = DataList[DataListLength - 1].Dimension[DimensionItem].RightBound;
			for (int i = 0; i < DataListLength; i++) {
				if (DataList[i].Dimension[DimensionItem].RightBound > RightMost)
					RightMost = DataList[i].Dimension[DimensionItem].RightBound;
			}
			double ThreshCost = 0;

			double IntervalCost = (RightMost - LeftMost) /
				(DimensionResult.Distance);
			ThreshCost = (IntervalCost < DimensionResult.TryTimes ?
				log2(IntervalCost) : log2(DimensionResult.TryTimes))
				/ DataListLength;

			DimensionResult.Entropy += ThreshCost;
#endif
			if (NowBestResult.Result == SPLIT_NOT_FOUND
				|| (DimensionResult.Result == SPLIT_WITH_DIVISION
				&& NowBestResult.Entropy > DimensionResult.Entropy)) {
				NowBestResult = DimensionResult;
			}

		}

	}



#ifndef TIME_TEST
	if (NowBestResult.Result == SPLIT_SUCCESS) {
		printf("[ND]");
	}
	else if (NowBestResult.Result == SPLIT_WITH_DIVISION)
		printf("[D]");
	printf("*The min entropy is: %.8f @ %s : Pos= %d\n\n",
		NowBestResult.Entropy, Index2Name[NowBestResult.SplitDimension].c_str(),
		NowBestResult.SplitPosition);
#endif

	if (NowBestResult.Result == SPLIT_NOT_FOUND) {

	    // XRC_Debug_CODE
//	    printf("<Debug-Start>\nSamples:\n");
//		for(int i=0; i<DataListLength; ++i){
//		    printf("Sample%d Siz=%d@%d=>%d: ", i, DataList[i].Size, DataList[i].Label, DynamicLabelList[DataList[i].DynamicLabelIndex]);
//		    for(int j=0;j<DimensionCount;++j){
//                if(DimensionType[j] != ARTIFICIAL_DIMENSION)
//                    printf("[%d,%d].",DataList[i].Dimension[j].LeftBound,DataList[i].Dimension[j].RightBound);
//                else
//                    printf("{%d,%d}.",DataList[i].Dimension[j].LeftBound,DataList[i].Dimension[j].RightBound);
//		    }
//            printf("\n");
//		}
//        printf("<Debug-End>\n");

	    // printf("[Error] Labels of data exist contradiction!\n");
		// Program::stop();
        Log::Error("[Error] Labels of data exist contradiction!");
        Program::stop();
	}
	return NowBestResult;
}



#define RightPositive (PositiveCount-LeftPositive)
#define RightNegative (NegativeCount-LeftNegative)
#define LeftAll (LeftPositive+LeftNegative)
#define AllAll (PositiveCount+NegativeCount)
#define RightAll (AllAll-LeftAll)
#define LeftPossibility (1.0*LeftAll/AllAll)
#define RightPossibility (1.0*RightAll/AllAll)



SplitResult ThresholdStrategy_Default::FindBestThresholdInDimensionWithoutDivision(
    int SplitDimension, Data *SortedDataList, int DataListLength,
    DataType PositiveCount, DataType NegativeCount){
	// std::vector<int> DynamicLabelList = *(this->DynamicLabelList);
	// std::vector<int> DimensionType = *(this->DimensionType);
    // Implications:
#ifdef SHOW_MORE_INFO
	FLOAT_TYPE OldEntropy = CalculateInfomationEntropyByCount(PositiveCount, NegativeCount);
	printf("The former entropy is %.8f\n", OldEntropy);
#endif
	SplitResult NowBestResult = SplitResult(SPLIT_NOT_FOUND, SplitDimension, 0, 0);

	//DataType *PossibleSplitPosition = new DataType[2 * DataListLength];
	//int PossibleSplitPositionCount = 0;

	if (DataListLength <= 1) {
		// printf("[Error] Data list is none or only one when split.");
		// Program::stop();
        Log::Error("[Error] Data list is none or only one when split.");
        Program::stop();
	}
//    // XRC_Debug_CODE
//    printf("<Debug-Start>\nSortedDataList:\n");
//    for(int i=0; i<DataListLength; ++i){
//        printf("Sample%d Siz=%d@%d=>%d: ", i, SortedDataList[i].Size, SortedDataList[i].Label, DynamicLabelList[SortedDataList[i].DynamicLabelIndex]);
//        for(int j=0;j<DimensionCount;++j){
//            if(DimensionType[j] != ARTIFICIAL_DIMENSION)
//                printf("[%d,%d].",SortedDataList[i].Dimension[j].LeftBound,SortedDataList[i].Dimension[j].RightBound);
//            else
//                printf("{%d,%d}.",SortedDataList[i].Dimension[j].LeftBound,SortedDataList[i].Dimension[j].RightBound);
//        }
//        printf("\n");
//    }
//    printf("<Debug-End>\n");

	DataType RightChecker = SortedDataList[0].Dimension[SplitDimension].RightBound;
	DataType LeftPositive = 0, LeftNegative = 0;
#ifndef IMPLICATION
	if (SortedDataList[0].Label == LABEL_TRUE) {
		LeftPositive += SortedDataList[0].Size;
	}
	else if (SortedDataList[0].Label == LABEL_FALSE) {
		LeftNegative += SortedDataList[0].Size;
	}
	else {
		printf("[Error] Label type is error.\n");
		Program::stop();
	}
#else
	// LIW is U->S and RIW is S->U
	DataType LeftImplicationWeight = 0, RightImplicationWeight = 0;
	
#ifdef USE_HASH_SET
	std::unordered_map<int,DataType> LeftSet, RightSet;
#else
	std::map<int, DataType> LeftSet, RightSet;
#endif 
	LeftSet[SortedDataList[0].DynamicLabelIndex] = SortedDataList[0].Size;
	for (int i = 1; i < DataListLength; ++i) {
		RightSet[SortedDataList[i].DynamicLabelIndex] = SortedDataList[i].Size;
	}
	

	if (DynamicLabelList[SortedDataList[0].DynamicLabelIndex] == LABEL_TRUE) {
		LeftPositive += SortedDataList[0].Size;
	}
	else if (DynamicLabelList[SortedDataList[0].DynamicLabelIndex] == LABEL_FALSE) {
		LeftNegative += SortedDataList[0].Size;
	}
	else if (DynamicLabelList[SortedDataList[0].DynamicLabelIndex] == LABEL_UNKNOWN) {
		for (int j = 0; j < SortedDataList[0].FromThisLength; ++j) {
			DataType LeftSize = SortedDataList[0].Size;
			DataType RightSize = RightSet[SortedDataList[0].FromThis[0][j]];
			if (RightSize != 0) {
				// Weight Calculation Way. NEED TO CHECK. TODO!
				if (ImplicationSet.count(std::make_pair(SortedDataList[0].DynamicLabelIndex,
					SortedDataList[0].FromThis[0][j])) == 1)
					LeftImplicationWeight += LeftSize * RightSize;
			}
		}
		for (int j = 0; j < SortedDataList[0].ToThisLength; ++j) {
			DataType LeftSize = SortedDataList[0].Size;
			DataType RightSize = RightSet[SortedDataList[0].ToThis[0][j]];
			if (RightSize != 0) {
				// Weight Calculation Way. NEED TO CHECK. TODO!
				if (ImplicationSet.count(std::make_pair(
					SortedDataList[0].ToThis[0][j],
					SortedDataList[0].DynamicLabelIndex)) == 1)
				RightImplicationWeight += LeftSize * RightSize;
			}
		}

	}
	else {
		// printf("[Error] Label type is error.\n");
		// Program::stop();
        Log::Error("Label type is error.");
        Program::stop();
	}
#endif
//    printf("<DEBUG>LA%d,RA%d\n",LeftAll,RightAll);
	for (int i = 1; i < DataListLength; ++i) {
//		printf("<DEBUG>RC@%d\n",RightChecker);
	    if (RightChecker > SortedDataList[i].Dimension[SplitDimension].LeftBound - 1) {
#ifndef IMPLICATION
			if (SortedDataList[i].Label == LABEL_TRUE) {
				LeftPositive += SortedDataList[i].Size;
			}
			else if (SortedDataList[i].Label == LABEL_FALSE) {
				LeftNegative += SortedDataList[i].Size;
			}
			else {
				printf("[Error] Label type is error.\n");
				Program::stop();
			}
#else
			if (DynamicLabelList[SortedDataList[i].DynamicLabelIndex] == LABEL_TRUE) {
				LeftPositive += SortedDataList[i].Size;
			}
			else if (DynamicLabelList[SortedDataList[i].DynamicLabelIndex] == LABEL_FALSE) {
				LeftNegative += SortedDataList[i].Size;
			}
			else if (DynamicLabelList[SortedDataList[i].DynamicLabelIndex] == LABEL_UNKNOWN) {
				// move item from Right to left
				RightSet[SortedDataList[i].DynamicLabelIndex] = 0;
				LeftSet[SortedDataList[i].DynamicLabelIndex] = SortedDataList[i].Size;
				// Weight add check
				for (int j = 0; j < SortedDataList[i].FromThisLength; ++j) {
					DataType LeftSize = SortedDataList[i].Size;
					DataType RightSize = RightSet[SortedDataList[i].FromThis[0][j]];
					if (RightSize != 0) {
						// Weight Calculation Way. NEED TO CHECK. TODO!
						if (ImplicationSet.count(std::make_pair(SortedDataList[i].DynamicLabelIndex,
							SortedDataList[i].FromThis[0][j])) == 1)
						LeftImplicationWeight += LeftSize * RightSize;
					}
				}
				for (int j = 0; j < SortedDataList[i].ToThisLength; ++j) {
					DataType LeftSize = SortedDataList[i].Size;
					DataType RightSize = RightSet[SortedDataList[i].ToThis[0][j]];
					if (RightSize != 0) {
						// Weight Calculation Way. NEED TO CHECK. TODO!
						if (ImplicationSet.count(std::make_pair(
							SortedDataList[i].ToThis[0][j],
							SortedDataList[i].DynamicLabelIndex)) == 1)
						RightImplicationWeight += LeftSize * RightSize;
					}
				}
				// Weight minus check
				for (int j = 0; j < SortedDataList[i].FromThisLength; ++j) {
					DataType RightSize = SortedDataList[i].Size;
					DataType LeftSize = LeftSet[SortedDataList[i].FromThis[0][j]];
					if (LeftSize != 0) {
						// Weight Calculation Way. NEED TO CHECK. TODO!
						if (ImplicationSet.count(std::make_pair(
							SortedDataList[i].DynamicLabelIndex,
							SortedDataList[i].FromThis[0][j])) == 1)
						RightImplicationWeight -= LeftSize * RightSize;
					}
				}
				for (int j = 0; j < SortedDataList[i].ToThisLength; ++j) {
					DataType RightSize = SortedDataList[i].Size;
					DataType LeftSize = LeftSet[SortedDataList[i].ToThis[0][j]];
					if (LeftSize != 0) {
						// Weight Calculation Way. NEED TO CHECK. TODO!
						if (ImplicationSet.count(std::make_pair(SortedDataList[i].ToThis[0][j],
							SortedDataList[i].DynamicLabelIndex)) == 1)
						LeftImplicationWeight -= LeftSize * RightSize;
					}
				}


			}
			else {
				// printf("[Error] Label type is error.\n");
				// Program::stop();
                Log::Error("Label type is error.");
                Program::stop();
			}
#endif
			if (RightChecker < SortedDataList[i].Dimension[SplitDimension].RightBound) {
				RightChecker = SortedDataList[i].Dimension[SplitDimension].RightBound;
			}

		}
		else {
			bool CheckPenalty = true;
			//XRC_DEBUG_CODE
//			printf("<DEBUG>LA%d,RA%d\n",LeftAll,RightAll);

#ifdef IMPLICATION
			/*reuse*/
			if ((LeftAll == 0) || (RightAll == 0))
				CheckPenalty = false;
			/*reuse*/
#endif
			if (CheckPenalty) {

				FLOAT_TYPE EntropyNow =
					CalculateInfomationEntropyByCount(LeftPositive, LeftNegative)
					* LeftPossibility
					+ CalculateInfomationEntropyByCount(RightPositive, RightNegative)
					* RightPossibility;
			
#ifdef SHOW_MORE_INFO
				printf("The spilt possible position @ %d:\n", RightChecker);
				printf("EntropyNow=%.8f;\n", EntropyNow);

#endif
#ifdef IMPLICATION
				FLOAT_TYPE Penalty;
				if (LeftAll == 0 || RightAll == 0) {
					Penalty = 1.0 * LeftImplicationWeight + 1.0 * RightImplicationWeight;
				}
				else {
				Penalty = 1.0 * LeftImplicationWeight *
					(1.0 - LeftNegative * RightPositive / (LeftAll) / (RightAll));
				Penalty += 1.0 * RightImplicationWeight *
					(1.0 - RightNegative * LeftPositive / (LeftAll) / (RightAll));
				}
				Penalty = Penalty * 2 / (PositiveCount + NegativeCount 
					+ 2 * (LeftImplicationWeight + RightImplicationWeight));
				
#ifdef SHOW_MORE_INFO
				printf("Penalty=%.8f;\n", Penalty);
#endif
#ifndef TIME_TEST
				//Test if need 
#endif
				EntropyNow += Penalty;
#endif
#ifdef SHOW_MORE_INFO
				printf("InfoGain=%.8f;\n",OldEntropy - EntropyNow);
#endif
#ifdef THRESHOLD_COST_ON
				++NowBestResult.TryTimes;
#endif
				if (NowBestResult.Result == SPLIT_NOT_FOUND || NowBestResult.Entropy > EntropyNow) {
					NowBestResult.Result = SPLIT_SUCCESS;
					NowBestResult.Entropy = EntropyNow;
#ifndef NO_DIVISION_HALF_SEARCH
#ifndef RAND_LEFT_OR_RIGHT
					NowBestResult.SplitPosition = RightChecker;
#else // !RAND_LEFT_OR_RIGHT
					srand(time(NULL));
					int RandNum = rand() % 2;
					if (RandNum < 1)
						NowBestResult.SplitPosition = RightChecker;
					else NowBestResult.SplitPosition = SortedDataList[i].Dimension[SplitDimension].LeftBound - 1;
#endif
#else // !NO_DIVISION_HALF_SEARCH

					NowBestResult.SplitPosition = DataType(RightChecker + SortedDataList[i].Dimension[SplitDimension].LeftBound - 1)/2;
#endif
#ifdef ADVANCE_BREAK
					if (EntropyNow < 1e-5) break;
#endif

				
#ifdef THRESHOLD_COST_ON
					NowBestResult.Distance = SortedDataList[i].Dimension[SplitDimension].LeftBound - RightChecker;
#endif
				}
			}
#ifndef IMPLICATION

			if (SortedDataList[i].Label == LABEL_TRUE) {
				LeftPositive += SortedDataList[i].Size;
			}
			else if (SortedDataList[i].Label == LABEL_FALSE) {
				LeftNegative += SortedDataList[i].Size;
			}
			else {
				printf("[Error] Label type is error.\n");
				Program::stop();
			}
#else
			if (DynamicLabelList[SortedDataList[i].DynamicLabelIndex] == LABEL_TRUE) {
				LeftPositive += SortedDataList[i].Size;
			}
			else if (DynamicLabelList[SortedDataList[i].DynamicLabelIndex] == LABEL_FALSE) {
				LeftNegative += SortedDataList[i].Size;
			}
			else if (DynamicLabelList[SortedDataList[i].DynamicLabelIndex] == LABEL_UNKNOWN) {
				// move item from Right to left
				RightSet[SortedDataList[i].DynamicLabelIndex] = 0;
				LeftSet[SortedDataList[i].DynamicLabelIndex] = SortedDataList[i].Size;
				// Weight add check
				for (int j = 0; j < SortedDataList[i].FromThisLength; ++j) {
					DataType LeftSize = SortedDataList[i].Size;
					DataType RightSize = RightSet[SortedDataList[i].FromThis[0][j]];
					if (RightSize != 0) {
						// Weight Calculation Way. NEED TO CHECK. TODO!
						if (ImplicationSet.count(std::make_pair(SortedDataList[i].DynamicLabelIndex,
							SortedDataList[i].FromThis[0][j])) == 1)
						LeftImplicationWeight += LeftSize * RightSize;
					}
				}
				for (int j = 0; j < SortedDataList[i].ToThisLength; ++j) {
					DataType LeftSize = SortedDataList[i].Size;
					DataType RightSize = RightSet[SortedDataList[i].ToThis[0][j]];
					if (RightSize != 0) {
						// Weight Calculation Way. NEED TO CHECK. TODO!
						if (ImplicationSet.count(std::make_pair(
							SortedDataList[i].ToThis[0][j],
							SortedDataList[i].DynamicLabelIndex)) == 1)
						RightImplicationWeight += LeftSize * RightSize;
					}
				}
				// Weight minus check
				for (int j = 0; j < SortedDataList[i].ToThisLength; ++j) {
					DataType RightSize = SortedDataList[i].Size;
					DataType LeftSize = LeftSet[SortedDataList[i].ToThis[0][j]];
					if (LeftSize != 0) {
						// Weight Calculation Way. NEED TO CHECK. TODO!
						if (ImplicationSet.count(std::make_pair(
							SortedDataList[i].ToThis[0][j],
							SortedDataList[i].DynamicLabelIndex)) == 1)
						LeftImplicationWeight -= LeftSize * RightSize;
					}
				}
				for (int j = 0; j < SortedDataList[i].FromThisLength; ++j) {
					DataType RightSize = SortedDataList[i].Size;
					DataType LeftSize = LeftSet[SortedDataList[i].FromThis[0][j]];
					if (LeftSize != 0) {
						// Weight Calculation Way. NEED TO CHECK. TODO!
						if (ImplicationSet.count(std::make_pair(SortedDataList[i].DynamicLabelIndex,
							SortedDataList[i].FromThis[0][j])) == 1)
						RightImplicationWeight -= LeftSize * RightSize;
					}
				}


			}
			else {
				// printf("[Error] Label type is error.\n");
				// Program::stop();
                Log::Error("Label type is error.");
                Program::stop();
			}
#endif
			if (RightChecker < SortedDataList[i].Dimension[SplitDimension].RightBound) {
				RightChecker = SortedDataList[i].Dimension[SplitDimension].RightBound;
			}

		}

	}

	//delete[] PossibleSplitPosition;
	return NowBestResult;
}

SplitResult ThresholdStrategy_Default::FindBestThresholdInDimensionWithDivision(
    int SplitDimension,	Data *SortedDataList, int DataListLength,
    DataType PositiveCount, DataType NegativeCount){
	// std::vector<int> DynamicLabelList = *(this->DynamicLabelList);
	// std::vector<int> DimensionType = *(this->DimensionType);
    // Implications:
	assert(DataListLength != 0);

	SplitResult NowBestResult = SplitResult(SPLIT_NOT_FOUND, SplitDimension, 0, 0);
	
	
	DataType* PossibleSplitPosition = new DataType[2 * DataListLength + 10];
	int PossibleSplitPositionLength = 0;
	for (int i = 0; i < DataListLength; ++i) {
		PossibleSplitPosition[PossibleSplitPositionLength] =
			SortedDataList[i].Dimension[SplitDimension].LeftBound - 1;
		++PossibleSplitPositionLength;
		PossibleSplitPosition[PossibleSplitPositionLength] =
			SortedDataList[i].Dimension[SplitDimension].RightBound;
		++PossibleSplitPositionLength;
	}
	std::sort(PossibleSplitPosition, PossibleSplitPosition + PossibleSplitPositionLength);
	DataType* PossibleSplitPositionUnique = new DataType[PossibleSplitPositionLength + 10];
	int PossibleSplitPositionUniqueLength = 1;
	PossibleSplitPositionUnique[0] = PossibleSplitPosition[0];
	for (int i = 1; i < PossibleSplitPositionLength; ++i) {
		if (PossibleSplitPosition[i] 
			!= PossibleSplitPositionUnique[PossibleSplitPositionUniqueLength - 1]) {
			PossibleSplitPositionUnique[PossibleSplitPositionUniqueLength] 
				= PossibleSplitPosition[i];
			++PossibleSplitPositionUniqueLength;
		}
	}
	delete[]PossibleSplitPosition;

	if (PossibleSplitPositionUniqueLength <= 2) {
		delete[]PossibleSplitPositionUnique;
		return NowBestResult;
	}

	DataType PositiveDensity = 0, NegativeDensity = 0;
	DataType LeftPositive = 0, LeftNegative = 0;
	//DataType LastChecker = 0;
#ifdef IMPLICATION
	DataType UnknownDensity = 0;// Sigma rou
	DataType UnknownDensityMultiplySum = 0;// Sigma rou(L-1+R)
	DataType UnknownDensityMultiplyProduct = 0;// Sigma rou(L-1)(R)
#endif

	std::priority_queue<DataItemInPriorityQueue> DataPriorityQueue;
#ifdef IMPLICATION
	std::vector<Implication> ImplicationPossible;// index of datalist and fromthislist index

	int* DynamicLabelIndex2ListIndex = new int[DynamicLabelList.size() + 10]; // Fix bug of incorrect init size
	for (int i = 0; i < DataListLength; ++i) {
		DynamicLabelIndex2ListIndex[i] = -1;// -1 means no visit
	}
	for (int i = 0; i < DataListLength; ++i) {
		if (DynamicLabelList[SortedDataList[i].DynamicLabelIndex] == LABEL_UNKNOWN) {
			DynamicLabelIndex2ListIndex[SortedDataList[i].DynamicLabelIndex] = i;
		}
	}
	for (int i = 0; i < DataListLength; ++i) {
		if (DynamicLabelList[SortedDataList[i].DynamicLabelIndex] == LABEL_UNKNOWN) {
			for (int j = 0; j < SortedDataList[i].FromThisLength; ++j) {
				if (DynamicLabelList[SortedDataList[i].FromThis[0][j]] == LABEL_UNKNOWN 
					&& ImplicationSet.count(
						std::make_pair(SortedDataList[i].DynamicLabelIndex,
							SortedDataList[i].FromThis[0][j])) == 1) {
					if (DynamicLabelIndex2ListIndex[SortedDataList[i].FromThis[0][j]] != -1) {
						ImplicationPossible.push_back(
							std::make_pair(i, DynamicLabelIndex2ListIndex[SortedDataList[i].FromThis[0][j]]));
					}
				}
			}
		}
	}
	int ImplicationPossibleLength = (int) ImplicationPossible.size();
	delete[]DynamicLabelIndex2ListIndex;

#endif
	int DataIterator = 0;
	// First and end positions are impossible.
	for (int i = 1; i < PossibleSplitPositionUniqueLength - 1; i++) {
		for (; DataIterator < DataListLength &&
			SortedDataList[DataIterator].Dimension[SplitDimension].LeftBound <=
			PossibleSplitPositionUnique[i];
			++DataIterator) {
			DataType DensityAddition = SortedDataList[DataIterator].Size /
				SortedDataList[DataIterator].Dimension[SplitDimension].Length();
#ifdef IMPLICATION
			if (DynamicLabelList[SortedDataList[DataIterator].DynamicLabelIndex] == LABEL_TRUE) {
#else
			if (SortedDataList[DataIterator].Label == LABEL_TRUE) {
#endif 
				PositiveDensity += DensityAddition;
				DataItemInPriorityQueue NewItem = DataItemInPriorityQueue(LABEL_TRUE, 
					SortedDataList[DataIterator].Dimension[SplitDimension].RightBound, 
					DensityAddition);
				DataPriorityQueue.push(NewItem);
			}
#ifdef IMPLICATION
			else if (DynamicLabelList[SortedDataList[DataIterator].DynamicLabelIndex] 
				== LABEL_FALSE) {
#else
			else if (SortedDataList[DataIterator].Label == LABEL_FALSE) {
#endif 
				NegativeDensity += DensityAddition;
				DataItemInPriorityQueue NewItem = DataItemInPriorityQueue(LABEL_FALSE,
					SortedDataList[DataIterator].Dimension[SplitDimension].RightBound,
					DensityAddition);
				DataPriorityQueue.push(NewItem);
			}
#ifdef IMPLICATION
			else if (DynamicLabelList[SortedDataList[DataIterator].DynamicLabelIndex]
				== LABEL_UNKNOWN) {
#else
			else if (SortedDataList[DataIterator].Label == LABEL_UNKNOWN) {
#endif 

#ifndef IMPLICATION
				printf("[Error] Unknown Label is not support yet!\n");
				Program::stop();
#else
				UnknownDensity += DensityAddition;
				UnknownDensityMultiplySum += UnknownDensity*(
					SortedDataList[DataIterator].Dimension[SplitDimension].RightBound
					+ SortedDataList[DataIterator].Dimension[SplitDimension].LeftBound - 1);
				UnknownDensityMultiplyProduct += UnknownDensity*UnknownDensity*(
					SortedDataList[DataIterator].Dimension[SplitDimension].RightBound
					* ( SortedDataList[DataIterator].Dimension[SplitDimension].LeftBound - 1));
//                UnknownDensity += 1;// Simple count num
				DataItemInPriorityQueue NewItem = DataItemInPriorityQueue(LABEL_UNKNOWN,
					SortedDataList[DataIterator].Dimension[SplitDimension].RightBound,
					DataIterator);
				DataPriorityQueue.push(NewItem);
#endif
			}
			else {
				printf("[Error] Label is wrong!\n");
				Program::stop();
			}
		}


		LeftPositive += PositiveDensity *
			(PossibleSplitPositionUnique[i] - PossibleSplitPositionUnique[i - 1]);
		LeftNegative += NegativeDensity *
			(PossibleSplitPositionUnique[i] - PossibleSplitPositionUnique[i - 1]);
		/*reuse*/
		if (LeftAll != 0 && RightAll != 0) {
		/**/
		/*
		if(true) {
		*/
			FLOAT_TYPE EntropyNow =
				CalculateInfomationEntropyByCount(LeftPositive, LeftNegative)
				* LeftPossibility
				+ CalculateInfomationEntropyByCount(RightPositive, RightNegative)
				* RightPossibility;
#ifdef SHOW_MORE_INFO
			printf("[D]Real Entropy %s @ %d = %.8f\n",
				Index2Name[SplitDimension].c_str(),
				PossibleSplitPositionUnique[i],
				EntropyNow);
#endif

			
#ifdef THRESHOLD_COST_ON
			++NowBestResult.TryTimes;
#endif

#ifdef IMPLICATION
			FLOAT_TYPE ImplicationDivisionPenalty = 0;
			FLOAT_TYPE DivisionPosition = PossibleSplitPositionUnique[i];

			// ?? check if right?
			FLOAT_TYPE ImplicationInnerPenalty;
			if (LeftAll == 0 || RightAll == 0)
				ImplicationInnerPenalty = (UnknownDensityMultiplySum * DivisionPosition
					- DivisionPosition*DivisionPosition
					- UnknownDensityMultiplyProduct);
			else ImplicationInnerPenalty = (UnknownDensityMultiplySum*DivisionPosition
				- DivisionPosition*DivisionPosition
				- UnknownDensityMultiplyProduct) * (1.0 - ( LeftPositive * RightNegative
					+ LeftNegative * RightPositive ) / (LeftAll)/(RightAll));
			// check ImplicationSize
			FLOAT_TYPE ImplicationSize = (UnknownDensityMultiplySum * DivisionPosition
				- DivisionPosition*DivisionPosition
				- UnknownDensityMultiplyProduct);

			for (int j = 0; j < ImplicationPossibleLength; ++j) {
				FLOAT_TYPE LeftSizeFrom = 0, LeftSizeTo = 0,RightSizeFrom = 0, RightSizeTo = 0;
				if (SortedDataList[ImplicationPossible[j].first].Dimension[SplitDimension].RightBound
					<= PossibleSplitPositionUnique[i]) {
					LeftSizeFrom = 1 + SortedDataList[ImplicationPossible[j].first]
						.Dimension[SplitDimension].RightBound -
						SortedDataList[ImplicationPossible[j].first].Dimension[SplitDimension].LeftBound;

				}
				else if (SortedDataList[ImplicationPossible[j].first].Dimension[SplitDimension].LeftBound 
			> PossibleSplitPositionUnique[i]) {
					LeftSizeFrom = 0;
				}
				else {
					LeftSizeFrom = 1 + PossibleSplitPositionUnique[i] - 
						SortedDataList[ImplicationPossible[j].first].Dimension[SplitDimension].LeftBound;
				}
				RightSizeFrom = 1 + SortedDataList[ImplicationPossible[j].first]
					.Dimension[SplitDimension].RightBound -
					SortedDataList[ImplicationPossible[j].first].Dimension[SplitDimension].LeftBound 
					- LeftSizeFrom;



				if (SortedDataList[ImplicationPossible[j].second].Dimension[SplitDimension].RightBound
					<= PossibleSplitPositionUnique[i]) {
					LeftSizeTo = 1 + SortedDataList[ImplicationPossible[j].second]
						.Dimension[SplitDimension].RightBound -
						SortedDataList[ImplicationPossible[j].second].Dimension[SplitDimension].LeftBound;

				}
				else if (SortedDataList[ImplicationPossible[j].second].Dimension[SplitDimension].LeftBound
			> PossibleSplitPositionUnique[i]) {
					LeftSizeTo = 0;
				}
				else {
					LeftSizeTo = 1 + PossibleSplitPositionUnique[i] -
						SortedDataList[ImplicationPossible[j].second].Dimension[SplitDimension].LeftBound;
				}

				RightSizeTo = 1 + SortedDataList[ImplicationPossible[j].second]
					.Dimension[SplitDimension].RightBound -
					SortedDataList[ImplicationPossible[j].second].Dimension[SplitDimension].LeftBound
					- LeftSizeTo;

				FLOAT_TYPE ImplicationPenaltyDensity = SortedDataList[ImplicationPossible[j].second].Size
					/ SortedDataList[ImplicationPossible[j].second].Dimension[SplitDimension].Length()
					* SortedDataList[ImplicationPossible[j].first].Size
					/ SortedDataList[ImplicationPossible[j].first].Dimension[SplitDimension].Length();

				FLOAT_TYPE ImplicationPenaltyItem; 
				if (LeftAll == 0 || RightAll == 0)
					ImplicationPenaltyItem = ImplicationPenaltyDensity *
					(RightSizeTo * LeftSizeFrom + RightSizeFrom * LeftSizeTo);
				else ImplicationPenaltyItem = ImplicationPenaltyDensity *
					( RightSizeTo * LeftSizeFrom * (1.0 - 1.0 * LeftNegative * RightPositive 
						/ LeftAll / RightAll) 
						+ RightSizeFrom * LeftSizeTo * (1.0 - 1.0 * LeftPositive * RightNegative
							/ LeftAll / RightAll));
				ImplicationSize += (RightSizeTo * LeftSizeFrom + RightSizeFrom * LeftSizeTo) * ImplicationPenaltyDensity;
				ImplicationDivisionPenalty += ImplicationPenaltyItem;
			}
#ifdef SHOW_MORE_INFO
			printf("[D]IDP = %.8f;IIP = %.8f;\n",
				ImplicationDivisionPenalty,
				ImplicationInnerPenalty);
#endif
			FLOAT_TYPE Penalty = ImplicationDivisionPenalty + ImplicationInnerPenalty;
			Penalty = Penalty * 2 / (PositiveCount + NegativeCount + 2 * ImplicationSize);
			EntropyNow += Penalty;
#ifdef SHOW_MORE_INFO
			printf("[D]C+= %d;C-= %d;IS= %.2f;Pen = %.8f;\n", PositiveCount, NegativeCount,
				ImplicationSize,Penalty);
#endif
#endif

			if (NowBestResult.Result == SPLIT_NOT_FOUND || NowBestResult.Entropy > EntropyNow) {
				NowBestResult.Result = SPLIT_WITH_DIVISION;
				NowBestResult.Entropy = EntropyNow;
				NowBestResult.SplitPosition = PossibleSplitPositionUnique[i];

#ifdef THRESHOLD_COST_ON
				NowBestResult.Distance = PossibleSplitPositionUnique[i] 
					- PossibleSplitPositionUnique[i-1];
#endif
			}
		}
		for (; !DataPriorityQueue.empty() 
			&& DataPriorityQueue.top().RightBound <= PossibleSplitPositionUnique[i]; ++i) {
			if (DataPriorityQueue.top().Label == LABEL_TRUE) {
				PositiveDensity -= DataPriorityQueue.top().Density;
				DataPriorityQueue.pop();
			}
			else if (DataPriorityQueue.top().Label == LABEL_FALSE) {
				NegativeDensity -= DataPriorityQueue.top().Density;
				DataPriorityQueue.pop();
			}
			else if (DataPriorityQueue.top().Label == LABEL_UNKNOWN) {
#ifndef IMPLICATION
				printf("[Error] Unknown Label is not support yet!\n");
				Program::stop();
#else
				DataType UnknownDensityMinus = SortedDataList[DataPriorityQueue.top().Density].Size /
					SortedDataList[DataPriorityQueue.top().Density]
					.Dimension[SplitDimension].Length();
				UnknownDensity -= UnknownDensityMinus;
				UnknownDensityMultiplySum -= UnknownDensity*(
					SortedDataList[DataPriorityQueue.top().Density]
					.Dimension[SplitDimension].RightBound
					+ SortedDataList[DataPriorityQueue.top().Density]
					.Dimension[SplitDimension].LeftBound - 1);
				UnknownDensityMultiplyProduct -= UnknownDensity*UnknownDensity*(
					SortedDataList[DataPriorityQueue.top().Density]
					.Dimension[SplitDimension].RightBound
					* ( SortedDataList[DataPriorityQueue.top().Density]
					.Dimension[SplitDimension].LeftBound - 1));

				DataPriorityQueue.pop();
#endif
				
			}
			else {
				printf("[Error] Label is wrong!\n");
				Program::stop();
			}
		}
	}
	delete[] PossibleSplitPositionUnique;

	return NowBestResult;
}


DataItemInPriorityQueue::DataItemInPriorityQueue(
	int _Label, DataType _RightBound, DataType _Density) {
	Label = _Label;
	RightBound = _RightBound;
	Density = _Density;
}


bool operator < (DataItemInPriorityQueue x, DataItemInPriorityQueue y) {
	return x.RightBound > y.RightBound;
}

