#!/bin/sh


TIMEOUT=1800
OUT="result_med"

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
{ time timeout $TIMEOUT lparse -c h=1  -c w=1  med1.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--2--"
echo "--2--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=5  -c w=5  med2.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--3--"
echo "--3--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=5  -c w=5  med3.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--4--"
echo "--4--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=5  -c w=5  med4.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT

echo "--5--"
echo "--5--" >> $OUT
{ time timeout $TIMEOUT lparse -c h=5  -c w=5  med5.smo  | smodels ; } 2>> $OUT
check_timeout >> $OUT
