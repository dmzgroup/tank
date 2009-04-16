#!/bin/sh

. ../scripts/envsetup.sh

if [ "$1" = "" ] ; then
   export EXTRA_FILE=config/blue.xml ;
fi

$RUN_DEBUG$BIN_HOME/dmzAppQt -f config/runtime.xml config/resource.xml config/common.xml config/audio.xml config/input.xml config/net.xml config/render.xml config/tank.xml config/tank_overlay.xml config/tank_score.xml config/tank_help.xml config/lua.xml config/pick.xml $* $EXTRA_FILE
