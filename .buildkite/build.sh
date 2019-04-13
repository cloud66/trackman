#!/bin/bash

channel="dev"
version=$(git describe --tags --always)
if [[ $BUILDKITE_TAG -ne "" ]]
  then
    version=$BUILDKITE_TAG
    channel="stable"
fi
if [[ $BUILDKITE_BRANCH -eq "master" ]]
  then
    channel="edge"
fi

force="false"
if [[ $FORCE == "--force" ]]
  then
    force="true"
fi

echo "Building $channel/$version"

mkdir build

curl -s http://downloads.cloud66.com.s3.amazonaws.com/trackman/versions.json | jq '.versions |= map(if (.channel == "'$channel'") then .version = "'$version'" else . end) | .versions |= map(if (.channel == "'$channel'") then .force = '$force' else . end)' > build/versions.json
echo "Current Versions"
cat build/versions.json | jq -r '.versions | map([.channel, .version] | join(": ")) | .[]'
echo

echo "Building"

docker run -i -e GITHUB_TOKEN=$GITHUB_TOKEN --rm -w /gopath/src/github.com/cloud66/trackman -v $(pwd):/gopath/src/github.com/cloud66/trackman cloud66/gobuildchain:2 /bin/bash << COMMANDS
echo "Compiling $channel/$version"
gox -ldflags "-X github.com/cloud66/trackman/utils.Version=$version -X github.com/cloud66/trackman/utils.Channel=$channel" -os="darwin linux windows" -arch="amd64" -output "build/{{.OS}}_{{.Arch}}_$version"
if [[ $channel -eq "stable" ]]
  then
    ghr -soft $version build/
  else
    echo "Not a release"
fi
chown -R 999:998 build
COMMANDS

source ~/.profile && s3cmd --recursive --acl-public put build/. s3://downloads.cloud66.com/trackman/
