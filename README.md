# Wayne Philip - My take on & use of miniKube
## This document is aimed at people wh want to deploy various things with miniKube application
### LINUX please :) - I use ubuntu204 but any LINUX will do  also should all work on a MAC
### This is specifically aimed at people wanting to set up an new environment for minikube  - IT IS MY WAY - THERE ARE MANY
### Feel free to fork & do whatever

## SO WHY -- I need to experiment with various configurations and combination for a very complex BareMetal custer

#### see:
>docs/MiniKubeInstallOnLinux.pdf
## To FAST-TRACK miniKube installation, Install core utilities and activate argoCD on the cluster
>$ ./mkStartup.sh -- [this will do what is documented in the file]

#### Once set up you can simply use 
>$ minikube start and it should all come back

###$ You may want to run multiple nodes -- this can be seen in 
>$ docs/miniKubeEnhanced.pdf

## argoCD
Once your miniKube cluster is running you will want to get to the front-end to set up repos..
#### Execute:
>kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

        -- this will give you a "passcode"

#### find the installed port on the cluster  (default 443 )

>kubectl get services -n argocd     -- and you will see the port (443)

#### now PortForward this for your browser
>kubectl port-forward svc/argocd-server -n argocd 8080:443 

> you can see it in localhost:8080 [you mau use any port for the 8080 part]


## External References
#### I use argoCD for CI/CD type deployments - deployed as as per [https://argo-cd.readthedocs.io/en/stable/getting_started/]
