#!/bin/bash  

###
# Tools executable paths
###
K3dCMD="../../ProgramData/chocolatey/bin/k3d.exe"
K8sCmd="../../ProgramData/chocolatey/bin/kubectl.exe"
HelmCMD="../../ProgramData/chocolatey/bin/helm.exe"

###
# Registry information.
###

registryName="registry.localhost"
registryPort=55555
createLocalDockerRegistryCMD="registry create $registryName --port $registryPort"
createRegistryCmdLogMessage="(*) INITIALIZING DOCKER REGISTRY name=$registryName port=$registryPort"
deleteRegistryCmdLogMessage="(*) REMOVING DOCKER REGISTRY name=$registryName port=$registryPort"

###
# Cluster information 
###
k8sClusterName="localk8s"
createClusterCmdLogMessage="(*) INITIALIZING K3D K8S CLUSTER name=$k8sClusterName"
deleteClusterCmdLogMessage="(*) REMOVING K3D K8S CLUSTER name=$k8sClusterName"
deployingClusterRequiredAppsLogMessage="(*) DEPLOYING HELM APPLICATIONS"
createClusterCMD="cluster create $k8sClusterName --registry-use k3d-$registryName:$registryPort"

###
# Required Cluster Apps
###

kong_chart="https://charts.konghq.com"
rabbitmq_chart="oci://registry-1.docker.io/bitnamicharts/rabbitmq"
postgres_chart="oci://registry-1.docker.io/bitnamicharts/postgresql"
prometheus_chart="https://prometheus-community.github.io/helm-charts"
grafana_chart="https://grafana.github.io/helm-charts"
#-------------------------------------------------


function initialize_cluster {
	echo "--------- INITIALIZING K8S CLUSTER --------"
	docker_registry_initialization
	echo $createClusterCmdLogMessage
	local result=$($K3dCMD $createClusterCMD 2>&1)
	if [[ "${result,,}" == *"because a cluster with that name already exists"* ]]; then 
	   echo "! Cluster $k8sClusterName is already running"
	   while true; do
			read -p "Do you want to reset it ? (yes/no) " yn
			case $yn in 
				yes )
				echo $deleteClusterCmdLogMessage
					$K3dCMD cluster delete $k8sClusterName
				echo $createClusterCmdLogMessage
					$K3dCMD $createClusterCMD
				echo $deployingClusterRequiredAppsLogMessage
					deploy_required_components
				break;;
			no )
				exit;;
			* ) echo invalid response;;
			esac
		done
	fi
	exit 0;
}

function deploy_required_components {
  $K8sCmd create namespace local
	### Kong 	
	$HelmCMD repo add kong "$kong_chart"
    $HelmCMD repo add prometheus-community "$prometheus_chart"
	$HelmCMD repo add grafana "$grafana_chart"

	$HelmCMD repo update
	$HelmCMD install kong kong/ingress -n kong --create-namespace 
	### rabbitmq
	$HelmCMD install rabbitmq "$rabbitmq_chart"
	### postgres server -1
	$HelmCMD install postgres1 "$postgres_chart"
	### postgres server -2
	$HelmCMD install postgres2 "$postgres_chart"
	### Prometheus
	$HelmCMD install prometheus prometheus-community/prometheus
	
	$HelmCMD install grafana grafana/grafana
}

# If docker-registry container exists then ask the user if he/she wants tor reset it
# If yes then we first delete the docker registry and then creating it again.
# If no then we exit.
# if the container does not exist we check if its stopped , if it is we start it again.
# if it does not exit at all create the registry
function docker_registry_initialization { 
  if [ "$(docker ps -a -q -f status=running -f name=$registryName)" ]; then
	 echo "! Registry $registryName is already running"
     while true; do
        read -p "Do you want to reset it ? (yes/no) " yn
        case $yn in 
          yes ) echo ok, we will proceed;
          echo $deleteRegistryCmdLogMessage
          $K3dCMD registry delete $registryName
          echo $createRegistryCmdLogMessage
          $K3dCMD $createLocalDockerRegistryCMD
          break;;
        no )
        return;;
        * ) echo invalid response;;
        esac
    done
  else 
    echo "Registry Container name=$registryName is not running or does not exist"
	  if [ "$(docker ps -a -q -f status=exited -f name=$registryName)" ]; then
		  echo "Registry's Container is stopped re-starting it"
		  docker start "k3d-$registryName"
	  else
	    echo $createRegistryCmdLogMessage
		  $K3dCMD $createLocalDockerRegistryCMD
	  fi
  fi
}

###
# Main body of script
###
initialize_cluster
