#!/bin/sh

TIMEOUT=1200

check_timeout() {
    if [ $? -eq 124 ]
    then
        echo "**************TIMEOUT*******************"
        echo "-> EXIT"
        exit 0
    else
        echo "**TERMINATE**"
    fi
}

run(){
    echo $0 > $OUT
    LEN=${#INSTANCES[@]}
    for ((i=0; i<$LEN; i++))
    do
        FILE=${!INSTANCES[i]:0:1}
        N=${!INSTANCES[i]:1:1}
        P=${!INSTANCES[i]:2:1}
        echo "---------$i: $FILE -c n=$N -c p=$P --------------"
        echo "---------$i: $FILE -c n=$N -c p=$P --------------" >> $OUT
        { time timeout $TIMEOUT bash -c "qasp2qbf.py --pipe $META $QUANT $DIR$FILE -c n=$N -c p=$P" ; } >> $OUT 2>&1
        check_timeout >> $OUT
    done
}
