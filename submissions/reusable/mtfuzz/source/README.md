This directory contains source code for each modules of MTFuzz.
- ec_pass: llvm pass for edge coverage  
- ctx_pass: llvm pass for call context coverage
- approach_pass: llvm pass for approach level coverage 
- br_pass: llvm pass for CMP instrution
- br_fast_pass: llvm pass for CMP instrution using fork server
- build.sh: build the above 5 pass and mtufzz
- mtfuzz_wrapper.py: a python wrapper to run mtfuzz fuzzing module
- nn.py: mtfuzz nn module
- programs: 10 real world programs reported in the paper and a program to demo how to compile with MTFuzz.
