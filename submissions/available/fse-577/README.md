# Artifact Description

Hereafter are the relevant artifact of FSE paper No. 577 
[[embed url=https://github.com/gaojun0816/fse20/blob/master/submissions/available/fse-577/article.pdf]].
There are 2 types of the artifact.
First type is the tool for detecting DICIs and it is named as DICIDer.
Another type is proof-of-concept which includes 2 apps.
The purpose of these apps is to showcase the possible malicious behaviors by
using DICI.

## The Tool
### DICIDer

DICIDer is a tool to detect DICIs in an Android installation file (i.e., APK file).
It can be obtained directly from the GitHub repo at [here](https://github.com/gaojun0816/code_access_finder)
or you can find the archived version for FSE in *index.md*.

To reproduce the result presented in the paper, relevant sample apps are listed
under *sample* directory separated by different RQs.
The lists only provide the SHA256 digest of individual APK files.
They need to be downloaded from [AndroZoo](https://androzoo.uni.lu/).

## Proof of Concept Apps
All following apps were tested on a Nexus 5 device running Android version 8.1.0.

### StealthApp

This app performs a malicious behavior to leak the IMEI of a device to the out
of the world via SMS via DICI.
The source code of this app can be found [here](https://github.com/gaojun0816/stealthapp).
Also, the archived version for FSE is included in *index.md*.

To reproduce the attack, it requires:
  + relevant permissions need to be granted manually from the system settings.  

  + other 2 benign apps installed on the same device: 
  com.globalcanofworms.android.simpleweatheralert and 
  org.communicorpbulgaria. bgradio respectively.
  They can be downloaded from [AndroZoo](https://androzoo.uni.lu/) with SHA256: 
  7E8365752A1AEE0F15E65E3D5A7A56B691E208880545987DEEA493B35965F3D5 and 
  3754F46387F856CE4398790B7F3CA62F5E62EE41DD8DBDD47C3B9EC4B393F578 respectively.


### TikTokDownloader

This app plagiarizes the "signature" algorithm implemented in TikTok by using DICI
to achieve downloading videos from their server which is blocked by TikTok normally.
The source code of this app can be found [here](https://github.com/gaojun0816/TikTokDownloader).
And the archived version for FSE is included in *index.md*.

For reproducing purpose, the relevant TikTok app is also required to be installed 
on the same device. 
The TikTok app used to develop this app can be downloaded 
[here](https://drive.google.com/file/d/15vBWULM9SSBDUkwMLASg4OoVVNY-mziN/view?usp=sharing).





