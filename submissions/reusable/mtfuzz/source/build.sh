# build edge coverage llvm pass
cd ec_pass; make -j; cd llvm_mode;make -j; cd ../../
# build call context coverage llvm pass
cd ctx_pass; make -j; cd llvm_mode;make -j; cd ../../
# build approach level coverage llvm pass
cd approach_pass; make -j; cd llvm_mode;make -j; cd ../../
# build CMP instrumentation llvm pass
cd br_pass/src/; make -j; cd llvm_mode;make -j; cd ../../../
# build CMP instrumentation fast llvm pass with fork server
cd br_fast_pass/src/; make -j; cd llvm_mode;make -j; cd ../../../
# build mtfuzz fuzzing module
gcc -O3 -funroll-loops ./mtfuzz.c -o mtfuzz
