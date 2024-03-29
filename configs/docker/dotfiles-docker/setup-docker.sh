#!/bin/bash

CONFIGS=$PWD/configs

# Install package 
function install {
    sudo apt install -y $1
}

function vim_setup {
    install "vim"

    cp $CONFIGS/vim/vimrc $HOME/.vimrc
}

function python_setup {
    echo "[*] python_setup"

    install "python3 python3-pip"
}

function zsh_setup {
    echo "[*] zsh_setup"

    if [ "$1" != "cont" ];
    then
        install "zsh autojump fd-find curl wget"
        git clone --depth=1 -b 0.35.1 https://github.com/junegunn/fzf.git $HOME/.fzf
        $HOME/.fzf/install --key-bindings --completion

        $CONFIGS/zsh/ohmyzsh.sh --skip-chsh
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

        git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/joshskidmore/zsh-fzf-history-search ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-fzf-history-search

        rm $HOME/.zshrc
        cp $CONFIGS/zsh/zshrc $HOME/.zshrc
        cp $CONFIGS/zsh/p10k.zsh $HOME/.p10k.zsh

        echo "export FZF_CONFIGS_COMMAND='fd -type f'" >> $HOME/.envvars
        echo "export LANG=\"en_US.UTF-8\"" >> $HOME/.envvars

        # Need to make not get password
        echo "sudo chsh -s $(which zsh) $USER"
        sudo chsh -s $(which zsh) $USER
    fi
}

function tmux_setup {
    echo "[*] tmux_setup"

    install "tmux xclip netcat"
    cp $CONFIGS/tmux/tmux.conf $HOME/.tmux.conf
}

function git_setup {
    echo "[*] git_setup"

    install "git"

    cp $CONFIGS/git/gitconfig $HOME/.gitconfig
}

function pyenv_setup {
    echo "[*] pyenv_setup"

    install "curl"

    curl https://pyenv.run | bash

    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $HOME/.envvars
    echo 'eval "$(pyenv init -)"' >> $HOME/.zshrc

    PYENV_ROOT=$HOME/.pyenv
    PATH=$PYENV_ROOT/bin:$PATH

    $PYENV_ROOT/bin/pyenv update
    $PYENV_ROOT/bin/pyenv install --list
}



#####################################################################

function setup {
    set -ex

    sudo apt update

    vim_setup
    python_setup
    git_setup
    zsh_setup
    zsh_setup cont
    tmux_setup
    pyenv_setup

    echo "export PATH=$PATH" >> $HOME/.envvars
}

setup
