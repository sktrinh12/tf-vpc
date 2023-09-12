aws --profile ${AWS_PROFILE} --region ${REGION} eks update-nodegroup-config --cluster-name ${CLUSTER_NAME} \
	--scaling-config "minSize=0,maxSize=1,desiredSize=0" --nodegroup-name ${NODE_GROUP_NAME}

sleep 100

aws --profile ${AWS_PROFILE} --region ${REGION} eks update-nodegroup-config --cluster-name ${CLUSTER_NAME} \
	--scaling-config "minSize=${MIN_SIZE},maxSize=${MAX_SIZE},desiredSize=${DESIRED_SIZE}" --nodegroup-name ${NODE_GROUP_NAME}
