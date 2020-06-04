import subprocess

subprocess.call("cp -r ./seeds /dev/shm/strip_in", shell=True )
subprocess.call("cp ./vari_seeds/* /dev/shm/strip_in", shell=True )

out = subprocess.check_output(['/home/ubuntu/afl-count', '-i', '/dev/shm/strip_in', '-o', '/dev/shm/strip_out','-m1024', '/home/ubuntu/MTFuzz/programs/strip/strip_ec', '-o', 'tmp', '@@'])
lines = out.splitlines()
for line in lines:
    line = str(line, 'utf-8')
    if line.startswith('####total branch number'):
        print(line)

subprocess.call("rm -rf /dev/shm/strip_in", shell=True )
subprocess.call("rm -rf /dev/shm/strip_out", shell=True )
