#!/bin/bash

# generates cpp with google's protobuf implementation. Not used in firmware, but used in unit test code
# do some renames so the names don't cause conflicts when both are used
set -e

PROTO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "$PROTO_DIR" > /dev/null # .option files are read from execution directory, so have to cd into this dir 

rm -rf "test/proto"
rm -rf "test/tmp_cc"

mkdir -p "test/proto"
mkdir -p "test/cpp"
mkdir -p "test/tmp_cpp"
mkdir -p "test/tmp_cc"

# copy proto files with _test appended and fix includes to prevent name clashes
for file in *.proto 
do
  testfile="test/proto/${file%.proto}_test.proto"
  cp -f "$file" "$testfile"
  sed -i 's/brewblox/brewblox_test/g' "$testfile"
  sed -i 's/BrewBlox/BrewBlox_test/g' "$testfile"
  sed -i 's/nanopb/nanopb_test/g' "$testfile"
  sed -i 's/ActuatorDigital.proto/ActuatorDigital_test.proto/g' "$testfile"
  sed -i 's/AnalogConstraints.proto/AnalogConstraints_test.proto/g' "$testfile"
  sed -i 's/DigitalConstraints.proto/DigitalConstraints_test.proto/g' "$testfile"
  sed -i 's/IoArray.proto/IoArray_test.proto/g' "$testfile"
  sed -i 's/SetpointSensorPair.proto/SetpointSensorPair_test.proto/g' "$testfile"
done

# generate code
cd test/proto
protoc "${PROTO_DIR}/test/proto"/*.proto --cpp_out=../tmp_cc --proto_path "${PROTO_DIR}/test/proto"

# rename .cc files to .cpp, skip nanopb because it is already included in the build
# use rsync to prevent touching files that have not really changed
cd ../tmp_cc
for file in *.cc 
do
  mv "$file" "../tmp_cpp/${file%.cc}.cpp"
done
for file in *.h
do
  mv "$file" "../tmp_cpp/$file"
done
  
cd ../tmp_cpp
rsync -r --checksum . ../cpp/ --delete

popd > /dev/null
