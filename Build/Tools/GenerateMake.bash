files=`cat makefilelist.txt`
echo \# Generated makefile - Do not edit!
for makeinc in $files ;
do
  bash $ROOTDIR/build/tools/GenerateSingleMake.bash $makeinc
#  echo \# ------------
#  echo include $makeinc
#  cat Makefile.rules
#  bash GenerateRuleTemplate.bash $makeinc
#  echo $tag_name
done


