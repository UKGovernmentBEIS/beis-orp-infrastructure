#!/bin/bash
apt install -y software-properties-common apt-transport-https unzip
apt-key adv --keyserver keyserver.ubuntu.com --recv 8F3DA4B5E9AEF44C
add-apt-repository 'deb [ arch=all ] https://repo.vaticle.com/repository/apt/ trusty main' -y
apt update
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
aws --version
apt-get -y install typedb-all=2.14.1 typedb-server=2.14.1 typedb-console=2.12.0 typedb-bin=2.12.0
typedb server &

sleep 11

# vars
AWS_REGION=${aws_region}
DATABASE_WORKDIR=${database_workdir}
TYPEDB_DATABASE_NAME=${typedb_database_name}
TYPEDB_DATABASE_SCHEMA=${typedb_database_schema}
TYPEDB_DATABASE_FILE=${typedb_database_file}
TYPEDB_DOCU_SQS_NAME=${typedb_docu_sqs_name}
S3_BUCKET=${s3_bucket}


CHECK_TYPEDB=$(typedb console --command='database list'|grep $TYPEDB_DATABASE_NAME)
#if database doesn't exist
if [[ $CHECK_TYPEDB != $TYPEDB_DATABASE_NAME ]]
then
  # import graph database into typedb server
  mkdir $DATABASE_WORKDIR
  aws s3 sync s3://$S3_BUCKET/pbeta/ $DATABASE_WORKDIR
  typedb console --command='database create '$TYPEDB_DATABASE_NAME'' --command='transaction '$TYPEDB_DATABASE_NAME' schema write' --command='source '$DATABASE_WORKDIR'/'$TYPEDB_DATABASE_SCHEMA'' --command='commit'
  typedb server import --database=$TYPEDB_DATABASE_NAME --file=$DATABASE_WORKDIR/$TYPEDB_DATABASE_FILE --port=1729
fi

CHECK_CRON=$(crontab -l)
# if no cron job running
if [ -z "$CHECK_CRON" ]
then
  # launch graph update as a cron job
  cd $DATABASE_WORKDIR/stream_update_process
  apt -y install python3-pip
  pip3 install -r requirements.txt 
  (crontab -l 2>/dev/null;  echo '* * * * * export TYPEDB_DOCU_SQS_NAME='$TYPEDB_DOCU_SQS_NAME' TYPEDB_DATABASE_NAME='$TYPEDB_DATABASE_NAME' AWS_REGION='$AWS_REGION' && cd '$(pwd) '&&' $(which python3) $(readlink -f main.py))| crontab -


  sleep 30
  # launch graph backup job to run weekly on Sat at 3AM
  DATE=$(date '+%Y%m%d')
  BACKUP_SCRIPT=/srv/weekly_backup.sh
  echo  """
  typedb server export --database=$TYPEDB_DATABASE_NAME --port=1729 --file=$DATE-orp-pbeta.typedb && echo "Graph copied to directory"
  aws s3 cp $DATE-orp-pbeta.typedb s3://$S3_BUCKET/backup/$DATE-orp-pbeta.typedb && echo "File copied to S3"
  aws s3 cp $DATE-orp-pbeta.typedb s3://$S3_BUCKET/pbeta/$TYPEDB_DATABASE_FILE && echo "Database file update to latest to pull at launch"
  sudo rm $DATE-orp-pbeta.typedb && echo "File deleted from directory"
  """ > $BACKUP_SCRIPT

  chmod a+x $BACKUP_SCRIPT
  crontab -l | { cat; echo "0 3 * * 6 "$BACKUP_SCRIPT; } | crontab -

fi
