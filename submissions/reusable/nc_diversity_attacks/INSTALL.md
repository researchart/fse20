# INSTALL

The following steps should be sufficient to get these attacks up and running on most systems running Python 3.7.3+.

```
numpy       ~=1.16.2
pandas      ~=0.24.2
torchvision ~=0.6.0
torch       ~=1.5.0
tqdm        ~=4.31.1
matplotlib  ~=3.0.3
scipy       ~=1.2.1
seaborn     ~=0.9.0
```
Note: these are the most recent versions of each library used, lower versions may be acceptable as well. If you have other versions Python, the `~=` operator should download the best compatible version of each package for you. It is also *highly* recommended that you use GPUs to execute the evaluation scripts. If you have access to GPUs, [download](https://pytorch.org/get-started/locally/) the appropriate version of PyTorch for your system instead of using the default above. 

```
pip install -r requirements.txt
```

The results are aggregated and visualized in a `jupyter notebook`, which can be viewed directly in GitHub or perused locally:
```
# install
pip install jupyter

# start notebook in working directory
jupyter notebook
```