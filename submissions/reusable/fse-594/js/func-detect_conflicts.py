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




def compute_contextID_to_windowID(rank2contextid2scripturls, rank2scripturl2windowid):
    rank2contextid2windowid = dict()

    for rank, contextid2scripturls in rank2contextid2scripturls.items():
        if rank not in rank2scripturl2windowid:
            continue
        if len(rank2scripturl2windowid[rank]) == 0:
            continue
        if rank not in rank2contextid2windowid:
            rank2contextid2windowid[rank] = dict()
            scripturl2windowid = rank2scripturl2windowid[rank]
        for context_id, script_urls in contextid2scripturls.items():
            result_for_cur_context = list()
            for script_url in script_urls:
                try:
                    windowids = scripturl2windowid[script_url] # it's possible that one script is included in multiple frames
                    result_for_cur_context.append(windowids)
                except KeyError as e:
                    pass
            if len(result_for_cur_context) == 0:
                rank2contextid2windowid[rank][context_id] = -1
                print(rank, context_id, 'unknown-script_not_found')
            else:
                common_window_ids = set(result_for_cur_context[0]).intersection(*result_for_cur_context[:1])
                if len(common_window_ids) == 0 or len(common_window_ids) > 1:
                    rank2contextid2windowid[rank][context_id] = -1
                    if len(common_window_ids) == 0:
                        print(rank, context_id, 'unknown-no_common_window_id')
                    else:
                        print(rank, context_id, 'unknown-multiple_common_window_id')
                else:
                    rank2contextid2windowid[rank][context_id] = list(common_window_ids)[0]
                    print(rank, context_id, 'success_mapping')
    return rank2contextid2windowid






def measure(user_dir, task_id, length, start, end, status_queue, process_index):
    global processed_data_dir, conflicting_rank_set, raw_data_dir
    current_pid = os.getpid()
    current_dir = os.getcwd()
    try:
        status = 'Process %-4d task %d/%d PID [%d] starting ...' % (process_index, task_id+1, length, current_pid)
        status_queue.put([process_index, status])
        #print(status)

        result_dict = dict()
        processed_list = set()

        raw_input_dir = user_dir + '_logs'
        input_dir = os.path.join(current_dir, raw_input_dir)
        file_list = os.listdir(input_dir)
        files = [f for f in file_list if f.endswith('-defined_func.json')]

        output_dir = os.path.join(processed_data_dir, raw_input_dir)
        if os.path.isdir(output_dir):
            finished_files = os.listdir(output_dir)
            finished_files = [f for f in finished_files if f.endswith('-func_name_conflicts.json')]
            for f in finished_files:
                rank = int(f.split('-')[0])
                processed_list.add(rank)

        raw_output_dir = os.path.join(processed_data_dir, raw_input_dir)
        if not os.path.isdir(raw_output_dir):
            os.mkdir(raw_output_dir)
        
        rank2contextid2scripturls = dict()
        rank2scripturl2windowid = dict()
        rank2function_info_dict = dict()
        rank2function_files = dict()
        rank2assign_files = dict()

        function_files = [f for f in file_list if f.endswith('-functions.json')]
        for function_file in function_files:
            rank = int(function_file.split('.')[0])
            if rank not in rank2function_files:
                rank2function_files[rank] = list()
            rank2function_files[rank].append(function_file)
            
        assign_files = [f for f in file_list if f.endswith('-assign.json')]
        for assign_file in assign_files:
            rank = int(assign_file.split('.')[0])
            if rank not in rank2assign_files:
                rank2assign_files[rank] = list()
            rank2assign_files[rank].append(assign_file)


        for task in files:
            rank = int(task.split('-')[0])
            if rank > end:
                print('rank > end')
                continue
            if rank % num_instances != task_id or rank in processed_list or rank < start:
                print('passed')
                continue
            window2script2conflicts =  {'funcs':dict(), 'func-var':dict()}
            try:
                try:
                    task_file = os.path.join(input_dir, task)
                    function_info_dict = dict()

                    
                    #if task_file.endswith('-defined_func.json'):
                    if rank not in rank2contextid2scripturls:
                        rank2contextid2scripturls[rank] = dict()
                    with open(task_file, 'r') as input_f:
                        func_dict = json.loads(input_f.read())
                        for window, script2funcs in func_dict.items():
                            for script, funcs in script2funcs.items():
                                for script_, funcs_ in script2funcs.items():
                                    defined_funcs = [func[0] for func in funcs]
                                    defined_funcs_ = [func_[0] for func_ in funcs_]
                                    if len(set(defined_funcs) & set(defined_funcs_)) > 0:
                                        if script_ == script:
                                            # if it's a conflict within the same script, we need to make sure 2 definitions are not exactly identical
                                            duplicate_defs = set(defined_funcs) & set(defined_funcs_)
                                            real_conflict_defs = set()
                                            for def_ in duplicate_defs:
                                                for func in funcs:
                                                    if func[0] == def_:
                                                        start_in_one = func[1]
                                                        end_in_one = func[2]
                                                        break
                                                for func_ in funcs_:
                                                    if func_[0] == def_:
                                                        start_in_two = func_[1]
                                                        end_in_two = func_[2]
                                                        break
                                                if start_in_one != start_in_two or end_in_one != end_in_two:
                                                    real_conflict_defs.add(def_)
                                        else:
                                            real_conflict_defs = set(set(defined_funcs) & set(defined_funcs_))
                                        if len(real_conflict_defs) > 0:
                                            conflicting_script_tuple = str(script_) + '-' + str(script)
                                            if window not in window2script2conflicts['funcs']:
                                                window2script2conflicts['funcs'][window] = dict()
                                            if str(script) + '-' + str(script_) in window2script2conflicts['funcs'][window]:
                                                continue

                                            conflicting_func_info_list = [(script, func[0], func[1], func[2], func[3], func[4], func[5]) for func in funcs if func[0] in real_conflict_defs] + [(script_, func_[0], func_[1], func_[2], func_[3], func_[4], func_[5]) for func_ in funcs_ if func_[0] in real_conflict_defs] 
                                            window2script2conflicts['funcs'][window][conflicting_script_tuple] = conflicting_func_info_list

                        for window, script2funcs in func_dict.items():
                            if window not in rank2contextid2scripturls[rank]:
                                rank2contextid2scripturls[rank][window] = set()
                            for script, funcs in script2funcs.items():
                                rank2contextid2scripturls[rank][window].add(funcs[0][3])



                        for window, script2funcs in func_dict.items():
                            for script, funcs in script2funcs.items():
                                for func in funcs:
                                    func_name = func[0]
                                    if func_name not in function_info_dict:
                                        function_info_dict[func_name] = list()
                                    function_info = (window, script, func[1], func[2], func[3], func[4], func[5])
                                    function_info_dict[func_name].append(function_info)
                        rank2function_info_dict[rank] = function_info_dict
                    



                    if int(rank) in rank2function_files:
                        function_files = rank2function_files[int(rank)]
                        for functions_file in function_files:
                            functions_file = os.path.join(input_dir, functions_file)
                            with open(functions_file, 'r') as input_f:
                                func2window2infos = json.loads(input_f.read())
                            function_info_dict = rank2function_info_dict[int(rank)]
                            for func, window2infos in func2window2infos.items():
                                if func not in function_info_dict:
                                    if func.startswith('window.') and '.'.join(func.split('.')[1:]) not in function_info_dict:
                                        continue
                                    elif func.startswith('window.') and '.'.join(func.split('.')[1:]) in function_info_dict:
                                        func = '.'.join(func.split('.')[1:])
                                    else:
                                        continue
                                same_func_name_infos = function_info_dict[func]
                                for window, infos in window2infos.items():
                                    for info in infos:
                                        #info: (assign_id, sript_id, script_url, timestamp)
                                        for info_ in same_func_name_infos:
                                            # info_: (context_id, script_id, start, end, script_url, timestamp, filename)
                                            if info_[0] != window:
                                                continue

                                            # let's keep conflicts within the same script
                                            #if int(info[1]) == int(info_[1]):
                                            #    continue

                                            if window not in window2script2conflicts['funcs']:
                                                window2script2conflicts['funcs'][window] = dict()
                                            conflicting_script_tuple = str(info[1]) + '-' + str(info_[1])
                                            if conflicting_script_tuple not in window2script2conflicts['funcs'][window]:
                                                window2script2conflicts['funcs'][window][conflicting_script_tuple] = list()
                                            #conflicting_info = (func, info[0], info[2], info[3], functions_file.split('/')[-1], info_[0], info_[2], info_[3], info_[4], info_[5], info_[6])
                                            #conflicting_info = [(info_[1], func, info_[2], info_[3], info_[4], info_[5], info_[6])] + [(info[1], func, None, None, info[2], info[3], functions_file.split('/')[-1])]
                                            conflicting_info = (info_[1], func, info_[2], info_[3], info_[4], info_[5], info_[6])
                                            window2script2conflicts['funcs'][window][conflicting_script_tuple].append(conflicting_info)
                                            conflicting_info = (info[1], func, None, None, info[2], info[3], functions_file.split('/')[-1])
                                            window2script2conflicts['funcs'][window][conflicting_script_tuple].append(conflicting_info)

                    if int(rank) in rank2assign_files:
                        assign_files = rank2assign_files[int(rank)]
                        for assign_file in assign_files:
                            assign_file = os.path.join(input_dir, assign_file)
                            rank = str(rank)
                            with open(assign_file, 'r') as input_f:
                                name2writes = json.loads(input_f.read())
                            function_info_dict = rank2function_info_dict[int(rank)]
                            for func_name, func_infos in function_info_dict.items():
                                if func_name not in name2writes:
                                    continue
                                writes = name2writes[func_name]
                                for write in writes:
                                    # write: (assign_id, window, value, rhs, rhs_type, script_id, script_url, pos, timestamp, typeof_lhs, ptr_of_lhs)
                                    for func_info in func_infos:
                                        # func_info: (window, script_id, start, end, script_url, timestamp, filename)
                                        if int(write[1]) == int(func_info[0]) and write[9] != 'function':
                                            window = int(write[1])
                                            if window not in window2script2conflicts['func-var']:
                                                window2script2conflicts['func-var'][window] = dict()
                                            conflicting_script_tuple = str(write[5]) + '-' + str(func_info[1])
                                            if conflicting_script_tuple not in window2script2conflicts['func-var'][window]:
                                                window2script2conflicts['func-var'][window][conflicting_script_tuple] = list()
                                            #conflicting_info = (func, info[0], info[2], info[3], functions_file.split('/')[-1], info_[0], info_[2], info_[3], info_[4], info_[5], info_[6])
                                            conflicting_info = (func_name, write[0], write[6], write[8], assign_file.split('/')[-1], int(func_info[0]), func_info[2], func_info[3], func_info[4], func_info[5], func_info[6])
                                            window2script2conflicts['func-var'][window][conflicting_script_tuple].append(conflicting_info)





                 
                except Exception as e:
                    #print(e)
                    try:
                        exc_type, exc_value, exc_traceback = sys.exc_info()
                        lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
                        print(''.join('!! ' + line for line in lines))
                        sys.stdout.flush()
                    except Exception:
                        pass

                    pass



            except KeyboardInterrupt as e:
                kill_all_processes()
            except Exception as e:
                status = 'Process %-4d task %s/%s raised an exception %s when processing URL [%d].' % (process_index, task_id+1, length, type(e), rank)
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

            
            
            if len(window2script2conflicts['funcs']) > 0 or len(window2script2conflicts['func-var']) > 0:
                output_file = str(rank) + '-func_name_conflicts.json'
                output_file = os.path.join(raw_input_dir, output_file)
                output_file = os.path.join(processed_data_dir, output_file)
                #if len(window2script2conflicts['func-var']) > 0:
                if 1:
                    print(output_file)
                with open(output_file, 'w') as output_f:
                    output_f.write(json.dumps(window2script2conflicts))





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




def main(argv):
    global raw_data_dir, processed_data_dir, num_instances, parent_pid, process_list, log_f, conflicting_rank_set

    signal.signal(signal.SIGTERM, signal_term_handler)
    parent_pid = os.getpid()
    try:
        opts, args = getopt.getopt(argv, 'hu:d:i:n:p:s:e:t:', ['help', 'user_dir=', 'exp_dir=', 'num=', 'process=', 'start=', 'end=', 'type='])
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
        elif opt in ('-h', '--help'):
            usage()
            sys.exit(0)

    if user_dir is None:
        usage()
        sys.exit(0)


    input_file = 'top-1m.csv'
    #task_queue = get_task_queue(input_file)

    raw_data_dir = exp_dir
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


    #if end is None:
    #    end = max([max(q, key=lambda x:x[0]) for q in task_queue])[0]

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
    #print(tab + '-t | --type=')
    #print(tab*2 + 'Input type, [url2index|info2index2script] default "url2index"')

if __name__ == '__main__':
    main(sys.argv[1:])

