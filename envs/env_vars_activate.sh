#!/bin/sh

# enable C compilation in R
CFLAGS_OLD=$CFLAGS
export CFLAGS_OLD
export CFLAGS="$(gsl-config --cflags) ${CFLAGS_OLD}"
 
LDFLAGS_OLD=$LDFLAGS
export LDFLAGS_OLD
export LDFLAGS="$(gsl-config --libs) ${LDFLAGS_OLD}"

# Set rpy2 library path
LD_LIBRARY_PATH_OLD=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH_OLD
export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib/R/lib/"

# Solve error in embedding:
# qt.qpa.plugin: Could not load the Qt platform plugin "xcb" in "" even though it was found.
QT_QPA_PLATFORM_OLD=$QT_QPA_PLATFORM
export QT_QPA_PLATFORM_OLD
export QT_QPA_PLATFORM='offscreen'
