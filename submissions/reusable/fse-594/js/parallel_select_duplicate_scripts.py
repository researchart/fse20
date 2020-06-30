import sys, codecs, json, re, time, os, getopt, traceback
import signal, psutil
from urlparse import urlparse
from multiprocessing import Process as Task, Queue
from subprocess import call, PIPE, STDOUT
import multiprocessing as mp
import random, calendar, shutil, sys, commands, hmac
from termcolor import colored
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import NoSuchElementException, ElementNotVisibleException, WebDriverException, NoSuchWindowException
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from urlparse import urlparse
import recipe
from pympler import asizeof


from calmjs.parse import es5
from calmjs.parse.asttypes import FuncDecl
from calmjs.parse.walkers import Walker



browser_width = None
browser_hieght = None
MAC_KEY = '12345'





def getlocaltime():
    return time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())

# This function tries to ensure that no extra zombie children stick around
def kill_child_processes(parent_pid=None, parent=None, timeout=3, sig=signal.SIGTERM, include_parent = True):
    global log_f
    #current_time = getlocaltime()
    if not parent and not parent_pid:
        return (None, None)
    try:
        if not parent and parent_pid:
            parent = psutil.Process(parent_pid)
    except (psutil.NoSuchProcess, psutil.ZombieProcess, psutil.AccessDenied):
        return (None, None)
    if parent.pid == os.getpid():
        include_parent = False
    children = parent.children(recursive=True)
    if include_parent:
        children.append(parent)
    for process in children:
        #msg = '%s\tKilling child process [%d] of [%d]...\n' % (current_time, process.pid, parent.pid)
        #if log_f:
            #log_f.write(msg)
        try:
            process.send_signal(sig)
        except (psutil.NoSuchProcess, psutil.ZombieProcess, psutil.AccessDenied):
            pass
    gone, alive = psutil.wait_procs(children, timeout=timeout, callback=None)
    if alive:
        for process in alive:
            try:
                process.kill() # SEND SIGKILL
            except (psutil.NoSuchProcess, psutil.ZombieProcess, psutil.AccessDenied):
                pass
        gone, alive = psutil.wait_procs(alive, timeout=timeout, callback=None)
    return (gone, alive)

def get_child_processes(parent_pid):
    try:
        parent = psutil.Process(parent_pid)
    except (psutil.NoSuchProcess, psutil.ZombieProcess, psutil.AccessDenied):
        return None
    children = parent.children(recursive=True)
    return children

def signal_term_handler(sig, frame):
    global parent_pid
    current_pid = os.getpid()
    if current_pid == parent_pid:
        #msg = '%s\tPARENT PROCESS [%d] received SIGTERM!!! Killing all child processes...\n' % (current_time, current_pid)
        process_name = 'chrome'
        kill_processes_by_name(process_name)
    kill_all_processes()

def kill_all_processes(restart_parent_flag=False):
    global parent_pid, process_list, log_f
    current_time = getlocaltime()
    current_pid = os.getpid()
    if current_pid == parent_pid:
        msg = '%s\tPARENT PROCESS [%d] received SIGTERM!!! Killing all child processes...\n' % (current_time, current_pid)
    else:
        msg = '%s\tProcess [%d] received SIGTERM!!! Killing all child processes... PARENT PID=[%d]\n' % (current_time, current_pid, parent_pid)
    #print(msg)
    #sys.stdout.flush()
    log_f.write(msg)
    kill_child_processes(parent_pid = current_pid)
    current_time = getlocaltime()
    msg = '%s\tAll child processes of Process [%d] are killed!!!\n' % (current_time, current_pid)
    #print(msg)
    log_f.write(msg)
    if current_pid == parent_pid:
        if restart_parent_flag:
            restart_all_tasks(log_f)
        else:
            log_f.close()
    sys.exit()



def get_task_queue(input_file): 
    global num_instances

    url_queue = [[] for i in range(num_instances)]
    rule = re.compile(ur"[^a-zA-Z0-9\u4e00-\u9fa5]")

    try:
        with codecs.open(input_file, mode='r', encoding='utf-8') as input_f:
            data = json.loads(input_f.read())
    except Exception as e:
        print(e)
        sys.exit(1)

    for index, script_list in data.items():
        index = int(index)
        split = index % num_instances
        for script in script_list:
            append_str = rule.sub('', script[-10:])   
            url_queue[split].append((index, append_str))

    for split, tasks in enumerate(url_queue):
        url_queue[split] = sorted(tasks, key=lambda x:x[0])

    #print(url_queue)
    return url_queue





def locate_alias_for_conflict():
    pass



def determine_window_id_of_main_frame(asg_logs, url, asg_file):
    #urls = set()
    # urls stores the URLs of scripts that are only included in the main frame
    main_window_id = None
    window_ids = set()
    for log in asg_logs:
        if len(log) == 0:
            continue
        log = log[1:]
        split_list = log.split(',elem_js_conflict,')
        first_tuple = split_list[0]
        if first_tuple == 'is_call' or first_tuple == 'is_call_new':
            script_id = int(split_list[2])
        elif first_tuple == 'is_new_temp':
            continue
        elif first_tuple == 'is_return':
            script_id = int(split_list[4])
        elif ',++0,' in log or ',++1,' in log:
            script_id = int(split_list[3])
        else:
            script_id = int(split_list[4])

        script_url = None
        id2url_file = asg_file.replace('.asg', '.id2url')
        #print(id2url_file)
        if os.path.isfile(id2url_file):
            with open(id2url_file, 'r') as id2url_input_f:
                for id2url_line in id2url_input_f:
                    if id2url_line.split(',')[0] == str(script_id):
                        script_url = (','.join(id2url_line.split(',')[1:])).split('\n')[0]
                        break
        if script_url is None:
            #rank = asg_file.split('/')[-1].split('.')[0]
            script_source_file = asg_file.replace('.asg', '.%d.script'%(script_id))
            #print(script_source_file)
            if os.path.isfile(script_source_file): 
                with open(script_source_file, 'r') as scriptsource_input_f:
                    for script_source_line in scriptsource_input_f:
                        script_url = script_source_line.split('\n')[0]
                        break
        #print(script_url, url)
        if script_url is None:
            continue
        #script_url = split_list[5]
        window_id = int(split_list[-1].split("\"")[0])
        window_ids.add(window_id)
        if script_url == url or script_url == '':
            main_window_id = window_id
            break

    if main_window_id is None:
        if len(window_ids) == 1:
            main_window_id = list(window_ids)[0]

    return main_window_id




def determine_context_id_of_main_frame(func_file, scripts_in_main, first_party_url):

    # if any of the logs contain a function definition in the first-party url
    # then the corresponding context id is the main frame context id
    # else check the .asg file to find the script urls that are contained only in the main frame, using the window id of the main frame
    with open(func_file, 'r') as input_f:
        for line in input_f:
            script_url = line.split()[3]
            if script_url in scripts_in_main:
                return line.split()[-1]
            elif script_url == first_party_url:
                return line.split()[-1]
    return None





def measure(user_dir, task_id, length, start, end, status_queue, process_index):
    global processed_data_dir, conflicting_rank_set, rank2url, func_dir, raw_data_dir

    current_pid = os.getpid()
    current_dir = os.getcwd()
    try:
        status = 'Process %-4d task %d/%d PID [%d] starting ...' % (process_index, task_id+1, length, current_pid)
        status_queue.put([process_index, status])
        #print(status)

        current_pid = os.getpid()
        current_dir = os.getcwd()

        input_dir = user_dir + '_analysis'
        files = os.listdir(input_dir)
        #files = [f for f in files if f.endswith('-category2target2type2script2infos.json')]
        files = [f for f in files if f.endswith('-category2target2type2script2infos.json')] # and not f.endswith('-used-category2type2target2infos.json')]
        cat2rank2target2type2infos = dict()
        cnt = 0
        #print(files)
        for f in files:
            try:
                rank = f.split('.')[0]
                input_file = os.path.join(input_dir, f)
                with open(input_file, 'r') as input_f:
                    category2target2type2script2infos = json.loads(input_f.read())
                    for category, target2type2script2infos in category2target2type2script2infos.items():
                        for target, type2script2infos in target2type2script2infos.items():
                            for type_, script2infos in type2script2infos.items():
                                #if type_ != 'funcs':
                                #    continue
                                for script, infos in script2infos.items():
                                    for info in infos:
                                        if len(info) >= 15:
                                            script_id_one = info[5]
                                            if '.asg' in info[-4]:
                                                source_file_one = info[-4].replace('.asg', '.'+str(script_id_one)+'.script')
                                            else:
                                                #source_file_one = info[3].replace('-functions.json', '.'+str(script_id_one)+'.script')
                                                continue

                                            script_id_two = info[15]
                                            if '.asg' in info[-4]:
                                                source_file_two = info[-4].replace('.asg', '.'+str(script_id_two)+'.script')
                                            else:
                                                #source_file_two = info[7].replace('-functions.json', '.'+str(script_id_two)+'.script')
                                                continue

                                        else:
                                            script_id_one = info[0]
                                            if '.func' in info[3]:
                                                source_file_one = info[3].replace('.func', '.'+str(script_id_one)+'.script')
                                            else:
                                                source_file_one = info[3].replace('-functions.json', '.'+str(script_id_one)+'.script')

                                            script_id_two = info[4]
                                            if '.func' in info[7]:
                                                source_file_two = info[7].replace('.func', '.'+str(script_id_two)+'.script')
                                            else:
                                                source_file_two = info[7].replace('-functions.json', '.'+str(script_id_two)+'.script')

                                        rank = rank.split('-')[0]
                                        script_dir = 'iso_' + str(int(rank)%num_instances) + '_logs'
                                        script_dir = os.path.join(raw_data_dir, script_dir)

                                        source_one = None
                                        source_two = None
                                        try:
                                            source_file_one = os.path.join(script_dir, source_file_one)
                                            with open(source_file_one, 'r') as input_f:
                                                source_one = input_f.read()

                                            source_file_two = os.path.join(script_dir, source_file_two)
                                            with open(source_file_two, 'r') as input_f:
                                                source_two = input_f.read()
                                        except IOError as e:
                                            #print(e)
                                            continue
                                            
                                        if source_one is not None and source_two is not None:
                                            #print(rank, program_one, program_two)
                                            #print(rank)
                                            clean_source_one = ''.join(source_one.strip().split()).replace(';', '') 
                                            clean_source_two = ''.join(source_two.strip().split()).replace(';', '')
                                            if clean_source_one == clean_source_two:
                                                if category not in cat2rank2target2type2infos:
                                                    cat2rank2target2type2infos[category] = dict()
                                                if rank not in cat2rank2target2type2infos[category]:
                                                    cat2rank2target2type2infos[category][rank] = dict()
                                                if target not in cat2rank2target2type2infos[category][rank]:
                                                    cat2rank2target2type2infos[category][rank][target] = dict()
                                                if type_ not in cat2rank2target2type2infos[category][rank][target]:
                                                    cat2rank2target2type2infos[category][rank][target][type_] = list()
                                                cnt += 1
                                                cat2rank2target2type2infos[category][rank][target][type_].append(info)
            


            except Exception as e:
                print(e)
                pass

           
    except OSError as e:
        pass
    except Exception as e:
        status = 'Process %-4d task %s/%s raised an exception %s.' % (process_index, task_id+1, length, type(e))
        status_queue.put([process_index, status])
        string = '%s\t%s' % (getlocaltime(), status)
        try:
            print(string)
            exc_type, exc_value, exc_traceback = sys.exc_info()
            lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
            print(''.join('!! ' + line for line in lines))
            sys.stdout.flush()
        except Exception:
            pass

    status = 'Process %-4d task %s/%s PID [%d] completed.' % (process_index, task_id+1, length, current_pid)
    status_queue.put([process_index, status])


    if cnt > 0:
        output_file = '%s-duplicate_script-cat2rank2target2type2infos.json'%(user_dir)
        with open(output_file, 'w') as output_f:
            output_f.write(json.dumps(cat2rank2target2type2infos))
        print(output_file)



def main(argv):
    global raw_data_dir, processed_data_dir, num_instances, parent_pid, process_list, log_f, conflicting_rank_set, func_dir, raw_data_dir

    signal.signal(signal.SIGTERM, signal_term_handler)
    parent_pid = os.getpid()
    try:
        opts, args = getopt.getopt(argv, 'hu:r:d:i:n:p:s:e:t:f:', ['help', 'user_dir=', 'raw_data_dir=', 'exp_dir=', 'num=', 'process=', 'start=', 'end=', 'type=', 'func_dir='])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    conflicting_rank_set = set()

        
    user_dir = None
    num_instances = 512
    maximum_process_num = 8 # Change to 1 for debugging purpose
    start = 0
    end = None
    exp_dir = "exps"
    extract = False
    clean = False
    send = False
    func_dir = None
    raw_data_dir = None
    #input_type = 'info2index2script'
    input_type = 'url2index'
    for opt, arg in opts:
        if opt in ('-u', '--user_dir'):
            user_dir = arg
        elif opt in ('-d', '--dir'):
            exp_dir = arg
        elif opt in ('-n', '--num'):
            num_instances = int(arg)
        elif opt in ('-p', '--process'):
            maximum_process_num = int(arg)
        elif opt in ('-s', '--start'):
            start = int(arg)
        elif opt in ('-e', '--end'):
            end = int(arg)
        elif opt in ('-t', '--type'):
            input_type = arg
        elif opt in ('-f', '--func_dir'):
            func_dir = arg
        elif opt in ('-r', '--raw_data_dir'):
            raw_data_dir = arg
        elif opt in ('-h', '--help'):
            usage()
            sys.exit(0)

    if user_dir is None:
        usage()
        sys.exit(0)


    input_file = 'top-1m.csv'
    #task_queue = get_task_queue(input_file)

    #raw_data_dir = exp_dir
    processed_data_dir = os.path.join(exp_dir, 'conflicting_data')
    if not os.path.isdir(processed_data_dir):
        try:
            os.mkdir(processed_data_dir)
        except Exception as e:
            print(e)


    log_file = 'convert_asg_logs.log'
    log_file = os.path.join(exp_dir, log_file)
    log_f = open(log_file, mode='w')

    current_time = getlocaltime()
    status = "PARENT SCRIPT STARTED! PARENT PID=[%d]" % parent_pid
    string = '%s\t%s\n' % (current_time, status)
    log_f.write(string)
    string = "%s\tProcess started, argv=%s\n" % (current_time, argv)
    log_f.write(string)


    completed_list = set()
    completion_reg = re.compile('Process [0-9\s]+task ([0-9]+)/[0-9]+ PID \[\d+\] completed.')
    with codecs.open(log_file, encoding='utf-8', mode='r') as input_f:
        for line in input_f:
            m = re.search(completion_reg, line)
            if m:
                task = int(m.group(1)) - 1
                completed_list.add(task)
    completed_list = set()


    try:
        os.chdir(exp_dir)
    except OSError as e:
        print(e)
        sys.exit(1)

    rank2url = dict()


    tasks = [i for i in range(num_instances-1, -1, -1)]
    try:
        length = len(tasks)
        status_queue = Queue()
        final_status_set = set()
        process_num = 0
        process2status = dict()
        running_processes = set()
        process2index = dict()
        index2task = dict()
        round_num = 0
        process_list = list()
        killed_process_list = list()
        alive_check_timeout = 10
        alive_count = 0

        while len(tasks) > 0 or len(running_processes) > 0:
            current_time = getlocaltime()
            num_alive_processes = sum(1 for process in process_list if process.is_alive())
            status = '[%d] processes are still alive, [%d] are running ...' % (num_alive_processes, len(running_processes))
            string = '%s\t%s\n' % (current_time, status)
            print(string)
            sys.stdout.flush()

            while len(running_processes) < maximum_process_num and len(tasks) > 0:
                group = tasks.pop()
                task = group
                if task in completed_list:
                    continue
                user_dir_group = '%s_%d' % (user_dir, group)
                process_index = process_num
                #task_list = task_queue[task]
                try:
                    process_list.append(Task(target=measure, args=(user_dir_group, task, length, start, end, status_queue, process_index)))
                    process = process_list[-1]
                    process.start()
                except OSError as e:
                    tasks.append(group)
                    time.sleep(5)
                    continue
                process_num += 1
                running_processes.add(process_list[-1])
                process2index[process_list[-1]] = process_index
                index2task[process_index] = task

                current_time = getlocaltime()
                process_status = 'Process %-4d task %d/%d created. PID=%d ...' % (process_index, task+1, length, process.pid)
                string = '%s\t%s' % (current_time, process_status)
                print(string)
                sys.stdout.flush()
                if process_num % 32 == 0:
                    break

            flag = False
            while any(process.is_alive() for process in process_list):
                time.sleep(1)
                current_time = getlocaltime()
                alive_count += 1
                num_alive_processes = sum(1 for process in process_list if process.is_alive())

                while not status_queue.empty():
                    process_index, process_status = status_queue.get()
                    string = '%s\t%s\n' % (current_time, process_status)
                    log_f.write(string)
                    if 'completed' in process_status:
                        flag = True
                        if process_status not in final_status_set:
                            final_status_set.add(process_status)

                if alive_count % alive_check_timeout == 0:
                    status = '[%d] processes are still alive ...' % (num_alive_processes)
                    string = '%s\t%s\n' % (current_time, status)
                    print(string)
                    sys.stdout.flush()

                    # We need to get a list. Otherwise, we will receive an exception: RuntimeError: Set changed size during iteration
                    for process in list(running_processes):
                        process_index = process2index[process]
                        group = index2task[process_index]

                        if not process.is_alive():
                            flag = True
                            process_status = 'Process %-4d task %d/%d is no longer alive...' % (process_index, group+1, length)
                        else:
                            process_status = 'Process %-4d task %d/%d is still alive...' % (process_index, group+1, length)
                        string = '%s\t%s\n' % (current_time, process_status)
                        log_f.write(string)

                if flag == True or (num_alive_processes < maximum_process_num and (len(tasks) > 0 or alive_count % alive_check_timeout == 0)):
                    break
            for process in process_list:
                if not process.is_alive():
                    if process in running_processes:
                        running_processes.remove(process)
    except (KeyboardInterrupt, Exception) as e:
        current_time = getlocaltime()
        status = "PARENT SCRIPT exception %s" % type(e)
        string = '%s\t%s\n' % (current_time, status)
        log_f.write(string)
        if not isinstance(e, KeyboardInterrupt):
            exc_type, exc_value, exc_traceback = sys.exc_info()
            lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
            print(type(e), "PARENT")
            print(''.join('!! ' + line for line in lines))
            status = ''.join('!! ' + line for line in lines)
            string = '%s\t%s\n' % (current_time, status)
            log_f.write(string)

        kill_all_processes()

    while not status_queue.empty():
        process_index, process_status = status_queue.get()
        string = '%s\t%s\n' % (current_time, process_status)
        log_f.write(string)

    for process in process_list:
        try:
            process.join()
        except Exception:
            pass

    gone, alive = kill_child_processes(parent_pid = parent_pid)

    timeout = 10
    while timeout:
        time.sleep(1)
        timeout -= 1
        if not mp.active_children():
            break

    current_time = getlocaltime()
    status = "PARENT SCRIPT COMPLETED! PARENT PID=[%d]" % parent_pid
    string = '%s\t%s\n' % (current_time, status)
    log_f.write(string)
    log_f.close()

    print(conflicting_rank_set)



def usage():
    tab = '\t'
    print('Usage:')
    print(tab + 'python %s [OPTIONS]' % (__file__))
    print(tab + '-d | --exp_dir=')
    print(tab*2 + 'Exp directory')
    print(tab + '-u | --user_dir=')
    print(tab*2 + 'User directory of Chrome')
    print(tab + '-n | --num=')
    print(tab*2 + 'Number of task splits, default is 512')
    print(tab + '-p | --process=')
    print(tab*2 + 'Maximum number of processes, default is 8')
    print(tab + '-s | --start')
    print(tab*2 + 'Start index, default 0')
    print(tab + '-e | --end')
    print(tab*2 + 'End index, default number of URLs')
    print(tab + '-f | --func_dir=')
    print(tab*2 + 'Function logs directory')
    print(tab + '-r | --raw_data_dir=')
    print(tab*2 + 'Raw logs directory')




if __name__ == '__main__':
    main(sys.argv[1:])

