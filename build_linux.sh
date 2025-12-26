#!/bin/bash

# Move to script's directory
cd "`dirname "$0"`"

arch=$1

sdlPath="$(cd "./SDL" && pwd -P)"
faudioPath="$(cd "./FAudio" && pwd -P)"

outputFolder="./binaries/linux-$arch"
rm -r -f $outputFolder
mkdir -p $outputFolder

logFolder="./logs/linux-$arch"
rm -r -f $logFolder
mkdir -p $logFolder

buildFolder="build"

sdlBuild="$sdlPath/$buildFolder"
faudioBuild="$faudioPath/$buildFolder"

# Generate SDL
echo "Generate SDL"

rm -r -f $sdlBuild

cmake -S $sdlPath -B $sdlBuild -DCMAKE_BUILD_TYPE=Release > "$logFolder/SDL.gen.log"

echo -e "\tDone"

# Build SDL
echo "Build SDL"

cmake --build $sdlBuild --target all > "$logFolder/SDL.bin.log"

echo -e "\tDone"

# Generate FAudio
echo "Generate FAudio"

rm -r -f $faudioBuild

cmake -S $faudioPath -B $faudioBuild -DSDL3_DIR="$sdlBuild" -DCMAKE_BUILD_TYPE=Release > "$logFolder/FAudio.gen.log"

echo -e "\tDone"

# Build FAudio
echo "Build FAudio"

cmake --build $faudioBuild --target FAudio-shared > "$logFolder/FAudio.bin.log"

cp -f "$faudioBuild/libFAudio.so" "$outputFolder/libFAudio.so"

echo -e "\tDone"
