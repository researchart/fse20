#ifndef CONFIG_H
#define CONFIG_H
/*
    This file is the config settings in compilation procedure
*/


#define MAX_FILE_LINE_BUFFER_SIZE MAX_FILE_LINE_SIZE+10

#define TIME_TEST

//#define THRESHOLD_COST_ON
// TODO: support the multi-thread 
//#define MULTI_THREAD_ON
//#define MEM_FREE_TOGETHER

#ifndef THRESHOLD_COST_ON
//#define ADVANCE_BREAK
#endif

#define IMPLICATION
#define IMPL_PENALTY


#define USE_HASH_SET

#ifndef TIME_TEST
#define SHOW_MORE_INFO
#endif


//#define UNKNOWN_LESS_FIRST
#ifndef UNKNOWN_LESS_FIRST
//#define LIST_LENGTH_LESS_FIRST
#ifndef LIST_LENGTH_LESS_FIRST
//#define SATISFIED_FIRST
#ifndef SATISFIED_FIRST
#define UNSATISFIED_FIRST
#endif // !SATISFIED_FIRST
#endif // !LIST_LENGTH_LESS_FIRST
#endif // !UNKNOWN_LESS_FIRST

#ifdef IMPLICATION
#define DATA_OVERLAP_PREPROCESS
#endif

//#define BFS_CHOOSE
//#define BFS_ADVANCE

#define READ_FROM_COMMAND


//#define NO_DIVISION_HALF_SEARCH
#ifndef NO_DIVISION_HALF_SEARCH
//#define RAND_LEFT_OR_RIGHT
#endif


//#define ADDITIONAL_WEIGHT




extern int MAX_FILE_LINE_SIZE;


// *** Float type setting in processing
// Only one should not be commented in next 3 lines
typedef double FLOAT_TYPE; // Default setting
// typedef float FLOAT_TYPE; // Fast speed
// typedef long double FLOAT_TYPE; // Relaiable accurancy
// ***

// *** Type of data to process
// Temporarily there is only 'int' type. Some algorithm may be modified if trying to apply other type
typedef int DataType; // int is default
// ***

#endif