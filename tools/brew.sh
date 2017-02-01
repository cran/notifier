#!/bin/bash
# Anticonf (tm) script by Jeroen Ooms (2016)

if [[ "$OSTYPE" == "darwin"* ]]; then

    PKG_BREW_NAME=terminal-notifier

    if brew --version >/dev/null 2>/dev/null; then
	BREWBIN=$(which brew)
    else
	echo "Auto-brewing $PKG_BREW_NAME..."
	BREWDIR="/tmp/homebrew"
	BREWBIN="$BREWDIR/bin/brew"
	rm -Rf $BREWDIR
	mkdir -p $BREWDIR
	curl -kfsSL https://github.com/Homebrew/brew/tarball/master \
	    | tar xz --strip 1 -C $BREWDIR
    fi

    BREW_DEPS=$($BREWBIN deps -n $PKG_BREW_NAME 2>/dev/null)
    if [ -z "$BREW_DEPS" ]; then
       HOMEBREW_CACHE="/tmp" $BREWBIN install $BREW_DEPS \
		     --force-bottle 2>/dev/null >/dev/null
    fi
    HOMEBREW_CACHE="/tmp" $BREWBIN install $PKG_BREW_NAME \
		  --force-bottle 2>/dev/null >/dev/null
    BREW_PKG_DIR=$($BREWBIN --prefix $PKG_BREW_NAME)

    # configure runs in the root of the source package
    mkdir -p ${R_PACKAGE_DIR}/tn
    cp -r ${BREW_PKG_DIR}/ ${R_PACKAGE_DIR}/tn

    # Find the terminal-notifier binary and write its place to a file,
    # so we don't have to do this search at runtime. There are two files
    # (at least on my system), one is a simple script that executes the
    # other one, but it refers to it with an absolute path, so we cannot
    # use that. We try to pick the binary one.
    binary=$(cd ${R_PACKAGE_DIR}/tn &&
		    find . -type f -perm -o=x -exec file \{\} \; |
		    grep -v "shell script" |
		    cut -d: -f1)
    echo $binary > ${R_PACKAGE_DIR}/tn/binary
fi
