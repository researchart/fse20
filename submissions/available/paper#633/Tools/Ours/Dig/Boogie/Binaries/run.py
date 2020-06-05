import sys
import os
import subprocess, threading, psutil
import re

#mode = "dt_penalty" | "dt_entropy" 
mode = sys.argv[1]

programs = ["..\\..\\benchmarks\\array.bpl", "..\\..\\benchmarks\\array2.bpl", "..\\..\\benchmarks\\afnp.bpl", "..\\..\\benchmarks\\cggmp.bpl", "..\\..\\benchmarks\\countud.bpl", "..\\..\\benchmarks\\dtuc.bpl", "..\\..\\benchmarks\\ex14.bpl", "..\\..\\benchmarks\\ex14c.bpl", "..\\..\\benchmarks\\ex23.bpl", "..\\..\\benchmarks\\ex7.bpl", "..\\..\\benchmarks\\matrixl1.bpl", "..\\..\\benchmarks\\matrixl1c.bpl", "..\\..\\benchmarks\\matrixl2.bpl", "..\\..\\benchmarks\\matrixl2c.bpl", "..\\..\\benchmarks\\nc11.bpl", "..\\..\\benchmarks\\nc11c.bpl", "..\\..\\benchmarks\\sum1.bpl", "..\\..\\benchmarks\\sum3.bpl", "..\\..\\benchmarks\\sum4.bpl", "..\\..\\benchmarks\\sum4c.bpl", "..\\..\\benchmarks\\tacas.bpl", "..\\..\\benchmarks\\trex1.bpl", "..\\..\\benchmarks\\trex3.bpl", "..\\..\\benchmarks\\vsend.bpl", "..\\..\\benchmarks\\arrayinv1.bpl", "..\\..\\benchmarks\\arrayinv2.bpl", "..\\..\\benchmarks\\dec.bpl", "..\\..\\benchmarks\\formula22.bpl", "..\\..\\benchmarks\\formula25.bpl", "..\\..\\benchmarks\\formula27.bpl", "..\\..\\benchmarks\\inc.bpl", "..\\..\\benchmarks\\inc2.bpl", "..\\..\\benchmarks\\loops.bpl", "..\\..\\benchmarks\\add.bpl", "..\\..\\benchmarks\\cegar1.bpl", "..\\..\\benchmarks\\cegar2.bpl", "..\\..\\benchmarks\\dillig01.bpl", "..\\..\\benchmarks\\dillig03.bpl", "..\\..\\benchmarks\\dillig05.bpl", "..\\..\\benchmarks\\dillig07.bpl", "..\\..\\benchmarks\\dillig12.bpl", "..\\..\\benchmarks\\dillig15.bpl", "..\\..\\benchmarks\\dillig17.bpl", "..\\..\\benchmarks\\dillig19.bpl", "..\\..\\benchmarks\\dillig24.bpl", "..\\..\\benchmarks\\dillig25.bpl", "..\\..\\benchmarks\\dillig28.bpl", "..\\..\\benchmarks\\fig1.bpl", "..\\..\\benchmarks\\fig3.bpl", "..\\..\\benchmarks\\fig9.bpl", "..\\..\\benchmarks\\w1.bpl", "..\\..\\benchmarks\\w2.bpl", "..\\..\\benchmarks\\array_diff.bpl", "..\\..\\benchmarks\\sqrt.bpl", "..\\..\\benchmarks\\square.bpl", "..\\..\\benchmarks\\multiply.bpl"]
 
total_time_dict = dict()
total_pos_dict = dict()
total_neg_dict = dict()
total_impl_dict = dict()
total_rounds_dict = dict()

def kill(proc_pid):
  try:
    process = psutil.Process(proc_pid)
    for proc in process.get_children(recursive=True):
        proc.kill()
    process.kill()
  except:
    pass

class Command(object):
    def __init__(self, cmd):
        self.cmd = cmd
        self.process = None

    def run(self, timeout,program_name):
        def target():
            print("program_name = " + program_name)
            self.process = subprocess.Popen(self.cmd, shell=True, stdout=subprocess.PIPE)
            output = self.process.communicate()[0]

            total_time_exp = re.compile(r'Total time: (.*)')
            total_pos_exp = re.compile(r'Number of examples:(.*)')
            total_neg_exp = re.compile(r'Number of counter-examples:(.*)')
            total_impl_exp = re.compile(r'Number of implications:(.*)')

            if mode == "dt_penalty" or mode == "dt_entropy":
                total_rounds_exp = re.compile(r'Number of C5 Learner queries = (.*)')

            elif mode == "ice":
                total_rounds_exp = re.compile(r'Number of Z3 Learner queries = (.*)')

            else:
                assert False


            lines = output.split('\n')
            found = False
            for line in lines:
                total_time_obj = total_time_exp.match(line)
                total_pos_obj = total_pos_exp.match(line)
                total_neg_obj = total_neg_exp.match(line)
                total_impl_obj = total_impl_exp.match(line)
                total_rounds_obj = total_rounds_exp.match(line)

                if total_time_obj:
                    found = True
                    total_time = total_time_obj.group(1)
                    total_time_dict[program_name] = total_time
                else:
                    pass

        
                if total_rounds_obj:
                    total_rounds = total_rounds_obj.group(1)
                    total_rounds_dict[program_name] = total_rounds
                else:
                    pass

                if total_pos_obj:
                    total_pos = total_pos_obj.group(1)
                    total_pos_dict[program_name] = total_pos
                else:
                    pass

                if total_neg_obj:
                    total_neg = total_neg_obj.group(1)
                    total_neg_dict[program_name] = total_neg
                else:
                    pass

                if total_impl_obj:
                    total_impl = total_impl_obj.group(1)
                    total_impl_dict[program_name] = total_impl
                else:
                    pass


            if not found:
                print ("Timeout")

            print (output)

        thread = threading.Thread(target=target)
        thread.start()

        thread.join(timeout)
        if thread.is_alive():
            print ('Terminating process')
            kill(self.process.pid)
            #self.process.terminate()
            thread.join()
        #print self.process.returncode


fo = open("results." + mode + ".txt", "w")
fo.close()
for p in programs:
    fo = open("results." + mode + ".txt", "a")
    if mode == "dt_penalty":
        command = Command("Boogie.exe /nologo /noinfer /contractInfer /mlHoudini:dt_penalty " + p)
    elif mode == "dt_entropy":
        command = Command("Boogie.exe /nologo /noinfer /contractInfer /mlHoudini:dt_entropy " + p)
    elif mode == "ice":
        command = Command("Boogie.exe /nologo /noinfer /contractInfer /ice /printAssignment " + p)
    else:
        assert False

    command.run(timeout=600, program_name=p)
    outputstr = ""
    outputstr += p
    if p not in total_time_dict.keys():
      outputstr += "," + total_pos_dict[p] + "," + total_neg_dict[p] + "," + total_impl_dict[p] + "," + total_rounds_dict[p] + ",>=600s"
    else:
      outputstr += "," + total_pos_dict[p] + "," + total_neg_dict[p] + "," + total_impl_dict[p] + "," + total_rounds_dict[p] + "," + total_time_dict[p]
    outputstr += "\n"
    fo.write(outputstr)
    fo.close()


total_time_dict.clear()
total_pos_dict.clear()
total_neg_dict.clear()
total_impl_dict.clear()
total_rounds_dict.clear()


