#!/bin/bash

VERSION=$1

if [ -z "$VERSION" ]
then
  echo "No version argument supplied. Please provide a version as first argument. Example: ./bin/build_release_packages.sh 0.0.1"
  exit 1
fi

echo "Building Android Package"
flutter build aar --no-profile --no-debug --build-number=$VERSION

echo "Building iOS Package"
flutter build ios-framework --cocoapods --no-profile --no-debug