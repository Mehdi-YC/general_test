#!/bin/bash

# Define output file path
mkdir -p ~/backup
cd ~/backup
rm app_backup_$(date +'%d-%m-%Y').sh
output_file="app_backup_$(date +'%d-%m-%Y').sh"
touch $output_file

# Initialize output file
echo "#!/bin/bash" > $output_file
echo "" >> $output_file

# Check for required packages and add installation commands to output file
if ! command -v podman &> /dev/null; then
    echo "Podman not found. Adding installation command to $output_file"
    echo "sudo dnf install podman -y" >> $output_file
    echo "" >> $output_file
fi

if ! command -v starship &> /dev/null; then
    echo "Starship not found. Adding installation command to $output_file"
    echo "sh -c \"\$(curl -fsSL https://starship.rs/install.sh)\"" >> $output_file
    echo "" >> $output_file
fi

if ! command -v nu &> /dev/null; then
    echo "Nushell not found. Adding installation command to $output_file"
    echo "sh -c \"\$(curl -fsSL https://www.nushell.sh/install.sh)\"" >> $output_file
    echo "" >> $output_file
fi

if ! command -v flatpak &> /dev/null; then
    echo "Flatpak not found. Adding installation command to $output_file"
    echo "sudo dnf install flatpak -y" >> $output_file
    echo "" >> $output_file
fi

if ! command -v pip &> /dev/null; then
    echo "Python pip not found. Adding installation command to $output_file"
    echo "sudo dnf install python3-pip -y" >> $output_file
    echo "" >> $output_file
fi

#install vscodium : 
if ! [ -x "$(command -v codium)" ]; then
  sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
  printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscodium.repo
  sudo dnf install codium
fi

# Add command to enable Flathub
if ! flatpak remote-list | grep -q "flathub"; then
    echo "Flathub not enabled. Adding command to enable to $output_file"
    echo "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo" >> $output_file
    echo "" >> $output_file
fi

# Add command to add Starship to bashrc
if ! grep -q "starship init bash" ~/.bashrc; then
    echo "Starship not found in bashrc. Adding command to add to $output_file"
    echo "echo 'eval \"\$(starship init bash)\"' >> ~/.bashrc" >> $output_file
    echo "" >> $output_file
fi

# Make output file executable
chmod +x $output_file

cat <<EOF > $output_file
#!/bin/bash

# Install flatpaks
EOF

# Check if Flatpak is installed
if command -v flatpak &> /dev/null; then
    # List installed flatpaks
    flatpak list --app --columns=application | awk '{print $1}' | while read app; do
        echo "flatpak install -y $app" >> $output_file
    done
fi

# Install Rust packages
cat <<EOF >> $output_file

# Install Rust packages
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source \$HOME/.cargo/env
EOF

# Check if Rust is installed
if command -v rustc &> /dev/null; then
    # List installed Rust packages
    cargo install --list | awk '{print $1}' | while read pkg; do
        echo "cargo install $pkg" >> $output_file
    done
fi

# Install Python packages
cat <<EOF >> $output_file

# Install Python packages
EOF

# Check if Python is installed
if command -v python &> /dev/null; then
    # List installed Python packages
    pip freeze | cut -d '=' -f 1 | while read pkg; do
        echo "pip install $pkg" >> $output_file
    done
fi

# Install VSCodium extensions
cat <<EOF >> $output_file

# Install VSCodium extensions
EOF

# Check if VSCodium is installed
if command -v codium &> /dev/null; then
    # List installed VSCodium extensions
    codium --list-extensions | while read ext; do
        echo "codium --install-extension $ext" >> $output_file
    done
fi

# Install GNOME extensions
cat <<EOF >> $output_file

# Install GNOME extensions
EOF

# Check if GNOME is installed
if command -v gnome-shell &> /dev/null; then
    # List installed GNOME extensions
    gnome-extensions list --enabled | awk '{print $1}' | while read ext; do
        echo "gnome-extensions install $ext" >> $output_file
    done
fi

# Make the script executable
chmod +x $output_file

echo "Script to install packages created: $output_file"