aws --profile ${AWS_PROFILE} --region ${REGION} eks update-nodegroup-config --cluster-name ${CLUSTER_NAME} \
	--scaling-config "minSize=0,maxSize=1,desiredSize=0" --nodegroup-name ${NODE_GROUP_NAME}

INSTANCE_COUNT=$(aws --profile ${AWS_PROFILE} --region ${REGION} autoscaling describe-auto-scaling-groups --auto-scaling-group-name ${ASG_NAME} |
	jq '.[][0] | .Instances | length')

echo $INSTANCE_COUNT
sleep 100

aws --profile ${AWS_PROFILE} --region ${REGION} eks update-nodegroup-config --cluster-name ${CLUSTER_NAME} \
	--scaling-config "minSize=${MIN_SIZE},maxSize=${MAX_SIZE},desiredSize=${DESIRED_SIZE}" --nodegroup-name ${NODE_GROUP_NAME}

INSTANCE_COUNT=$(aws --profile ${AWS_PROFILE} --region ${REGION} autoscaling describe-auto-scaling-groups --auto-scaling-group-name ${ASG_NAME} |
	jq '.[][0] | .Instances | length')

echo $INSTANCE_COUNT
