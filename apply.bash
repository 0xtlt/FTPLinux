#!/bin/bash

CONFIG_FILE="users.yaml"

# Get the version of yq
YQ_VERSION=$(yq --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

# Use version comparison function to check if yq version is less than 4
version_lt() {
    [ "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
}

# Display error and exit if yq version is less than 4
if version_lt $YQ_VERSION "4.0.0"; then
    echo "Error: yq version must be at least 4.0.0. Current version: $YQ_VERSION"
    exit 1
fi

echo "yq version $YQ_VERSION is sufficient."

# Extract usernames using yq and store them in an array
mapfile -t user_list < <(yq e '.users | keys | .[]' $CONFIG_FILE)

# Create or update users with the "ftp_" prefix
for USERNAME in "${user_list[@]}"; do
    # Check if the username starts with "ftp_"
    if [[ "$USERNAME" == ftp_* ]]; then
        PASSWORD=$(yq e ".users.${USERNAME}.password" $CONFIG_FILE)
        DIRECTORY=$(yq e ".users.${USERNAME}.directory" $CONFIG_FILE)

        # Check if the user already exists
        if id "$USERNAME" &>/dev/null; then
            echo "Updating user $USERNAME..."
            # Update the user's password
            echo "$USERNAME:$PASSWORD" | chpasswd
        else
            echo "Creating user $USERNAME with directory $DIRECTORY"
            useradd $USERNAME -p $(openssl passwd -1 $PASSWORD) -d $DIRECTORY -m
            mkdir -p $DIRECTORY
            chown $USERNAME:$USERNAME $DIRECTORY
        fi
    else
        echo "Error: The username $USERNAME must start with 'ftp_'. User not created."
    fi
done

# Remove users with the "ftp_" prefix who are no longer in the list
current_users=$(getent passwd {1000..60000} | cut -d: -f1) # Retrieves users with a UID >= 1000
for user in $current_users; do
    if [[ "$user" == ftp_* && ! " ${user_list[*]} " =~ " ${user} " ]]; then
        echo "Removing user $user not present in users.yaml"
        userdel -r $user
    fi
done
