#include "Program.h"
#include "HelperServer.h"
#include "SearchStrategyServer.h"
#include "ThresholdStrategyServer.h"
#include "TreePrinterServer.h"
#include "Env.h"
#include "UnionFind.h"
#include "Log.h"

const std::string Program::VERSION = "1.0Dev";
const std::string Program::AUTHOR = "R. Xu";
const std::string Program::RELEASE_TIME = "2019";


std::vector<ProgramTask*> Program::programTaskRecorder;
std::vector<ThresholdStrategy*> Program::thresholdStrategyRecorder;
std::vector<SearchStrategy*> Program::searchStrategyRecorder;
std::vector<Helper*> Program::helperRecorder;
std::vector<TreePrinter*> Program::treePrinterRecorder;

ThresholdStrategy* Program::thresholdStrategyActive = nullptr;
SearchStrategy* Program::searchStrategyActive = nullptr;
TreePrinter* Program::treePrinterActive = nullptr;
Helper* Program::helperActive = nullptr;

#ifndef MSVC
#ifdef V_RELEASE
const enum VersionType Program::VERSION_TYPE = VersionType::RELEASE;
const enum LogLevel Program::LOG_LEVEL = LogLevel::INFO;
#else
#ifdef V_I_RELEASE
const enum VersionType Program::VERSION_TYPE = VersionType::INNER_RELEASE;
const enum LogLevel Program::LOG_LEVEL = LogLevel::NO_OUTPUT;
#else
const enum VersionType Program::VERSION_TYPE = VersionType::DEVELOPMENT;
const enum LogLevel Program::LOG_LEVEL = LogLevel::FINE;
#endif
#endif
#else
#ifdef V_RELEASE
const enum class VersionType Program::VERSION_TYPE = VersionType::RELEASE;
const enum class LogLevel Program::LOG_LEVEL = LogLevel::INFO;
#else
#ifdef V_I_RELEASE
const enum class VersionType Program::VERSION_TYPE = VersionType::INNER_RELEASE;
const enum class LogLevel Program::LOG_LEVEL = LogLevel::NO_OUTPUT;
#else
const enum class VersionType Program::VERSION_TYPE = VersionType::DEVELOPMENT;
const enum class LogLevel Program::LOG_LEVEL = LogLevel::FINE;
#endif
#endif
#endif
std::map<std::string,std::string> Program::argumentsMapper;

bool Program::IMPLICATION_ON = true;
bool Program::IMPLICATION_INITIAL_CHECK_ON = true;
bool Program::DATA_OVERLAP_PREPROCESS_ON = true;
bool Program::TIME_TEST_ON = true;

std::string Program::programTarget = "";
void Program::argumentsParse(int argc, char *argv[]){
    if(argc==1) {
        Program::programTarget = "";
        return;
    }
    int argc_no_target = argv[argc-1][0]=='-'?argc:argc-1;
    for(int i=1; i<argc_no_target; ++i)
    {
        if(argv[i][0]=='-')
        {
            if(i+1<argc_no_target&&argv[i+1][0]!='-')
            {
                Program::argumentsMapper[argv[i]]=argv[i+1];
                ++i;
            }
            else
            {
                Program::argumentsMapper[argv[i]]="NONE";
            }
        }
    }
    if(argc==argc_no_target)
        Program::programTarget = "";
    else Program::programTarget = argv[argc-1];
}

std::string Program::getArgumentByName(std::string shortName,std::string fullName){
    std::string ret = "";
    if(fullName != "")
        ret = Program::argumentsMapper["--" + fullName];
    if(ret == "" && shortName != "")
        ret = Program::argumentsMapper["-" + shortName];
    return ret;
}

void Program::dataOverlapPreprocess(){
    int* Father = new int[SampleCount + 10];
    int* ActualDimension = new int[ActualDimensionCount + 10];
    int CountActualDimension = 0;
    for (int i = 0; i < DimensionCount; ++i) {
        if (DimensionType[i] == ACTUAL_DIMENSION) {
            ActualDimension[CountActualDimension] = i;
            ++CountActualDimension;
        }
    }
    for (int i = 0; i < SampleCount; ++i) {
        Father[i] = i;
    }
    for (int i = 0; i < SampleCount; ++i) {
        //Father[i] = i;
        for (int j = 0; j < i; ++j) {
            int flag = 0;
            for (int k = 0; k < CountActualDimension; ++k) {
                if (DataListSaved[i].Dimension[ActualDimension[k]].LeftBound >
                    DataListSaved[j].Dimension[ActualDimension[k]].RightBound ||
                    DataListSaved[i].Dimension[ActualDimension[k]].RightBound <
                    DataListSaved[j].Dimension[ActualDimension[k]].LeftBound) {
                    flag = 1;
                    break;
                }
            }
            if (flag == 0) {
                Union(Father, i, j);
            }
        }
    }
    for (int i = 0; i < SampleCount; ++i) {
        int x = Find(Father, i);
        if (x != i) {
            
            ImplicationSet.insert(std::make_pair(x, i));
            ImplicationSet.insert(std::make_pair(i, x));

            DataListSaved[i].FromThis[0].push_back(x);
            DataListSaved[i].ToThis[0].push_back(x);
            ++DataListSaved[i].FromThisLength;
            DataListSaved[i].ToThis[0].push_back(x);
            ++DataListSaved[i].ToThisLength;

            DataListSaved[x].FromThis[0].push_back(i);
            ++DataListSaved[x].FromThisLength;
            DataListSaved[x].ToThis[0].push_back(i);
            ++DataListSaved[x].ToThisLength;
            
            //DataListSaved[i].DynamicLabelIndex = x;
        }
    }

    delete[] Father;
    delete[] ActualDimension;
}
void Program::implicationCheck(){
    if (ImplicationPreprocess() == PREPROCESS_FAILED) {
        Log::Error("Implication no solution!");
        Program::stop();
    }	
}
/*
Program::serve will initialize the program service
*/
void Program::serve(){
    // Environment initialize
    EnvInit();


    // Move to main function to avoid cycle link:
    // // Services start
    // // Helper service
    // HelperServer::serve(Program::helperRecorder);
    // // Search strategy service
    // SearchStrategyServer::serve(Program::searchStrategyRecorder);   
    // // Threshold strategy service
    // ThresholdStrategyServer::serve(Program::thresholdStrategyRecorder);
    // // Tree printer service
    // TreePrinterServer::serve(Program::treePrinterRecorder);
    // // TODO: other services in future
}

void Program::stop(){
    exit(0);
}