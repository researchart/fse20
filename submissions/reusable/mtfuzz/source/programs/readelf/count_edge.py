import subprocess

subprocess.call("cp -r ./seeds /dev/shm/readelf_in", shell=True )
subprocess.call("cp ./vari_seeds/* /dev/shm/readelf_in", shell=True )

out = subprocess.check_output(['/home/ubuntu/afl-count', '-i', '/dev/shm/readelf_in', '-o', '/dev/shm/readelf_out','-m1024', '/home/ubuntu/MTFuzz/programs/readelf/readelf_ec','-a', '@@'])
lines = out.splitlines()
for line in lines:
    line = str(line, 'utf-8')
    if line.startswith('####total branch number'):
        print(line)

subprocess.call("rm -rf /dev/shm/readelf_in", shell=True )
subprocess.call("rm -rf /dev/shm/readelf_out", shell=True )
