git clone https://github.com/kripa432/Panoply.git panoply
cd panoply
git clone https://github.com/intel/linux-sgx.git
cd linux-sgx
git checkout sgx_2.0
./download_prebuilt.sh
make sdk
make sdk_install_pkg
printf "no\n/opt/intel\n\n" | sudo ./linux/installer/bin/sgx_linux_x64_sdk_*.bin
cd ..
sudo cp sgx_status.h /opt/intel/sgxsdk/include
