pushd ~/.icons/ &&
    tar -Jxvf Papirus-Custom.tar.xz && tar -Jxvf Papirus-Dark-Custom.tar.xz &&
    sudo ln -vs ~/.icons/Papirus-Custom /usr/share/icons/Papirus-Custom &&
    sudo ln -vs ~/.icons/Papirus-Dark-Custom /usr/share/icons/Papirus-Dark-Custom &&
popd

