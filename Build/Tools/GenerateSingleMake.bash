makeinc=$1
echo \# ------------
echo include $makeinc
bash $ROOTDIR/build/tools/GenerateRuleTemplate.bash $makeinc
