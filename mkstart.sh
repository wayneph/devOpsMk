#!/bin/bash
# Wayne Philip
## for use by linux-type bashes only 
## prerequisites
    # instqalled & fuctioning minikube
## Starting up minikube
## for chrions -- uncomment these
    # export TERM=${TERM:-dumb}
    # exec 2> /dev/null


### WHAT THIS DOES 
    # installs miniKube, kubeCtl
    # aaplies some basic alis commands
    # activates dasboard, ingerss, metrics-server
    # applies argocd to the cluster
clear
echo "create aliases"
source aliasMaker.sh
echo "now start minikube up"
## Start miniKube up -- asume you have kubctle installed
minikube stop    
minikube delete --all  
minikube start   
minikube status 
echo "addind some stuff"
echo "adding dashboard & ingress &metrics server"
minikube addons enable dashboard
minikube addons enable ingress
minikube addons enable metrics-server
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "done  - start the dashboard with || $ minikube dashboard || but we actually like the lens app. "