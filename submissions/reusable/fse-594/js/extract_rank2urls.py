import json, os, sys, traceback, getopt




def measure(user_dir, task_id, start, end):
    global raw_data_dir, rank2url

    current_pid = os.getpid()
    current_dir = os.getcwd()
    try:
        input_dir = user_dir + '_logs'
        input_dir = os.path.join(current_dir, input_dir)
        files = os.listdir(input_dir)
        files = [f for f in files if f.split('.')[-1] == 'frame']
        for f in files:
            f = os.path.join(input_dir, f)
            with open(f, 'r') as input_f:
                for line in input_f:
                    if line.startswith('[main]'):
                        rank = f.split('/')[-1].split('.')[0]
                        url = line.split()[1]
                        if not url.startswith('chrome-error') and not url.startswith('about:blank'):
                            rank2url[rank] = url
                            #print(rank, url)
    except Exception as e:
        print(e)
        pass




def main(argv):
    global raw_data_dir, num_instances, rank2url

    parent_pid = os.getpid()
    try:
        opts, args = getopt.getopt(argv, 'hu:d:i:n:p:s:e:t:o:', ['help', 'user_dir=', 'exp_dir=', 'num=', 'process=', 'start=', 'end=', 'type=', 'output_dir='])
    except getopt.GetoptError:
        usage()
        sys.exit(2)


        
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
        elif opt in ('-o', '--output_dir'):
            output_dir = arg
        elif opt in ('-h', '--help'):
            usage()
            sys.exit(0)


    rank2url = dict()
    input_file = 'top-1m.csv'
    #task_queue = get_task_queue(input_file)
    raw_data_dir = exp_dir

    try:
        os.chdir(exp_dir)
    except OSError as e:
        print(e)
        sys.exit(1)




    tasks = [i for i in range(num_instances-1, -1, -1)]
    for task in tasks:
        user_dir_group = '%s_%d' %(user_dir, task)
        try:
            measure(user_dir_group, task, start, end)
        except OSError as e:
            print(e)
            continue
    
    output_file = 'top-1m.url'
    output_file = os.path.join(output_dir, output_file)
    with open(output_file, 'w') as output_f:
        for rank, url in sorted(rank2url.items(), key=lambda x:int(x[0])):
            line = rank + ',' + url + '\n'
            output_f.write(line)

    print('Visited %d websites\n'%(len(rank2url)))


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
    print(tab + '-o | --output_dir=')
    print(tab*2 + 'Output directory where the output file is saved')



if __name__ == '__main__':
    main(sys.argv[1:])
