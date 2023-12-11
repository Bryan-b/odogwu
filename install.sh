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

    if [ "$(uname)" == "Darwin" ]; then
        # add to .zshrc and .bashrc
        echo "export PATH=$PATH:/usr/local/bin/odogwu/odogwu.sh" >> ~/.zshrc
        echo "export PATH=$PATH:/usr/local/bin/odogwu/odogwu.sh" >> ~/.bashrc
        echo alias odogwu='bash /usr/local/bin/odogwu/odogwu.sh' >> ~/.zshrc
        echo alias odogwu='bash /usr/local/bin/odogwu/odogwu.sh' >> ~/.bashrc
        source ~/.zshrc
        source ~/.bashrc
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        echo "export PATH=$PATH:/usr/local/bin/odogwu/odogwu.sh" >> ~/.bashrc
        echo "export PATH=$PATH:/usr/local/bin/odogwu/odogwu.sh" >> ~/.bash_profile
        echo alias odogwu='bash /usr/local/bin/odogwu/odogwu.sh' >> ~/.bashrc
        echo alias odogwu='bash /usr/local/bin/odogwu/odogwu.sh' >> ~/.bash_profile
        source ~/.bashrc
        source ~/.bash_profile
    else
        echo "Invalid choice"
        exit 1
    fi

    echo "Odogwu installed successfully!"
    echo "=============================="
    echo "Run 'odogwu' to get started"
}

download 
setup