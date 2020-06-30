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

        result_dict = dict()
        processed_list = set()

        raw_input_dir = user_dir + '_logs'
        input_dir = os.path.join(current_dir, raw_input_dir)
        file_list = os.listdir(input_dir)
        files = [f for f in file_list if f.endswith('-conflicts.json')]

        func_name_dir = user_dir + '_logs'
        func_name_dir = os.path.join(func_dir, func_name_dir)
        func_name_files = os.listdir(func_name_dir)
        rank2files = dict()
        for f in files:
            rank = int(f.split('.')[0])
            if rank not in rank2files:
                rank2files[rank] = list()
            rank2files[rank].append(f)
        for f in func_name_files:
            rank = int(f.split('-')[0])
            if rank not in rank2files:
                rank2files[rank] = list()
            rank2files[rank].append(f)

        output_dir = input_dir
        finished_files = os.listdir(output_dir)
        finished_files = [f for f in finished_files if f.endswith('-cat2name2conflicts.json')]
        for f in finished_files:
            rank = int(f.split('-')[0])
            processed_list.add(rank)
        

        raw_output_dir = os.path.join(processed_data_dir, raw_input_dir)
        if not os.path.isdir(raw_output_dir):
            os.mkdir(raw_output_dir)
        
        for rank, conflict_files in rank2files.items():
            if rank > end:
                print('rank > end')
                continue
            if rank % num_instances != task_id or rank in processed_list or rank < start:
                print('passed')
                continue

            adjusted_type2target2infos = {'value': dict(), 'type': dict(), 'funcs': dict(), 'func-var':dict()}


            for task in conflict_files:
                try:
                    try:
                        if task.endswith('-conflicts.json'):
                            rank = int(task.split('.')[0])
                            if task.split('.')[1] == 'sub':
                                continue
                        elif task.endswith('-func_name_conflicts.json'):
                            rank = int(task.split('-')[0])
                        try:
                            main_func_file = str(rank) + '.main.0.func'
                            func_file_dir = user_dir + '_logs'
                            func_file_dir = os.path.join(raw_data_dir, func_file_dir)
                            main_func_file = os.path.join(func_file_dir, main_func_file)
                            if not os.path.isfile(main_func_file):
                                continue

                            frame_file_dir = user_dir + '_logs'
                            frame_file_dir = os.path.join(raw_data_dir, frame_file_dir)
                            frame_file = str(rank) + '.main.0.frame' #task.split('-')[0] + '.frame'
                            frame_file = os.path.join(frame_file_dir, frame_file)                   
                            if not os.path.isfile(frame_file):
                                continue
                            with open(frame_file, 'r') as input_f:
                                for line in input_f:
                                    if line.startswith('[main]'):
                                        first_party_url = line.split()[1]
                                        break

                            asg_file_dir = user_dir + '_logs'
                            asg_file_dir = os.path.join(raw_data_dir, frame_file_dir)
                            asg_file = str(rank) + '.main.0.asg' #task.split('-')[0] + '.asg'
                            asg_file = os.path.join(asg_file_dir, asg_file)
                            if not os.path.isfile(asg_file):
                                continue
                            with open(asg_file, 'r') as input_f:
                                input_f = input_f.read()
                                asg_logs = input_f.split("\tscript_conflicts\n")
                                main_window_id = determine_window_id_of_main_frame(asg_logs, first_party_url, asg_file)
                            main_context_id = None
                            if main_window_id is None:
                                print('*** !!! ==>', task, first_party_url)
                            else:
                                #main_context_id = determine_context_id_of_main_frame(main_func_file, urls, first_party_url)
                                main_context_id = main_window_id
                        except Exception as e:
                            try:
                                exc_type, exc_value, exc_traceback = sys.exc_info()
                                lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
                                print(''.join('!! ' + line for line in lines))
                                sys.stdout.flush()
                            except Exception:
                                pass
                            continue

                        if task.endswith('-conflicts.json'):
                            assign_file = task.split('-')[0] + '-' + 'assign.json'
                            assign_file = os.path.join(input_dir, assign_file)
                            conflict_file = os.path.join(input_dir, task)
                            with open(conflict_file, 'r') as input_f:
                                type2target2infos = json.loads(input_f.read())
                            with open(assign_file, 'r') as input_f:
                                target2writes = json.loads(input_f.read())

                            for type_, target2infos in type2target2infos.items():
                                #if type_ not in adjusted_type2target2infos:
                                #    adjusted_type2target2infos[type_] = dict()
                                for target, infos in target2infos.items():
                                    if len(target.split('-')) > 1 or target.split('.')[0] == 'this' or target.startswith('Yx$Q7r$zJUnQUy__'):
                                        continue
                                    for info in infos:
                                        # info: (assign_id_1,window_id, value_1, rhs_1, rhs_type_1, script_id_1, script_url_1, pos_1, timestamp_1, typeof_1, lhs_1, assign_id_2, value_2, rhs_2, rhs_type_2, script_id_2, script_url_2, pos_2, timestamp_2, typeof_2, lhs_2, filename)
                                        if int(info[1]) != main_window_id and main_window_id is not None:
                                            continue
                                        if info[5] == info[15] and '[' in target and ']' in target:
                                            continue
                                        if target.startswith('0x'):
                                            if '.' in target and '[' in target:
                                                dot_index = target.split('-')[-1].find('.')
                                                square_index = target.split('-')[-1].find('[')
                                                if dot_index < square_index:
                                                    target_obj = target.split('.')[0]
                                                else:
                                                    target_obj = target.split('[')[0]
                                            elif '.' in target:
                                                target_obj = target.split('.')[0]
                                            elif '[' in target:
                                                target_obj = target.split('[')[0]
                                            else:
                                                target_obj = target
                                            found_global_obj_for_addr = False
                                            for target_, writes_ in target2writes.items():
                                                if len(target_.split('-')) > 1:
                                                    continue
                                                for write_ in writes_:
                                                    # write_: (assign_id, window_id, value_of_lhs, rhs_full_string, rhs_type, script_id, script_url, pos, timestamp. typeof_lhs. ptr_of_lhs)
                                                    if int(write_[1]) == int(info[1]) and write_[2] == target_obj and not target_.startswith('Yx$Q7r$zJUnQUy__') and not target_.startswith('this'):
                                                        target = target.replace(target_obj, target_)
                                                        found_global_obj_for_addr = True
                                                        break
                                                if found_global_obj_for_addr:
                                                    break
                                        if target.startswith('0x'):
                                            continue

                                        if target not in adjusted_type2target2infos[type_]:
                                            adjusted_type2target2infos[type_][target] = list()
                                        adjusted_type2target2infos[type_][target].append((info[0], info[1], info[2], info[3], info[4], info[5], info[6], info[7], info[8], info[9], info[10], info[11], info[12], info[13], info[14], info[15], info[16], info[17], info[18], info[19], info[20], info[21], task))
                    


                        elif task.endswith('-func_name_conflicts.json'):
                            #if 'func_name' not in adjusted_type2target2infos:
                            #    adjusted_type2target2infos['func_name'] = dict()
                            if main_context_id is None:
                                print('*** !!! ==>', task, 'func')

                            func_name_file = os.path.join(func_name_dir, task)
                            with open(func_name_file, 'r') as input_f:
                                func_type2context2script2infos = json.loads(input_f.read())
                            for func_type, context2script2infos in func_type2context2script2infos.items():
                                for context, script2infos in context2script2infos.items():
                                    if str(context) != str(main_context_id) and main_context_id is not None:
                                        continue
                                    for script_tuple, infos in script2infos.items():
                                        for info in infos:
                                            if func_type == 'funcs':
                                                # info: (script_id, func_name, start, end, script_url, timestamp, filename)
                                                for info_ in infos:
                                                    if info == info_:
                                                        continue
                                                    if info[1] == info_[1]:
                                                        if info[1] not in adjusted_type2target2infos[func_type]:
                                                            adjusted_type2target2infos[func_type][info[1]] = list()
                                                        conflict_info = (int(info[0]), info[4], info[5], info[6], int(info_[0]), info_[4], info_[5], info_[6], context)
                                                        if (int(info_[0]), info_[4], info_[5],info_[6],int(info[0]), info[4], info[5], info[6], context) not in adjusted_type2target2infos[func_type][info[1]]:
                                                            adjusted_type2target2infos[func_type][info[1]].append(conflict_info)
                                            elif func_type == 'func-var':
                                                # info: (func_name, assign_id, script_url_1, timestamp_1, filename_1, context_id, start, end, script_url_2, timestamp_2, filename_2)
                                                if info[0] not in adjusted_type2target2infos[func_type]:
                                                    adjusted_type2target2infos[func_type][info[0]] = list()
                                                first_script_id = int(script_tuple.split('-')[0])
                                                second_script_id = int(script_tuple.split('-')[1])
                                                conflict_info = (first_script_id, info[2], info[3], info[4], second_script_id, info[8], info[9], info[10], context)
                                                adjusted_type2target2infos[func_type][info[0]].append(conflict_info)


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


            if len(adjusted_type2target2infos['value']) > 0 or len(adjusted_type2target2infos['type']) > 0 or len(adjusted_type2target2infos['funcs']) > 0 or len(adjusted_type2target2infos['func-var']) > 0:
                output_file = str(rank) + '-cat2name2conflicts.json'
                output_file = os.path.join(input_dir, output_file)
                if len(adjusted_type2target2infos['value']) > 0 or len(adjusted_type2target2infos['type']) > 0:
                    print(output_file)
                with open(output_file, 'w') as output_f:
                    output_f.write(json.dumps(adjusted_type2target2infos))

           
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
    print(tab + '-f | --func_dir=')
    print(tab*2 + 'Function log files directory')
    print(tab + '-r | --raw_data_dir=')
    print(tab*2 + 'Raw log files directory')

    

if __name__ == '__main__':
    main(sys.argv[1:])

