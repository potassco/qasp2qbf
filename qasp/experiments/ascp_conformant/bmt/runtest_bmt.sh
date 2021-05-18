#!/bin/sh

#lparse -c h=2  -c w=1 bmt_2_2.smo  | smodels
#lparse -c h=4  -c w=1 bmt_4_2.smo  | smodels
#lparse -c h=6  -c w=1 bmt_6_2.smo  | smodels
#lparse -c h=8  -c w=1 bmt_8_4.smo  | smodels
#lparse -c h=10 -c w=1 bmt_10_4.smo | smodels

TIMEOUT=1000
OUT="result_bmt"

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
{ time timeout $TIMEOUT lparse -c h=2  -c w=1 bt_2_2.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--2--"
echo "--2--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=4  -c w=1 bt_4_2.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--3--"
echo "--3--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=6  -c w=1 bt_6_2.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--4--"
echo "--4--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=8  -c w=1 bt_8_4.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--5--"
echo "--5--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=10 -c w=1 bt_10_4.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT
