#!/bin/bash
echo
echo ============================================================
echo ============================================================
echo =====================TIN-TA SCRIPT==========================
echo ============================================================
echo ============================================================
echo
echo 'Hello..... using Kubernetes? Use this!'
echo
echo
while :
do
	#############
	#Menu
	#############
	echo 'SELECT ONE OF THE ITEMS BELOW:'
	echo
	echo '[1]. All NameSpaces'
	echo '[2]. All PODs'
	echo '[3]. All Running PODs'
	echo '[4]. All PODs NOT-running PODs'
	read INPUT_CHOICE
	case $INPUT_CHOICE in
		1)
			echo ==============================
        		NameSpacelength=$(kubectl get namespaces -o json | jq '[.items[]] | length')
			echo '--> Getting list of' $NameSpacelength 'namespaces...'
			echo
        		i=0
			while [ $i -le $NameSpacelength ]
            			do
                			kubectl get namespaces -o json | jq '.items['$i'].metadata.name'
					i=$((i+1))
            			done
			echo ==============================
			;;
		2)
			echo ==============================
			echo 'Enter name Space: (default): '
			read NAME_SPACE
			if [ -z "$NAME_SPACE" ]; then
				NAME_SPACE=default
			fi
			echo '--> Looking for all PODs in '$NAME_SPACE' namespace...'
			pod_length=$(kubectl get pods -n ${NAME_SPACE} -o json | jq '[.items[]] | length')
			echo
			i=0
			while [ $i -le $pod_length ]
				do
					kubectl get pods -n $NAME_SPACE -o json | jq '.items['$i'].metadata.name'
					i=$((i+1))
				done
			;;
		*)
			echo 'not recognized command'
			;;
	esac
done
