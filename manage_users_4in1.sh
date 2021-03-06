#!/usr/bin/env bash

: '

The script accepts a username but if the username is not provided will execute the 
prompt_user function

'

# Create a prompt_user function

prompt_user () {
		# Create a way that by default displays "Enter the account details" 
		# Or give an option to enter a new message
		
        message=${1:-"Enter the account details"}
        echo "$message"
		# Read the user_name variable from user imput
        read -rp "Enter a username: " user_name
		# Read the user_password variable from user imput in silent mode
        read -srp "Enter a password: " user_password
		# Enter a empty line
        echo ""
		# Requesting a password confirmation and assigning
		# the password value to a different value for future validation
        read -srp "Enter the password again: " user_password_check
        # Enter a empty line
		echo ""
}

# Create a check_user function - verifies if user does not exist already

check_user () {
  grep -q \^${1}\: /etc/passwd && return 0
}

# Create a check_user function

create_user () {
	
	# call the prompt_user fuction and add text "Enter new user detail2
	prompt_user "Enter new user detail"
	
	# Create while loop to check if user exists and leave
	# a message in case exists
	while check_user "$user_name" ; do
    prompt_user "The user name you have chosen already exists, please select fresh details"
	done
	
	# Create a while loop to check both passwords entered by the user
	while [ "$user_password" != "$user_password_check" ] ; do
		prompt_user "Passwords didn't match, re-enter details"
	done
	
	# Add the command to create the user
	sudo useradd -m $user_name
	# Add the command to assign a new password to a user
	echo "${user_name}:$user_password" | sudo chpasswd
	# Send a message to out saying the user has been craeted
	echo "$user_name created"
}

# Create function to check if CSV format file exists
# There is not validation on the quility of CSV file provided 
check_file_exists(){
read -rp "Enter the name of the file in CSV format: " file_to_read
if [ -z "$file_to_read" ]; then
echo "You need to enter the name of the file - argument cannot be empty"
return 1
else
[[ -e ./$file_to_read ]]
fi
}

# Create function to parse the CSV file and create users and apply the passwords set on that file

create_user_from_list() {

while ! check_file_exists ; do
echo "Please place a file with name ${file_to_read} in same folder a script"
done

while IFS="," read -r user_name user_password 
do
  if check_user "$user_name"; then
	echo "User exists is not going to be created"
  else
  sudo useradd -m $user_name
  echo "${user_name}:$user_password" | sudo chpasswd
  echo "$user_name created"
  echo ""
  fi
done < <(tail -n +2 $file_to_read)

}

# Create a function to delete a user
delete_user () {
	# Read the user_name variable from user imput 
	read -rp "Enter user to delete: " user_name
	# Create a while loop to if user exists
	while  ! check_user "$user_name" ; do
		echo "User not found"
		return 1
	done
	# Add the command to delete the user and home directory of user
	sudo userdel -r $user_name
	# Send a message to out saying the user has been deleted
	echo "$user_name deleted"
}

if [ -z $1 ]; then

	while true ; do
	  clear
	  echo ''' User Management Tool:
	  
	  4 in 1 tool:
	  
	  shell command: ./manage_users.sh <user_name> <user_password>
	  
	  Menu:
	  
	  Press 1 to Create User
	  Press 2 to Delete User1
	  Press 3 to Create users from file
	  Press 4 to Exit

	'''
	read -rsn1 
	  case "$REPLY" in 
		1) create_user;;
		2) delete_user;;
		3) create_user_from_list;;
		4) exit 0;;
	  esac
	  read -rn1 -p "Press any key"
	done
else 
	user_name=$1
	user_password=$2
	sudo useradd -m $user_name && echo "$user_name created"
	if [ $? = 0 ]; then 
	check_user $user_name && echo "${user_name}:$user_password" | sudo chpasswd && echo "password set for ${user_name}"
	fi
fi
