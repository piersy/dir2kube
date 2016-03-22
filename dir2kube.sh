#!/bin/bash

#Arguments
#
# $1 -> baseDir
# $2 -> targetDir
# $3 -> mountDir
# $4 -> kubeConfigPath
# $5 -> yamlFiles

#Secret naming convention
#Details: must be a DNS subdomain (at most 253 characters, matching regex [a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)
#We replace forward slashes with hyphens inoprder to comply

baseDir=${1%/}
targetDir=${2%/}
mountDir=${3%/}
kubeConfigPath=$4
#Remainder of params
yamlFiles=${@:5}

previousDir=
for currentFile in $(find $baseDir/$targetDir -type f | sort); do
    echo "curr $currentFile"
    #Remove chars following end slash inclusive
    currentDir=${currentFile%/*}
    #Delete everything up to end slash inclusive
    filenameOnly=${currentFile##*/}
    trailingDir=${currentDir#$baseDir/$targetDir}
    #Remove potential preceeding slash
    trailingDir=${trailingDir#/}
    volumeMount=$mountDir
    if [[ $trailingDir != ""  ]]; then
        volumeMount=${mountDir}/${trailingDir}
    fi

    #Secret name is defined by its path under the base dir
    secretName=$(echo ${currentDir#$baseDir/} | tr '/' '-')

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
        secretNameYaml="              secretName: $secretName"
        mountPath="        - mountPath: $volumeMount"
        mountName="          name: $secretName"
        for yamlFile in $yamlFiles; do
            perl -p -i -e  "s|(^.*volumes:.*$)|\1\n${volumeName}\n${secret}\n${secretNameYaml}|" $yamlFile
            perl -p -i -e  "s|(^.*volumeMounts:.*$)|\1\n${mountPath}\n${mountName}|" $yamlFile
        done
    fi
    previousDir=$currentDir
done
