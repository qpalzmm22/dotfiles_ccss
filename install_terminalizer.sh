#/bin/bash
#
# install package
#
if ! type npm>/dev/null; then
    distro=$(cat /etc/os-release | grep "^ID=" | cut -d\= -f2 | sed -e 's/"//g')
    case "$distro" in
    "ubuntu" | "kali")
        sudo apt-get install nodejs npm -y
        ;;
    "arch")
        sudo pacman -S --noconfirm nodejs npm
        ;;
    esac
fi

if ! type terminalizer>/dev/null; then
    sudo npm install -g --unsafe-perm terminalizer
fi
#
# Solving some issues
#
GLOBAL_NODE_MODULE="$(npm list -g | head -n1)/node_modules"

# https://github.com/faressoft/terminalizer/issues/29
OWNER=$(stat -c '%U' $GLOBAL_NODE_MODULE)
if [ $OWNER != $(whoami) ]; then
    sudo chown -R $(whoami) $GLOBAL_NODE_MODULE
fi

# https://github.com/faressoft/terminalizer/issues/79
RENDER_JS="$GLOBAL_NODE_MODULE/terminalizer/render/index.js"
if ! grep "app.disableHardwareAcceleration();" "$RENDER_JS">/dev/null; then
    
    NR=$(awk "/app.on\('ready', createWindow);/ {print NR}" $RENDER_JS)
    sed -i~ $NR'iapp.disableHardwareAcceleration();' $RENDER_JS
fi

cp _terminalizer/config.yml ~/.terminalizer/
