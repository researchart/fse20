#ifndef PROGRAM_H
#define PROGRAM_H

#include <string>
#include <vector>
#include "ProgramTask.h"
#include "SearchStrategy.h"
#include "ThresholdStrategy.h"
#include "Helper.h"
#include "TreePrinter.h"

enum class VersionType{
    DEVELOPMENT,
    INNER_RELEASE,
    RELEASE
};

enum class LogLevel{
    NO_OUTPUT=100,
    ERROR=200,
    WARNING=300,
    INFO=400,
    DETAIL=500,
    FINE=600
};


class Program {
    public:
    // Program infomations
    static const std::string VERSION;
    static const std::string AUTHOR;
    static const std::string RELEASE_TIME;
    static const enum class VersionType VERSION_TYPE;
    static const enum class LogLevel LOG_LEVEL;
    
    static std::vector<ProgramTask*> programTaskRecorder;
    static std::vector<ThresholdStrategy*> thresholdStrategyRecorder;
    static std::vector<SearchStrategy*> searchStrategyRecorder;
    static std::vector<Helper*> helperRecorder;
    static std::vector<TreePrinter*> treePrinterRecorder;

    static ThresholdStrategy* thresholdStrategyActive;
    static SearchStrategy* searchStrategyActive;
    static TreePrinter* treePrinterActive;
    static Helper* helperActive;

    static void serve();

    static void stop();

    static std::map<std::string,std::string> argumentsMapper;


    // Config Options:
    static bool IMPLICATION_ON;
    static bool IMPLICATION_INITIAL_CHECK_ON;
    static bool DATA_OVERLAP_PREPROCESS_ON;
    static bool TIME_TEST_ON;

    static std::string programTarget;
    static void argumentsParse(int argc, char *argv[]);
    static std::string getArgumentByName(std::string shortName,std::string fullName);

    static void dataOverlapPreprocess();
    static void implicationCheck();
};

#endif