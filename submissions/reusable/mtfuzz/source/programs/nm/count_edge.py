import subprocess

subprocess.call("cp -r ./seeds /dev/shm/nm_in", shell=True )
subprocess.call("cp ./vari_seeds/* /dev/shm/nm_in", shell=True )

out = subprocess.check_output(['/home/ubuntu/afl-count', '-i', '/dev/shm/nm_in', '-o', '/dev/shm/nm_out','-m1024', '/home/ubuntu/MTFuzz/programs/nm/nm_ec','-C', '@@'])
lines = out.splitlines()
for line in lines:
    line = str(line, 'utf-8')
    if line.startswith('####total branch number'):
        print(line)

subprocess.call("rm -rf /dev/shm/nm_in", shell=True )
subprocess.call("rm -rf /dev/shm/nm_out", shell=True )
