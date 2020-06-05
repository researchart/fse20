#ifndef PROGRAM_TASK_H
#define PROGRAM_TASK_H

#include<string>
// Interface for Program Task
class ProgramTask{
    public:
        virtual void RunTask(int argc,std::string args[]) = 0;
        virtual std::string ProgramTaskName() = 0;
        virtual std::string ProgramTaskIntroduction() = 0;
};

#endif