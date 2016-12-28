#!/bin/bash

#USAGE: run_boost_context.sh

read -p "Enter your tacc user: " user 
#rsync -avx $user@poldrack.lonestar.tacc.utexas.edu:/corral-repl/utexas/poldracklab/data/Food_study/Boost_MVPA/ ./
chmod ug+rwx *;

echo ""
echo "***********************************************"
echo "All files up to date!"
echo "***********************************************"
echo ""

a=1
while [ $a -gt 0 ]
do
    read -p "Please enter subject ID: " subjid
    echo ""
    echo "You entered Subject ID: ${subjid}"
    echo ""
    if [ "$subjid" != '' ]; then
	a=0
    fi

    if [ -e "Output/${subjid}_BDM2.txt" ]; then
	echo ""
	echo "**********************************"
	echo "WARNNG: subject $subjid already run! Please check subject ID and try again."
	echo "**********************************"
	echo ""
	break
    fi
done

a=1
while [ $a -gt 0 ]
do
    read -p "Please enter experiment phase (1: prescan, or 2: postscan): " sess
    echo""
   	echo "You entered experiment phase ${sess}. Must be 1 or 2" 
   	echo""
	if [ "$sess" != '' ]; then
		a=0
    fi
done
a=1
while [ $a -gt 0 ]
do
    read -p "Please enter participant order number: " order
    echo""
   	echo "You participant order number ${order}. Must be 1 or 2" 
   	echo""
	if [ "$order" != '' ]; then
		a=0
    fi
done

case $sess in
    1)
	python BDM_demo.py $subjid;
	python BDM.py $subjid;;
    2)
        python BDM2.py $subjid; 
	Rscript random_BDM_trial.R $subjid; 
	matlab -maci -nodesktop -r "beep_no_beep('$subjid',0,$order); quit"; 
	open -a safari https://redcap.prc.utexas.edu/redcap/surveys/?s=GjyPuZ; 
	rsync -avx Output/ $user@poldrack.lonestar.tacc.utexas.edu:/corral-repl/utexas/poldracklab/data/Food_study/Boost_MVPA/Output/; 
	ssh $user@poldrack.lonestar.tacc.utexas.edu "chmod -R g+rw /corral-repl/utexas/poldracklab/data/Food_study/Boost_MVPA/Output/;ll /corral-repl/utexas/poldracklab/data/Food_study/Boost_MVPA/Output/";
	echo "";
	echo "*******************************"; 
	more Output/${subjid}_BDM1_resolve.txt;
	echo "*******************************";
	echo "";
	read -p "Continue?: " cont
	echo "";
	echo "*******************************"; 
	more Output/${subjid}_probe_resolve.txt;
	echo "*******************************";
	echo "";;
esac




