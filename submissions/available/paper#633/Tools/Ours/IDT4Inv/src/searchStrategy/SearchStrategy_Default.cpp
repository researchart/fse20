#include "SearchStrategy_Default.h"
#include "Log.h"
#include "Program.h"

std::string SearchStrategy_Default::SearchStrategyName(){
    return "Default Search Strategy";
}

std::string SearchStrategy_Default::SearchStrategyIntroduction(){
    //TODO: Add introduction
    return "";
}

bool SearchStrategy_Default::isStrategy(std::string name){
	// As it is the default Strategy, we return true at any time
	return true;
}

IntervalDecisionTreeNode* SearchStrategy_Default::BuildIDT(Data* DataList,int DataListLength){
	
	IntervalDecisionTreeNode* NewNode = new IntervalDecisionTreeNode();
#ifndef TIME_TEST
	Log::Text(Format("- - -@ Node %lld:\n", (long long) NewNode));
#endif
	if(this->activeThresholdStrategy == nullptr){
		Log::Error("No active threshold strategy!");
		Program::stop();
	}
	SplitResult Result = this->activeThresholdStrategy->FindBestThreshold(DataList, DataListLength);

#ifndef TIME_TEST
	Log::Text("- - -\n");
#endif
	if (Result.Result == ONE_CLASS_LEFT) {
		NewNode->SatisfiedNode = NewNode->UnsatisfiedNode = nullptr;
		NewNode->FeatureSplit = END_POINT;
		NewNode->ClassDivided = Result.OneClassKind;

		std::queue<int> DataToProcess;
		for (int i = 0; i < DataListLength; ++i) {
			if (DynamicLabelList[DataList[i].DynamicLabelIndex] == LABEL_UNKNOWN) {
				if (Result.OneClassKind == LABEL_TRUE) {
					DynamicLabelList[DataList[i].DynamicLabelIndex] = LABEL_TRUE;
					for (int j = 0; j < DataList[i].FromThisLength; ++j) {
						ImplicationSet.erase(std::make_pair(DataList[i].DynamicLabelIndex,
							DataList[i].FromThis[0][j]));
						if (DynamicLabelList[DataList[i].FromThis[0][j]] == LABEL_FALSE) {
							// printf("[error]No Solution!\n");
							Log::Error("No Solution!");
							Program::stop();
						}
						else {
							DynamicLabelList[DataList[i].FromThis[0][j]] = LABEL_TRUE;
							DataToProcess.push(DataList[i].FromThis[0][j]);
						}
					}
				}
				else if (Result.OneClassKind == LABEL_FALSE) {
					DynamicLabelList[DataList[i].DynamicLabelIndex] = LABEL_FALSE;
					for (int j = 0; j < DataList[i].ToThisLength; ++j) {
						ImplicationSet.erase(std::make_pair(DataList[i].ToThis[0][j], 
							DataList[i].DynamicLabelIndex));
						if (DynamicLabelList[DataList[i].ToThis[0][j]] == LABEL_TRUE) {
							// printf("[error]No Solution!\n");
							Log::Error("No Solution!");
							Program::stop();
						}
						else {
							DynamicLabelList[DataList[i].ToThis[0][j]] = LABEL_FALSE;
							DataToProcess.push(DataList[i].ToThis[0][j]);
						}
					}
				}
				else {
					/*
					printf("[error]Kind error!\n");
					Program::stop();
					*/
					// always true if all is unknown label.
					DynamicLabelList[DataList[i].DynamicLabelIndex] = LABEL_TRUE;
					for (int j = 0; j < DataList[i].FromThisLength; ++j) {
						ImplicationSet.erase(std::make_pair(DataList[i].DynamicLabelIndex,
							DataList[i].FromThis[0][j]));
						if (DynamicLabelList[DataList[i].FromThis[0][j]] == LABEL_FALSE) {
							// printf("[error]No Solution!\n");
							Log::Error("No Solution!");
							Program::stop();
						}
						else {
							DynamicLabelList[DataList[i].FromThis[0][j]] = LABEL_TRUE;
							DataToProcess.push(DataList[i].FromThis[0][j]);
						}
					}

				}
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
						// printf("[error]Kind error!\n");
						Log::Error("No Solution!");
						Program::stop();
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
						// printf("[error]Kind error!\n");
						Log::Error("No Solution!");
						Program::stop();
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
				// printf("[Error] Should not exist unknown label!");
				Log::Error("Should not exist unknown label!");
				Program::stop();
			}
			else {
				// printf("[Error] Label error!");
				Log::Error("Label error!");
				Program::stop();
			}


		}


#ifndef MEM_FREE_TOGETHER
		// Release memory
		for (int i = 0; i < DataListLength; ++i) {
			DataList[i].IntervalFree();
		}
		delete[]DataList;

#endif
	}
	else if (Result.Result == SPLIT_SUCCESS) {
		DivisionResult Division = this->activeThresholdStrategy->
			DataListDivideByDimensionThresholdWithoutDivision(
			DataList, DataListLength, Result.SplitDimension, Result.SplitPosition);
		NewNode->FeatureSplit = Result.SplitDimension;
		NewNode->SplitThreshold = Result.SplitPosition;
#ifdef UNKNOWN_LESS_FIRST
		int SatisfiedUnknown = 0, UnsatisfiedUnknown = 0;
#ifdef IMPLICATION
		for (int i = 0; i<Division.DataSatisfiedListLength; ++i)
			if (DynamicLabelList[Division.DataSatisfiedList[i].DynamicLabelIndex]==LABEL_UNKNOWN)
			{
				++SatisfiedUnknown;
			}
		for (int i = 0; i<Division.DataUnsatisfiedListLength; ++i)
			if (DynamicLabelList[Division.DataUnsatisfiedList[i].DynamicLabelIndex] == LABEL_UNKNOWN)
			{
				++UnsatisfiedUnknown;
			}
		if (SatisfiedUnknown < UnsatisfiedUnknown && Division.DataSatisfiedListLength > SatisfiedUnknown
			|| Division.DataUnsatisfiedListLength == UnsatisfiedUnknown) {
			NewNode->SatisfiedNode = BuildIDT(
				Division.DataSatisfiedList, Division.DataSatisfiedListLength);
			NewNode->UnsatisfiedNode = BuildIDT(
				Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
		}
		else {
			NewNode->UnsatisfiedNode = BuildIDT(
				Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
			NewNode->SatisfiedNode = BuildIDT(
				Division.DataSatisfiedList, Division.DataSatisfiedListLength);
		}
#else
		for (int i = 0; i<Division.DataSatisfiedListLength; ++i)
			if (Division.DataSatisfiedList[i].Label == LABEL_UNKNOWN)
			{
				++SatisfiedUnknown;
			}
		for (int i = 0; i<Division.DataUnsatisfiedListLength; ++i)
			if (Division.DataUnsatisfiedList[i].Label == LABEL_UNKNOWN)
			{
				++UnsatisfiedUnknown;
			}
		if (SatisfiedUnknown < UnsatisfiedUnknown) {
			NewNode->SatisfiedNode = BuildIDT(
				Division.DataSatisfiedList, Division.DataSatisfiedListLength);
			NewNode->UnsatisfiedNode = BuildIDT(
				Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
		}
		else {
			NewNode->UnsatisfiedNode = BuildIDT(
				Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
			NewNode->SatisfiedNode = BuildIDT(
				Division.DataSatisfiedList, Division.DataSatisfiedListLength);
		}
#endif
#endif
#ifdef LIST_LENGTH_LESS_FIRST
		// choose less one seems to have less nodes?
		if (Division.DataSatisfiedListLength < Division.DataUnsatisfiedListLength) {
			NewNode->SatisfiedNode = BuildIDT(
				Division.DataSatisfiedList, Division.DataSatisfiedListLength);
			NewNode->UnsatisfiedNode = BuildIDT(
				Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
		}
		else {
			NewNode->UnsatisfiedNode = BuildIDT(
				Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
			NewNode->SatisfiedNode = BuildIDT(
				Division.DataSatisfiedList, Division.DataSatisfiedListLength);
		}
#endif
#ifdef SATISFIED_FIRST
		NewNode->SatisfiedNode = BuildIDT(
			Division.DataSatisfiedList, Division.DataSatisfiedListLength);
		NewNode->UnsatisfiedNode = BuildIDT(
			Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
#endif
#ifdef UNSATISFIED_FIRST
		NewNode->UnsatisfiedNode = BuildIDT(
			Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
		NewNode->SatisfiedNode = BuildIDT(
			Division.DataSatisfiedList, Division.DataSatisfiedListLength);
#endif
	}
	else if (Result.Result == SPLIT_WITH_DIVISION) {
		DivisionResult Division = this->activeThresholdStrategy->
			DataListDivideByDimensionThresholdWithDivision(
			DataList, DataListLength, Result.SplitDimension, Result.SplitPosition);
		NewNode->FeatureSplit = Result.SplitDimension;
		NewNode->SplitThreshold = Result.SplitPosition;
#ifdef UNKNOWN_LESS_FIRST
		int SatisfiedUnknown = 0, UnsatisfiedUnknown = 0;
#ifdef IMPLICATION
		for (int i = 0; i<Division.DataSatisfiedListLength; ++i)
			if (DynamicLabelList[Division.DataSatisfiedList[i].DynamicLabelIndex] == LABEL_UNKNOWN)
			{
				++SatisfiedUnknown;
			}
		for (int i = 0; i<Division.DataUnsatisfiedListLength; ++i)
			if (DynamicLabelList[Division.DataUnsatisfiedList[i].DynamicLabelIndex] == LABEL_UNKNOWN)
			{
				++UnsatisfiedUnknown;
			}
		if (SatisfiedUnknown < UnsatisfiedUnknown && Division.DataSatisfiedListLength > SatisfiedUnknown
			|| Division.DataUnsatisfiedListLength == UnsatisfiedUnknown) {
			NewNode->SatisfiedNode = BuildIDT(
				Division.DataSatisfiedList, Division.DataSatisfiedListLength);
			NewNode->UnsatisfiedNode = BuildIDT(
				Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
		}
		else {
			NewNode->UnsatisfiedNode = BuildIDT(
				Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
			NewNode->SatisfiedNode = BuildIDT(
				Division.DataSatisfiedList, Division.DataSatisfiedListLength);
		}
#else
		for (int i = 0; i<Division.DataSatisfiedListLength; ++i)
			if (Division.DataSatisfiedList[i].Label == LABEL_UNKNOWN)
			{
				++SatisfiedUnknown;
			}
		for (int i = 0; i<Division.DataUnsatisfiedListLength; ++i)
			if (Division.DataUnsatisfiedList[i].Label == LABEL_UNKNOWN)
			{
				++UnsatisfiedUnknown;
			}
		if (SatisfiedUnknown < UnsatisfiedUnknown) {
			NewNode->SatisfiedNode = BuildIDT(
				Division.DataSatisfiedList, Division.DataSatisfiedListLength);
			NewNode->UnsatisfiedNode = BuildIDT(
				Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
		}
		else {
			NewNode->UnsatisfiedNode = BuildIDT(
				Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
			NewNode->SatisfiedNode = BuildIDT(
				Division.DataSatisfiedList, Division.DataSatisfiedListLength);
		}
#endif
#endif
#ifdef LIST_LENGTH_LESS_FIRST
		// choose less one seems to have less nodes?
		if (Division.DataSatisfiedListLength < Division.DataUnsatisfiedListLength) {
			NewNode->SatisfiedNode = BuildIDT(
				Division.DataSatisfiedList, Division.DataSatisfiedListLength);
			NewNode->UnsatisfiedNode = BuildIDT(
				Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
		}
		else {
			NewNode->UnsatisfiedNode = BuildIDT(
				Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
			NewNode->SatisfiedNode = BuildIDT(
				Division.DataSatisfiedList, Division.DataSatisfiedListLength);
		}
#endif
#ifdef SATISFIED_FIRST
		NewNode->SatisfiedNode = BuildIDT(
			Division.DataSatisfiedList, Division.DataSatisfiedListLength);
		NewNode->UnsatisfiedNode = BuildIDT(
			Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
#endif
#ifdef UNSATISFIED_FIRST
		NewNode->UnsatisfiedNode = BuildIDT(
			Division.DataUnsatisfiedList, Division.DataUnsatisfiedListLength);
		NewNode->SatisfiedNode = BuildIDT(
			Division.DataSatisfiedList, Division.DataSatisfiedListLength);
#endif

	}
	else if (Result.Result == SPLIT_NOT_FOUND) {
		// printf("[Error] Split not found!");
		Log::Error("Split not found!");
		Program::stop();
	}
	else {
		// printf("[Error] Unknown result!");
		Log::Error("Unknown result!");
		Program::stop();
	}

#ifndef TIME_TEST
	// print info
	Log::Text("\n--------------Tree Node--------------\n");
	Log::Text(Format("Node: %lld\n", (long long) NewNode));
	if (NewNode->FeatureSplit == END_POINT) {
		Log::Text("This is an end-point. The Class is: ");
		if (NewNode->ClassDivided == LABEL_TRUE) {
			Log::Text("\t[True]");
		}
		else if (NewNode->ClassDivided == LABEL_FALSE) {
			Log::Text("\t[False]");
		}
		else {
			// Log::Error("Unknown label.");
			// Program::stop();
		}
	}
	else {
		Log::Text(Format("Split Feature is: %d\n",NewNode->FeatureSplit));
		Log::Text(Format("Split Threshold is: %d\n", NewNode->SplitThreshold));
		Log::Text(Format("SatisfiedSonNode(>) is: %lld\n", (long long)NewNode->SatisfiedNode));
		Log::Text(Format("UnsatisfiedSonNode(<=) is: %lld\n", (long long)NewNode->UnsatisfiedNode));
	}
	Log::Text("\n-----------------END-----------------\n");
#endif

	return NewNode;
}


// TODO: spiltion in other object