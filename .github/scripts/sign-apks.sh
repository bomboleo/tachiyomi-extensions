#!/bin/bash
set -e
shopt -s globstar nullglob extglob

TOOLS="$(ls -d ${ANDROID_HOME}/build-tools/* | tail -1)"

# Get APKs from previous jobs' artifacts
cp -R ~/apk-artifacts/ $PWD
APKS=( **/*".apk" )

# Fail if too little extensions seem to have been built
if [ "${#APKS[@]}" -le "100" ]; then
    echo "Insufficient amount of APKs found. Please check the project configuration."
    exit 1
else
    echo "Signing ${#APKS[@]} APKs"
fi

# Take base64 encoded key input and put it into a file
STORE_PATH=$PWD/signingkey.jks
rm -f $STORE_PATH && touch $STORE_PATH
echo $1 | base64 -d > $STORE_PATH

STORE_ALIAS=$2
export KEY_STORE_PASSWORD=$3
export KEY_PASSWORD=$4

DEST=$PWD/apk
rm -rf $DEST && mkdir -p $DEST

MAX_PARALLEL=5

# Sign all of the APKs
for APK in ${APKS[@]}; do
    (
        echo "Signing $APK"
        BASENAME=$(basename $APK)
        APKNAME="${BASENAME%%+(-release*)}.apk"
        APKDEST="$DEST/$APKNAME"

        # AGP already zipaligns APKs
        # ${TOOLS}/zipalign -c -v -p 4 $APK

        cp $APK $APKDEST
        ${TOOLS}/apksigner sign --ks $STORE_PATH --ks-key-alias $STORE_ALIAS --ks-pass env:KEY_STORE_PASSWORD --key-pass env:KEY_PASSWORD $APKDEST
    ) &

    # Allow to execute up to $MAX_PARALLEL jobs in parallel
    if [[ $(jobs -r -p | wc -l) -ge $MAX_PARALLEL ]]; then
        wait -n
    fi
done

wait

rm $STORE_PATH
unset KEY_STORE_PASSWORD
unset KEY_PASSWORD
