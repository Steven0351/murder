# Murder

A simple command line application meant to run as a daemon process via launchd that kills applications when the screen is locked.

### System Requirements
macOS Catalina or later

Xcode 12 or higher

### Use
Edit the config.json file to change what applications you want to kill when your screen locks. Then run the following:
```
make
make install
```

#### Note
For some reason that I have been unable to ascertain, DistributedNotificationCenter only appears to work under the debug configuration.
