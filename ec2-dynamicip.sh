#!/bin/bash

#Copyright (c) 2002-2011 "EMI Science Limited" 
#	source: [https://github.com/emiscience/ec2-dynamicip]
#	website: [http://www.emiscience.com]
#	email: opensource [at] emiscience.com
#	
#This file is part of ec2-dynamicip.
#
#ec2-dynamicip is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

#Config Secrion

# ec2SecurityGroupID		Is the group ID in the Amazon AWS management console.
# 							I sugegst having a separate group which is purely for 
#							yourself and this script. This makes it easier to manage
# 							and also great for debugging and testing purposes.. 
#							You won't be breaking global groups then!
ec2SecurityGroupID="foo";

# secutyAgent				Is the security string which is used to get your external
#							IP address from the ipecho.php script. This string should
#							match the $secureAgent string in the ipecho.php or it won't
#							work.
secureAgent="bar";

# ipechoURL				This is the full URL to the ipecho.php script that you 
#							would have edited and uploaded to a webserver on the web.
ipechoURL="http://www.foobar.com/ipecho.php";

#End Config Section

echo "Starting AWS Security Group Update for your external IP address..";
echo
echo "please wait..."
echo


#get external IP using a secured ipecho.php script which is literally only the following lines:

#		<?php
#		$secureAgent='mN7atcAvJNY3EvIyixmjs64HV5lf7C8nU7nxn90RRLbFefFT2prWGLGKdBfLxzxN';
#
#		if ($_SERVER['HTTP_USER_AGENT'] == $secureAgent){
#			die($ip = $_SERVER['REMOTE_ADDR']);
#		}else{
#			header('Location: http://www.emiaccounts.com/');
#		}
#		exit;
#		?>

# The secureAgent string is literally only a form of authentication so you won't get loads of people
# trying to get their IP using your script. If you want you can totally remove this for public access.


# Assign the IP returned from the above script to EXTERNALIP
externameIP=`curl -A "$secureAgent" $ipechoURL`

# oldIP is pulled from the API by querying the description of the security group. Here is the structure of the response received:
# Note there is a header and contents. First line is the header, and the second is the content:
ec2Response=`ec2-describe-group $ec2SecurityGroupID | grep -E 'all.*ingres.*'`

#Split the response up into handy chunks
oldIPWithCIDR=$(echo $ec2Response | awk '{printf $9}')
oldIP=$(echo $oldIPWithCIDR | awk -F "/" '{print $1}')
oldCIDR=$(echo $oldIPWithCIDR | awk -F "/" '{print $2}')
allowedPorts=$(echo $ec2Response | awk '{printf $6}')

echo
echo "Your Current External IP: $externameIP"

# Validate that there is an UP address reitrned from the OLD IP.

willDeauthoriseIP=1;


# Validate the IP address, kudos to Mitch Frazier at http://www.linuxjournal.com/content/validating-ip-address-bash-script for this.
#if echo "$oldIP" | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/32'
if [[ "$oldIP" =~ ^([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})$ ]]; then
    for (( i=1; i<${#BASH_REMATCH[@]}; ++i ))
    do
      (( ${BASH_REMATCH[$i]} <= 255 )) || { echo "bad ip" >&2; exit 1; willDeauthoriseIP=0;}
    done
else
      echo "bad ip" >&2
      willDeauthoriseIP=0;
      exit 1;
fi

if (($willDeauthoriseIP > 0)); then
	echo
	echo "Existing rule is:"
	echo
	echo "Allow IP Address: $oldIP"
	echo "With IP Mask: $oldCIDR"
	echo "Access To Ports: $allowedPorts"
	echo

	read -p "Do you want to delete this old rule?  " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		echo
		echo "Revoking old rule..."
		echo
		ec2-revoke $ec2SecurityGroupID -P $allowedPorts -s $oldIP/$oldCIDR
		echo
		echo "The old rule was deleted..."
		echo
	else
		echo 
		echo "Leaving old rule behind..."
		echo 
	fi
fi

	read -p "Do you want to add a new rule but with the same settings as the old rule?  " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		echo
		echo "Adding new rule..."
		echo
		ec2-authorize $ec2SecurityGroupID -P $allowedPorts -s ${externameIP}/$oldCIDR
		echo
		echo "The new rule was added"
		echo
	else
		echo
		echo "no rules added."
		echo
	fi

#helper function 
#thanks to whoever that was on Google Groups who posted this fucntion
#if I track the post down I will add you as a mention!

is_validip()
{
	case "$*" in
	""|*[!0-9.]*|*[!0-9]) return 1 ;;
	esac

	local IFS=.  ## local is bash-specific
	set -- $*

        [ $# -eq 4 ] &&
	    [ ${1:-666} -le 255 ] && [ ${2:-666} -le 255 ] &&
	    [ ${3:-666} -le 255 ] && [ ${4:-666} -le 254 ]
}


echo
echo "complete.."
exit 0
