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






def update_conflict_and_write_dict(name, addr, target2infos, conflict_infos):
    pending_names = list()
    for target, infos in target2infos.items():
        if '.' in target.split('-')[-1] or '[' in target.split('-')[-1]:
            if '.' in target.split('-')[-1] and '[' in target.split('-')[-1]:
                dot_index = target.split('-')[-1].rfind('.')
                square_index = target.split('-')[-1].rfind('[')
                r_square_index = target.split('-')[-1].rfind(']')
                if r_square_index > dot_index:
                    prop_key = target.split('-')[-1][square_index:].split('[')[-1].split(']')[0] #target.split('-')[-1].split('[')[-1].split(']')[0] # for a-B-ID[0], it's 0
                    prop_obj = target.split('-')[-1][:square_index] #target.split('-')[-1].split('[')[0] # for a-B-ID[0], it's ID
                    if prop_obj == addr:
                        new_prop = name + '[' + prop_key + ']' # ID[0] => name[0]
                        new_target = '-'.join(target.split('-')[:-1]) + new_prop
                        try:
                            del target2infos[target]
                        except KeyError as e:
                            pass

                        if new_target not in target2infos:
                            target2infos[new_target] = list()
                        for info in infos:
                            target2infos[new_target].append(info)
                            if (info[9] == 'object' or info[9] == 'function') and info[2].startswith('0x'):
                                pending_names.append((new_target, info[2]))

                        # need to keep the order
                        # sort(...)
                        inordered_infos = target2infos[new_target]
                        inordered_infos.sort(key=lambda x: x[0])
                        target2infos[new_target] = inordered_infos
                        for pending_name in pending_names:
                            update_conflict_and_write_dict(pending_name[0], pending_name[1], target2infos, conflict_infos)
                        pending_names = []
                else:
                    prop_key = target.split('-')[-1][dot_index:].split('.')[-1]#'.'.join(target.split('-')[-1].split('.')[1:]) # for a-B-ID.x, it's x
                    prop_obj = target.split('-')[-1][:dot_index]#target.split('-')[-1].split('.')[0] # for a-B-ID.x, it's ID
                    if prop_obj == addr:
                        new_prop = name + '.' + prop_key # ID.x => name.x
                        new_target = '-'.join(target.split('-')[:-1]) + new_prop
                        try:
                            del target2infos[target]
                        except KeyError as e:
                            pass
                        if new_target not in target2infos:
                            target2infos[new_target] = list()
                        for info in infos:
                            target2infos[new_target].append(info)
                            if (info[9] == 'object' or info[9] == 'function') and info[2].startswith('0x'):
                                pending_names.append((new_target, info[2]))
                        # need to keep the order
                        # sort(...)
                        inordered_infos = target2infos[new_target]
                        inordered_infos.sort(key=lambda x: x[0])
                        target2infos[new_target] = inordered_infos
                        for pending_name in pending_names:
                            update_conflict_and_write_dict(pending_name[0], pending_name[1], target2infos, conflict_infos)
                        pending_names = []



            elif '.' in target.split('-')[-1]:
                dot_index = target.split('-')[-1].rfind('.')
                prop_key = target.split('-')[-1][dot_index:].split('.')[-1]  #'.'.join(target.split('-')[-1].split('.')[1:]) # for a-B-ID.x, it's x
                prop_obj = target.split('-')[-1][:dot_index]  #target.split('-')[-1].split('.')[0] # for a-B-ID.x, it's ID
                if prop_obj == addr:
                    new_prop = name + '.' + prop_key # ID.x => name.x
                    new_target = '-'.join(target.split('-')[:-1]) + new_prop
                    try:
                        del target2infos[target]
                    except KeyError as e:
                        pass
                    if new_target not in target2infos:
                        target2infos[new_target] = list()
                    for info in infos:
                        target2infos[new_target].append(info)
                        if (info[9] == 'object' or info[9] == 'function') and info[2].startswith('0x'):
                            pending_names.append((new_target, info[2]))
                    # need to keep the order
                    # sort(...)
                    inordered_infos = target2infos[new_target]
                    inordered_infos.sort(key=lambda x: x[0])
                    target2infos[new_target] = inordered_infos
                    for pending_name in pending_names:
                        update_conflict_and_write_dict(pending_name[0], pending_name[1], target2infos, conflict_infos)
                    pending_names = []


            else:
                square_index = target.split('-')[-1].rfind('[')
                prop_key = target.split('-')[-1][square_index:].split('[')[-1].split(']')[0]  #.split('[')[-1].split(']')[0] # for a-B-ID[0], it's 0
                prop_obj = target.split('-')[-1][:square_index]  #.split('[')[0] # for a-B-ID[0], it's ID
                if prop_obj == addr:
                    new_prop = name + '[' + prop_key + ']' # ID[0] => name[0]
                    new_target = '-'.join(target.split('-')[:-1]) + new_prop
                    try:
                        del target2infos[target]
                    except KeyError as e:
                        pass

                    if new_target not in target2infos:
                        target2infos[new_target] = list()
                    for info in infos:
                        target2infos[new_target].append(info)
                        if (info[9] == 'object' or info[9] == 'function') and info[2].startswith('0x'):
                            pending_names.append((new_target, info[2]))

                    # need to keep the order
                    # sort(...)
                    inordered_infos = target2infos[new_target]
                    inordered_infos.sort(key=lambda x: x[0])
                    target2infos[new_target] = inordered_infos
                    for pending_name in pending_names:
                        update_conflict_and_write_dict(pending_name[0], pending_name[1], target2infos, conflict_infos)
                    pending_names = []
 
        else:
            if target == addr:
                new_target = name
                try:
                    del target2infos[target]
                except KeyError as e:
                    pass

                if new_target not in target2infos:
                    target2infos[new_target] = list()
                for info in infos:
                    target2infos[new_target].append(info)
                inordered_infos = target2infos[new_target]
                inordered_infos.sort(key=lambda x: x[0])
                target2infos[new_target] = inordered_infos



    for cat in ['type', 'value']:
        for target, infos in conflict_infos[cat].items():
            if '.' in target.split('-')[-1] or '[' in target.split('-')[-1]:
                if '.' in target.split('-')[-1] and '[' in target.split('-')[-1]:
                    dot_index = target.split('-')[-1].rfind('.')
                    square_index = target.split('-')[-1].rfind('[')
                    r_square_index = target.split('-')[-1].rfind(']')
                    if r_square_index > dot_index:
                        prop_key = target.split('-')[-1][square_index:].split('[')[-1].split(']')[0] #target.split('-')[-1].split('[')[-1].split(']')[0] # for a-B-ID[0], it's 0
                        prop_obj = target.split('-')[-1][:square_index] #target.split('-')[-1].split('[')[0] # for a-B-ID[0], it's ID
                        if prop_obj == addr:
                            new_prop = name + '[' + prop_key + ']' # ID[0] => name[0]
                            new_target = '-'.join(target.split('-')[:-1]) + new_prop
                            try:
                                del conflict_infos[cat][target]
                            except KeyError as e:
                                pass

                            if new_target not in conflict_infos[cat]:
                                conflict_infos[cat][new_target] = list()
                            for info in infos:
                                conflict_infos[cat][new_target].append(info)
                                if (info[9] == 'object' or info[9] == 'function') and info[2].startswith('0x'):
                                    pending_names.append((new_target, info[2]))

                                # do NOT need to keep the order for conflicts
                            #print('conflict, new_target', new_target, 'cat', cat)
                            #print(conflict_infos[cat][new_target])
                            for pending_name in pending_names:
                                update_conflict_and_write_dict(pending_name[0], pending_name[1], target2infos, conflict_infos)
                            pending_names = []

                    else:
                        prop_key = target.split('-')[-1][dot_index:].split('.')[-1] #'.'.join(target.split('-')[-1].split('.')[1:]) # for a-B-ID.x, it's x
                        prop_obj = target.split('-')[-1][:dot_index]#target.split('-')[-1].split('.')[0] # for a-B-ID.x, it's ID
                        if prop_obj == addr:
                            new_prop = name + '.' + prop_key # ID.x => name.x
                            new_target = '-'.join(target.split('-')[:-1]) + new_prop
                            try:
                                del conflict_infos[cat][target]
                            except KeyError as e:
                                pass
                            if new_target not in conflict_infos[cat]:
                                conflict_infos[cat][new_target] = list()
                            for info in infos:
                                conflict_infos[cat][new_target].append(info)
                                if (info[9] == 'object' or info[9] == 'function') and info[2].startswith('0x'):
                                    pending_names.append((new_target, info[2]))

                                # do NOT need to keep the order for conflicts                    
                            for pending_name in pending_names:
                                update_conflict_and_write_dict(pending_name[0], pending_name[1], target2infos, conflict_infos)
                            pending_names = []

                     

                elif '.' in target.split('-')[-1]:
                    dot_index = target.split('-')[-1].rfind('.')
                    prop_key = target.split('-')[-1][dot_index:].split('.')[-1]   #'.'.join(target.split('-')[-1].split('.')[1:]) # for a-B-ID.x, it's x
                    prop_obj = target.split('-')[-1][:dot_index]#.split('.')[0] # for a-B-ID.x, it's ID
                    if prop_obj == addr:
                        new_prop = name + '.' + prop_key # ID.x => name.x
                        new_target = '-'.join(target.split('-')[:-1]) + new_prop
                        try:
                            del conflict_infos[cat][target]
                        except KeyError as e:
                            pass
                        if new_target not in conflict_infos[cat]:
                            conflict_infos[cat][new_target] = list()
                        for info in infos:
                            conflict_infos[cat][new_target].append(info)
                            if (info[9] == 'object' or info[9] == 'function') and info[2].startswith('0x'):
                                pending_names.append((new_target, info[2]))

                            # do NOT need to keep the order for conflicts                    
                        for pending_name in pending_names:
                            update_conflict_and_write_dict(pending_name[0], pending_name[1], target2infos, conflict_infos)
                        pending_names = []



                else:
                    square_index = target.split('-')[-1].rfind('[')
                    prop_key = target.split('-')[-1][square_index:].split('[')[-1].split(']')[0]#.split('[')[-1].split(']')[0] # for a-B-ID[0], it's 0
                    prop_obj = target.split('-')[-1][:square_index] #.split('[')[0] # for a-B-ID[0], it's ID
                    if prop_obj == addr:
                        new_prop = name + '[' + prop_key + ']' # ID[0] => name[0]
                        new_target = '-'.join(target.split('-')[:-1]) + new_prop
                        try:
                            del conflict_infos[cat][target]
                        except KeyError as e:
                            pass

                        if new_target not in conflict_infos[cat]:
                            conflict_infos[cat][new_target] = list()
                        for info in infos:
                            conflict_infos[cat][new_target].append(info)
                            if (info[9] == 'object' or info[9] == 'function') and info[2].startswith('0x'):
                                pending_names.append((new_target, info[2]))

                            # do NOT need to keep the order for conflicts
                        for pending_name in pending_names:
                            update_conflict_and_write_dict(pending_name[0], pending_name[1], target2infos, conflict_infos)
                        pending_names = []


            else:
                if target == addr:
                    new_target = name
                    try:
                        del conflict_infos[cat][target]
                    except KeyError as e:
                        pass

                    if new_target not in conflict_infos[cat]:
                        conflict_infos[cat][new_target] = list()
                    for info in infos:
                        conflict_infos[cat][new_target].append(info)





def construct_conflict_info_for_obj_values(ptr1, ptr2, addr2value, calls, addr2names, window):
    suffix = ""
    if ptr1 not in addr2value and ptr2 not in addr2value:
        if ptr1 not in addr2names and ptr2 not in addr2names:
            # think of them as both empty
            suffix = "new_obj_literal_assigned_both_empty_0"
        elif ptr1 in addr2names and ptr2 not in addr2names:
            # think of them as having diff content, because there's no way to determine the value of ptr2
            suffix = "new_obj_literal_assigned_diff_0"
        elif ptr2 in addr2names and ptr1 not in addr2names:
            # think of them as having diff content, because there's no way to determine the value of ptr1
            suffix = "new_obj_literal_assigned_diff_0"
        else:
            search_target_1 = list()
            found_1 = False
            for name in addr2names[ptr1]:
                search_target_1.append(name+'.concat')
                search_target_1.append(name+'.unshift')
                search_target_1.append(name+'.push')
            search_target_2 = list()
            found_2 = False
            for name in addr2names[ptr2]:
                search_target_2.append(name+'.concat')
                search_target_2.append(name+'.unshift')
                search_target_2.append(name+'.push')

            for call in reversed(calls):
                # call: (window_id, callee_name, script_id, timestamp, call_pos)
                if int(call[0] == window) and call[1] in search_target_1:
                    found_1 = True
                    if found_1 and found_2:
                        break
                elif int(call[0] == window) and call[1] in search_target_2:
                    found_2 = True
                    if found_1 and found_2:
                        break
            if ((found_1 and not found_2) or (found_2 and not found_1)):
                suffix = "new_obj_literal_assigned_diff_1"
            elif found_1 and found_2:
                suffix = "new_obj_literal_assigned_diff_0"
            else:
                suffix = "new_obj_literal_assigned_both_empty_0"
    elif ptr1 in addr2value and ptr2 not in addr2value:
        if ptr2 not in addr2names:
            # think of ptr2 as empty, because there's no way to determine the value of ptr2
            if addr2value[ptr1] != '{}':
                suffix = 'new_obj_literal_assigned_diff_1'
            else:
                suffix = 'new_obj_literal_assigned_both_empty_0'
        else:
            found_2 = False
            search_target_2 = list()
            for name in addr2names[ptr2]:
                search_target_2.append(name + '.concat')
                search_target_2.append(name + '.push')
                search_target_2.append(name + '.unshift')
            for call in reversed(calls):
                if int(call[0]) == window and call[1] in search_target_2:
                    found_2 = True
                    break
            if found_2:
                suffix = "new_obj_literal_assigned_diff_0"
            else:
                if addr2value[ptr1] != '{}':
                    suffix = 'new_obj_literal_assigned_diff_1'
                else:
                    suffix = 'new_obj_literal_assigned_both_empty_0'

        pass
    elif ptr1 not in addr2value and ptr2 in addr2value:
        if ptr1 not in addr2names:
            # think of ptr1 as empty, because there's no way to determine the value of ptr1
            if addr2value[ptr2] != '{}':
                suffix = 'new_obj_literal_assigned_diff_1'
            else:
                suffix = 'new_obj_literal_assigned_both_empty_0'
        else:
            found_1 = False
            search_target_1 = list()
            for name in addr2names[ptr1]:
                search_target_1.append(name + '.concat')
                search_target_1.append(name + '.push')
                search_target_1.append(name + '.unshift')
            for call in reversed(calls):
                if int(call[0]) == window and call[1] in search_target_1:
                    found_1 = True
                    break
            if found_1:
                suffix = "new_obj_literal_assigned_diff_0"
            else:
                if addr2value[ptr2] != '{}':
                    suffix = 'new_obj_literal_assigned_diff_1'
                else:
                    suffix = 'new_obj_literal_assigned_both_empty_0'

        pass
    else:
        if addr2value[ptr1] == addr2value[ptr2]:
            suffix = "new_obj_literal_assigned_same_1"
        else:
            suffix = "new_obj_literal_assigned_diff_1"

    return suffix    








def convert_obj_dict_to_literal_str(obj2key):
    obj_str = '{'
    for obj, key in obj2key.items():
        obj_str = obj_str + obj + ':' + key + ','
    obj_str = obj_str[:-1] + '}'
    return obj_str




def measure(user_dir, task_id, length, start, end, status_queue, process_index):
    global processed_data_dir, conflicting_rank_set

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
        #print(input_dir)
        file_list = os.listdir(input_dir)
        files = [f for f in file_list if f.endswith('.asg')]


        raw_output_dir = os.path.join(processed_data_dir, raw_input_dir)
        if not os.path.isdir(raw_output_dir):
            os.mkdir(raw_output_dir)


        rank2suffix_list = dict()
        for f in file_list:
            if f.endswith('.html') or f.endswith('rank2contextID2windowID.json') or f.startswith('webdriver_'):
                continue
            try:
                rank = int(f.split('.')[0])
            except Exception as e:
                print(e)
                continue
            if rank not in rank2suffix_list:
                rank2suffix_list[rank] = set()
            suffix = f.split('.')[1] + '-' + f.split('.')[2]
            rank2suffix_list[rank].add(suffix)
        #print('rank2suffixes', rank2suffix_list)



        rank2suffix2produced_files = dict()
        output_file_list = os.listdir(raw_output_dir)
        for f in output_file_list:
            if f.endswith('-defined_func.json') or f.endswith('rank2contextID2windowID.json'):
                continue
            #print(f)
            try:
                rank = int(f.split('.')[0])
            except ValueError as e:
                continue
            suffix = f.split('.')[1] + '-' + f.split('.')[2].split('-')[0]
            ext = f.split('-')[1]
            if ext in ['assign.json', 'conflicts.json', 'addr2infos.json', 'functions.json']:
                if rank not in rank2suffix2produced_files:
                    rank2suffix2produced_files[rank] = dict()
                if suffix not in rank2suffix2produced_files[rank]:
                    rank2suffix2produced_files[rank][suffix] = list()
                rank2suffix2produced_files[rank][suffix].append(f)


        for rank, suffix2output_files in rank2suffix2produced_files.items():
            expected_suffix_set = rank2suffix_list[rank]
            finished = True
            for suffix in expected_suffix_set:
                try:
                    current_files = rank2suffix2produced_files[rank][suffix]
                    #print(rank, expected_suffix_set, suffix, files)
                    if len(current_files) < 4:
                        finished = False
                        break
                except KeyError as e:
                    finished = False
                    break
            if finished:
                processed_list.add(rank)
        #print('processed_list', processed_list)
        del rank2suffix2produced_files
        del rank2suffix_list

        for task in files:
            rank = int(task.split('.')[0])
            if rank > end:
                print('rank > end', rank, end, task)
                continue
            if rank % num_instances != task_id or rank in processed_list or rank < start:
                #print('pass %d'%(rank))
                if rank % num_instances != task_id:
                    print(rank)
                elif rank in processed_list:
                    #print('finished %d'%(rank))
                    pass
                else:
                    print('rank < start')
                continue
            
            print('start %d'%(rank))
            try:
                try:
                    task_file = os.path.join(input_dir, task)
                    #print(task_file)
                    line_no = 0
                    addr2value = dict()
                    addr2obj2key = dict()
                    name2addr = dict()
                    addr2names = dict()
                    global_func_info = dict()
                    conflicts_info = {'type':dict(), 'value':dict()}
                    defined_funcs = dict()
                    target2infos = dict()
                    addr2infos = dict()
                    invalid_lines = set()
                    closed_obj_addrs = set()
                    global_func_info = dict()
                    calls = list()
                    with open(task_file, 'r') as input_f:
                        input_f = input_f.read()
                        input_f = input_f.split("\tscript_conflicts\n")
                        #starttime = time.time()
                
                        for line in input_f:
                            line = line[1:]
                            if len(line) == 0:
                                continue
                            try:
                                line_no += 1
                                old_obj_str = None
                                if line_no > 500000:
                                    print('%s too large'%(task))
                                    break
                                split_list = line.split(',elem_js_conflict,')
                                first_tuple = split_list[0]
 

                                if first_tuple == 'is_call' or first_tuple == 'is_call_new':
                                    callee_name = split_list[1]
                                    script_id = int(split_list[2])
                                    ##script_url = split_list[3]
                                    timestamp = float(split_list[3])
                                    call_pos = int(split_list[4])
                                    window_id = int(split_list[-1].split("\"")[0])
                                    if callee_name.split('.')[-1] == 'push' or callee_name.split('.')[-1] == 'unshift' or callee_name.split('.')[-1] == 'concat':
                                        calls.append((window_id, callee_name, script_id, timestamp, call_pos))
                                    continue

                                else:
                                    assignID = int(first_tuple)
                                    lhsFullString = split_list[1]
                                    rhsFullString = split_list[2]
                                    rhsType = split_list[3] # this is not typeof, but rhs_is_call, rhs_is_expr etc.
                                    scriptID = int(split_list[4])
                                    ##scriptURL = split_list[5]
                                    exprPos = int(split_list[5])
                                    timestamp = float(split_list[6])
                                    typeofLHS = split_list[7]
                                    valueofLHS = split_list[8]
                                    ptrofLHS = split_list[9]
                                    wholePtr = split_list[10]
                                    windowID = int(split_list[-1].split("\"")[0])

                                 

                                    # the end of the initialization of an object or a function
                                    if typeofLHS == 'object' and not lhsFullString.startswith('Yx$Q7r$zJUnQUy__') and not lhsFullString.startswith('this'):
                                        closed_obj_addrs.add(valueofLHS)
                                    elif typeofLHS == 'function' and '.' not in lhsFullString.split('-')[-1] and '[' not in lhsFullString.split('-')[-1] and not lhsFullString.startswith('Yx$Q7r$zJUnQUy__') and not lhsFullString.startswith('this'):
                                        closed_obj_addrs.add(ptrofLHS)



                                    # for a write to tmp.x or tmp[0], replace the lhs with ID.x or ID[0]
                                    original_lhsFullString = lhsFullString
                                    if lhsFullString.split('-')[-1].startswith('Yx$Q7r$zJUnQUy__'):
                                        if '.' in lhsFullString.split('-')[-1] and '[' in lhsFullString.split('-')[-1]:
                                            dot_index = lhsFullString.split('-')[-1].rfind('.')
                                            square_index = lhsFullString.split('-')[-1].rfind('[')
                                            r_square_index = lhsFullString.split('-')[-1].rfind(']')
                                            if r_square_index > dot_index:
                                                new_prop = ptrofLHS + '[' +  lhsFullString.split('-')[-1][square_index:].split('[')[-1].split(']')[0] + ']' #.split('[')[-1].split(']')[0] + ']' # for a-B-tmp[0], it's ID[0]
                                                lhsFullString = '-'.join(lhsFullString.split('-')[:-1]) + new_prop

                                            else:
                                                new_prop = ptrofLHS + '.' +  lhsFullString.split('-')[-1][dot_index:].split('.')[-1]  #'.'.join(lhsFullString.split('-')[-1].split('.')[1:]) # for a-B-tmp.x, it's ID.x
                                                lhsFullString = '-'.join(lhsFullString.split('-')[:-1]) + new_prop
                                        elif '.' in lhsFullString.split('-')[-1]:
                                            dot_index = lhsFullString.split('-')[-1].rfind('.')
                                            new_prop = ptrofLHS + '.' +  lhsFullString.split('-')[-1][dot_index:].split('.')[-1] #'.'.join(lhsFullString.split('-')[-1].split('.')[1:]) # for a-B-tmp.x, it's ID.x
                                            lhsFullString = '-'.join(lhsFullString.split('-')[:-1]) + new_prop
                                        elif '[' in lhsFullString.split('-')[-1]:
                                            square_index = lhsFullString.split('-')[-1].rfind('[')
                                            new_prop = ptrofLHS + '[' +  lhsFullString.split('-')[-1][square_index:].split('[')[-1].split(']')[0] + ']'#.split('[')[-1].split(']')[0] + ']' # for a-B-tmp[0], it's ID[0]
                                            lhsFullString = '-'.join(lhsFullString.split('-')[:-1]) + new_prop





                                    # only if it is writing to the whole var, do we need to check these
                                    if '.' not in lhsFullString.split('-')[-1] and '[' not in lhsFullString.split('-')[-1]:
                                        current_name = original_lhsFullString
                                        should_update_names = False
                                        if not current_name.startswith('Yx$Q7r$zJUnQUy__') and not current_name.startswith('this'):
                                            should_update_names = True
                                        elif not rhsFullString.split('(=)')[-1].split('=')[0].startswith('Yx$Q7r$zJUnQUy__') and not rhsFullString.split('(=)')[-1].split('=')[0].startswith('this') and rhsType == 'rhs_is_var':
                                            current_name = rhsFullString.split('(=)')[-1].split('=')[0]
                                            should_update_names = True
                                        if should_update_names:
                                            # the write is not to tmp.xxx
                                            # we should log the name, which is defined by the script itself
                                            if ptrofLHS != '---':
                                                if ptrofLHS not in addr2names:
                                                    addr2names[ptrofLHS] = list()
                                                addr2names[ptrofLHS].append(current_name)
                                                if len(current_name.split('-')) == 1 and '[' not in current_name and ']' not in current_name: 
                                                    #print('==>', current_name, ptrofLHS)
                                                    update_conflict_and_write_dict(current_name, ptrofLHS, target2infos, conflicts_info)


                                            if current_name in name2addr and ptrofLHS != name2addr[current_name] and ptrofLHS != '---':
                                                old_addr = name2addr[current_name]
                                                # there must be an element [current_name] in addr2names[old_addr], we should now delete it from addr2names
                                                try:
                                                    addr2names[old_addr].remove(current_name)
                                                except Exception as e:
                                                    print(addr2names)
                                                    print(name2addr)
                                                    print(current_name)
                                                if len(addr2names[old_addr]) == 0:
                                                    #for conflicting_target, infos in conflict_infos.items():

                                                    # there is no variable pointing to the old address
                                                    # that old address may be reclaimed later
                                                    # we should not be able to get the invalid writes to old_addr
                                                    ##for info in addr2infos[old_addr]:
                                                    ##    invalid_lines.add(info[11])
                                                    update_conflict_and_write_dict(current_name, old_addr, target2infos, conflicts_info)

                                                    try:
                                                        del addr2infos[old_addr]
                                                    except KeyError as e:
                                                        pass
                                                    try:
                                                        del addr2value[old_addr]
                                                    except KeyError as e:
                                                        pass
                                                    try:
                                                        del addr2obj2key[old_addr]
                                                    except KeyError as e:
                                                        pass
                                                    try:
                                                        closed_obj_addrs.remove(old_addr)
                                                    except Exception as e:
                                                        pass

                                            if ptrofLHS != '---':
                                                name2addr[current_name] = ptrofLHS
                                    else:
                                        # this is a write to a property
                                        # addr2value records both function and object values
                                        # but actually for functions, the literal is directly logged in the logs and we do not use addr2value to determine function literals in our analysis
                                        if ptrofLHS != '---':
                                            if '.' in lhsFullString.split('-')[-1]:
                                                prop_key = lhsFullString.split('.')[-1]
                                            else:
                                                prop_key = lhsFullString.split('[')[-1].split(']')[0]
                                            if valueofLHS in addr2value:
                                                prop_value = addr2value[valueofLHS]
                                            else:
                                                prop_value = valueofLHS

                                            if ptrofLHS not in addr2obj2key:
                                                addr2obj2key[ptrofLHS] = dict()
                                                addr2obj2key[ptrofLHS][prop_key] = prop_value
                                                obj_str = convert_obj_dict_to_literal_str(addr2obj2key[ptrofLHS])
                                                addr2value[ptrofLHS] = obj_str
                                                #print(addr2value)
                                                old_obj_str = '{}'
                                            else:
                                                old_obj_str = convert_obj_dict_to_literal_str(addr2obj2key[ptrofLHS])
                                                addr2obj2key[ptrofLHS][prop_key] = prop_value
                                                obj_str = convert_obj_dict_to_literal_str(addr2obj2key[ptrofLHS])
                                                addr2value[ptrofLHS] = obj_str
                                                #print(addr2value)

                                     

                                    # if it's a write to a property, i.e., tmp.x = ...
                                    # then this write will affect the object/function that tmp points to, e.g., 
                                    # script A has: 1) obj = {x:...}, and 2) t = obj.
                                    # script B has: 1) t.x = {...}.
                                    # both t and obj in A will be affected.
                                    # so we search for every previous writes to that object
                                    #if ('.' in lhsFullString  and lhsFullString.split('.')[0].startswith('Yx$Q7r$zJUnQUy__')) or ('[' in lhsFullString and lhsFullString.split('[')[0].startswith('Yx$Q7r$zJUnQUy__')):
                                    if '.' in lhsFullString.split('-')[-1] or '[' in lhsFullString.split('-')[-1]:
                                        if '.' in lhsFullString.split('-')[-1] and '[' in lhsFullString.split('-')[-1]:
                                            dot_index = lhsFullString.split('-')[-1].rfind('.')
                                            square_index = lhsFullString.split('-')[-1].rfind('[')
                                            r_square_index = lhsFullString.split('-')[-1].rfind(']')
                                            if r_square_index > dot_index:
                                                write_prop_key = lhsFullString.split('-')[-1][square_index:].split('[')[-1].split(']')[0]
                                            else:
                                                write_prop_key = lhsFullString.split('-')[-1][dot_index:].split('.')[-1]#'.'.join(lhsFullString.split('-')[-1].split('.')[1:])
                                        elif '.' in lhsFullString.split('-')[-1]:
                                            dot_index = lhsFullString.split('-')[-1].rfind('.')
                                            write_prop_key = lhsFullString.split('-')[-1][dot_index:].split('.')[-1] #'.'.join(lhsFullString.split('-')[-1].split('.')[1:])
                                        else:
                                            square_index = lhsFullString.split('-')[-1].rfind('[')
                                            write_prop_key = lhsFullString.split('-')[-1][square_index:].split('[')[-1].split(']')[0]

                                        if ptrofLHS in addr2infos:
                                            found_write_to_same_prop_key = False
                                            for info in reversed(addr2infos[ptrofLHS]):
                                                # info: (assignID, windowID, valueofLHS, rhsFullString, rhsType, scriptID, scriptURL, exprPos, timestamp, typeofLHS, lhsFullString, line_no))
                                                info_lhs = info[10]
                                                prev_write_value = info[2]
                                                if (info[9] == 'object' or info[9] == 'function') and info[2] in addr2value:
                                                    prev_write_value = addr2value[info[2]]
                                                    if old_obj_str is not None:
                                                        prev_write_value = old_obj_str
                                                cur_write_value = valueofLHS
                                                if (typeofLHS == 'object' or typeofLHS == 'function') and valueofLHS in addr2value:
                                                    cur_write_value = addr2value[valueofLHS]
                                                #if ('.' in info_lhs  and info_lhs.split('.')[0].startswith('Yx$Q7r$zJUnQUy__')) or ('[' in info_lhs and info_lhs.split('[')[0].startswith('Yx$Q7r$zJUnQUy__')):
                                                if '.' in info_lhs.split('-')[-1]  or '[' in info_lhs.split('-')[-1]:
                                                    if '.' in info_lhs.split('-')[-1] and '[' in info_lhs.split('-')[-1]:
                                                        dot_index = info_lhs.split('-')[-1].rfind('.')
                                                        square_index = info_lhs.split('-')[-1].rfind('[')
                                                        r_square_index = info_lhs.split('-')[-1].rfind(']')
                                                        if r_square_index > dot_index:
                                                            info_prop_key = info_lhs.split('-')[-1][square_index:].split('[')[-1].split(']')[0]
                                                        else:
                                                            info_prop_key = info_lhs.split('-')[-1][dot_index:].split('.')[-1]#'.'.join(info_lhs.split('-')[-1].split('.')[1:])
                                                    elif '.' in info_lhs:
                                                        dot_index = info_lhs.split('-')[-1].rfind('.')
                                                        info_prop_key = info_lhs.split('-')[-1][dot_index:].split('.')[-1]
                                                    else:
                                                        square_index = info_lhs.split('-')[-1].rfind('[')
                                                        info_prop_key = info_lhs.split('-')[-1][square_index:].split('[')[-1].split(']')[0]
                                                    if info_prop_key == write_prop_key:
                                                        found_write_to_same_prop_key = True
                                                        # there're more than one write to the same property of the same object/function
                                                        # now we need to check the type
                                                        if typeofLHS != info[9] and info[1] == windowID:
                                                            # different types, there's a type conflict on *tmp.x*
                                                            conflict_info = (assignID, windowID, cur_write_value, rhsFullString, rhsType, scriptID, wholePtr, exprPos, timestamp, typeofLHS, lhsFullString, info[0], prev_write_value, info[3], info[4], info[5], info[6], info[7], info[8], info[9], info[10], task, None)
                                                            if lhsFullString not in conflicts_info['type']:
                                                                conflicts_info['type'][lhsFullString] = list()
                                                            conflicts_info['type'][lhsFullString].append(conflict_info)
                                                            pass
                                                        elif typeofLHS == 'object' and info[9] == 'object':
                                                            # there're more than one assignments to tmp.x and both assign an object to tmp.x
                                                            # we need to check the object literal content
                                                            '''
                                                            obj_value_str = addr2value[valueofLHS]
                                                            if info[2] != obj_value_str and info[1] == windowID:
                                                            '''
                                                            obj_value_str = valueofLHS
                                                            if valueofLHS in addr2value:
                                                                obj_value_str = addr2value[valueofLHS]
                                                            if valueofLHS != info[2] and info[1] == windowID:
                                                                # value conflict on *tmp.x*
                                                                cur_write_value = valueofLHS
                                                                if valueofLHS in addr2value:
                                                                    cur_write_value = addr2value[valueofLHS]
                                                                suffix = construct_conflict_info_for_obj_values(valueofLHS, info[2], addr2value, calls, addr2names, windowID)
                                                                    
                                                                conflict_info = (assignID, windowID, cur_write_value, rhsFullString, rhsType, scriptID, wholePtr, exprPos, timestamp, typeofLHS, lhsFullString, info[0], prev_write_value, info[3], info[4], info[5], info[6], info[7], info[8], info[9], info[10], task, suffix)
                                                                if lhsFullString not in conflicts_info['value']:
                                                                    conflicts_info['value'][lhsFullString] = list()
                                                                conflicts_info['value'][lhsFullString].append(conflict_info)
                                                        else:
                                                            # there're more than one assignment to tmp.x and both assign a non-object value to tmp.x
                                                            # in this case, the value has been logged, we can directly use it to compare the value
                                                            if info[2] != valueofLHS and info[1] == windowID:
                                                                # the values are different, there's a value conflict on *tmp.x*
                                                                conflict_info = (assignID, windowID, cur_write_value, rhsFullString, rhsType, scriptID, wholePtr, exprPos, timestamp, typeofLHS, lhsFullString, info[0], prev_write_value, info[3], info[4], info[5], info[6], info[7], info[8], info[9], info[10], task, 'new_func_or_value_assigned')
                                                                if lhsFullString not in conflicts_info['value']:
                                                                    conflicts_info['value'][lhsFullString] = list()
                                                                conflicts_info['value'][lhsFullString].append(conflict_info)

                                                                pass
                                                        break
                                                else:
                                                    # previously there has already been a write to tmp
                                                    pass

                                            if not found_write_to_same_prop_key:
                                                # there has been at least one write to object/function tmp
                                                # but none of them writes tmp.x
                                                # so the current write assigns a new attribute x to object/function tmp
                                                # i.e., this is a value conflict on *tmp*
                                                for info in reversed(addr2infos[ptrofLHS]):
                                                    info_lhs = info[10]
                                                    prev_write_value = info[2]
                                                    if (info[9] == 'object' or info[9] == 'function') and info[2] in addr2value:
                                                        prev_write_value = addr2value[info[2]]
                                                        if old_obj_str is not None:
                                                            prev_write_value = old_obj_str
                                                    cur_write_value = valueofLHS
                                                    if (typeofLHS == 'object' or typeofLHS == 'function') and valueofLHS in addr2value:
                                                        cur_write_value = addr2value[valueofLHS]
                                                    if ('.' in info_lhs  and info_lhs.split('.')[0].startswith('Yx$Q7r$zJUnQUy__')) or ('[' in info_lhs and info_lhs.split('[')[0].startswith('Yx$Q7r$zJUnQUy__')):
                                                        pass
                                                    elif info[1] == windowID and ptrofLHS in closed_obj_addrs:
                                                        conflict_info = (assignID, windowID, cur_write_value, rhsFullString, rhsType, scriptID, wholePtr, exprPos, timestamp, typeofLHS, lhsFullString, info[0], prev_write_value, info[3], info[4], info[5], info[6], info[7], info[8], info[9], info[10], task, 'add_new_attribute')
                                                        if '.' in lhsFullString.split('-')[-1] and '[' in lhsFullString.split('-')[-1]:
                                                            dot_index = lhsFullString.split('-')[-1].rfind('.')
                                                            square_index = lhsFullString.split('-')[-1].rfind('[')
                                                            r_square_index = lhsFullString.split('-')[-1].rfind(']')
                                                            if r_square_index > dot_index:
                                                                conflicting_target = lhsFullString.split('-')[-1][:square_index]#.split('[')[0]
                                                                prefix = '-'.join(lhsFullString.split('-')[:-1])
                                                                if len(prefix) > 0:
                                                                    prefix += '-'
                                                                conflicting_target = prefix + conflicting_target

                                                            else:
                                                                conflicting_target = lhsFullString.split('-')[-1][:dot_index]#.split('.')[0]
                                                                prefix = '-'.join(lhsFullString.split('-')[:-1])
                                                                if len(prefix) > 0:
                                                                    prefix += '-'
                                                                conflicting_target = prefix + conflicting_target
                                                        elif '[' in lhsFullString.split('-')[-1]:
                                                            square_index = lhsFullString.split('-')[-1].rfind('[')
                                                            conflicting_target = lhsFullString.split('-')[-1][:square_index]#.split('[')[0]
                                                            prefix = '-'.join(lhsFullString.split('-')[:-1])
                                                            if len(prefix) > 0:
                                                                prefix += '-'
                                                            conflicting_target = prefix + conflicting_target
                                                        elif '.' in lhsFullString.split('-')[-1]:
                                                            dot_index = lhsFullString.split('-')[-1].rfind('.')
                                                            conflicting_target = lhsFullString.split('-')[-1][:dot_index]#.split('.')[0]
                                                            prefix = '-'.join(lhsFullString.split('-')[:-1])
                                                            if len(prefix) > 0:
                                                                prefix += '-'
                                                            conflicting_target = prefix + conflicting_target
                                                        if conflicting_target in addr2names and len(addr2names[conflicting_target]) > 0:
                                                            conflicting_target = addr2names[conflicting_target][0]
                                                        if conflicting_target not in conflicts_info['value']:
                                                            conflicts_info['value'][conflicting_target] = list()
                                                        conflicts_info['value'][conflicting_target].append(conflict_info)
                                                        #print('3-[][][]', conflicting_target, conflict_info)
                                                        break
                                                

                                    # if it's simply a write to a variable, i.e., var = ...
                                    # even if the type is 'object'/'function', we only need to search for the writes to the same name, e.g., 
                                    # script A has: 1) obj = {...}, and 2) t = obj.
                                    # script B has: 1) t = {...}.
                                    # in this case, the write in B will only affect t in A, but not obj in A.
                                    # so we only search for previous writes to the same name
                                    else:
                                        if lhsFullString in target2infos:
                                            for info in reversed(target2infos[lhsFullString]):
                                                # info: (assignID, windowID, valueofLHS, rhsFullString, rhsType, scriptID, scriptURL, exprPos, timestamp, typeofLHS, ptrofLHS)
                                                prev_write_value = info[2]
                                                if (info[9] == 'object' or info[9] == 'function') and info[2] in addr2value:
                                                    prev_write_value = addr2value[info[2]]
                                                    if old_obj_str is not None:
                                                        prev_write_value = old_obj_str

                                                cur_write_value = valueofLHS
                                                if (typeofLHS == 'object' or typeofLHS == 'function') and valueofLHS in addr2value:
                                                    cur_write_value = addr2value[valueofLHS]

                                                if info[9] != typeofLHS and info[1] == windowID:
                                                    # type conflict on *var*
                                                    conflict_info = (assignID, windowID, cur_write_value, rhsFullString, rhsType, scriptID, wholePtr, exprPos, timestamp, typeofLHS, lhsFullString, info[0], prev_write_value, info[3], info[4], info[5], info[6], info[7], info[8], info[9], info[10], task, None)
                                                    if lhsFullString not in conflicts_info['type']:
                                                        conflicts_info['type'][lhsFullString] = list()
                                                    conflicts_info['type'][lhsFullString].append(conflict_info)

                                                    pass
                                                elif typeofLHS == 'object' and info[9] == 'object':
                                                    # we need to check the object literal value
                                                    if info[2] != valueofLHS and info[1] == windowID:
                                                        # value conflict on *tmp*      
                                                        suffix = construct_conflict_info_for_obj_values(valueofLHS, info[2], addr2value, calls, addr2names, windowID)
                                                        conflict_info = (assignID, windowID, cur_write_value, rhsFullString, rhsType, scriptID, wholePtr, exprPos, timestamp, typeofLHS, lhsFullString, info[0], prev_write_value, info[3], info[4], info[5], info[6], info[7], info[8], info[9], info[10], task, suffix)
                                                        if lhsFullString not in conflicts_info['value']:
                                                            conflicts_info['value'][lhsFullString] = list()
                                                        conflicts_info['value'][lhsFullString].append(conflict_info)

                                                        pass
                                                else:
                                                    # we can directly use the value logged in the logs
                                                    if info[2] != valueofLHS and info[1] == windowID:
                                                        # value conflict on *tmp*
                                                        conflict_info = (assignID, windowID, cur_write_value, rhsFullString, rhsType, scriptID, wholePtr, exprPos, timestamp, typeofLHS, lhsFullString, info[0], prev_write_value, info[3], info[4], info[5], info[6], info[7], info[8], info[9], info[10], task, 'new_func_or_value_assigned')
                                                        if lhsFullString not in conflicts_info['value']:
                                                            conflicts_info['value'][lhsFullString] = list()
                                                        conflicts_info['value'][lhsFullString].append(conflict_info)
                                                        pass
                                                # only check the last previous write to tmp
                                                break

    


                                    if typeofLHS == 'function':
                                        if lhsFullString not in defined_funcs:
                                            defined_funcs[lhsFullString] = dict()
                                        if windowID not in defined_funcs[lhsFullString]:
                                            defined_funcs[lhsFullString][windowID] = list()
                                        defined_funcs[lhsFullString][windowID].append((assignID, scriptID, wholePtr, timestamp))

                                    if lhsFullString not in target2infos:
                                        target2infos[lhsFullString] = list()
                                    target2infos[lhsFullString].append((assignID, windowID, valueofLHS, rhsFullString, rhsType, scriptID, wholePtr, exprPos, timestamp, typeofLHS, ptrofLHS))                                                      
                                    if ptrofLHS not in addr2infos:
                                        addr2infos[ptrofLHS] = list()
                                    addr2infos[ptrofLHS].append((assignID, windowID, valueofLHS, rhsFullString, rhsType, scriptID, wholePtr, exprPos, timestamp, typeofLHS, lhsFullString, line_no))



                                 
                            except Exception as e:
                                print('\n')
                                print(rank)   
                                try:
                                    exc_type, exc_value, exc_traceback = sys.exc_info()
                                    lines_ = traceback.format_exception(exc_type, exc_value, exc_traceback)
                                    print(''.join('!! ' + line_ for line_ in lines_))
                                    sys.stdout.flush()
                                except Exception:
                                    pass
                                continue

                    #endtime = time.time()
                    #print('finish in %f'%(endtime-starttime))

                    task_list = task.split('.')
                    mid_str = task_list[0] + '.' + task_list[1] + '.' + task_list[2]

                    for addr, names in addr2names.items():
                        if len(names) == 0:
                            continue
                        new_name = names[0]
                        for name in names:
                            if len(name.split('-')) == 1 and '[' not in name and ']' not in name:
                                new_name = name
                                break
                        update_conflict_and_write_dict(new_name, addr, target2infos, conflicts_info)

                    output_file = mid_str + '-assign.json'
                    output_file = os.path.join(raw_input_dir, output_file)
                    output_file = os.path.join(processed_data_dir, output_file)
                    with open(output_file, 'w') as output_f:
                        output_f.write(json.dumps(target2infos))
                    del target2infos
                    
                    output_file = mid_str + '-addr2infos.json'
                    output_file = os.path.join(raw_input_dir, output_file)
                    output_file = os.path.join(processed_data_dir, output_file)
                    with open(output_file, 'w') as output_f:
                        output_f.write(json.dumps(addr2infos))
                    del addr2infos

                   

                    if len(conflicts_info['type']) > 0 or len(conflicts_info['value']) > 0:
                        output_file = mid_str + '-conflicts.json'
                        output_file = os.path.join(raw_input_dir, output_file)
                        output_file = os.path.join(processed_data_dir, output_file)
                        print(output_file)
                        #print(addr2names)
                        with open(output_file, 'w') as output_f:
                            output_f.write(json.dumps(conflicts_info))

                    del conflicts_info
                    del calls


                    output_file = mid_str + '-functions.json'
                    output_file = os.path.join(raw_input_dir, output_file)
                    output_file = os.path.join(processed_data_dir, output_file)
                    with open(output_file, 'w') as output_f:
                        output_f.write(json.dumps(defined_funcs))
                    del defined_funcs

                    print('end %d'%(rank))


                except OSError as e:
                    pass
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
    processed_data_dir = os.path.join(exp_dir, 'processed_data')
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

    #print(conflicting_rank_set)



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

