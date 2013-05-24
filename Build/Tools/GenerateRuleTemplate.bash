# ./Pipeline/Processor/make.inc -> Pipeline_Processor
# first expression: replace first ./ with nothing
# second expression: replace last /make.inc with nothing
# third expression: replace remaining slashes with underscores

tag_name=`echo $1 | sed -e "s/^\.\///" -e "s/\/make.inc$//" -e "s/\//_/g"`

# first expression: replace @@TAGNAME@@ with tagname computed
cat Makefile.rules | sed -e "s/@@TAGNAME@@/$tag_name/g"
