#!/bin/bash

# generates cpp with google's protobuf implementation. Not used in firmware, but used in unit test code
# do some renames so the names don't cause conflicts when both are used

PROTO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "$PROTO_DIR" > /dev/null # .option files are read from execution directory, so have to cd into this dir 

rm -rf "test"

mkdir -p "test/proto"
mkdir -p "test/cpp"
mkdir -p "test/tmp_cpp"

# copy proto files with _test appended and fix includes to prevent name clashes
for file in *.proto 
do
  testfile="test/proto/${file%.proto}_test.proto"
  cp -f "$file" "$testfile"
  sed -i 's/brewblox.proto/brewblox_test.proto/g' "$testfile"
  sed -i 's/nanopb/nanopb_test/g' "$testfile"
  sed -i 's/ActuatorDigital.proto/ActuatorDigital_test.proto/g' "$testfile"
  sed -i 's/AnalogConstraints.proto/AnalogConstraints_test.proto/g' "$testfile"
  sed -i 's/DigitalConstraints.proto/DigitalConstraints_test.proto/g' "$testfile"
  sed -i 's/BrewbloxOptions/BrewbloxTestOptions/g' "$testfile"
done

# generate code
cd test/proto
protoc *.proto --cpp_out=../tmp_cpp --proto_path ${PROTO_DIR}/test/proto

#rename .cc files to .cpp, skip nanopb because it is already included in the build
cd ../tmp_cpp
for file in *.cc 
do
  mv "$file" "${file%.cc}.cpp"
done

rsync -r --checksum . ../cpp/ --delete

popd > /dev/null
