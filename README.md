ec2-dynamicip
==
 <br />
This sript simply pulls your IP address from a secure php script located on a webserver somewhere on the internet. It then talks to the Amazon AWS EC2 API to update a rule in one of your security groups with your new external IP address. If you have any questions, feel free to email me on opensource [at] emiscience.com

Version
----

0.0.1

Prerequisites
-----------

You will need to have the followin installed and workint up before this script will work properly.

1.  [Amazon Web Services]] Amazon Web Services Account
2.	[Amazon Web Services CLI Tools] - Command line tools for Amazon Web Services
		* n.b. if you are using OSX follow the [Starting Amazon EC2 with Mac OS X] guide to install the EC2 tools. I can confirm this works up to and including OSX 10.9 Mavericks.
3. Separate security group for use with this script

Installation
--------------


##### ipecho.php script

1. Copy the script to somewhere with a websites root directory (it can be in a subdirectory too)
2. Permissions are not important
3. Edit the script and set the <code>$secureAgent</code> variable. Use alphanumeric characters [a-Z][0-0]Try to make it fairly long and note it down, you will need it again.
4. test the script with 
```sh
curl -A "stringxN" http://www.foo.com/ipecho.php
```
*    string = the string you created in step 3

This should only return an IP address with no other text..This means that it's working.


##### ec2-dynamicip.sh script

1. Copy the script to a location of your choice. I suggest somewhere which is in your path environment
2. Change the value of <code>ipechoURL</code> to be the full URL of the ipecho.php script. e.g. http://www.foo.com/ipecho.php
3. Change the value of <code>ec2SecurityGroupID</code> to match the security group that you intend to use with this script. <code>Please ensure that you use this script with a SEPARATE security group. This will avert the danger of deleting things that shouldnt be deleted</code>
4. Change the value of <code>secureAgent</code> so that it matches the value of the $secureAgent string in ipecho.php
5. Make the script executable.
```sh
chmod +x ec2-dynamicip.sh
```

Usage
----

To use the script you only have to exectute it. Version 0.0.1 has no command line arguements.

Todo
----
1. Get the script to deal with NO existing rules
2. Have a menu rather than a yes/no wizard so there is a greater choice of things to do
3. Have command line arguements to make it more scriptable

Proof of Concept
----
Below is a screenshot of iTerm (Mac OSX)of me showing you before running the ec2-dynamicip.sh script and after. Before the script, I renewed my DHCP lease getting my another dynamic IP from the ISP (i.e. it's not been authorised to access the example internal server I set up). I then ran the script, agreed to both reauthorising the OLD IP, then agreed to authorising the NEW IP...

Finally, presto, I can now ping the server.<br><br>

![alt text](https://raw.github.com/emiscience/ec2-dynamicip/master/example-images/ec2-dynamicip-in-action.png "ec2-dynamicip.sh Proof Of Concept")


License
----

GNU GENERAL PUBLIC LICENS  Version 3


Other
----
have fun and feel free to contribute! EMI Science wouldn't be where it is today without 
the opensource community and therefor support it fully.

Thankyou - Adrian Sluijters - Managing Director


[Amazon Web Services]:http://aws.amazon.coms
[Amazon Web Services CLI Tools]:http://aws.amazon.com/developertools/351
[Starting Amazon EC2 with Mac OS X]:http://www.robertsosinski.com/2008/01/26/starting-amazon-ec2-with-mac-os-x/

    