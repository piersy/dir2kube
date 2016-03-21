#!/bin/bash



#Arguments
#
# $1 -> baseDir
# $2 -> targetDir
# $3 -> mountDir
# $4 -> kubeConfigPath
# $5 -> yamlFiles


baseDir=$1
targetDir=$2
mountDir=$3
kubeConfigPath=$4
#Remainder of params
yamlFiles=${@:5}

currentSecretYaml=
previousDir=
#Gotta distinguish between new or additional files to know if we patch or not
for currentFile in $(find $baseDir/$targetDir); do
    #Remove chars following end slash inclusive
    currentDir=${currentFile%/*}
    #Delete everything up to end slash inclusive
    filenameOnly=${currentFile##*/}
    secretName=$(echo $currentDir | tr '/.' '-')

    if [[ $currentDir == $previousDir ]]; then
       #Patch since we are adding a file to the existing dir 
       echo "kubectl --kubeconfig $kubeConfigPath patch secret $secretName -p \$(conf2kube -f $currentFile -n $secretName -k $filenameOnly)"
    else
        #Crete a new secret
        #Ensure we delete the old one first
        echo "kubectl --kubeconfig $kubeConfigPath delete secret $secretName"
        echo "conf2Kube -f $currentFile -n $secretName -k $filenameOnly | kubectl --kubeconfig $kubeConfigPath -f -"
        volumeName="        - name: $secretName"
            secret="          secret:"
        secretName="              secretName: $secretName"
        volumeMount=${mountDir}/${currentDir##$baseDir/$targetDir}
        mountPath="        - mountPath: $voluemMount"
        mountName="          name: $secretName"
        for yamlFile in $yamlFiles; do
            perl -pe  "s|(^.*volumes:.*$)|\1\n${volumeName}\n${hostPath}\n${secretName}|" $yamlFile
            perl -pe  "s|(^.*volumeMounts:.*$)|\1\n${mountPath}\n${mountName}|" $yamlFile
        done
    fi
    previousDir=$currentDir
done
