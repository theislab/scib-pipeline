#!/bin/sh

# enable C compilation in R
CFLAGS_OLD=$CFLAGS
export CFLAGS_OLD
CFLAGS="$(gsl-config --cflags) ${CFLAGS_OLD}"
export CFLAGS
 
LDFLAGS_OLD=$LDFLAGS
export LDFLAGS_OLD
LDFLAGS="$(gsl-config --libs) ${LDFLAGS_OLD}"
export LDFLAGS

# Set rpy2 library path
LD_LIBRARY_PATH_OLD=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH_OLD
export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib/R/lib/"

# Solve error in embedding:
# qt.qpa.plugin: Could not load the Qt platform plugin "xcb" in "" even though it was found.
QT_QPA_PLATFORM_OLD=$QT_QPA_PLATFORM
export QT_QPA_PLATFORM_OLD
export QT_QPA_PLATFORM='offscreen'

# set R home path
R_HOME_OLD=${R_HOME}
export R_HOME_OLD
export R_HOME=${CONDA_PREFIX}/lib/R

# unset system R libs
R_LIBS_OLD=$R_LIBS
export R_LIBS_OLD
export R_LIBS=""
