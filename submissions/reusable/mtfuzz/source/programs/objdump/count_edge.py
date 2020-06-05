import subprocess

subprocess.call("cp -r ./seeds /dev/shm/objdump_in", shell=True )
subprocess.call("cp ./vari_seeds/* /dev/shm/objdump_in", shell=True )

out = subprocess.check_output(['/home/ubuntu/afl-count', '-i', '/dev/shm/objdump_in', '-o', '/dev/shm/objdump_out','-m1024', '/home/ubuntu/MTFuzz/programs/objdump/objdump_ec','-D', '@@'])
lines = out.splitlines()
for line in lines:
    line = str(line, 'utf-8')
    if line.startswith('####total branch number'):
        print(line)

subprocess.call("rm -rf /dev/shm/objdump_in", shell=True )
subprocess.call("rm -rf /dev/shm/objdump_out", shell=True )
