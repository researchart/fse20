/*
    This file is the implication of Min-Json tree printer
*/
#define _CRT_SECURE_NO_WARNINGS
#include "TreePrinterJson.h"
#include "Log.h"

std::string TreePrinterJson::TreePrinterName(){
    return "StdJson";
}

bool TreePrinterJson::isTreePrinter(std::string name){
    if(name=="StdJson") return true;
    if(name=="Json") return true;
    if(name=="json") return true;
    if(name=="std") return true;
    if(name=="Std") return true;
    if(name=="Standard") return true;
    if(name=="standard") return true; 
    if(name=="Min") return true;
    if(name=="MIN") return true; 
    if(name=="JsonMin") return true;
    if(name=="jsonMin") return true; 

    return true;
}

void TreePrinterJson::writeFile(IntervalDecisionTreeNode** IDTreeList, char* fileName){
    FILE* File = fopen(fileName, "w");
	if (File == nullptr) {
        Log::Error("Data file is failed to find!");
		Program::stop();
	}
    if (LoopCount == 1) {
		fprintf(File, "{\"attribute\":\"$pc\",\"cut\":0,\"classification\":0,\"children\":[");
			TreeDFS(IDTreeList[0], File);
		fprintf(File, ",{\"attribute\":\"\",\"cut\":0,\"classification\":true,\"children\":null}]}");
	}
	else {
		fprintf(File, "{\"attribute\":\"$pc\",\"cut\":0,\"classification\":0,\"children\":[");
		for (int i = 0; i < LoopCount; ++i) {
			if (i != 0)	fprintf(File, ",");
			TreeDFS(IDTreeList[i], File);
		}
		fprintf(File, "]}");
	}

}

void TreePrinterJson::TreeDFS(IntervalDecisionTreeNode* IDTree, FILE* File) {
	fprintf(File, "{");
	if (IDTree->FeatureSplit != END_POINT) {
		fprintf(File, "\"attribute\":\"%s\","
			, Index2Name[IDTree->FeatureSplit].c_str());
		fprintf(File, "\"cut\":%d,"
			, IDTree->SplitThreshold);
		fprintf(File, "\"classification\":%d,"
			, 0);
		fprintf(File, "\"children\":[");
		TreePrinterJson::TreeDFS(IDTree->UnsatisfiedNode, File);
		fprintf(File, ",");
		TreePrinterJson::TreeDFS(IDTree->SatisfiedNode, File);
		fprintf(File, "]");
	}
	else
	{
		fprintf(File, "\"attribute\":\"\",");
		fprintf(File, "\"cut\":%d,", 0);
		if (IDTree->ClassDivided == LABEL_TRUE)
			fprintf(File, "\"classification\":true,");
		else if (IDTree->ClassDivided == LABEL_FALSE) {
			fprintf(File, "\"classification\":false,");
		}
		else {
			//Program::stop();
			//otherwise always true
			fprintf(File, "\"classification\":true,");
		}
		fprintf(File, "\"children\":null");
	}
	fprintf(File, "}");
}