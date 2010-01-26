#!/bin/sh

# $OSTYPE isn't exported by my Linux bash shell.
if [ "$OSTYPE" = "" ]; then
    OSTYPE=`uname`;
fi


if [ "$OSTYPE" = "Linux" -o "$OSTYPE" = "linux-gnu" ]; then
    if command -v sbcl 1>&2 > /dev/null; then  # Preferring SBCL on Linux.
        CL="sbcl";
    elif command -v lx86cl 1>&2 > /dev/null; then
        CL="lx86cl";
    elif command -v clisp 1>&2 > /dev/null; then
        CL="clisp";
    else
        echo "Could not find SBCL, CCL or CLISP in PATH... aborting.";
        exit 1;
    fi
elif [ "$OSTYPE" = "Windows_NT" -o "$OSTYPE" = "msys" ]; then
    PATH=$PATH:./lib;
    if command -v wx86cl 1>&2 > /dev/null; then  # Preferring CCL on Windows.
        CL="wx86cl";
    elif command -v sbcl 1>&2 > /dev/null; then
        CL="sbcl";
    elif command -v clisp 1>&2 > /dev/null; then
        CL="clisp";
    else
        echo "Could not find SBCL, CCL or CLISP in PATH... aborting.";
        exit 1;
    fi
fi


if [ "$CL" = "sbcl" -o "$CL" = "lx86cl" -o "$CL" = "wx86cl" ]; then
    if [ -f cl-gtk2-gtk.core -a "$CL" = "sbcl" ]; then
        $CL --core cl-gtk2-gtk.core --no-userinit --load init-gtk.lisp --eval "(in-package :clysma)";
    else
        $CL --load init-gtk.lisp --eval "(in-package :clysma)";
    fi
elif [ "$CL" = "clisp" ]; then
    echo "CLISP support not implemented yet."
    exit 1;
fi


if [ "$OSTYPE" = "Linux" -o "$OSTYPE" = "linux-gnu" ]; then
    xset r on;
fi

exit 0;
