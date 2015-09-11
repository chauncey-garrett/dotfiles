alias get-keychain='security find-generic-password -a "$1" -g 2>&1 | grep password | sed -e "s/password: \"//" -e "s/\"//"'
