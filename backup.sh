# get empty backup.sh
mkdir -p ~/backup
rm ~/backup/app_backup_$(date +'%d-%m-%Y').sh
cat <<EOT >> ~/backup/app_backup_$(date +'%d-%m-%Y').sh
#install flatpak and add flathub : 
if ! [ -x "$(command -v flatpak)" ]; then
  sudo dnf install flatpak
fi
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo


#install vscodium : 
if ! [ -x "$(command -v codium)" ]; then
  sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
  printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscodium.repo
  sudo dnf install codium
fi


# install rust : 
if ! [ -x "$(command -v cargo)" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  source \$HOME/.cargo/env
  cargo install  hyperfine mdcat zellij miniserve just bat hoard-rs
fi


#install pip if not installed :
if ! [ -x "$(command -v pip)" ]; then
  sudo dnf install python3-pip
fi

# installing some usefull dnf packages : 
sudo dnf install podman podman-docker jq tmux htop  wget curl neovim git nodejs npm ansible afetch gcc jq unzip zip -y

sudo dnf copr enable alciregi/distrobox
sudo dnf install distrobox

sudo dnf copr enable zeno/scrcpy
sudo dnf install scrcpy


echo "Installing nvchad"
cd
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim
mkdir .config
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim


# my omt mod
cd
git clone https://github.com/mehdi-yc/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .

#installing starship
curl -sS https://starship.rs/install.sh | sh
cd
source ~/.bashrc
echo 'eval "$(starship init bash)"' >> ~/.bashrc

# starship for nushell
mkdir ~/.cache/starship
sh -c \"\$(curl -fsSL https://www.nushell.sh/install.sh)
starship init nu | save ~/.cache/starship/init.nu

echo "source ~/.cache/starship/init.nu" | save --raw --append $nu.config-path

# installing lazydocker (for podman)
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
sudo cp lazydocker /usr/bin/lazydocker

EOT

echo -e "\n# listing flatpaks pips and crates to install  : " >>  ~/backup/app_backup_$(date +'%d-%m-%Y').sh

echo -e "\n#flatpaks..."
echo -e "\n\n#flatpaks : " >>  ~/backup/app_backup_$(date +'%d-%m-%Y').sh
flatpak list --columns=app | sort | uniq | tail -n +2 | while read line; do echo flatpak install ${line}; done >> ~/backup/app_backup_$(date +'%d-%m-%Y').sh


echo -e "\n#python packages..." 
echo -e "\n\n#python packages : " >>  ~/backup/app_backup_$(date +'%d-%m-%Y').sh
echo pip install $(pip freeze | cut -d "=" -f1  | sort -h | uniq | sed ':a;N;$!ba;s/\n/ /g') >>  ~/backup/app_backup_$(date +'%d-%m-%Y').sh

echo -e "\n#Rust crates..."
echo -e "\n\n#Rust crates : " >>  ~/backup/app_backup_$(date +'%d-%m-%Y').sh
echo cargo install $( cargo install --list c | awk '/^\w/ { print $1 }'| sort -h | uniq | sed ':a;N;$!ba;s/\n/ /g') >>  ~/backup/app_backup_$(date +'%d-%m-%Y').sh

echo -e "\n#vscodium extentions..." 
echo -e "\n\n#vscodium extentions : " >>  ~/backup/app_backup_$(date +'%d-%m-%Y').sh
codium --list-extensions | while read line; do echo codium --install-extension ${line}; done >> ~/backup/app_backup_$(date +'%d-%m-%Y').sh

echo -e "\n#.config dir ..." 
rm -rf ~/backup/.config_$(date +'%d-%m-%Y')
cp -r ~/.config/ ~/backup/.config_$(date +'%d-%m-%Y')

echo -e "\n#zip the backup ..." 
rm ~/backup/backup$(date +'%d-%m-%Y').zip
zip -r ~/backup/backup$(date +'%d-%m-%Y').zip ~/backup/
echo ~/backup/backup$(date +'%d-%m-%Y').zip
