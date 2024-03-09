# FTPLinux

FTPLinux is a streamlined solution designed for managing FTP users on Linux systems. It leverages `yq` for handling YAML configurations, offering a straightforward way to manage user accounts and settings.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- `yq` version 4 or higher
- Bash environment

## Getting Started

**Note:** The instructions below are tailored for a general Linux environment. If you're using Docker for testing, ensure you're familiar with Docker commands and environments.

1. **Install yq**

Ensure that you have `yq` version 4 or higher installed. You can check your version with:

```sh
yq --version
```

If you need to install or upgrade `yq`, follow the instructions on the [official yq GitHub page](https://github.com/mikefarah/yq).

OR

```sh
wget https://github.com/mikefarah/yq/releases/download/v4.42.1/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq
```

2. **Clone the Repository**

If applicable, clone the repository where `FTPLinux` is hosted to access the configuration files and scripts.

```sh
git clone https://github.com/0xtlt/FTPLinux.git
cd FTPLinux
```

3. **Configure FTP Users**

Edit the `users.yaml` file to define the FTP users and their settings. Here's an example configuration:

```yaml
users:
  ftp_user1:
    password: "password1"
    directory: "/home/user1"
  ftp_user2:
    password: "password2"
    directory: "/home/user2"
```

4. **Run the Setup Script**

Execute the `apply.bash` script to apply the configurations specified in `users.yaml`.

```sh
./apply.bash
```

## Configuration Details

- **`users.yaml`**: This YAML file contains the configuration for each FTP user. Adjust this file to manage FTP user settings.

## Contribution

Your contributions are welcome! If you'd like to improve FTPLinux or suggest features, please feel free to fork the repository, make your changes, and submit a pull request.
