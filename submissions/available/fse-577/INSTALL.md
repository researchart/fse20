# DICIDer

The source of this tool is an eclipse Java project.
Moreover, the tool also requires the project of [Soot](https://github.com/Sable/soot) 
and [FlowDroid](https://github.com/secure-software-engineering/FlowDroid) to be 
add as required projects on the build path.

To run, arguments should be provided as:
`a.apk path/to/android-platforms`
where *a.apk* is the apk file need to be analyzed and *android-platforms* is the
SDK platforms of Android which can be downloaded via Android Studio or directly
download from [here](https://github.com/lilicoding/android-platforms) while missing
versions is possible.
The output is a file with same name of the APK file (named *a* in this case) at
current directory.

# StealthApp & TikTokDownloader

The source of these 2 proof-of-concept apps are Android Studio project.
They can be installed via Android Studio.
There are certain requirements for these apps to work properly and those requirements
are listed in *README.md*.
To play with these 2 apps, the UI is easy and comprehensive.

For **StealthApp**, it should be able to obtain the IMEI number and send it to a
specified phone number and for **TikTokDownloader**,
it will provide the ability to search users via keywords. After selecting a certain
user name, all videos of the user will be downloaded and listed in an individual
UI.
As all these functionalities are "plagiarized" from relevant apps. Thus, if required
apps were not installed, these operations will be failed.

Moreover, the apps may need to be installed on a real phone instead of emulator.
Since either sending SMS or native code are required.

