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
#new_script_hash = hmac.new(MAC_KEY, page)






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



def determine_parameter_position(f, line_number, funcID, funcName, scriptID_, scriptURL_, windowID_):
    next_line = f[line_number][1:]
    while ',--,' in f[line_number][1:]:
        split_list = f[line_number][1:].split(",elem_js_conflict,")
        if split_list[-2].split("\"")[0]:
            functionID = int(split_list[-2].split("\"")[0])
        else:
            functionID = -1
        functionName = split_list[-3]
        if functionID != funcID or functionName != funcName:
            return (None, None)
        line_number += 1

    next_line = f[line_number][1:]
    split_list = next_line.split(",elem_js_conflict,")
    first_tuple = split_list[0]
    if first_tuple == '*** start_of_func':
        if split_list[-3]:
            functionID = int(split_list[-3])
        else:
            functionID = -1
        windowID = int(split_list[-1])
        functionName = split_list[-4]
        if (funcID == functionID and funcID != -1) or funcName == functionName or funcName.split('.')[-1] == functionName or funcName.split('[')[0] == functionName or funcName.split('-')[-1] == functionName:
            functionEndPos = int(split_list[-5])
            functionStartPos = int(split_list[-6])
            #functions_list.append((functionName, functionID)) #, functionStartPos, functionEndPos))
            scriptID = int(split_list[1])
            scriptURL = split_list[2]
            if scriptID == scriptID_ and scriptURL == scriptURL_ and windowID == windowID_:
                return (functionStartPos, functionEndPos)
            else:
                return (None, None)
    else:
        return (None, None)
    


def update_write_stack_using_alias(alias_target, alias, write_stack, position_tuple = None):
    # alias: (alias_name, rhsFullString, assignID, windowID, scriptID, scriptURL, exprPos)
    write_index = 0
    #for write in write_stack:
    while write_index < len(write_stack):
        write = write_stack[write_index]
        # write: (assignID, windowID, lhsFullString, rhsFullString, rhsType, scriptID, scriptURL, exprPos, typeofLHS)
        target = write[2]
        if alias[0] == target or alias[0] in re.split(r'\[|\]|\.', target): #target.split('.') or alias[0] in target.split('['):
            window_id = write[1]
            script_id = write[-4]
            script_url = write[-3]
            alias_window_id = alias[3]
            alias_script_id = alias[-3]
            alias_script_url = alias[-2]
            #print('write', write)
            #print('alias', alias)
            if window_id == alias_window_id and script_id == alias_script_id and script_url == alias_script_url and write[3] != alias[1]:
                alias_write_target = target.replace(alias[0], alias_target)
                alias_write = (write[0], write[1], alias_write_target, write[3], write[4], write[5], write[6], write[7], write[8])
                #print(' ==>', alias_write)
                #print('- - - - - - - - - - - - - -')
                move_index = len(write_stack)
                for write_ in reversed(write_stack):
                    move_index -= 1
                    if move_index == write_index:
                        break
                    if move_index == len(write_stack)-1:
                        write_stack.append(write_stack[move_index])
                    else:
                        write_stack[move_index+1] = write_stack[move_index]
               
                if move_index == len(write_stack)-1:
                    write_stack.append(alias_write)
                else:
                    write_stack[move_index+1] = alias_write

                if write[-1] == 'object' and ('(=)' in write[3] or '=)' not in write[3]):
                    recurse_alias_name = write[3].split('(=)')[-1].split('=')[0]
                    recurse_alias_target = alias_target
                    recurse_alias = (recurse_alias_name, recurse_alias_name, write[0], write[-4], write[-3], write[-2])
                    #print('recursion', recurse_alias_target, recurse_alias)
                    update_write_stack_using_alias(recurse_alias_target, recurse_alias, write_stack)
                
                #if write[3].split('(=)')[-1].split('=')[0]


        write_index += 1











def update_write_dict_using_alias(alias_target, alias, write_dict):

    # alias: (alias_name, rhsFullString, assignID, windowID, scriptID, scriptURL, exprPos)
    alias_assign_id = alias[2]
    replace_start_assign_id = None
    replace_end_assign_id = None
    if alias_target in write_dict:
        for write_ in reversed(write_dict[alias_target]):
            # write_: (assignID, windowID, rhsFullString, rhsType, scriptID, scriptURL, exprPos, typeofLHS)
            assign_id_ = write_[0]
            rhs_full_string_ = write_[2]
            if assign_id_ < alias_assign_id and ('(=)' in rhs_full_string_ or '=)' not in rhs_full_string_):
                replace_start_assign_id = assign_id_
                break
        for write_ in write_dict[alias_target]:
            # write_: (assignID, windowID, rhsFullString, rhsType, scriptID, scriptURL, exprPos, typeofLHS)
            assign_id_ = write_[0]
            rhs_full_string_ = write_[2]
            if assign_id_ > alias_assign_id and ('(=)' in rhs_full_string_ or '=)' not in rhs_full_string_):
                replace_end_assign_id = assign_id_
                break

    #print('alias_target: %s\tstart_index: %s'%(alias_target, str(replace_start_assign_id)))
    #print('alias_target: %s\tend_index: %s'%(alias_target, str(replace_end_assign_id)))


    # if replace_start_assign_id is not None, we should replace alias_name with alias_target for assignments with ID > replace_start_assign_id and < alias_assign_id
    # if replace_start_assign_id is None, we replace alias_name with alias_target for all assignments with ID < alias_assign_id
    for write_target, write_list in write_dict.items():
        for write in write_list:
            # write: (assignID, windowID, rhsFullString, rhsType, scriptID, scriptURL, exprPos, typeofLHS)
            if write_target == alias[0] or alias[0] in re.split(r'\[|\]|\.', write_target): #alias[0] in write_target.split('.') or alias[0] in write_target.split('[')
                if (replace_start_assign_id is not None and write[0] > replace_start_assign_id and write[0] < alias_assign_id) or (replace_start_assign_id is None and write[0] < alias_assign_id):
                    if write[1] == alias[3]:
                        alias_write_target = write_target.replace(alias[0], alias_target)
                        if alias_write_target not in write_dict:
                            write_dict[alias_write_target] = list()
                        write_dict[alias_write_target].append((alias_assign_id, write[1], write[2], write[3], write[4], write[5], write[6], write[7]))
                        #print('==>', alias_assign_id, alias_write_target, write_target, write)


    # if replace_end_assign_id is not None, we should replace alias_name with alias_target, and alias_target with alias_name
    # for assignments with ID > alias_assign_id and < replace_end_assign_id
    # if replace_end_assign_id is None, we replace alias_name with alias_target, and alias_target with alias_name
    # for assignments with ID > alias_assign_id
    for write_target, write_list in write_dict.items():
        for write in write_list:
            # write: (assignID, windowID, rhsFullString, rhsType, scriptID, scriptURL, exprPos, typeofLHS)
            alias_write_target = None
            if (write_target == alias[0] or alias[0] in re.split(r'\[|\]|\.', write_target)) and write[1] == alias[3]:
                if (replace_end_assign_id is not None and write[0] > alias_assign_id and write[0] < replace_end_assign_id) or (replace_end_assign_id is None and write[0] > alias_assign_id):
                    alias_write_target = write_target.replace(alias[0], alias_target)
            if (write_target == alias_target or alias_target in re.split(r'\[|\]|\.', write_target)) and write[1] == alias[3]:
                if (replace_end_assign_id is not None and write[0] > alias_assign_id and write[0] < replace_end_assign_id) or (replace_end_assign_id is None and write[0] > alias_assign_id):
                    alias_write_target = write_target.replace(alias_target, alias[0])
            if alias_write_target is not None:
                if alias_write_target not in write_dict:
                    write_dict[alias_write_target] = list()
                write_dict[alias_write_target].append((alias_assign_id, write[1], write[2], write[3], write[4], write[5], write[6], write[7]))
                #print('==>', alias_assign_id, alias_write_target, write_target, write)



def update_write_stack_using_args(start, end, before, after, write_stack, call_stack):
    # write: (assignID, windowID, lhsFullString, rhsFullString, rhsType, scriptID, scriptURL, exprPos, tpyeofLHS)
    index = len(write_stack)
    matched = False
    for write in reversed(write_stack):
        index -= 1
        target = write[2]
        if before not in target:
            continue
        writePos = write[-2]
        if writePos <= end and writePos >= start:
            matched = True
            new_write = (write[0], write[1], write[2].replace(before, after), write[3], write[4], write[5], write[6], write[7], write[8])
            write_stack[index] = new_write
        else:
            if matched == True:
                break








def update_write_dict_using_args(start, end, before, after, write_dict, call_stack):
    for target, write_list in write_dict.items():
        if target != before:
            continue
        new_write_dict = dict()
        new_write_list = list()
        for write in write_list:
            writePos = int(write[-2])
            located_function = locate_function(writePos, call_stack)
            newWriteKey = after
            if located_function is not None:
                if located_function[0]:
                    thisAlias = located_function[1]
                    if 'this' in argumentName:
                        newWriteKey = after.replace('this', thisAlias)
                elif located_function[2]:
                    newAlias = located_function[3]
                    if 'this' in argumentName:
                        newWriteKey = after.replace('this', newAlias)
            if writePos >= start and writePos <= end:
                new_write_list.append(write)
                if newWriteKey not in new_write_dict:
                    new_write_dict[newWriteKey] = list()
                new_write_dict[newWriteKey].append(write)

        #write_dict.pop(target, None)
        for newWriteKey, updated_write_list in new_write_dict.items():
            if newWriteKey not in write_dict:
                write_dict[newWriteKey] = updated_write_list
            else:
                for new_write in updated_write_list:
                    write_dict[newWriteKey].append(new_write)
        unchanged_write_list = [write for write in write_list if write not in new_write_list]
        if len(unchanged_write_list) > 0:
            write_dict[before] = unchanged_write_list
        else:
            write_dict.pop(target, None)



def update_write_stack_using_new_temp(var_name, write_stack, func_id, func_name, window_id, script_id, script_url, call_stack):
    # write: (assignID, windowID, lhsFullString, rhsFullString, rhsType, scriptID, scriptURL, exprPos, tpyeofLHS)
    index = len(write_stack)
    matched = False
    for write in reversed(write_stack):
        index -= 1
        target = write[2]
        if 'this' not in target:
            continue
        writePos = write[-2]
        located_function = locate_function(writePos, call_stack)
        #print('==> ', write, writePos, located_function, len(call_stack))
        if located_function is not None:
            # located_function: (isObjCall, thisAlias, isObjNew, newAlias, functionID, functionName, windowID, scriptID, scriptURL, functionStartPos, functionEndPos)
            funcName = located_function[5]
            funcID = located_function[4]
            windowID = located_function[6]
            scriptID = located_function[7]
            scriptURL = located_function[8]
            #print('  ==> ', funcName, funcID, windowID, scriptID, scriptURL)
            #print('  ==> ', func_name, func_id, window_id, script_id, script_url)
            if (funcName == func_name or funcName == func_name.split('.')[-1] or funcName == func_name.split('[')[0] or funcName == func_name.split('-')[-1]) and scriptID == script_id and scriptURL == script_url and windowID == window_id:
                if (func_id is not None and func_id == funcID) or func_id is None:
                    matched = True
                    new_write = (write[0], write[1], write[2].replace('this', var_name), write[3], write[4], write[5], write[6], write[7], write[8])
                    write_stack[index] = new_write
                elif matched == True:
                    break
            elif matched == True:
                break


def locate_function(exprPos, call_stack):
    for call in reversed(call_stack):
        functionStartPos = int(call[-2])
        functionEndPos = int(call[-1])
        #print(exprPos, functionStartPos, functionEndPos)
        if exprPos <= functionEndPos and exprPos >= functionStartPos:
            return call
    return None


def locate_obj_call_or_obj_new(exprPos, obj_stack):
    pass





def pop_param_args_dict(param2args, poped_call):
    # poped_call: (isObjCall, thisAlias, isObjNew, newAlias, functionID, functionName, windowID, scriptID, scriptURL, functionStartPos, functionEndPos)
    poped_func_id = poped_call[4]
    poped_func_name = poped_call[5]
    poped_window_id = poped_call[6]
    poped_script_id = poped_call[7]
    poped_script_url = poped_call[8]

    for param2arg in reversed(param2args):
        # param2arg: (paramName, assignID, windowID, argumentName, argumentIndex, scriptID, scriptURL, functionID, functionName, functionStartPos, functionEndPos, argumentPos, typeof)
        arg_func_id = param2arg[7]
        arg_func_name = param2arg[8]
        arg_window_id = param2arg[2]
        arg_script_id = param2arg[5]
        arg_script_url = param2arg[6]

        if ((arg_func_id == poped_func_id and arg_func_id != -1) or arg_func_name == poped_func_name or poped_func_name == arg_func_name.split('.')[-1] or poped_func_name == arg_func_name.split('[')[0] or poped_func_name == arg_func_name.split('-')[-1]) and arg_window_id == poped_window_id and arg_script_id == poped_script_id and arg_script_url == poped_script_url:
            param2args.remove(param2arg)



def pop_call_stack(startPos, endPos, call_stack, param2args):
    if len(call_stack) > 0:
        last_call = call_stack[-1]
        if endPos is  None:
            if startPos < int(last_call[-2]) or startPos > int(last_call[-1]):
                poped_call = call_stack.pop()
                print('poped_call', startPos, endPos, poped_call)
                pop_param_args_dict(param2args, poped_call)
        else:
            if endPos < int(last_call[-2]) or startPos > int(last_call[-1]):
                poped_call = call_stack.pop() 
                print('poped_call', startPos, endPos, poped_call)
                pop_param_args_dict(param2args, poped_call)




def determine_direct_call_or_not(func_id, func_name, window_id, script_id, script_url, input_f, line_number, valid_first_tuple_list, arg_is_valid):
    #print('\n\n')
    while line_number <= len(input_f):
        next_line = input_f[line_number][1:]
        #print(next_line)
        split_list = next_line.split(',elem_js_conflict,')
        first_tuple = split_list[0]
        if first_tuple == '*** start_of_func':
            if split_list[-3]:
                functionID = int(split_list[-3])
            else:
                functionID = -1
            windowID = int(split_list[-1])
            functionName = split_list[-4]
            scriptID = int(split_list[1])
            scriptURL = split_list[2]
            if (func_name == functionName or functionName == func_name.split('.')[-1] or functionName == func_name.split('[')[0] or functionName == func_name.split('-')[-1]) and windowID == window_id and scriptID == script_id and scriptURL == script_url:
                if func_id is not None:
                    if func_id == functionID:
                        return True
                    else:
                        return False
                else:
                    return True


        if first_tuple in valid_first_tuple_list:
            if first_tuple == 'is_new_temp':
                windiowID = int(split_list[-1])
                if split_list[2]:
                    functionID = int(split_list[2])
                else:
                    functionID = -1
                functionName = split_list[1]
                scriptID = int(split_list[-4])
                scriptURL = split_list[-3]
                if scriptID == script_id and windowID == window_id and scriptURL == script_url and func_name == functionName:
                    if func_id is not None and func_id != functionID:
                        return False
                else:
                    return False


            elif first_tuple == 'is_keyed_obj_new' or first_tuple == 'is_named_obj_new' or first_tuple == 'is_named_obj_call' or first_tuple == 'is_keyed_obj_call':
                windowID = int(split_list[-1])
                scriptURL = split_list[-3]
                scriptID = int(split_list[-4])
                callKey = split_list[1]
                callValue = split_list[2]
                if first_tuple == 'is_keyed_obj_new' or first_tuple == 'is_keyed_obj_call':
                    functionName = callKey + '[' + callValue + ']'
                else:
                    functionName = callKey + '.' + callValue
                if scriptID == script_id and windowID == window_id and scriptURL == script_url and func_name == functionName:
                    if func_id is not None and func_id != functionID:
                        return False
                else:
                    return False


        elif arg_is_valid and ',--,' in next_line:
            windowID = int(split_list[-1])
            if split_list[-2].split("\"")[0]:
                functionID = int(split_list[-2].split("\"")[0])
            else:
                functionID = -1
            functionName = split_list[-3]
            scriptURL = split_list[-6]
            scriptID = int(split_list[-7])
            if scriptID == script_id and windowID == window_id and scriptURL == script_url and func_name == functionName:
                if func_id is not None and func_id != functionID:
                    return False
            else:
                return False
           
        else:
            return False
        line_number += 1

    return False


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
        rank2func_files = dict()
        for f in file_list:
            if f.endswith('.func'):
                split_list = f.split('.')
                rank = int(split_list[0])
                if rank not in rank2func_files:
                    rank2func_files[rank] = list()
                rank2func_files[rank].append(f)


        output_dir = os.path.join(processed_data_dir, raw_input_dir)
        finished_files = os.listdir(output_dir)
        finished_files = [f for f in finished_files if f.endswith('-defined_func.json')]
        #files = [f for f in file_list if f.endswith('.func')]
        for f in finished_files:
            rank = int(f.split('-')[0])
            processed_list.add(rank)


        raw_output_dir = os.path.join(processed_data_dir, raw_input_dir)
        if not os.path.isdir(raw_output_dir):
            os.mkdir(raw_output_dir)

        for rank, func_files in rank2func_files.items():
            #rank = int(task.split('.')[0])
            if rank > end:
                #print('rank > end')
                continue
            if rank % num_instances != task_id or rank in processed_list or rank < start:
                print('finished %d'%(rank))
                continue
            window2scriptID2func = dict()
            #print('\n\n')
            try:
                for task in func_files:
                    try:
                        task_file = os.path.join(input_dir, task)
                        #print(task_file)
                        with open(task_file, 'r') as input_f:
                            for line in input_f:
                                #line = line.split("\"")[-1]
                                try:
                                    line_split = line.split('\n')[0].split('\t')
                                    function_name = line_split[0]
                                    start_position = int(line_split[1])
                                    end_position = int(line_split[2])
                                    script_url = line_split[3]
                                    timestamp = float(line_split[4])
                                    script_id = int(line_split[5])
                                    context_id = line_split[6]
                                    if context_id not in window2scriptID2func:
                                        window2scriptID2func[context_id] = dict()
                                    if script_id not in window2scriptID2func[context_id]:
                                        window2scriptID2func[context_id][script_id] = list()
                                    func_info = (function_name, start_position, end_position, script_url, timestamp, task)
                                    window2scriptID2func[context_id][script_id].append(func_info)
                                except Exception as e:
                                    try:
                                         exc_type, exc_value, exc_traceback = sys.exc_info()
                                         lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
                                         print(''.join('!! ' + line for line in lines))
                                         sys.stdout.flush()
                                    except Exception:
                                         pass

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

                output_file = str(rank) + '-defined_func.json'
                output_file = os.path.join(raw_input_dir, output_file)
                output_file = os.path.join(processed_data_dir, output_file)
                if len(window2scriptID2func) > 0:
                    print(output_file)
                with open(output_file, 'w') as output_f:
                    output_f.write(json.dumps(window2scriptID2func))

            except KeyboardInterrupt as e:
                kill_all_processes()
            except Exception as e:
                status = 'Process %-4d task %s/%s raised an exception %s when processing URL [%d].' % (process_index, task_id+1, length, type(e), rank)
                status_queue.put([process_index, status])
                string = '%s\t%s' % (getlocaltime(), status)
                try:
                    print(task_file)
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
    print(tab + '-t | --type=')
    print(tab*2 + 'Input type, [url2index|info2index2script] default "url2index"')

if __name__ == '__main__':
    main(sys.argv[1:])

