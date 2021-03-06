#!/bin/sh

error_on_quit=0

echo_err() {
	 echo "$@" >&2
}

check_installed() {
	if [ -z "$(which $1)" ]; then
		echo_err "Could not find $1. Please install $2."
		error_on_quit=1
		return 1
	fi
	return 0
}

for prog in automake autoconf pkg-config java ant yasm nasm wget; do
	check_installed "$prog" "it"
done
check_installed "libtoolize" "libtool"
check_installed "ndk-build" "android NDK"
if check_installed "android" "android SDK"; then
	check_installed "adb" "android SDK platform tools"
	# check that at least one target is installed
	if [ -z "$(android list target -c)" ]; then
		echo_err "Install at least one android target in the android SDK"
		error_on_quit=1
	fi
fi
if nasm -f elf32 2>&1 | grep -q "fatal: unrecognised output format"; then
	echo_err "Invalid version of nasm: your version does not support elf32 output format. If you have installed nasm, please check that your PATH env variable is set correctly."
	error_on_quit=1
fi
if ! (find submodules/linphone/mediastreamer2 -mindepth 1 2>/dev/null | grep -q . \
	|| find submodules/linphone/oRTP -mindepth 1 2>/dev/null | grep -q .); then
	echo_err "Missing some git submodules. Did you run 'git submodule update --init --recursive'?"
fi

if [ $error_on_quit = 0 ]; then
	rm -f check_tools.mk
	touch check_tools.mk
	echo "JAVA=\"$(which java)\"" >> check_tools.mk
	echo "ANTLR=\"$(which java)\" -jar \"submodules/externals/antlr3/antlr-3.2.jar\"" >> check_tools.mk
else
	echo "Failed to detect required tools, aborting."
fi

exit $error_on_quit
