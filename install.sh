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


    echo "=============================="
    echo "Select your shell environment"
    echo "=============================="
    echo "1. Bash"
    echo "2. Zsh"
    echo "3. Bash Profile"
    echo "=============================="
    read -p "Enter your choice: " choice

    # Check if $choice is empty or not an integer
    if [ -z "$choice" ] || ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo "Invalid choice"
        exit 1
    fi

    if [ "$choice" -eq 1 ]; then
        echo "export PATH=$PATH:/usr/local/bin/odogwu/odogwu.sh" >> ~/.bashrc
        alias odogwu='bash /usr/local/bin/odogwu/odogwu.sh'
        source ~/.bashrc
    elif [ "$choice" -eq 2 ]; then
        echo "export PATH=$PATH:/usr/local/bin/odogwu/odogwu.sh" >> ~/.zshrc
        alias odogwu='bash /usr/local/bin/odogwu/odogwu.sh'
        source ~/.zshrc
    elif [ "$choice" -eq 3 ]; then
        echo "export PATH=$PATH:/usr/local/bin/odogwu/odogwu.sh" >> ~/.bash_profile
        alias odogwu='bash /usr/local/bin/odogwu/odogwu.sh'
        source ~/.bash_profile
    else
        echo "Invalid choice"
        exit 1
    fi


    echo "Odogwu installed successfully!"
    echo "=============================="
    echo "Run 'odogwu' to get started"
}

download && setup