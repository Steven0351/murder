murder:
	swift build

install:
	cp ./.build/x86_64-apple-macosx/debug/murder /usr/local/bin/
	mkdir -p /usr/local/var/murder
	cp config.json /usr/local/var/murder
	cp dev.stevensherry.murder.plist ~/Library/LaunchAgents
	launchctl load ~/Library/LaunchAgents/dev.stevensherry.murder.plist

clean: 
	rm -rf .build

uninstall:
	rm /usr/local/bin/murder
	rm -rf /usr/local/var/murder
	launchctl unload ~/Library/LaunchAgents/dev.stevensherry.murder.plist
	rm ~/Library/LaunchAgents/dev.stevensherry.murder.plist