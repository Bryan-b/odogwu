download() {
    download_url="https://github.com/Bryan-b/odogwu/archive/refs/tags/v.1.0.0.tar.gz"
    # download using curl
    curl -LJO $download_url

    # extract the tar file
    tar -xvf odogwu-*.tar.gz

    cd odogwu-*
    
    rm -rf .git .gitignore README.md install.sh LICENSE

    sudo rm -rf /usr/local/bin/odogwu/*
    sudo mv * /usr/local/bin/odogwu
}

permit() {
    sudo chmod +x /usr/local/bin/odogwu/odogwu
    sudo chmod +x /usr/local/bin/odogwu/utils.sh
    sudo chmod +x /usr/local/bin/odogwu/install.sh

    sudo ln -s /usr/local/bin/odogwu/odogwu /usr/local/bin/odogwu

    echo "Odogwu installed successfully!"
    echo "=============================="
    echo "Run 'odogwu' to get started"
}

download && permit