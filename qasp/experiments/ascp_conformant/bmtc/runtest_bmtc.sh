#!/bin/sh

#lparse -c h=2  -c w=1 bmtc_2_2.smo  | smodels
#lparse -c h=6  -c w=1 bmtc_4_2.smo  | smodels
#lparse -c h=10 -c w=1 bmtc_6_2.smo  | smodels
#lparse -c h=12 -c w=1 bmtc_8_4.smo  | smodels
#lparse -c h=16 -c w=1 bmtc_10_4.smo | smodels

TIMEOUT=10
OUT="result_bmtc"

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
{ time timeout $TIMEOUT lparse -c h=2  -c w=1 bmtc_2_2.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--2--"
echo "--2--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=6  -c w=1 bmtc_4_2.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--3--"
echo "--3--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=10 -c w=1 bmtc_6_2.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--4--"
echo "--4--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=12 -c w=1 bmtc_8_4.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--5--"
echo "--5--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=16 -c w=1 bmtc_10_4.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT
