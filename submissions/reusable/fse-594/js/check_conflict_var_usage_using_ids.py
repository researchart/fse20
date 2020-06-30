import sys, codecs, json, re, time, os, getopt, traceback
import signal, psutil, tldextract
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



def is_same_organization(_host, hostname):

    if _host is None or hostname is None:
        return False
    _ext = extract(_host)
    ext = extract(hostname)
    if ext.domain == _ext.domain:
        return True
    else:
        return False


def determine_script_privilege(url, first_party_domain):
    global host2domain, extract
    
    script_priv = -1
    parse = urlparse(url)
    script_host = parse.hostname
        
    ext = extract(script_host)
    script_domain = ext.domain
    
    if script_domain == first_party_domain:
        script_priv = 1
    else:
        script_priv = 3
    return script_priv


def find_script_url_using_id(script_id, asg_file, raw_input_dir):
    global raw_dir

    script_url = None
    raw_input_dir = raw_input_dir.replace('_analysis', '_logs')
    id2url_file = asg_file.replace('.asg', '.id2url')
    id2url_file = os.path.join(raw_input_dir, id2url_file)
    id2url_file = os.path.join(raw_dir, id2url_file)
    if os.path.isfile(id2url_file):
        with open(id2url_file, 'r') as id2url_input_f:
            for id2url_line in id2url_input_f:
                if id2url_line.split(',')[0] == str(script_id):
                    script_url = (','.join(id2url_line.split(',')[1:])).split('\n')[0]
                    break
    if script_url is None:
        script_source_file = asg_file.replace('.asg', '.%d.script'%(script_id))
        script_source_file = os.path.join(raw_input_dir, script_source_file)
        script_source_file = os.path.join(raw_dir, script_source_file)
        if os.path.isfile(script_source_file): 
            with open(script_source_file, 'r') as scriptsource_input_f:
                for script_source_line in scriptsource_input_f:
                    script_url = script_source_line.split('\n')[0]
                    break
    return script_url



def measure(user_dir, task_id, length, start, end, status_queue, process_index):
    global processed_data_dir, conflicting_rank_set, raw_dir, rank2url, domain2hosts, host2domain, extract, domain2ns, domain2soa, ns_domain2hosts, ns_host2domain, dynamic_dns_list, managed_dns_re, extract, raw_logs_dir


    current_pid = os.getpid()
    current_dir = os.getcwd()
    try:
        status = 'Process %-4d task %d/%d PID [%d] starting ...' % (process_index, task_id+1, length, current_pid)
        status_queue.put([process_index, status])
        #print(status)

        result_dict = dict()
        processed_list = set()

        raw_input_dir = user_dir + '_analysis'
        input_dir = os.path.join(current_dir, raw_input_dir)
        file_list = os.listdir(input_dir)
        files = [f for f in file_list if f.endswith('-category2target2type2script2infos.json')]


        finished_files = os.listdir(input_dir)
        finished_files = [f for f in finished_files if f.endswith('-used-category2type2target2infos.json')]
        for f in finished_files:
            rank = int(f.split('-')[0])
            processed_list.add(rank)

        raw_assign_dir = user_dir + '_logs'
        raw_assign_dir = os.path.join(raw_dir, raw_assign_dir)
        assign_files = os.listdir(raw_assign_dir)
        assign_files = [f for f in assign_files if f.endswith('.asg')]
        rank2assign_files = dict()
        for assign_file in assign_files:
            rank = int(assign_file.split('.')[0])
            if rank not in rank2assign_files:
                rank2assign_files[rank] = list()
            rank2assign_files[rank].append(assign_file)

        raw_output_dir = os.path.join(processed_data_dir, raw_input_dir)
        if not os.path.isdir(raw_output_dir):
            os.mkdir(raw_output_dir)

        for task in files:
            try:
                rank = int(task.split('-')[0])
            except ValueError as e:
                print(e)
                continue
            if rank > end:
                #print('rank > end')
                continue
            #if rank % num_instances != task_id or rank in processed_list or rank < start:
            if rank % num_instances != task_id or rank < start:
                #print('passed %d'%(rank))
                continue
            output_file = str(rank) + '-used-category2type2target2infos.json'
            output_file = os.path.join(input_dir, output_file)


            first_party_url = rank2url[rank]
           
            parse = urlparse(first_party_url)
            first_party_host = parse.hostname       
            ext = extract(first_party_host)
            first_party_domain = ext.domain

            should_write_to_file = False
            try:
                try:
                    cat2target2type2script2infos = dict()
                    cat2type2target2infos = dict()
                    cat2used_type2target2infos = dict()


                    task_file = os.path.join(input_dir, task)
                    with open(task_file, 'r') as input_f:
                        cat2target2type2script2infos = json.loads(input_f.read())
                    for cat, target2type2script2infos in cat2target2type2script2infos.items():
                        if cat not in cat2type2target2infos:
                            cat2type2target2infos[cat] = dict()
                        for target, type2script2infos in target2type2script2infos.items():
                            for type_, script2infos in type2script2infos.items():
                                if type_ not in cat2type2target2infos[cat]:
                                    cat2type2target2infos[cat][type_] = dict()
                                if target not in cat2type2target2infos[cat][type_]:
                                    cat2type2target2infos[cat][type_][target] = list()
                                for script, infos in script2infos.items():
                                    for info in infos:
                                        cat2type2target2infos[cat][type_][target].append(info)


                    #print(cat2type2target2infos)
                    raw_assign_file_list = rank2assign_files[rank]
                    should_ignore_funcs = False
                    map_file_dir = user_dir + '_logs'
                    map_file_dir = os.path.join(current_dir, map_file_dir)
                    for raw_assign_file in raw_assign_file_list:
                        raw_assign_file = os.path.join(raw_assign_dir, raw_assign_file)
                        with open(raw_assign_file, 'r') as input_f:
                            assign_logs = input_f.read()
                        assign_logs = assign_logs.split('\tscript_conflicts\n')


                        for cat, type2target2infos in cat2type2target2infos.items():
                            if cat not in cat2used_type2target2infos: #cat2type2target2usages = dict()
                                cat2used_type2target2infos[cat] = dict()
                            for type_, target2infos in type2target2infos.items():
                                for target, infos in target2infos.items():
                                    for info in infos:
                                        # info: (assign_id_1, window_id, value_1, rhs_1, rhs_type_1, script_id_1, script_url_1, pos_1, timestamp_1, typeof_1, lhs_1, assign_id_2, value_2, rhs_2, rhs_type_2, script_id_2, script_url_2, pos_2, timestamp_2, typeof_2, lhs_2)
                                        if type_ == 'type' or type_ == 'value':
                                            should_skip = True
                                            if info[9] == 'function' and info[19] != 'function':
                                                should_skip = False
                                            elif info[19] == 'function' and info[9] != 'function':
                                                should_skip = False
                                            if should_skip:
                                                #print('skip, no func', info[9], info[19])
                                                continue
                                        overwrite_script_id = None
                                        if type_ == 'value' or type_ == 'type':
                                            if info[5] == info[15]:
                                                #print('skip, same script', info[5], info[15])
                                                continue
                                            asg_file = info[21]
                                            first_script_url = info[-2]
                                            second_script_url = info[-1]
                                            if int(info[0]) < int(info[11]):
                                                first_timestamp = info[8] #info[6]
                                                second_timestamp = info[18] #info[13]
                                                overwrite_script_id = info[15]
                                                #overwrite_script_url = info[16]
                                                overwrite_script_url = second_script_url
                                            else:
                                                first_timestamp = info[18] #info[13]
                                                second_timestamp = info[8] #info[6]
                                                overwrite_script_id = info[5]
                                                #overwrite_script_url = info[6]
                                                overwrite_script_url = first_script_url

                                        elif type_ == 'funcs' or type_ == 'func-var':
                                            first_script_url = info[-2]
                                            second_script_url = info[-1]
                                            if info[4] == info[0]:
                                                #print('skip, same script', info[0], info[4])
                                                continue
                                            if info[2] < info[6]:
                                                first_timestamp = info[2]
                                                second_timestamp = info[6]
                                                overwrite_script_id = info[4]
                                                overwrite_script_url = second_script_url
                                            else:
                                                first_timestamp = info[6]
                                                second_timestamp = info[2]
                                                overwrite_script_id = info[0]
                                                overwrite_script_url = first_script_url

                                        if overwrite_script_url is None:
                                            #print('skip, no script url')
                                            continue
                                        overwrite_timestamp = max(first_timestamp, second_timestamp)
                                        found_valid_user = False
                                        found_usage = False
                                        found_used_info = None
                                        for assign_log in assign_logs:
                                            if len(assign_log) == 0:
                                                continue
                                            assign_log = assign_log[1:]
                                            split_list = assign_log.split(',elem_js_conflict,')
                                            first_tuple = split_list[0]
                                            if first_tuple == '*** start_of_func':
                                                pass

                                            elif first_tuple == 'is_call' or first_tuple == 'is_call_new':
                                                if type_ == 'funcs' or type_ == 'func-var' or type_ == 'type':
                                                    function_name = split_list[1]
                                                    timestamp = float(split_list[3])
                                                    window_id = split_list[-1].split('\"')[0]
                                                    script_id = int(split_list[2])
                                                    #script_url = split_list[3]
                                                    script_url = find_script_url_using_id(script_id, raw_assign_file.split('/')[-1], raw_input_dir)
                                                    if script_url is None:
                                                        print(raw_assign_file.split('/')[-1])
                                                        continue
                                                    call_expr_pos = int(split_list[4])
                                                    if timestamp > overwrite_timestamp:
                                                        # function gets called after re-definition
                                                        should_log = False
                                                        if function_name == target and script_id != overwrite_script_id:
                                                            # if script A redefines the function and then script A calls it, we do NOT consider it as a use-after-overwrite case
                                                            if not should_ignore_funcs and type_ == 'funcs' and int(window_id) == int(info[8]):
                                                                should_log = True
                                                            elif type_ == 'func-var' and int(info[8]) == int(window_id):
                                                                should_log = True

                                                            elif type_ == 'type' and int(info[1]) == int(window_id):
                                                                should_log = True

                                                        if should_log:
                                                            found_usage = True
                                                            found_valid_user = True
                                                            if script_url == '' or script_url == '0':
                                                                script_priv = -1
                                                            else:
                                                                script_priv = determine_script_privilege(script_url, first_party_domain)
                                                            use_type = None
                                                            if script_priv == -1:
                                                                use_type = 'unknown'
                                                            elif cat.startswith('third_'):
                                                                if script_priv == 3:
                                                                    # third overwrites, then another thrid use
                                                                    overwrite_script_host = urlparse(overwrite_script_url).hostname
                                                                    script_host = urlparse(script_url).hostname
                                                                    if is_same_organization(overwrite_script_host, script_host):
                                                                        use_type = 'same_thrid'
                                                                    else:
                                                                        use_type = 'diff_third'
                                                                else:
                                                                    # third overwrites, then first use
                                                                    use_type = 'first'
                                                            elif cat.startswith('first_'):
                                                                if script_priv == 3:
                                                                    # first overwrites, then third use
                                                                    use_type = 'third'
                                                                else:
                                                                    use_type = 'first'
                                                            else:
                                                                use_type = 'unknown'
                                                            found_used_info = (info, (0, script_id, script_url, timestamp, script_priv, use_type))
                                                            if type_ not in cat2used_type2target2infos[cat]:
                                                                cat2used_type2target2infos[cat][type_] = dict()
                                                            if target not in cat2used_type2target2infos[cat][type_]:
                                                                cat2used_type2target2infos[cat][type_][target] = list()
                                                            cat2used_type2target2infos[cat][type_][target].append(found_used_info)
                                                            should_write_to_file = True
                                                            break


                                            elif first_tuple == 'is_new_temp':
                                                #print(assign_log)
                                                timestamp = float(split_list[6])
                                                window_id = split_list[-1]
                                                function_name = split_list[1]
                                                script_id = int(split_list[4])
                                                script_url = split_list[5]
                                                if type_ == 'funcs' or type_ == 'func-var' or type_ == 'type':
                                                    if timestamp > overwrite_timestamp:
                                                        # function used in new operators after re-defition
                                                        if function_name == target and script_id != overwrite_script_id:
                                                            should_log = False
                                                            if not should_ignore_funcs and type_ == 'funcs' and info[6] in rank2context2window[str(rank)] and rank2context2window[str(rank)][info[6]] == window_id:
                                                                should_log = True
                                                            elif type_ == 'func-var' and info[6] == window_id:
                                                                should_log = True
                                                            elif type_ == 'type' and int(info[1]) == int(window_id):
                                                                print('!!!!!!!')
                                                                should_log = True
                                                           


                                                            if should_log:
                                                                found_usage = True
                                                                found_valid_user = True
                                                                if type_ not in cat2used_type2target2infos[cat]:
                                                                    cat2used_type2target2infos[cat][type_] = dict()
                                                                if target not in cat2used_type2target2infos[cat][type_]:
                                                                    cat2used_type2target2infos[cat][type_][target] = list()
                                                                if script_url == '' or script_url == '0':
                                                                    script_priv = -1
                                                                else:
                                                                    script_priv = determine_script_privilege(script_url, first_party_domain)


                                                                if script_priv == -1:
                                                                    use_type = 'unknown'
                                                                elif cat.startswith('third_'):
                                                                    if script_priv == 3:
                                                                        # third overwrites, then another third use
                                                                        overwrite_script_host = urlparse(overwrite_script_url).hostname
                                                                        script_host = urlparse(script_url).hostname
                                                                        if is_same_organization(overwrite_script_host, script_host):
                                                                            use_type = 'same_third'
                                                                        else:
                                                                            use_type = 'diff_third'
                                                                    else:
                                                                        # third overwrites, then first use
                                                                        use_type = 'first'
                                                                elif cat.startswith('first_'):
                                                                    if script_priv == 3:
                                                                        # first overwrites, then thrid use
                                                                        use_type = 'third'
                                                                    else:
                                                                        # first overwrites, then first use
                                                                        use_type = 'first'
                                                                else:
                                                                    use_type = 'unknown'
                                                                used_info = (info, (0, script_id, script_url, timestamp, script_priv, use_type))
                                                                cat2used_type2target2infos[cat][type_][target].append(used_info)
                                                                should_write_to_file = True
                                                                break

                                                pass

                                            elif first_tuple == 'is_return':
                                                pass
                                            elif ',++0,' in assign_log or ',++1' in assign_log:
                                                pass
                                            elif ',--,' in assign_log:
                                                pass 
                                            else:
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

            if should_write_to_file:
                should_print_filename = False
                for cat, type2target2infos in cat2used_type2target2infos.items():
                    if 'type' in type2target2infos:
                        should_print_filename = True
                        break
                output_file = str(rank) + '-used-category2type2target2infos.json'
                output_file = os.path.join(input_dir, output_file)
                if should_print_filename:
                    print(output_file)
                with open(output_file, 'w') as output_f:
                    output_f.write(json.dumps(cat2used_type2target2infos))

           
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
    global raw_data_dir, processed_data_dir, num_instances, parent_pid, process_list, log_f, conflicting_rank_set, raw_dir, rank2url, domain2hosts, host2domain, extract, domain2ns, domain2soa, ns_domain2hosts, ns_host2domain, dynamic_dns_list, managed_dns_re, extract, raw_logs_dir


    signal.signal(signal.SIGTERM, signal_term_handler)
    parent_pid = os.getpid()
    try:
        opts, args = getopt.getopt(argv, 'hu:d:i:n:p:s:e:t:r:', ['help', 'user_dir=', 'exp_dir=', 'num=', 'process=', 'start=', 'end=','type=', 'raw_dir='])
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
    raw_logs_dir = False
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
        elif opt in ('-r', '--raw_dir'):
            raw_dir = arg
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

    extract = tldextract.TLDExtract(include_psl_private_domains=True)
    


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
    input_file = 'top-1m.url'
    input_file = os.path.join(exp_dir, input_file)
    rank2url = dict()
    with open(input_file, 'r') as input_f:
        for line in input_f:
            data = line[:-1].split(',')
            rank = data[0]
            rank = int(rank)
            url = ','.join(data[1:])
            rank2url[rank] = url

    domain2hosts = dict()
    host2domain = dict()

    extract = tldextract.TLDExtract(include_psl_private_domains=True)



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
    print(tab + '-r | --raw_dir=')
    print(tab*2 + 'Raw logs directory')

if __name__ == '__main__':
    main(sys.argv[1:])

