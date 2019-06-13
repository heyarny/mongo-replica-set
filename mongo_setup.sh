#!/bin/bash

# check if variables were set
if [ -z "${MONGO_HOSTS}" ]; then
	echo "Error: MONGO_HOSTS environment was not set."
	exit 1
fi

if [ -z "${MONGO_REPLSET}" ]; then
	echo "Error: MONGO_REPLSET environment was not set."
	exit 1
fi

# split hosts by space
#IFS=' ' read -ra MONGO_HOSTS_LIST <<< "$MONGO_HOSTS"
MONGO_HOSTS_LIST=$(echo $MONGO_HOSTS | tr " " "\n")

# resolve hosts to ips
MONGO_IPS_LIST=()
for HOST in ${MONGO_HOSTS_LIST}; do
	IP=`getent hosts ${HOST} | awk '{ print $1 ; exit }'`
	MONGO_IPS_LIST+=("${IP}")
done

MONGO_RS="${MONGO_REPLSET}"
MONGO_1_IP="${MONGO_IPS_LIST[0]}"

echo "Waiting for startup.. (${MONGO_1_IP})"
until mongo --host ${MONGO_1_IP}:27017 --eval "db.stats()" 2>&1 | grep '"ok"' &> /dev/null; do
  sleep 1
done

echo "Mongo is running.."
echo "Setting up replica set.."

# prepare config
CONFIG_MEMBERS="";
for i in ${!MONGO_IPS_LIST[@]}; do
	if [ ! -z "${CONFIG_MEMBERS}" ]; then
		CONFIG_MEMBERS+=", "
	fi
	
	CFG="{\"_id\": $i, \"host\": \"${MONGO_IPS_LIST[i]}:27017\", \"priority\": 2}"
	CONFIG_MEMBERS+="${CFG}"
done

read -d '' CONFIG <<EOF
{
	"_id": "${MONGO_RS}",
	"version": 1,
	"members": [
		${CONFIG_MEMBERS}
	]
}
EOF

echo "Applying replica config: ${CONFIG}"

mongo --host ${MONGO_1_IP}:27017 <<EOF
   var cfg = ${CONFIG};
    rs.initiate(cfg, { force: true });
    rs.reconfig(cfg, { force: true });
EOF
