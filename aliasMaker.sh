#!/bin/bash
# Wayne Philip
## for use by linux-type bashes only 
## prerequisites
    # full acvces to ~/.bashrc
clear
## Aiases common .. in file aliases.txt .. you may add alliases to this file as required
echo "adding aliasses to alias command"
while read a; do
  echo "$a"
  alias "$a"
done <aliasesMK.txt
echo ""
echo ""
read -t 15 -N 1 -p "Update these aliases permanently .. (y/N)? " answer
if [ "${answer,,}" == "y" ]
then
    echo ""
    day=$(date +"%Y-%m-%d")
    tm=$(date +"%H:%M")
    now="$day @ $tm"
    echo -e "\n\n## new logged aliases\n#miniKube - auto -alias maker .. $now" >> .bash_aliases
    cat .bash_aliases aliasesMK.txt >> .bash_aliases
fi
echo "----------------------->>>"
echo "these are your saved aliases "
cat .bash_aliases
echo "you may want to overwrite the .bash_aliases file the root of you home file for permanence"
echo ""