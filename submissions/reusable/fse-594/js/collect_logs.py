# Used to run chromium browser in command line
# python log_access.py -u <user_dir> -d <data_dir> -s xxx -e yyy -i <input_file> -n <num_instances> -p <num_processes>
# xxx: starting rank
# yyy: end rank
# <input_file>: a file containing the domain name of websites, each line in format: <rank,domain_name>
# REMEMBER TO PUT THIS FILE UNDER THE SAME FOLDER WITH A profile-template FOLDER !!

import random, time, os, shutil, re, codecs, sys, commands, json, traceback, getopt, httplib, subprocess
import signal, psutil
from multiprocessing import Process as Task, Queue, Lock
import multiprocessing as mp
from subprocess import call, PIPE, STDOUT
from urlparse import urlparse
from threading import Timer

# This script do not need to destroy browser process between navigations
# This script can not capture browser event traces

reload(sys)
sys.setdefaultencoding('utf-8')
up = r'../'

ROOT = os.path.dirname(os.path.realpath(__file__))
PROFILE_TEMPLATE_DIR = os.path.join(ROOT, 'profile-template')
CHROME = os.path.join(ROOT, '../chromium/src/out/Release/chrome') # modify this to the local path of the binary file
print(CHROME)
ext_path = "../v8"
ext_path = os.path.join(ROOT, ext_path)

class FunctionTimeoutException(Exception):
    pass

class NavigationStuckException(Exception):
    pass

class TooManyTasksDead(Exception):
    pass

def restart_all_tasks(log_f):
    #status = 'Restarting [GDM]...'
    #current_time = getlocaltime()
    #string = '%s\t%s\n' % (current_time, status)
    #print(string)
    #log_f.write(string)

    #cmd = ['eudo', 'service', 'gdm', 'restart']
    #process = subprocess.Popen(cmd, stdin=PIPE, stdout=PIPE, stderr=PIPE)
    #out, err = process.communicate()

    time.sleep(1)

    status = 'Restarting [PARENT SCRIPT]...'
    current_time = getlocaltime()
    string = '%s\t%s\n' % (current_time, status)
    print(string)
    log_f.write(string)
    log_f.close()
    argv = sys.argv + ['&']

    #os.execl('/usr/bin/nohup', '/usr/bin/python', *argv)
    os.execl('/usr/bin/python', '/usr/bin/python', *sys.argv)

# Garbage collection of terminated chrome processes
def gc_chrome_tmp_files(force=False):
    global log_f
    tmp_dir = '/tmp'
    num = 0
    for p in os.listdir(tmp_dir):
        path = os.path.join(tmp_dir, p)
        if os.path.isfile(path) and p.startswith('domac-browser'):
            flag = force
            if not force:
                try:
                    pid = int(p.split('-')[-1])
                except ValueError:
                    continue
                try:
                    os.kill(pid, 0)
                except OSError:
                    # The pid is not running
                    flag = True
            if flag:
                try:
                    #print("Removing [%s]" % path)
                    os.remove(path)
                    num += 1
                except OSError as e:
                    pass
    status = 'GC [%d] files.' % (num)
    current_time = getlocaltime()
    string = '%s\t%s\n' % (current_time, status)
    log_f.write(string)

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

def kill_processes_by_name(name):
    for process in psutil.process_iter():
        try:
            cmdline = ' '.join(process.cmdline())
            if name not in cmdline:
                continue
            #print(cmdline)
            #sys.stdout.flush()
            #pid = process.pid
            kill_child_processes(parent = process)
        except (psutil.NoSuchProcess, psutil.ZombieProcess, psutil.AccessDenied):
            pass


def get_date_string(t):
    return time.strftime("%Y%m%d%H%M%S", t)

def get_time(t):
    return time.strftime("%Y-%m-%d %H:%M:%S", t)

def prepare_profile(user_dir, remove_only=False):
    try:
        shutil.rmtree(user_dir)
    except OSError as e:
        pass
    if not remove_only:
        shutil.copytree(PROFILE_TEMPLATE_DIR, user_dir)




def save_result_files(logs_dir, rank, user_dir):
    global chrome_newtab_url, about_blank_url, chrome_extension_prefix, chrome_extension_suffix, last_rank, last_logs_dir

    last_rank = rank
    last_logs_dir = logs_dir

    subframe_count = 0
    subfunc_count = 0
    subasg_count = 0
    subscript_count = 0
    children_tmp1 = get_child_processes(os.getpid())
    dst_folder_tmp = logs_dir 
    main_frame_pid = -1
    main_frame_filename = None
 
    for child in children_tmp1:
        mv_filename = str(child.pid) + '.txt'
        function_filename = str(child.pid) + '.func'
        asglogs_filename = str(child.pid) + '.asg'
        id2url_filename = str(child.pid) + '.id2url'
        is_main_frame_file = False
        script_file_list = os.listdir(os.getcwd())
        script_file_list = [f_ for f_ in script_file_list if f_.split('.')[-1] == 'script' and int(f_.split('.')[0]) == child.pid]
        new_script_file_list = []
        try:
            f = open(mv_filename, 'r')
        except Exception as e:
            continue

        try:
            lines = f.read().split('\n')[:-1]
            for line in lines:
                type_ = line.split(' ')[0]
                url_ = line.split(' ')[1]
                if(type_ == '[main]' and chrome_newtab_url not in url_ and about_blank_url not in url_):
                    if not (url_.startswith(chrome_extension_prefix) and url_.endswith(chrome_extension_suffix)):
                        i = 0
                        while True:
                            new_file = "%d.main.%d" %(rank, i)
                            mv_new_filename = new_file + ".frame"
                            mv_new_filename = os.path.join(dst_folder_tmp, mv_new_filename)
                            if not os.path.isfile(mv_new_filename):
                                asglogs_new_filename = new_file + '.asg'
                                asglogs_new_filename = os.path.join(dst_folder_tmp, asglogs_new_filename)
                                function_new_filename = new_file + ".func"
                                function_new_filename = os.path.join(dst_folder_tmp, function_new_filename)
                                id2url_new_filename = new_file + ".id2url"
                                id2url_new_filename = os.path.join(dst_folder_tmp, id2url_new_filename)

                                for f_ in script_file_list:
                                    script_id = f_.split('.')[1]
                                    new_filename = new_file + '.' + script_id + '.script'
                                    new_filename = os.path.join(dst_folder_tmp, new_filename)
                                    new_script_file_list.append((f_, new_filename))
                                break
                            i += 1
                        is_main_frame_file = True
                        main_frame_pid = child.pid
                        main_frame_filename = mv_new_filename
                        break
            f.close()
            if not is_main_frame_file:
                mv_new_filename = str(rank) + '.' + 'sub.' + str(subframe_count) + '.frame'
                mv_new_filename = os.path.join(dst_folder_tmp, mv_new_filename)
                asglogs_new_filename = str(rank) + '.' + 'sub.' + str(subasg_count) + '.asg'
                asglogs_new_filename = os.path.join(dst_folder_tmp, asglogs_new_filename)
                function_new_filename = str(rank) + '.' + 'sub.' + str(subfunc_count) + '.func'
                function_new_filename = os.path.join(dst_folder_tmp, function_new_filename)
                id2url_new_filename = str(rank) + '.' + 'sub.' + str(subfunc_count) + '.id2url'
                id2url_new_filename = os.path.join(dst_folder_tmp, id2url_new_filename)

                for f in script_file_list:
                    script_id = f.split('.')[1]
                    new_filename = str(rank) + '.' + 'sub.' + str(subscript_count) + '.' + script_id + '.script'
                    new_filename = os.path.join(dst_folder_tmp, new_filename)
                    new_script_file_list.append((f, new_filename))
                subframe_count += 1
                subfunc_count += 1
                subasg_count += 1
                subscript_count += 1

        except OSError as e:
            pass

        try:
            shutil.move(mv_filename, mv_new_filename)
        except OSError as e:
            pass
        except IOError:
            pass
        try:
            shutil.move(asglogs_filename, asglogs_new_filename)
        except OSError as e:
            pass
        except IOError:
            pass
        try:
            shutil.move(function_filename, function_new_filename)
        except OSError as e:
            pass
        except IOError:
            pass
        try:
            shutil.move(id2url_filename, id2url_new_filename)
        except OSError as e:
            pass
        except IOError as e:
            pass

        for f in new_script_file_list:
            try: 
                shutil.move(f[0], f[1])
            except OSError as e:
                continue
            except IOError as e:
                continue




def getlocaltime():
    return time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())

def measure(user_dir, task_id, length, start, end, status_queue, process_index):
    global rank2domain, access_control, find_sub_pages_script, num_instances, log_dir, script_dir, logs_dir, browser, chrome_newtab_url, about_blank_url, chrome_extension_prefix, chrome_extension_suffix, rank, last_rank, last_logs_dir

    current_pid = os.getpid()
    random.seed(time.time())

    chrome_newtab_url = 'https://www.google.com/_/chrome/newtab'
    about_blank_url = 'about:blank'
    chrome_extension_prefix = 'chrome-extension://'
    chrome_extension_suffix = 'generated_background_page.html'
    try:
        status = 'Process %-4d task %d/%d PID [%d] starting ...' % (process_index, task_id+1, length, current_pid)
        status_queue.put([process_index, status])
        #print(status)
    except Exception as e:
        pass

    try:
        os.mkdir(user_dir)
    except OSError as e:
        pass
    os.chdir(user_dir)

    try:
        filenames = os.listdir(log_dir)
    except OSError as e:
        #print(e, "x", log_dir, os.getcwd())
        return
    logs_dir = user_dir+'_logs'
    logs_dir = os.path.join(log_dir, logs_dir)
    try:
        os.mkdir(logs_dir)
    except OSError as e:
        pass

    log_file = '%s.log' % (user_dir)
    log_file = os.path.join(log_dir, log_file)
    webdriver_log = 'webdriver_%s.log' % (user_dir)
    processed_list = list()
    failed_list = list()
    log_f = None
    try:
        log_f = open(log_file, 'r')
        for line in log_f:
            split_list = line.split('start visiting')[1:] # the first element should be a time
            for element in split_list:
                element_split_list = element.split()
                rank = int(element_split_list[0])
                processed_list.append(rank)
            '''
            data = line[:-1].split('\t')
            rank = int(data[1])
            status = data[3]
            if status == 'main':
                url = data[2]
                if not url.startswith(about_blank_url):
                    processed_list.append(rank)
            elif status == 'failed':
                url = data[2]
                if not url.startswith(about_blank_url):
                    failed_list.append(rank)
            '''
        log_f.close()
    except IOError as e:
        pass

    filenames = [f for f in filenames if f.endswith('.json') and f.startswith(user_dir)]
    rank2files = dict()
    files = list()
    try:
        files += os.listdir(logs_dir)
    except OSError as e:
        print('err1 ')
        return

    for f in files:
        split_list = f.split('.')
        if f.startswith('webdriver_'):
            rank = f.split('_')[1].split('.')[0]
        else:
            rank = split_list[0]
        try:
            rank = int(rank)
        except ValueError:
            continue
        if rank not in rank2files:
            rank2files[rank] = list()
        #if suffix in ['txt']:
        suffix = ""
        if len(split_list) == 4:
            suffix = split_list[1] + split_list[3]
        elif len(split_list) == 2:
            suffix = split_list[1]
        elif len(split_list) == 5:
            suffix = split_list[1] + split_list[4]
        if suffix in ['mainframe', 'mainasg', 'mainfunc', 'log', 'mainscript', 'mainid2url']:
            rank2files[rank].append(suffix)
    completed_list = [rank for rank, suffix_list in rank2files.items() if len(suffix_list) >= 6]
    del rank2files

    browser = None
    display = None
    count = 0
    task_list = set(processed_list + failed_list)
    task_list = set([rank for rank in task_list if rank >= start and rank <= end])
    #processed_list = set(completed_list + failed_list)
    processed_list = set(completed_list)
    processed_list = set([rank for rank in processed_list if rank >= start and rank <= end])


    rank2fail_num = dict()
    while True:
        try:
            last_url = None
            last_rank = None
            last_logs_dir = None

            for rank, domain in sorted(rank2domain.items()):
                if rank > end:
                    continue
               
                if rank % num_instances != task_id or rank in processed_list or rank < start:
                    continue

                if rank in rank2fail_num and rank2fail_num[rank] >=3:
                    continue
                task_list.add(rank)

                prev_file_list = os.listdir(os.getcwd())
                for f in prev_file_list:
                    try:
                        os.remove(f)
                    except Exception as e:
                        pass

                
                prepare_profile(user_dir=user_dir)
                signal.signal(signal.SIGALRM, function_timeout_handler)
                timeout = 120
                signal.alarm(timeout)
                try:
                    if input_type == 'url':
                        url = domain
                    else:
                        url = "http://www."+domain
                    cmd = [CHROME, '--no-sandbox', '--headless', '--remote-debugging-port=9222', '--disable-gpu', '--enable-logging', '--v=1', '--user-data-dir=%s'%(os.getcwd()), url]

                    log_f = codecs.open(log_file, encoding='utf-8', mode='a')
                    string = '%s\tstart visiting %d %s' % (getlocaltime(), rank, url)
                    log_f.write(string)
                    log_f.close()
                    proc = subprocess.Popen(cmd, stderr=subprocess.PIPE) #, stdout=subprocess.PIPE)
                    o, e = proc.communicate()

                    save_result_files(logs_dir, rank, user_dir)
                    signal.alarm(0)
                    
                    gone, alive = kill_child_processes(parent_pid = current_pid)
                    process_name = 'user-data-dir=%s' % (user_dir)
                    kill_processes_by_name(process_name)
                except FunctionTimeoutException as e:
                    save_result_files(logs_dir, rank, user_dir)
                    proc.kill()
                processed_list.add(rank)
                       
            remaining_tasks = task_list - processed_list
            if len(remaining_tasks) == 0:
                break
        except KeyboardInterrupt as e:
            #kill_child_processes(parent_pid = current_pid)
            kill_all_processes()
            pass
        except Exception as e:
        #except (KeyboardInterrupt, Exception) as e:
            try:
                print(rank)
                exc_type, exc_value, exc_traceback = sys.exc_info()
                lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
                print(''.join('!! ' + line for line in lines))
                sys.stdout.flush()
            except Exception:
                pass

            signal.alarm(0)
            if log_f:
                log_f.close()
            status = 'process %-4d task %s/%s raised an Exception %s when visiting [%d].' % (process_index, task_id+1, length, type(e), rank)
            status_queue.put([process_index, status])
            string = '%s\t%s' % (getlocaltime(), status)
            if not isinstance(e, TimeoutException) and not isinstance(e, httplib.CannotSendRequest) and not isinstance(e, FunctionTimeoutException) and not isinstance(e, NavigationStuckException) and not isinstance(e, httplib.BadStatusLine):
            #if not isinstance(e, TimeoutException) and not isinstance(e, httplib.CannotSendRequest) and not isinstance(e, FunctionTimeoutException) and not isinstance(e, NavigationStuckException) and not isinstance(e, httplib.BadStatusLine):
                try:
                    print(string)
                    print(rank)
                    exc_type, exc_value, exc_traceback = sys.exc_info()
                    lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
                    print(''.join('!! ' + line for line in lines))
                    sys.stdout.flush()
                except Exception:
                    pass
            if isinstance(e, IOError):
                kill_all_processes()
            if rank not in rank2fail_num:
                rank2fail_num[rank] = 1
            else:
                if isinstance(e, WebDriverException):
                    rank2fail_num[rank] += 0.5
                else:
                    if isinstance(e, TimeoutException) or isinstance(e, FunctionTimeoutException):
                        rank2fail_num[rank] += 3
                    else:
                        rank2fail_num[rank] += 1
            if rank2fail_num[rank] >= 3:
                # we need to add the failed rank to processed_list.
                # otherwise, the while loop won't terminate
                processed_list.add(rank)
                log_f = open(log_file, 'a')
                status = 'failed'
                l = '%s\t%d\t%s\t%s\n' % (getlocaltime(), rank, domain, status)
                log_f.write(l)
                log_f.close()
                status = 'process %-4d task %s/%s failed to visit [%d].' % (process_index, task_id+1, length, rank)
                status_queue.put([process_index, status])



def function_timeout_handler(sig, frame):
    raise FunctionTimeoutException("function timeouted!")

def signal_term_handler(sig, frame):
    global parent_pid
    current_pid = os.getpid()
    if current_pid == parent_pid:
        #msg = '%s\tparent process [%d] received sigterm!!! killing all child processes...\n' % (current_time, current_pid)
        process_name = 'chrome'
        kill_processes_by_name(process_name)
    kill_all_processes()

def kill_all_processes(restart_parent_flag=False):
    global parent_pid, process_list, log_f
    current_time = getlocaltime()
    current_pid = os.getpid()
    if current_pid == parent_pid:
        msg = '%s\tparent process [%d] received sigterm!!! killing all child processes...\n' % (current_time, current_pid)
    else:
        msg = '%s\tprocess [%d] received sigterm!!! killing all child processes... parent pid=[%d]\n' % (current_time, current_pid, parent_pid)
    #print(msg)
    #sys.stdout.flush()
    log_f.write(msg)
    kill_child_processes(parent_pid = current_pid)
    current_time = getlocaltime()
    msg = '%s\tall child processes of process [%d] are killed!!!\n' % (current_time, current_pid)
    #print(msg)
    log_f.write(msg)
    if current_pid == parent_pid:
        if restart_parent_flag:
            restart_all_tasks(log_f)
        else:
            log_f.close()
    sys.exit()

def main(argv):
    global rank2domain, input_type, access_control, find_sub_pages_script, get_max_size_script, fetch_doc_log_script, fire_events_script, num_instances, parent_pid, process_list, log_f, log_dir, script_dir, fetch_asg_logs_script, chrome_newtab_url, about_blank_url, chrome_extension_prefix, chrome_extension_suffix, rank

    signal.signal(signal.SIGTERM, signal_term_handler)
    start_time = time.time()
    try:
        opts, args = getopt.getopt(argv, 'hu:d:i:n:p:t:s:e:', ['help', 'user_dir=', 'log_dir=', 'num=', 'process=', 'type=', 'input_file=', 'start=', 'end='])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    user_dir = None
    access_control = True
    input_type = 'domain'
    input_file = 'top-1m.csv'
    num_instances = 512
    maximum_process_num = 8 # Change to 1 for debugging purposeF
    start = 0
    end = None
    exp_dir = "exps"
    log_dir = None
    for opt, arg in opts:
        if opt in ('-u', '--user_dir'):
            user_dir = arg
        elif opt in ('-d', '--dir'):
            log_dir = arg
        elif opt in ('-i', '--input_file'):
            input_file = arg
        elif opt in ('-n', '--num'):
            num_instances = int(arg)
        elif opt in ('-p', '--process'):
            maximum_process_num = int(arg)
        elif opt in ('-t', '--type'):
            input_type = arg
        elif opt in ('-s', '--start'):
            start = int(arg)
        elif opt in ('-e', '--end'):
            end = int(arg)
        elif opt in ('-h', '--help'):
            usage()
            sys.exit(0)
    if user_dir is None or log_dir is None:
        usage()
        sys.exit(0)


    try:
        os.mkdir(exp_dir)
    except OSError as e:
        pass
    try:
        os.mkdir(log_dir)
    except OSError as e:
        pass

    parent_pid = os.getpid()
    script_dir = os.getcwd()
    restart_parent_flag = False

    log_dir = os.path.join(script_dir, log_dir)
    log_file = 'exp_%s.log' % (user_dir)
    log_file = os.path.join(log_dir, log_file)
    log_f = codecs.open(log_file, encoding='utf-8', mode='a')
    current_time = getlocaltime()
    status = "PARENT SCRIPT STARTED! PARENT PID=[%d]" % parent_pid
    string = '%s\t%s\n' % (current_time, status)
    print(string)
    log_f.write(string)
    string = "%s\tProcess started, argv=%s\n" % (current_time, argv)
    log_f.write(string)

    completed_list = set()
    completion_reg = re.compile('Process [0-9\s]+task ([0-9]+)/[0-9]+ PID \[\d+\] completed.')
    with codecs.open(log_file, encoding='utf-8', mode='r') as input_f:
        for line in input_f:
            match = re.search(completion_reg, line)
            if match:
                task = int(match.group(1)) - 1
                completed_list.add(task)
    completed_list = set()

    input_f = open(input_file, 'r')
    lines = input_f.read().split('\n')[:-1]
    input_f.close()
    rank2domain = dict()
    for line in lines:
        data = line.split(',')
        rank = data[0]
        rank = int(rank)
        url = ','.join(data[1:])
        rank2domain[rank] = url
    if end is None:
        end = len(rank2domain)


    try:
        os.chdir(exp_dir)
    except OSError as e:
        pass

    # Remove temp files
    gc_chrome_tmp_files(force=True)

    process_name = 'chrome'
    kill_processes_by_name(process_name)

    tasks = [i for i in range(num_instances-1, -1, -1)]
    status_queue = Queue()
    try:
        length = len(tasks)
        head = 'Preparing [%d] task ...' % (length)
        final_status_set = set()
        progress = dict()
        for j in range(maximum_process_num, 0, -1):
            progress[j] = ''
        id_pool = [j for j in range(maximum_process_num, 0, -1)]
        process_num = 0
        process2status = dict()
        running_processes = set()
        process2id = dict()
        process2index = dict()
        process2start_time = dict()
        id2index = dict()
        id2task = dict()
        index2task = dict()
        round_num = 0
        process_list = list()
        killed_process_list = list()
        dead_num = 0
        dead_ratio = 0
        alive_check_timeout = 60
        dead_ratio_list = []
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
                try:
                    process_list.append(Task(target=measure, args=(user_dir_group, task, length, start, end, status_queue, process_index)))
                    process = process_list[-1]
                    process.start()
                except OSError as e:
                    tasks.append(group)
                    time.sleep(5)
                    continue
                process_num += 1
                running_processes.add(process)
                process2index[process] = process_index
                process2start_time[process] = time.time()
                index2task[process_index] = task

                current_time = getlocaltime()
                process_status = 'Process %-4d task %d/%d created. PID=%d ...' % (process_index, task+1, length, process.pid)
                string = '%s\t%s' % (current_time, process_status)
                print(string)
                sys.stdout.flush()
                if process_num % 20 == 0:
                    break
                #break

            #time.sleep(1)
            flag = False
            while any(process.is_alive() for process in process_list):
                time.sleep(1)
                current_time = getlocaltime()
                alive_count += 1
                num_alive_processes = sum(1 for process in process_list if process.is_alive())

                #flag = False
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

                    gc_chrome_tmp_files()
                    current_timestamp = time.time()
                    elapse = current_timestamp - start_time
                    dead_num = 0
                    # We need to get a list. Otherwise, we will receive an Exception: RuntimeError: Set changed size during iteration
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

                        # Start checking log file modification time after 10 minutes
                        if elapse >= 60*10:
                            process_start_time = process2start_time[process]
                            process_elapse = current_timestamp - process_start_time
                            user_dir_group = '%s_%d' % (user_dir, group)
                            user_dir_log_file = '%s.log' % (user_dir_group)
                            user_dir_log_file = os.path.join(log_dir, user_dir_log_file)
                            #mtime = current_timestamp
                            ctime = current_timestamp
                            try:
                                #mtime = os.path.getmtime(user_dir_log_file) # https://docs.python.org/2/library/os.path.html#os.path.getmtime
                                ctime = os.path.getctime(user_dir_log_file) # https://docs.python.org/2/library/os.path.html#os.path.getctime
                            except OSError as e:
                                pass
                            if current_timestamp - ctime >= 60*10 and process_elapse >= 60*5:
                                dead_num += 1
                                process_status = 'Process %-4d task %d/%d PID [%d] seems to be dead. Terminating and restarting process...' % (process_index, group+1, length, process.pid)
                                string = '%s\t%s\n' % (current_time, process_status)
                                log_f.write(string)
                                gone, alive = kill_child_processes(parent_pid = process.pid)
                                process_name = 'user-data-dir=%s' % (user_dir_group)
                                kill_processes_by_name(process_name)
                                process_name = 'log-path=webdriver_%s.log' % (user_dir_group)
                                kill_processes_by_name(process_name)

                                running_processes.remove(process)
                                tasks.append(group)
                                flag = True
                                current_timestamp = time.time()
                    dead_ratio = 1.0 * dead_num / maximum_process_num
                    if len(dead_ratio_list) >= 5:
                        dead_ratio_list.pop(0)
                    dead_ratio_list.append(dead_ratio)
                    avg_dead_ratio = sum(dead_ratio_list) / float(len(dead_ratio_list))
                    if avg_dead_ratio >= 0.1:
                        status = "Too many tasks are dead! Average dead ratio is %.2f!" % (avg_dead_ratio)
                        string = '%s\t%s\n' % (current_time, status)
                        print(string)
                        log_f.write(string)
                        raise TooManyTasksDead("Too many tasks are dead! Average dead ratio is %.2f!" % (avg_dead_ratio))
                if flag == True or (num_alive_processes < maximum_process_num and (len(tasks) > 0 or alive_count % alive_check_timeout == 0)):
                    break
            # We need to get a list. Otherwise, we will receive an Exception: RuntimeError: Set changed size during iteration
            #for process in list(running_processes):
            for process in process_list:
                if not process.is_alive():
                    if process in running_processes:
                        running_processes.remove(process)

    except (KeyboardInterrupt, Exception) as e:
        current_time = getlocaltime()
        status = "PARENT SCRIPT Exception %s" % type(e)
        string = '%s\t%s\n' % (current_time, status)
        log_f.write(string)
        if not isinstance(e, KeyboardInterrupt) and not isinstance(e, TooManyTasksDead):
            exc_type, exc_value, exc_traceback = sys.exc_info()
            lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
            print(type(e), "PARENT")
            print(''.join('!! ' + line for line in lines))
            status = ''.join('!! ' + line for line in lines)
            string = '%s\t%s\n' % (current_time, status)
            log_f.write(string)
        restart_parent_flag = isinstance(e, TooManyTasksDead)
        if restart_parent_flag:
            os.chdir(script_dir)
        #for process in process_list:
            #try:
                #process.terminate()
            #except Exception:
                #pass

        #process_name = 'chrome'
        #kill_processes_by_name(process_name)
        kill_all_processes(restart_parent_flag)


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

    gc_chrome_tmp_files()

    current_time = getlocaltime()
    status = "PARENT SCRIPT COMPLETED! PARENT PID=[%d]" % parent_pid
    string = '%s\t%s\n' % (current_time, status)
    log_f.write(string)
    log_f.close()

def usage():
    tab = '\t'
    print('Usage:')
    print(tab + 'python %s [OPTIONS]' % (__file__))
    print(tab + '-d | --log_dir=')
    print(tab*2 + 'Log directory')
    print(tab + '-u | --user_dir=')
    print(tab*2 + 'User directory of Chrome')
    print(tab + '-i | --input_file=')
    print(tab*2 + 'Input file that contains URLs and ranks')
    print(tab + '-n | --num=')
    print(tab*2 + 'Number of task splits, default is 512')
    print(tab + '-p | --process=')
    print(tab*2 + 'Maximum number of processes, default is 8')
    print(tab + '-t | --type')
    print(tab*2 + 'Input type, [domain|url], default [domain]')
    print(tab + '-s | --start')
    print(tab*2 + 'Start index, default 0')
    print(tab + '-e | --end')
    print(tab*2 + 'End index, default number of URLs')

if __name__ == '__main__':
    main(sys.argv[1:])
