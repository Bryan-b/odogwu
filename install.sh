download() {
    git clone https://github.com/Bryan-b/odogwu.git odogwu
    cd odogwu
    rm -rf .git .gitignore README.md install.sh LICENSE

    if [ ! -d /usr/local/bin/odogwu ]; then
        sudo mkdir /usr/local/bin/odogwu
    fi
    sudo cp * /usr/local/bin/odogwu

    cd ..
    rm -rf odogwu
}

setup() {
    sudo chmod +x /usr/local/bin/odogwu/odogwu.sh
    sudo chmod +x /usr/local/bin/odogwu/utils.sh

    sudo ln -s /usr/local/bin/odogwu/odogwu.sh /usr/local/bin/odogwu

    which_shell=$(echo $SHELL)

    if [ $which_shell = "/bin/zsh" ]; then
        sed -i '' '/PATH=$PATH:\/usr\/local\/bin\/odogwu/d' ~/.zshrc
        sed -i '' '/alias odogwu="\/usr\/local\/bin\/odogwu\/odogwu.sh"/d' ~/.zshrc

        echo "PATH=$PATH:/usr/local/bin/odogwu" >> ~/.zshrc
        echo alias odogwu="bash /usr/local/bin/odogwu/odogwu.sh" >> ~/.zshrc
        echo "source /usr/local/bin/odogwu/odogwu.sh" >> ~/.zshrc
    elif [ $which_shell = "/bin/bash" ]; then
        sed -i '' '/PATH=$PATH:\/usr\/local\/bin\/odogwu/d' ~/.bashrc
        sed -i '' '/alias odogwu="\/usr\/local\/bin\/odogwu\/odogwu.sh"/d' ~/.bashrc

        echo "PATH=$PATH:/usr/local/bin/odogwu" >> ~/.bashrc
        echo alias odogwu="bash /usr/local/bin/odogwu/odogwu.sh" >> ~/.bashrc
        echo "source /usr/local/bin/odogwu/odogwu.sh" >> ~/.bashrc
    else
        sed -i '' '/PATH=$PATH:\/usr\/local\/bin\/odogwu/d' ~/.bash_profile
        sed -i '' '/alias odogwu="\/usr\/local\/bin\/odogwu\/odogwu.sh"/d' ~/.bash_profile
        
        echo "PATH=$PATH:/usr/local/bin/odogwu" >> ~/.bash_profile
        echo alias odogwu="/usr/local/bin/odogwu/odogwu.sh" >> ~/.bash_profile
        echo "source /usr/local/bin/odogwu/odogwu.sh" >> ~/.bash_profile
    fi

    echo "Odogwu installed successfully!"
    echo "=============================="
    echo "Run 'odogwu' to get started"
}

download 
setup