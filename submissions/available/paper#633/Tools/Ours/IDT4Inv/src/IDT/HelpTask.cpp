#include "HelpTask.h"
#include "Program.h"
#include <iostream>

void HelpTask::setHelper(Helper* helper){
    _helper = helper;
}

void HelpTask::RunTask(int argc,std::string args[]) {
    if(argc==0){
        if(_helper!=nullptr&&_helper->getTranslation("Help Info")!="")
            std::cout<<_helper->getTranslation("Help Info");
        else std::cout<< "Usage\n"
                 << "\n"
                 << "  IDT4Inv [options] <target>\n"
                 << "\n"
                 << "Target: Target should be a boogie language file."
                 << "\n"
                 << "Options:\n"
                 << "  -h/--help [<target>] : Get the help info. If target exist, return the introduction of target.\n"
                 << "  -l/--lang <language> : Set the infomation language.\n"
                 << "  -s/--search <strategy> : Set the search strategy.\n"
                 << "  -t/--threshold <strategy> : Set the threshold strategy.\n"
                 << "  -p/--printer <strategy> : Set the output strategy.\n"
                 << "  -o/--output <target> : Set the path to the output file.\n"
                 << "  --log <level> : Set the log level.\n"//TODO:
                 << "  --nocolor : Disable the output color in terminal.\n"
                 << "Other Options show in details.\n";

    }
    else
    {
        //TODO:
    }
    
    Program::stop();
}
std::string HelpTask::ProgramTaskName() {
    return "Help";
}
std::string HelpTask::ProgramTaskIntroduction() {
    return "This is help!";
}