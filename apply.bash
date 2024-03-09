#!/bin/bash

CONFIG_FILE="users.yaml"

# Get the version of yq
YQ_VERSION=$(yq --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

# Display error and exit if yq version is less than 4
if [[ "$(echo -e "$YQ_VERSION\n4.0.0" | sort -V | head -n1)" != "4.0.0" ]]; then
    echo "Error: yq version must be at least 4.0.0. Current version: $YQ_VERSION"
    exit 1
fi

echo "Using yq version $YQ_VERSION."

# Extract usernames using yq
mapfile -t user_list < <(yq e '.users | keys | .[]' $CONFIG_FILE)

# Create or update users
for USERNAME in "${user_list[@]}"; do
    if [[ "$USERNAME" == ftp_* ]]; then
        PASSWORD=$(yq e ".users.${USERNAME}.password" $CONFIG_FILE)
        DIRECTORY=$(yq e ".users.${USERNAME}.directory" $CONFIG_FILE)
        FILES_DIR="${DIRECTORY}/files"

        if id "$USERNAME" &>/dev/null; then
            echo "Updating user $USERNAME..."
            echo "$USERNAME:$PASSWORD" | chpasswd
        else
            echo "Creating user $USERNAME with directory $DIRECTORY"
            useradd $USERNAME -p $(openssl passwd -1 $PASSWORD) -d $DIRECTORY -m -s /sbin/nologin
        fi

        # Prepare the directory structure with correct permissions
        mkdir -p $FILES_DIR
        chown root:root $DIRECTORY
        chmod 755 $DIRECTORY
        chown $USERNAME:$USERNAME $FILES_DIR
        chmod 700 $FILES_DIR

    else
        echo "Error: Username $USERNAME must start with 'ftp_'. User not created."
    fi
done

# Remove users not in list
for user in $(getent passwd {1000..60000} | cut -d: -f1); do
    if [[ "$user" == ftp_* && ! " ${user_list[*]} " =~ " ${user} " ]]; then
        if pgrep -u "$user" > /dev/null; then
            pkill -9 -u "$user"
            sleep 1 # Give some time for processes to be terminated
        fi
        userdel -r "$user" 2>/dev/null
    fi
done
