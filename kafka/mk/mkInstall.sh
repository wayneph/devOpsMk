#!/bin/bash
# Wayne Philip
## Backup files
## put it in an hourly CronJob
### 5. cleanup & make ready for remote cron
export TERM=${TERM:-dumb}
exec 2> /dev/null
clear
daystokeep="4"
dd=$(date)
st=$(date '+%s')
day=$(date +"%Y%m%d")
tm=$(date +"%H%M")
now=$day-$tm
echo " "
echo " ..........................now=$now........"
echo " "
echo " .........................getting bastion stuff......."
scp dev01:bu.tar.gz /home/wayne-local/bastion/
echo " "
echo " .........................got it......."
then=$(date +"%Y%m%d" -d "$daystokeep day ago")
destination="/media/wayne-local/ub/bu/$now"
deldirfmt="/media/wayne-local/ub/bu/$then*"
echo "==> BACKUP on  <=="
##### echo some of this to the screen
echo "NAME: kafka-service"
LAST DEPLOYED: Tue Feb  8 08:58:37 2022
NAMESPACE: kafka
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: kafka
CHART VERSION: 15.0.5
APP VERSION: 3.1.0

** Please be patient while the chart is being deployed **

Kafka can be accessed by consumers via port 9092 on the following DNS name from within your cluster:

    kafka-service.kafka.svc.cluster.local

Each Kafka broker can be accessed by producers via port 9092 on the following DNS name(s) from within your cluster:

    kafka-service-0.kafka-service-headless.kafka.svc.cluster.local:9092

To create a pod that you can use as a Kafka client run the following commands:

    kubectl run kafka-service-client --restart='Never' --image docker.io/bitnami/kafka:3.1.0-debian-10-r8 --namespace kafka --command -- sleep infinity
    kubectl exec --tty -i kafka-service-client --namespace kafka -- bash

    PRODUCER:
        kafka-console-producer.sh \
            
            --broker-list kafka-service-0.kafka-service-headless.kafka.svc.cluster.local:9092 \
            --topic test

    CONSUMER:
        kafka-console-consumer.sh \
            
            --bootstrap-server kafka-service.kafka.svc.cluster.local:9092 \
            --topic test \
            --from-beginning
echo "==>keep for ($daystokeep) days"
echo "==>started($st)"
echo "==>create dir ($destination)"
echo "==>delete dir ($deldirfmt)"
echo ""
echo "synch start"
#make dir
makecmd="mkdir $destination -p"
echo "==>Creating Dir with .. $makecmd"
$makecmd
#rsych cmd
sudo rsync -avzlh /home/wayne-local/* $destination
sudo rsync -avzlh /home/wayne-local/.bash* $destination
sudo rsync -avzlh /home/wayne-local/.ssh $destination
rmcmd="sudo rm -R $deldirfmt"
echo "==>Removing Dir(s) like .. $rmcmd"
sudo $rmcmd
echo "==> EOF(DATA BACKUP on $server)"