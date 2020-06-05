#define _CRT_SECURE_NO_WARNINGS
#include <cstdio>
#include <cassert>
#include "Program.h"
#include "Data.h"
#include "Test.h"
#include <ctime>
#include "ReadData.h"
#include "BuildTree.h"
#include "Config.h"
#include "PrintJson.h"
#include "UnionFind.h"
#include <iostream>
#include "Log.h"
#include "HelpTask.h"

#include "HelperServer.h"
#include "SearchStrategyServer.h"
#include "ThresholdStrategyServer.h"
#include "TreePrinterServer.h"

int main(int argc, char *argv[]) {


	// Program initialize
	Program::serve();


	// Services start
    // Helper service
    HelperServer::serve(Program::helperRecorder);
    // Search strategy service
    SearchStrategyServer::serve(Program::searchStrategyRecorder);   
    // Threshold strategy service
    ThresholdStrategyServer::serve(Program::thresholdStrategyRecorder);
    // Tree printer service
    TreePrinterServer::serve(Program::treePrinterRecorder);
    // TODO: other services in future

	// Arguments analyse
	Program::argumentsParse(argc,argv);

	// Find the helper with lang arg <Test>
	std::string lang = Program::getArgumentByName("l","lang");
	int helperIndex = 0;
	while(!Program::helperRecorder[helperIndex]->isLanguage(lang)){
		++helperIndex;
	}
	Program::helperActive = Program::helperRecorder[helperIndex];
	Helper* hp = Program::helperRecorder[helperIndex];
	Log::Debug(Program::helperActive->HelperName());

	bool colorOff = (Program::getArgumentByName("","nocolor") == "NONE");
	if(colorOff)
	{
		Log::colorOn = false;
	}

	std::string helpStatus = Program::getArgumentByName("h","help");
	if(helpStatus!="")
	{
		HelpTask* ht = new HelpTask();
		ht->setHelper(Program::helperActive);
		ht->RunTask(0,nullptr);
	}
	// output test
	// Log::Error("Hello");
	// Log::Warning("Hello");
	// Log::Key("Hello");
	// Log::Info("Hello");
	// Log::Debug("Hello");
	// Log::Text("Hello");
	// Program::stop();
	// std::cout<<hp->getTranslation("Welcome");

	// Find the search strategy with search_strategy arg <Test>
	std::string search_strategy = Program::getArgumentByName("s","search");
	int searchStrategyIndex = 0;
	while(!Program::searchStrategyRecorder[searchStrategyIndex]->isStrategy(search_strategy)){
		++searchStrategyIndex;
	}
	Program::searchStrategyActive = Program::searchStrategyRecorder[searchStrategyIndex];
	Log::Debug(Program::searchStrategyActive->SearchStrategyName());

	// Find the threshold strategy with threshold_strategy arg <Test>
	std::string threshold_strategy = Program::getArgumentByName("t","threshold");
	int thresholdStrategyIndex = 0;
	while(!Program::thresholdStrategyRecorder[thresholdStrategyIndex]->isStrategy(threshold_strategy)){
		++thresholdStrategyIndex;
	}
	Program::thresholdStrategyActive = Program::thresholdStrategyRecorder[thresholdStrategyIndex];
	Log::Debug(Program::thresholdStrategyActive->ThresholdStrategyName());

	// Find the tree printer with tree_printer arg <Test>
	std::string tree_printer = Program::getArgumentByName("p","printer");
	int treePrinterIndex = 0;
	while(!Program::treePrinterRecorder[treePrinterIndex]->isTreePrinter(tree_printer)){
		++treePrinterIndex;
	}
	Program::treePrinterActive = Program::treePrinterRecorder[treePrinterIndex];
	Log::Debug(Program::treePrinterActive->TreePrinterName());

	std::string outputFile = Program::getArgumentByName("o","output");
	if(outputFile=="")
	{
		outputFile = Program::programTarget + ".tree.json";
	}
	// Program::stop();

#ifndef READ_FROM_COMMAND
	char target[] = "dtuc.bpl";
#else // !READ_FROM_COMMAND
	char *target = strdup(Program::programTarget.c_str());
#endif	

//#ifdef TIME_TEST
	int TimeStart = clock();
//#endif

	LoadNames(target);
	LoadData(target);
#ifdef IMPLICATION
	if(Program::IMPLICATION_ON){
		LoadImplications(target);
#ifdef DATA_OVERLAP_PREPROCESS
		if(Program::DATA_OVERLAP_PREPROCESS_ON)
			Program::dataOverlapPreprocess();
#endif
		if(Program::IMPLICATION_INITIAL_CHECK_ON)
			Program::implicationCheck();
	}
#endif // IMPLICATION




#ifndef TIME_TEST
	if(!Program::TIME_TEST_ON)
		ShowDataList();
#endif

	Data* DataArray = DataListCopyVector2Array(DataListSaved);
	//Data* DataArray = DataListSaved.data();

	IntervalDecisionTreeNode** IDTreeList
		= new IntervalDecisionTreeNode*[LoopCount + 5];


	for (int i = 0; i < LoopCount; ++i) {
		NowProcessingLoopIndex = i;
		Data* DataArrayInLoop = new Data[DataListSaved.size() + 5];
		int ArrayCount = 0;
		int AllSize = (int) DataListSaved.size();
		for (int j = 0; j < AllSize; ++j) {
			if (DataArray[j].LoopBelong == i) {
				//memcpy(DataArrayInLoop + ArrayCount, DataArray + j, sizeof(Data));
				DataArrayInLoop[ArrayCount] = DataArray[j];
				++ArrayCount;
			}
		}
		NowProcessingLoopIndex = i;
		// Old approach
		// IntervalDecisionTreeNode* IDTree = BuildIDT(DataArrayInLoop,
			// ArrayCount);
		// New approach:

		Program::searchStrategyActive->setThresholdStrategy(Program::thresholdStrategyActive);
		// Program::thresholdStrategyActive->setEnv(DynamicLabelList,DimensionType);
		IntervalDecisionTreeNode* IDTree = Program::searchStrategyActive->BuildIDT(
			DataArrayInLoop,ArrayCount);

		IDTreeList[i] = IDTree;
		//delete[] DataArrayInLoop;
	}

/*
#ifndef BFS_CHOOSE
	IntervalDecisionTreeNode* IDTree = BuildIDT(DataArray, (int) DataListSaved.size());
#else
#ifdef BFS_ADVANCE
	IntervalDecisionTreeNode* IDTree = BuildIDTWithBFSAdvance(DataArray, (int)DataListSaved.size());
#else

	IntervalDecisionTreeNode* IDTree = BuildIDTWithBFS(DataArray, (int)DataListSaved.size());
#endif
#endif

*/
// 	char real_name[1024];
// 	real_name[0] = 0;
// #ifndef READ_FROM_COMMAND
// 	strcpy(real_name, "data/");
// #endif
// 	strcat(real_name, target);
// 	strcat(real_name, ".tree.json");
	// Old approach
	// PrintJson(IDTreeList, target);
	// New approach
	char* real_name = strdup(outputFile.c_str());
	Program::treePrinterActive->writeFile(IDTreeList,real_name);

	//#ifdef TIME_TEST

	int TimeEnd = clock();
//#endif
	Log::Info("[OK] Tree make Finished!");
//#ifdef TIME_TEST
	Log::Info(Format("The Time used is: %.8f second.\n", 1.0*(TimeEnd - TimeStart) / CLOCKS_PER_SEC));
//#endif

	
#ifndef READ_FROM_COMMAND
	getchar();
#endif
	return 0;
}