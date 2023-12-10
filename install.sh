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
    sudo chmod +x /usr/local/bin/odogwu/odogwu
    sudo chmod +x /usr/local/bin/odogwu/utils.sh
    sudo chmod +x /usr/local/bin/odogwu/install.sh

    sudo ln -s /usr/local/bin/odogwu/odogwu /usr/local/bin/odogwu

    echo "Odogwu installed successfully!"
    echo "=============================="
    echo "Run 'odogwu' to get started"
}

download && setup