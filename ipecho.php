<?php

/*
Copyright (c) 2002-2011 "EMI Science Limited" 
	[http://www.emiscience.com]

This file is part of ec2-dynamicip.

ec2-dynamicip is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

$secureAgent='bar';

if ($_SERVER['HTTP_USER_AGENT'] == $secureAgent){
	die($ip = $_SERVER['REMOTE_ADDR']);
}else{
	header('Location: http://www.emiaccounts.com/');
}
exit;
?>
