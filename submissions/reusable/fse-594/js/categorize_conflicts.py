import sys, codecs, json, re, time, os, getopt, traceback
import signal, psutil, tldextract
from urlparse import urlparse
from multiprocessing import Process as Task, Queue
from subprocess import call, PIPE, STDOUT
import multiprocessing as mp
import random, calendar, shutil, sys, commands, hmac
from termcolor import colored
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



def is_same_organization(_host, hostname):

    if _host is None or hostname is None:
        return False
    _ext = extract(_host)
    ext = extract(hostname)
    if ext.domain == _ext.domain:
        return True
    else:
        return False




def find_script_url_using_id(script_id, asg_file, raw_input_dir):
    global raw_logs_dir

    script_url = None
    id2url_file = asg_file.replace('.asg', '.id2url')
    id2url_file = os.path.join(raw_input_dir, id2url_file)
    id2url_file = os.path.join(raw_logs_dir, id2url_file)
    if os.path.isfile(id2url_file):
        with open(id2url_file, 'r') as id2url_input_f:
            for id2url_line in id2url_input_f:
                if id2url_line.split(',')[0] == str(script_id):
                    script_url = (','.join(id2url_line.split(',')[1:])).split('\n')[0]
                    break
    if script_url is None:
        script_source_file = asg_file.replace('.asg', '.%d.script'%(script_id))
        script_source_file = os.path.join(raw_input_dir, script_source_file)
        script_source_file = os.path.join(raw_logs_dir, script_source_file)
        if os.path.isfile(script_source_file): 
            with open(script_source_file, 'r') as scriptsource_input_f:
                for script_source_line in scriptsource_input_f:
                    script_url = script_source_line.split('\n')[0]
                    break
    return script_url





def measure(user_dir, task_id, length, start, end, status_queue, process_index):
    global processed_data_dir, rank2url, host2domain

    current_pid = os.getpid()
    current_dir = os.getcwd()
    try:
        status = 'Process %-4d task %d/%d PID [%d] starting ...' % (process_index, task_id+1, length, current_pid)
        status_queue.put([process_index, status])

        result_dict = dict()
        processed_list = set()

        raw_input_dir = user_dir + '_logs'
        input_dir = os.path.join(current_dir, raw_input_dir)
        file_list = os.listdir(input_dir)
        files = [f for f in file_list if f.endswith('-cat2name2conflicts.json')]

        raw_analysis_dir = user_dir + '_analysis'
        input_analysis_dir = os.path.join(current_dir, raw_analysis_dir)

        if os.path.isdir(input_analysis_dir):
            finished_files = os.listdir(input_analysis_dir)
            finished_files = [f for f in finished_files if f.endswith('-category2target2type2script2infos.json')]
            for f in finished_files:
                rank = int(f.split('-')[0])
                processed_list.add(rank)
        else:
            try:
                os.mkdir(input_analysis_dir)
            except Exception as e:
                pass


        raw_output_dir = os.path.join(processed_data_dir, raw_input_dir)
        if not os.path.isdir(raw_output_dir):
            os.mkdir(raw_output_dir)
        for task in files:
            rank = int(task.split('.')[0].split('-')[0])
            if rank > end:
                #print('rank > end')
                continue
            if rank % num_instances != task_id or rank in processed_list or rank < start:
                #print('passed %d'%(rank))
                continue


            first_party_url = rank2url[rank]
            parse = urlparse(first_party_url)
            first_party_host = parse.hostname
            first_party_origin = parse.scheme + '://' + parse.netloc
            ext = extract(first_party_host)
            first_party_domain = ext.domain

            try:
                try:
                    task_file = os.path.join(input_dir, task)
                    #target2window2type2script2infos = dict()
                    type2target2infos = dict()
                    category2target2type2script2infos = {'first_overwrites_first': dict(), 'first_overwrites_third': dict(), 'third_overwrites_first': dict(), 'third_overwrites_same_third': dict(), 'third_overwrites_diff_third': dict(), 'unknown': dict()}

                    if task.endswith('-cat2name2conflicts.json'):
                        with open(task_file, 'r') as input_f:
                            type2target2infos = json.loads(input_f.read())
                            for type_, target2infos in type2target2infos.items():
                                for target, infos in target2infos.items():
                                    for info in infos:
                                        # info: (assign_id_1, window_id, value_1, rhs_1, rhs_type_1, script_id_1, script_url_1, pos_1, timestamp_1, typeof_1, lhs_1, assign_id_2, value_2, rhs_2, rhs_type_2, script_id_2, script_url_2, pos_2, timestamp_2, typeof_2, lhs_2, asg_filename, conflict_filename)
                                        if type_ == 'value' or type_ == 'type':
                                            first_script_id = info[5]
                                            second_script_id = info[15]
                                            # let's use the assign id, because it's possible that two logs have the same timestamp (in us)
                                            asg_file = info[21]
                                            first_script_url = find_script_url_using_id(first_script_id, asg_file, raw_input_dir)
                                            second_script_url = find_script_url_using_id(second_script_id, asg_file, raw_input_dir)
                                            if first_script_url is None or second_script_url is None:
                                                continue
                                            first_timestamp = int(info[0]) #float(info[8])
                                            second_timestamp = int(info[11]) #float(info[13])

                                        elif type_ == 'funcs' or type_ == 'func-var':
                                            first_script_id = info[0]
                                            second_script_id = info[4]
                                            if type_ == 'funcs':
                                                first_script_url = info[1]
                                                second_script_url = info[5]
                                            else:
                                                second_script_url = info[5]
                                                asg_file = info[7]
                                                first_script_url = find_script_url_using_id(first_script_id, asg_file, raw_input_dir)
                                                if first_script_url is None:
                                                    continue

                                            first_timestamp = float(info[2])
                                            second_timestamp = float(info[6])

                                        script_tuple = str(first_script_id) + '-' + str(second_script_id)

                                        pre_assigned_category = None
                                        if first_script_url == '' or first_script_url == '0' or second_script_url == '' or second_script_url == '0':
                                            pre_assigned_category = 'unknown'
                                        else:
                                            try:
                                                first_script_priv = determine_script_privilege(first_script_url, first_party_domain)
                                                second_script_priv = determine_script_privilege(second_script_url, first_party_domain)

                                            except Exception as e:
                                                #print(first_script_url, white_list, first_party_origin, first_party_domain)
                                                continue

                                        info_ = list()
                                        for item in info:
                                            info_.append(item)
                                        info_.append(first_script_url)
                                        info_.append(second_script_url)
                                        if pre_assigned_category is None:
                                            if first_script_priv < 3 and second_script_priv < 3:
                                                if target not in category2target2type2script2infos['first_overwrites_first']:
                                                    category2target2type2script2infos['first_overwrites_first'][target] = dict()
                                                if type_ not in category2target2type2script2infos['first_overwrites_first'][target]:
                                                    category2target2type2script2infos['first_overwrites_first'][target][type_] = dict()
                                                if script_tuple not in category2target2type2script2infos['first_overwrites_first'][target][type_]:
                                                    category2target2type2script2infos['first_overwrites_first'][target][type_][script_tuple] = list()
                                                category2target2type2script2infos['first_overwrites_first'][target][type_][script_tuple].append(info_)

                                            elif first_script_priv < 3 and second_script_priv == 3:
                                                if first_timestamp < second_timestamp:
                                                    if target not in category2target2type2script2infos['third_overwrites_first']:
                                                        category2target2type2script2infos['third_overwrites_first'][target] = dict()
                                                    if type_ not in category2target2type2script2infos['third_overwrites_first'][target]:
                                                        category2target2type2script2infos['third_overwrites_first'][target][type_] = dict()
                                                    if script_tuple not in category2target2type2script2infos['third_overwrites_first'][target][type_]:
                                                        category2target2type2script2infos['third_overwrites_first'][target][type_][script_tuple] = list()
                                                    category2target2type2script2infos['third_overwrites_first'][target][type_][script_tuple].append(info_)

                                                else:
                                                    if target not in category2target2type2script2infos['first_overwrites_third']:
                                                        category2target2type2script2infos['first_overwrites_third'][target] = dict()
                                                    if type_ not in category2target2type2script2infos['first_overwrites_third'][target]:
                                                        category2target2type2script2infos['first_overwrites_third'][target][type_] = dict()
                                                    if script_tuple not in category2target2type2script2infos['first_overwrites_third'][target][type_]:
                                                        category2target2type2script2infos['first_overwrites_third'][target][type_][script_tuple] = list()
                                                    category2target2type2script2infos['first_overwrites_third'][target][type_][script_tuple].append(info_)


                                            elif first_script_priv == 3 and second_script_priv < 3:
                                                if first_timestamp < second_timestamp:
                                                    if target not in category2target2type2script2infos['first_overwrites_third']:
                                                        category2target2type2script2infos['first_overwrites_third'][target] = dict()
                                                    if type_ not in category2target2type2script2infos['first_overwrites_third'][target]:
                                                        category2target2type2script2infos['first_overwrites_third'][target][type_] = dict()
                                                    if script_tuple not in category2target2type2script2infos['first_overwrites_third'][target][type_]:
                                                        category2target2type2script2infos['first_overwrites_third'][target][type_][script_tuple] = list()
                                                    category2target2type2script2infos['first_overwrites_third'][target][type_][script_tuple].append(info_)

                                                else:
                                                    if target not in category2target2type2script2infos['third_overwrites_first']:
                                                        category2target2type2script2infos['third_overwrites_first'][target] = dict()
                                                    if type_ not in category2target2type2script2infos['third_overwrites_first'][target]:
                                                        category2target2type2script2infos['third_overwrites_first'][target][type_] = dict()
                                                    if script_tuple not in category2target2type2script2infos['third_overwrites_first'][target][type_]:
                                                        category2target2type2script2infos['third_overwrites_first'][target][type_][script_tuple] = list()
                                                    category2target2type2script2infos['third_overwrites_first'][target][type_][script_tuple].append(info_)
                                        
                                            
                                            elif first_script_priv == 3 and second_script_priv == 3:
                                                first_script_host = urlparse(first_script_url).hostname
                                                second_script_host = urlparse(second_script_url).hostname
                                                if not is_same_organization(first_script_host, second_script_host):
                                                    if target not in category2target2type2script2infos['third_overwrites_diff_third']:
                                                        category2target2type2script2infos['third_overwrites_diff_third'][target] = dict()
                                                    if type_ not in category2target2type2script2infos['third_overwrites_diff_third'][target]:
                                                        category2target2type2script2infos['third_overwrites_diff_third'][target][type_] = dict()
                                                    if script_tuple not in category2target2type2script2infos['third_overwrites_diff_third'][target][type_]:
                                                        category2target2type2script2infos['third_overwrites_diff_third'][target][type_][script_tuple] = list()
                                                    category2target2type2script2infos['third_overwrites_diff_third'][target][type_][script_tuple].append(info_)

                                                else:
                                                    if target not in category2target2type2script2infos['third_overwrites_same_third']:
                                                        category2target2type2script2infos['third_overwrites_same_third'][target] = dict()
                                                    if type_ not in category2target2type2script2infos['third_overwrites_same_third'][target]:
                                                        category2target2type2script2infos['third_overwrites_same_third'][target][type_] = dict()
                                                    if script_tuple not in category2target2type2script2infos['third_overwrites_same_third'][target][type_]:
                                                        category2target2type2script2infos['third_overwrites_same_third'][target][type_][script_tuple] = list()
                                                    category2target2type2script2infos['third_overwrites_same_third'][target][type_][script_tuple].append(info_)
                                        else:
                                            if target not in category2target2type2script2infos[pre_assigned_category]:
                                                category2target2type2script2infos[pre_assigned_category][target] = dict()
                                            if type_ not in category2target2type2script2infos[pre_assigned_category][target]:
                                                category2target2type2script2infos[pre_assigned_category][target][type_] = dict()
                                            if script_tuple not in category2target2type2script2infos[pre_assigned_category][target][type_]:
                                                category2target2type2script2infos[pre_assigned_category][target][type_][script_tuple] = list()
                                            category2target2type2script2infos[pre_assigned_category][target][type_][script_tuple].append(info_)



                        
                        if len(category2target2type2script2infos) > 0:
                            output_file = '%d-category2target2type2script2infos.json'%(rank)
                            output_file = os.path.join(input_analysis_dir, output_file)
                            if len(category2target2type2script2infos['third_overwrites_first']) > 0:
                                print('=>', output_file)
                            else:
                                print(output_file)
                            with open(output_file, 'w') as output_f:
                                output_f.write(json.dumps(category2target2type2script2infos))


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
    global raw_data_dir, processed_data_dir, num_instances, parent_pid, process_list, log_f, conflicting_rank_set, rank2url, domain2hosts, host2domain, extract, domain2ns, domain2soa, ns_domain2hosts, ns_host2domain, dynamic_dns_list, managed_dns_re, raw_logs_dir

    signal.signal(signal.SIGTERM, signal_term_handler)
    parent_pid = os.getpid()
    try:
        opts, args = getopt.getopt(argv, 'hu:d:i:n:p:s:e:l:t:', ['help', 'user_dir=', 'exp_dir=', 'num=', 'process=', 'start=', 'end=', 'logs_dir=', 'type='])
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
        elif opt in ('-l', '--logs_dir'):
            raw_logs_dir = arg
        elif opt in ('-h', '--help'):
            usage()
            sys.exit(0)

    if user_dir is None or raw_logs_dir is None:
        usage()
        sys.exit(0)
    
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
    print(tab + '-l | --logs_dir=')
    print(tab*2 + 'Raw logs directory')

if __name__ == '__main__':
    main(sys.argv[1:])

