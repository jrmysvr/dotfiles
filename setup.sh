#!/usr/bin/env bash

#------------------------
# Install Apt Packages
#------------------------
setup_apt() {
    sudo apt update && sudo apt install -y \
        build-essential \
        cmake \
        curl \
        git \
        vim \
        neovim \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
        openssh-server \
        openssh-client \
        tmux
}

#------------------------
# Install Other Packages
#------------------------

# Tailscale
# https://tailscale.com/download
setup_tailscale() {
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo apt-key add -
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list
    sudo apt update && sudo apt install tailscale
    ## Authenticate
    # sudo tailscale up
    ## Show Tailscale IP
    # ip addr show tailscale0
}

# Rust
# https://www.rust-lang.org/tools/install
setup_rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

# Nim
# https://github.com/dom96/choosenim#unix
setup_nim() {
    curl https://nim-lang.org/choosenim/init.sh -sSf | sh
}

# SBCL
# https://lisp-lang.org/learn/getting-started/
setup_sbcl() {
    # sudo apt install sbcl
    return 1
}

# Guile
# https://www.gnu.org/software/guile/download/
setup_guile() {
    # sudo apt install guile-3.0
    return 1
}

# Dr. Racket (just handle in Docker?)
# sudo add-apt-repository ppa:plt/racket && sudo apt update && sudo apt install racket

# Haskell
# https://docs.haskellstack.org/en/stable/install_and_upgrade/#ubuntu
setup_haskell() {
    # sudo apt install stack -y && stack upgrade
    return 1
}

# keybase
## Still kind of an unresolved issue: adding a new device on OS reinstall
setup_keybase() {
    # curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb
    # sudo apt install ./keybase_amd64.deb
    # run_keybase
    return 1
}

# Docker
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
setup_docker() {
    sudo apt remove docker docker-engine docker.io containerd runc

    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io
    # Check if Docker installation succeeded
    # sudo docker run hello_world
}

# croc
# https://github.com/schollz/croc
setup_croc() {
    curl https://getcroc.schollz.com | bash
}

# nix
# https://nixos.org/download.html
setup_nix() {
    curl -L https://nixos.org/nix/install | sh
}
# Chrome

#------------------------
# Link .dotfiles
#------------------------

## Shamelessly taken from https://github.com/tomnomnom/dotfiles/blob/master/setup.sh

dotfilesDir=$(pwd)

function link_dotfile {
  dest="${HOME}/${1}"
  dateStr=$(date +%Y-%m-%d-%H%M)

  if [ -h ~/"${1}" ]; then
    # Existing symlink
    echo "Removing existing symlink: ${dest}"
    rm "${dest}"

  elif [ -f "${dest}" ]; then
    # Existing file
    echo "Backing up existing file: ${dest}"
    # shellcheck disable=SC2086
    mv ${dest}{,.${dateStr}}

  elif [ -d "${dest}" ]; then
    # Existing dir
    echo "Backing up existing dir: ${dest}"
    # shellcheck disable=SC2086
    mv ${dest}{,.${dateStr}}
  fi

  echo "Creating new symlink: ${dest}"
  ln -s "${dotfilesDir}/${1}" "${dest}"
}

link_dotfiles() {
    #link_dotfile .vim
    link_dotfile .vimrc
    #link_dotfile .bashrc
    #link_dotfile .gitconfig
    #link_dotfile .ackrc
    #link_dotfile .tmux.conf
    #link_dotfile .inputrc
    #link_dotfile .xinitrc
    #link_dotfile .curlrc
    #link_dotfile .gf
}

setup_dotfiles() {
    git submodule update --init --recursive

    ln -sr "$dotfilesDir/vimrc/.vimrc" "$dotfilesDir/.vimrc"
    link_dotfiles
}

setup_vim() {
    mkdir -p "$dotfilesDir/.vim/bundle"
    cd "$dotfilesDir/.vim/bundle" || exit
    git clone git://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall

    sudo apt install neovim
}

#------------------------------------
do_thing() {
    case $1 in
        apt|--apt)
            echo "Installing Apt Packages"
            setup_apt
            ;;
        rust|--rust)
            echo "Installing Rust"
            setup_rust
            ;;
        nim|--nim)
            echo "Installing Nim"
            setup_nim
            ;;
        tailscale|--tailscale)
            echo "Installing Tailscale"
            setup_tailscale
            ;;
        docker|--docker)
            echo "Installing Docker"
            setup_docker
            ;;
        croc|--croc)
            echo "Installing croc"
            setup_croc
            ;;
        nix|--nix)
            echo "Installing Nix"
            setup_nix
            ;;
        dotfiles|--dotfiles)
            echo "Setting up dotfiles"
            setup_dotfiles
            ;;
        vim|--vim)
            echo "Setting up vim"
            setup_vim
            ;;
            *)
            echo "Unsupported argument: \"$1\""
            ;;
    esac
}

echo "-----------------------"
echo "Jeremy's computer setup"
echo "-----------------------"
if [ -z "$*" ]
then
    echo "Nothing to do"
else
    for thing in "$@"
    do
        do_thing "$thing"
    done
fi
#------------------------------------
