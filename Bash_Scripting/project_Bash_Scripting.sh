#!/bin/bash

if [ "$EUID" -eq 0 ]; then
    while true; do

        echo "================================================================"
        echo "                     USER MANAGMENT SCRIPT                      "
        echo "================================================================"
        echo " "
        echo "Choose an action by entering a number: "
        echo " "
        echo "1.Create User"
        echo "2.Create group"
        echo "3.Assign user to a group"
        echo "4.Check existing users"
        echo "5.Check existing groups"
        echo "6.EXIT"
        echo " "
        echo " "
        echo "================================================================"
        read -p "Enter your choice: " choice
        if [ "$choice" = "1" ]; then
            echo " "
            echo "________________________________________________________________"
            echo "                          CREATE USER                           "
            echo "________________________________________________________________"
            read -p "Enter new username: " username
            echo "Checking if '$username' exists in the system..."
            if getent passwd "$username" > /dev/null; then
                echo "Result: $username already exists."
                echo "Status: OPERATION ABORTED"
                echo "________________________________________________________________"
                echo "                             ERROR                              "
                echo "________________________________________________________________"
                echo "The username you entered already exists on this system."
                echo "Please choose a different username."
                read -p "Press ENTER to return to the main menu..."
            else
                echo "The username '$username' is available."
                useradd -m -s /bin/bash $username
                read -s -p "Enter new password for user '$username': " pass1
                echo " "
                read -s -p "Confirm new password: " pass2
                echo " "
                if [ "$pass1" = "$pass2" ]; then
                    chpasswd <<< "$username:$pass1"
                else
                    echo "________________________________________________________________"
                    echo "                             ERROR                              "
                    echo "________________________________________________________________"
                    echo "The passwords didn't match"
                    read -p "Press ENTER to return to the main menu..."
                fi
                login_shell=$(getent passwd "$username" | cut -d: -f7)
                home_user=$(getent passwd "$username" | cut -d: -f6)
                chown "$username:$username" "/home/$username"
                owner=$(stat -c "%U:%G" "/home/$username")
                #Set permissions: rwx for owner and group
                chmod 770 /home/$username
                #set sticky bit
                chmod +t /home/$username
                perms=$(ls -ld "/home/$username" | awk '{print $1}')
                echo " "
                echo "________________________________________________________________"
                echo "                            Summary                             "
                echo "________________________________________________________________"
                echo "User creation completed successfully."
                echo "Username                                     : $username"
                echo "Primary Group                                : $(id -gn $username)"
                echo "Other groups (including the private group)   : $(id -Gn $username)"
                echo "Login shell                                  : $login_shell"
                echo "User Directory                               : $home_user"
                echo "User Ownership                               : $owner"
                echo "Actual Permissions                           : $perms"
                echo "________________________________________________________________"
                read -p "Press ENTER to return to the main menu..."
            fi
        elif [ "$choice" = "2" ]; then
            echo "________________________________________________________________"
            echo "                          CREATE GROUP                          "
            echo "________________________________________________________________"
            read -p "Enter the name of the group you want to create: " groupname
            echo "Checking if '$groupname' exists in the system..."
            if getent group "$groupname" > /dev/null; then
                echo "Result: $groupname already exists."
                echo "Status: OPERATION ABORTED"
                echo "________________________________________________________________"
                echo "                             ERROR                              "
                echo "________________________________________________________________"
                echo "This group name you entered already exists on this system."
                echo "Please choose a different username."
                read -p "Press ENTER to return to the main menu..."
            else
                echo "The groupname '$groupname' is available."
                groupadd $groupname
                echo "'$groupname' is created successfully"
                echo " "
                echo "Verifying that '$groupname' is created..."
                check=$( getent group $groupname)
                echo "$check"
                echo "________________________________________________________________"
                read -p "Press ENTER to return to the main menu..."
            fi
        elif [ "$choice" = "3" ]; then
            echo " "
            echo "________________________________________________________________"
            echo "                  ASSIGNING A USER TO A GROUP                   "
            echo "________________________________________________________________"
            echo "CAUTION: USER & GROUP MUST EXIST"
            read -p "Enter the username that you want to assign to a group: " user_g
            if getent passwd "$user_g" > /dev/null; then
                echo "This user '$user_g' exists"
                read -p "Enter the group you want to assign '$user_g': " group_g
                if getent group "$group_g" > /dev/null; then
                    usermod -aG $group_g $user_g
                    echo "User '$user_g' is assigned to '$group_g' successfully"
                    echo "________________________________________________________________"
                    read -p "Press ENTER to return to the main menu..."
                else
                    echo " "
                    echo "Group '$group_g' does not exist. Create the group first"
                    echo "Status: OPERATION ABORTED"
                    echo "________________________________________________________________"
                    echo " "
                    echo "                             ERROR                              "
                    echo "________________________________________________________________"
                    echo "Please choose a group that exists!"
                    read -p "Press ENTER to return to the main menu..."
                fi
            else
                echo "Username '$user_g' do not exist"
                echo "Status: OPERATION ABORTED"
                echo "________________________________________________________________"
                echo " "
                echo "                             ERROR                              "
                echo "________________________________________________________________"
                echo "Please choose a user that exists!"
                read -p "Press ENTER to return to the main menu..."
            fi
        elif [ "$choice" = "4" ]; then
            echo "________________________________________________________________"
            echo " "
            echo "                          CHECK USERS                           "
            echo "________________________________________________________________"
            getent passwd | awk -F: '$3 >= 1000 { print $1 }'
            echo "Checking users was completed successfully"
            echo "________________________________________________________________"
            read -p "Press ENTER to return to the main menu..."
        elif [ "$choice" = "5" ]; then
            echo "________________________________________________________________"
            echo " "
            echo "                          CHECK GROUPS                          "
            echo "________________________________________________________________"
            read -p "Enter the group name that you want to check: " ch_group
            if getent group "$ch_group" > /dev/null; then
                getent group $ch_group
                #getent group | awk -F: '$3 >= 1000 { print $1 }'
                echo "Checking groups was completed successfully"
                echo "________________________________________________________________"
                read -p "Press ENTER to return to the main menu..."
            else
                echo "This group does not exist"
                echo "Status: OPERATION ABORTED"
                echo "________________________________________________________________"
                echo " "
                echo "                             ERROR                              "
                echo "________________________________________________________________"
                read -p "Press ENTER to return to the main menu..."
            fi
        elif [ "$choice" = "6" ]; then
            echo "________________________________________________________________"
            echo "Exiting script...."
            exit 1
        else
            echo "Write only numbers from 1 to 6"
            read -p "Press ENTER to return to the main menu..."
        fi
    done
else
    echo "You do not have permission to run this script"
    exit 1
fi
