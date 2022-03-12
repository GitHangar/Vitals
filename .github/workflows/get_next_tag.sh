#!/bin/bash

set -o pipefail

# get latest tag that looks like a semver (with or without v)
tag_context=${TAG_CONTEXT:-repo}
case "$tag_context" in
    *repo*)
        echo "here 1"
        taglist="$(git for-each-ref --sort=-v:refname --format '%(refname:lstrip=2)' | grep -E "$tagFmt")"
        tag="$(semver $taglist | tail -n 1)"
        ;;
    *branch*)
        echo "here 2"
        taglist="$(git tag --list --merged HEAD --sort=-v:refname | grep -E "$tagFmt")"
        tag="$(semver $taglist | tail -n 1)"
        ;;
esac

# if there are none, start tags at INITIAL_VERSION which defaults to 0.0.0
if [ -z "$tag" ]; then
    echo "there 1"
    tag="$(jq .version metadata.json).0.0"
else
    echo "there 2"
    tag="$(semver -i minor $tag)"
fi

echo "---"
echo $tag
echo "---"

# export env var for subsequent steps
echo "TAG=$tag" >> $GITHUB_ENV