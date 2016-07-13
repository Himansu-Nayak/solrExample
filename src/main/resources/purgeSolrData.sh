#!/bin/sh
#
### BEGIN INIT INFO
##Description: Script for cleaning the data from solr based on the solr core and number of days data to be hold provided by the operator.
##              This can be executed when the solr index is locked(Reasons could be the sfs allocated is full).
### END INIT INFO


TOUCH=/bin/touch
AWK=/bin/awk
CHMOD=/bin/chmod
GREP=/bin/grep
RESPFILE=/tmp/responsefile
CURLCMD=/tmp/curl
CURLCMD1=/tmp/curl1
$TOUCH $RESPFILE
$TOUCH $CURLCMD
$TOUCH $CURLCMD1
$CHMOD 777 $CURLCMD1


check_for_user_confirmation ()
 {
 REPLY=Y
 while [ "$REPLY" == "Y" ] || [ "$REPLY" != "y" ]
 do
  echo "All the data from core:: $CORENAME will be deleted"
  echo -e "\t\tPress 'y' to continue\t\t\tPress 'n' to quit"
  read -n1 -s
      case "$REPLY" in
      "n")  exit                      ;;
      "N")  echo "case sensitive!!"   ;;
      "y")  clear                     ;;
      "Y")  echo "case sensitive!!"   ;;
      * )  echo "Invalid Option"     ;;
 esac
 done
 }

numOfArguments=$#
CORENAME=$1
NUMOFDAYS=$2

IPADDRESS=`getent hosts|$GREP solr|$AWK '{print $1}'`

if [ "$numOfArguments" -eq 1 ]
#Case for deleting all the data from a particular core provided by the user.
then
check_for_user_confirmation
echo "########################################################################################"
echo "Removing the data from the collection:: ${CORENAME}"
echo "########################################################################################"
echo "curl http://IPADDRESS:8983/solr/CORENAME/update/?commit=true -H "Content-Type: text/xml\" -d \"\<delete\>\<query\>*:*\</query\>\</delete\>\" | sed -e "s/CORENAME/${CORENAME}/g"|sed -e "s/IPADDRESS/${IPADDRESS}/g" > $CURLCMD
$AWK '{print $1 " " $2 " " $3 " \""$4 " " $5 " " $6 " " $7}' $CURLCMD > $CURLCMD1
$CURLCMD1 > $RESPFILE
$GREP 'status\">0' $RESPFILE
if [ $? -eq 0 ]
then
echo "########################################################################################"
echo "Successfully removed data from the core:: ${CORENAME}"
echo "########################################################################################"
else
echo "########################################################################################"
echo "Failed to remove data from the core:: ${CORENAME}. See below response from solr for more details."
echo "########################################################################################"
cat $RESPFILE
echo "########################################################################################"
fi
elif [ "$numOfArguments" -eq 2 ]
#Case for deleting the data from a particular core and for few days provided by the user.
then
echo "########################################################################################"
echo "Removing the data from the core:: ${CORENAME}. The data for only last $NUMOFDAYS days would be available in solr"
echo "########################################################################################"
echo "curl http://IPADDRESS:8983/solr/CORENAME/update/?commit=true -H "Content-Type: text/xml\" -d \"\<delete\>\<query\>insertTime:[* TO NOW-NUMOFDAYSDAYS]\</query\>\</delete\>\" | sed -e "s/CORENAME/${CORENAME}/g"|sed -e "s/NUMOFDAYS/${NUMOFDAYS}/g"|sed -e "s/IPADDRESS/${IPADDRESS}/g" > $CURLCMD
$AWK '{print $1 " " $2 " " $3 " \""$4 " " $5 " " $6 " " $7 " " $8 " " $9}' $CURLCMD > $CURLCMD1
$CURLCMD1 > $RESPFILE
$GREP 'status\">0' $RESPFILE
if [ $? -eq 0 ]
then
echo "########################################################################################"
echo "Successfully removed data from the core:: ${CORENAME}"
echo "########################################################################################"
else
echo "########################################################################################"
echo "Failed to remove data from the core:: ${CORENAME}. See below response from solr for more details."
echo "########################################################################################"
cat $RESPFILE
echo "########################################################################################"
fi
else
echo "==============>HELP----->SCRIPT OPTIONS<=============="
echo "1. Delete All Records  : command <CORE NAME >"
echo "   Example : ./script.sh collection1"
echo "2. Delete Records Based on Time : command <CORE NAME > <Number of days of data to be hold>"
echo "   Example : ./script.sh collection1 20"
fi

rm -rf $RESPFILE
rm -rf $CURLCMD
rm -rf $CURLCMD1


