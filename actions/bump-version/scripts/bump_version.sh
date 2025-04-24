#!/bin/bash

set -euo pipefail

TYPE=$1
FILE=$2

# Validate input
if [[ ! "$TYPE" =~ ^(major|minor|patch)$ ]]; then
  echo "Error: Invalid bump type '$TYPE'"
  echo "Usage: bump_version.sh [major|minor|patch] [path-to-Configuration.kt]"
  exit 1
fi

# Validate file exists and is readable
if [[ ! -f "$FILE" ]]; then
  echo "Error: File not found: $FILE"
  exit 1
fi

if [[ ! -r "$FILE" ]]; then
  echo "Error: File is not readable: $FILE"
  exit 1
fi

# Extract current version numbers from the file
major=$(grep 'const val majorVersion' "$FILE" | grep -o '[0-9]\+' || echo "")
minor=$(grep 'const val minorVersion' "$FILE" | grep -o '[0-9]\+' || echo "")
patch=$(grep 'const val patchVersion' "$FILE" | grep -o '[0-9]\+' || echo "")

# Validate version numbers were found
if [[ -z "$major" ]] || [[ -z "$minor" ]] || [[ -z "$patch" ]]; then
  echo "Error: Could not find all version numbers in $FILE"
  echo "Make sure the file contains:"
  echo "  const val majorVersion = X"
  echo "  const val minorVersion = Y"
  echo "  const val patchVersion = Z"
  exit 1
fi

# Validate version numbers are integers
if ! [[ "$major" =~ ^[0-9]+$ ]] || ! [[ "$minor" =~ ^[0-9]+$ ]] || ! [[ "$patch" =~ ^[0-9]+$ ]]; then
  echo "Error: Invalid version numbers found in $FILE"
  exit 1
fi

# Increment version based on the bump type
if [[ $TYPE == "major" ]]; then
  major=$((major + 1))
  minor=0
  patch=0
elif [[ $TYPE == "minor" ]]; then
  minor=$((minor + 1))
  patch=0
elif [[ $TYPE == "patch" ]]; then
  patch=$((patch + 1))
fi

# Create a backup of the original file
cp "$FILE" "${FILE}.bak"

# Update the file with new version values
if ! sed -i'' -E "s/const val majorVersion = [0-9]+/const val majorVersion = $major/" "$FILE"; then
  echo "Error: Failed to update major version"
  mv "${FILE}.bak" "$FILE"
  exit 1
fi

if ! sed -i'' -E "s/const val minorVersion = [0-9]+/const val minorVersion = $minor/" "$FILE"; then
  echo "Error: Failed to update minor version"
  mv "${FILE}.bak" "$FILE"
  exit 1
fi

if ! sed -i'' -E "s/const val patchVersion = [0-9]+/const val patchVersion = $patch/" "$FILE"; then
  echo "Error: Failed to update patch version"
  mv "${FILE}.bak" "$FILE"
  exit 1
fi

# Remove backup file if everything succeeded
rm "${FILE}.bak"

echo "Successfully updated to version $major.$minor.$patch"
echo "RELEASE_VERSION=$major.$minor.$patch" >> $GITHUB_OUTPUT

