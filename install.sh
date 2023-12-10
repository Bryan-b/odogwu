create_dir() {
    if [ ! -d /usr/local/bin/odogwu ]; then
        sudo mkdir /usr/local/bin/odogwu
    fi
}

replace_all() {
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

create_dir
replace_all
permit