#!/bin/sh

#lparse -c h=3  -c w=1  domino_1.smo | smodels
#lparse -c h=5  -c w=4  domino_2.smo | smodels
#lparse -c h=7  -c w=8  domino_3.smo | smodels
#lparse -c h=9  -c w=16 domino_4.smo | smodels
#lparse -c h=11 -c w=32 domino_5.smo | smodels

TIMEOUT=1800
OUT="result_dom"

check_timeout() {
    if [ $? -eq 124 ]
    then
        echo "TIMEOUT" 2>> $OUT
        echo "EXIT"
        exit 0
    else
        echo "OK" 2>> $OUT
    fi
}

echo "--1--"
echo "--1--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=3  -c w=1  domino_1.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--2--"
echo "--2--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=5  -c w=4  domino_2.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--3--"
echo "--3--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=7  -c w=8  domino_3.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--4--"
echo "--4--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=9  -c w=16 domino_4.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--5--"
echo "--5--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=11 -c w=32 domino_5.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT
