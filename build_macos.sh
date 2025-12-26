#!/bin/bash

# Move to script's directory
cd "`dirname "$0"`"

sdlPath="$(cd "./SDL" && pwd -P)"
faudioPath="$(cd "./FAudio" && pwd -P)"

outputFolder="./binaries/osx"
rm -r -f $outputFolder
mkdir -p $outputFolder

logFolder="./logs/osx"
rm -r -f $logFolder
mkdir -p $logFolder

buildFolder="build"

sdlBuild="$sdlPath/$buildFolder"
faudioBuild="$faudioPath/$buildFolder"

# Generate SDL
echo "Generate SDL"

rm -r -f $sdlBuild

cmake -S $sdlPath -B $sdlBuild > "$logFolder/SDL.gen.log"

echo -e "\tDone"

# Build SDL
echo "Build SDL"

cmake --build $sdlBuild --target all -DCMAKE_OSX_DEPLOYMENT_TARGET="10.15" -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" > "$logFolder/SDL.bin.log"

echo -e "\tDone"

# Generate FAudio
echo "Generate FAudio"

rm -r -f $faudioBuild

cmake -S $faudioPath -B $faudioBuild -DSDL3_DIR="$sdlBuild" -DCMAKE_OSX_DEPLOYMENT_TARGET="10.15" -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" > "$logFolder/FAudio.gen.log"

echo -e "\tDone"

# Build FAudio
echo "Build FAudio"

cmake --build $faudioBuild --target FAudio-shared > "$logFolder/FAudio.bin.log"

cp -f "$faudioBuild/libFAudio.dylib" "$outputFolder/libFAudio.dylib"

echo -e "\tDone"
