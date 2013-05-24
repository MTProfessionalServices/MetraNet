echo $1 | sed -e "s/^\.\///" -e "s/^\.\///" -e "s/\/make.inc$//" -e "s/\\make.inc$//" -e "s/\//_/g" -e "s/\\/_/g"
