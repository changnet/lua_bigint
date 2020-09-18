#!/bin/bash

# sh do NOT support array，do NOT run this script with sh

SRC=../boost_1_74_0
DST="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# clear directory if not empty
# if [ ! -z "$(ls -A ./boost)" ]; then
#    rm -R ./boost
# fi

LIST_F=$DST/BOOST_FILES

# run make and catch error message to find out what boost header is missing
# this is ugly and slow but it works

# if terminal's language is not english, run
# unset LANGUAGE
# LC_MESSAGES=C
# to set it as english,this should only affect current terminal

function find_boost_header()
{
    msg=$(make bundled 2>&1)

    F=`echo $msg \
    | grep -Eo 'fatal error: boost(.*): No such file or directory'\
    | sed 's/fatal error: \(.*\): No such file or directory/\1/'`

    if [[ ! -z  $F  ]]; then
        echo $F
        echo $F >> $LIST_F
        cd $SRC
        cp --parent $F $DST
        cd - > /dev/null

        return 1
    fi

    return 0
}

# loop a few times to find missing header file
for i in {1..1024}; do
    find_boost_header

    n=$?
    if [[ "$n" -ne "1" ]]; then
        break
    fi
done

# copy LICENSE
cp $SRC/LICENSE_1_0.txt $DST/boost
