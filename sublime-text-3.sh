#!/usr/bin/env bash
# Usage: {script} TARGET BUILD
# 
#   TARGET      Default target is "/opt".
#   BUILD       If not defined tries to get the build into the Sublime Text 3 website.
#

set -e

declare URL
declare URL_FORMAT="http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_%d_x%d.tar.bz2"
declare TARGET="${1:-/opt}"
declare BUILD="${2}"
declare BITS

if [[ -z "${BUILD}" ]]; then
    BUILD=$(
        curl -Ls http://www.sublimetext.com/3 |
        grep '<h2>Build' |
        head -n1 |
        sed -E 's#<h2>Build ([0-9]+)</h2>#\1#g'
    )
fi

if [[ "$(uname -m)" = "x86_64" ]]; then
    BITS=64
else
    BITS=32
fi

URL=$(printf "${URL_FORMAT}" "${BUILD}" "${BITS}")

read -p "Do you really want to install Sublime Text 3 (Build ${BUILD}, x${BITS}) on \"${TARGET}\"? [Y/n]: " CONFIRM
CONFIRM=$(echo "${CONFIRM}" | tr [a-z] [A-Z])
if [[ "${CONFIRM}" = 'N' ]] || [[ "${CONFIRM}" = 'NO' ]]; then
    echo "Aborted!"
    exit
fi

echo "Downloading Sublime Text 3"
curl -L "${URL}" | tar -xjC ${TARGET}

echo "Creating shortcut file"
cat > "/usr/share/applications/sublime-text-3.desktop" <<SHORTCUT
[Desktop Entry]
Type=Application
Name=Sublime Text 3
GenericName=Text Editor
Comment=Sophisticated text editor for code, markup and prose
Exec=${TARGET}/sublime_text_3/sublime_text %F
Terminal=false
MimeType=text/plain;
Icon=${TARGET}/sublime_text_3/Icon/256x256/sublime-text.png
Categories=TextEditor;Development;
StartupNotify=true
Actions=Window;Document;
 
[Desktop Action Window]
Name=New Window
Exec=${TARGET}/sublime_text_3/sublime_text -n
OnlyShowIn=Unity;
 
[Desktop Action Document]
Name=New File
Exec=${TARGET}/sublime_text_3/sublime_text --command new_file
OnlyShowIn=Unity;
SHORTCUT

echo "'ln' the program to /usr/bin , so you can run the program in terminal by type 'sublime-text'"
ln -s ${TARGET}/sublime_text_3/sublime_text /usr/bin/sublime-text

echo "Finish!"
