#!/bin/sh
DEPTH=../../..
lmk -m opt -b
cp -RL $DEPTH/bin/macos-opt/tankdemo.app $DEPTH
mkdir $DEPTH/tankdemo.app/Contents/Frameworks/Qt
cp $DEPTH/depend/Qt/QtCore $DEPTH/tankdemo.app/Contents/Frameworks/Qt
cp $DEPTH/depend/Qt/QtGui $DEPTH/tankdemo.app/Contents/Frameworks/Qt
cp $DEPTH/depend/Qt/QtXml $DEPTH/tankdemo.app/Contents/Frameworks/Qt
cp $DEPTH/depend/Qt/QtSvg $DEPTH/tankdemo.app/Contents/Frameworks/Qt
cp $DEPTH/depend/Qt/QtOpenGL $DEPTH/tankdemo.app/Contents/Frameworks/Qt
OSGDIR=$DEPTH/tankdemo.app/Contents/Frameworks/osg
OSGPLUGINDIR=$DEPTH/tankdemo.app/Contents/PlugIns/
mkdir $OSGDIR
mkdir $OSGPLUGINDIR
cp $DEPTH/depend/osg/lib/libosg.dylib $OSGDIR
cp $DEPTH/depend/osg/lib/libosgSim.dylib $OSGDIR
cp $DEPTH/depend/osg/lib/libosgGA.dylib $OSGDIR
cp $DEPTH/depend/osg/lib/libosgViewer.dylib $OSGDIR
cp $DEPTH/depend/osg/lib/libosgParticle.dylib $OSGDIR
cp $DEPTH/depend/osg/lib/libosgUtil.dylib $OSGDIR
cp $DEPTH/depend/osg/lib/libOpenThreads.dylib $OSGDIR
cp $DEPTH/depend/osg/lib/libosgText.dylib $OSGDIR
cp $DEPTH/depend/osg/lib/libosgTerrain.dylib $OSGDIR
cp $DEPTH/depend/osg/lib/libosgDB.dylib $OSGDIR
cp $DEPTH/depend/osg/lib/libosgFX.dylib $OSGDIR
cp $DEPTH/depend/osg/lib/osgdb_qt.so $OSGPLUGINDIR
cp $DEPTH/depend/osg/lib/osgdb_ive.so $OSGPLUGINDIR
cp $DEPTH/depend/osg/lib/osgdb_osgsim.so $OSGPLUGINDIR
cp $DEPTH/depend/osg/lib/osgdb_freetype.so $OSGPLUGINDIR
hdiutil create -srcfolder $DEPTH/tankdemo.app $DEPTH/tankdemo-`cat $DEPTH/tmp/macos-opt/mbraapp/buildnumber.txt`.dmg
hdiutil internet-enable -yes -verbose $DEPTH/tankdemo-`cat $DEPTH/tmp/macos-opt/mbraapp/buildnumber.txt`.dmg
rm -rf $DEPTH/tankdemo.app/
