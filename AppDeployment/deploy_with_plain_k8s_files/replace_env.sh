#!/bin/bash

applicationK8sDefinitionDirectory=$1
environmentValuesFile=$2

replace_environment_variables(){
  extension="*.yml"
  
  cp -a $applicationK8sDefinitionDirectory ./

  for file in */$extension; do
    if [ -f "$file" ]; then
      echo "Environment variables substitution for $file" 
  
      for line in $(cat $environmentValuesFile); do
        trimmedLine="$(echo $line | tr -d '[:space:]')"
        echo $trimmedLine
        envVarName="$(echo $trimmedLine | cut -d'=' -f1)"
        envVarValue="$(echo $trimmedLine | cut -d'=' -f2)"
        echo "$envVarName => $envVarValue"
        sed -i "s/\${$envVarName-}/$envVarValue/" $file 
      done
    fi
  done
}

if [ -n "$applicationK8sDefinitionDirectory" ] && [ -n "$environmentValuesFile" ]; then
    if [ ! -d "$applicationK8sDefinitionDirectory" ];  then 
      echo "K8s Definition Directory path does not point to existing folder."
      exit -1
    elif [ ! -f "$environmentValuesFile" ]; then
      echo "Environment values file path does not point to existing file."
      exit -1
    else
      replace_environment_variables
    fi
else
    echo "Please give non empty argument values for 1) the application 's K8s Definition Directory and 2) Environment values file."
fi