#ifndef HELP_TASK_H
#define HELP_TASK_H

#include "ProgramTask.h"
#include "Helper.h"
class HelpTask: public ProgramTask{
    Helper* _helper;
    public:
    void RunTask(int argc,std::string args[]) override;
    std::string ProgramTaskName() override;
    std::string ProgramTaskIntroduction() override;
    void setHelper(Helper* helper);
};

#endif