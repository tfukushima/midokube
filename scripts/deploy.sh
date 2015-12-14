#!/usr/bin/env bash -xe

MINION_LIST=.minions
USER=tfukushima
TIMEOUT=180
MIDOKUBE_DIR=/usr/libexec/kubernetes/kubelet-plugins/net/exec/midokube
MIDOKUBE_LOG_DIR=/var/log/midokube
EXECUTABLE=./midokube

DOES_COPY_BINARY=${DOES_COPY_BINARY:-1}

SSH_OPT="-i $HOME/.ssh/id_rsa -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no"
PSSH=$(((which parallel-ssh > /dev/null) && which parallel-ssh) || \
        ((which pssh > /dev/null) && which pssh))
SCP="scp $SSH_OPT" 

echo "Creating $MIDOKUBE_DIR and $MIDOKUBE_LOG_DIR"
$PSSH -h $MINION_LIST -x '"$SSH_OPT"' -i \
    "sudo mkdir -p $MIDOKUBE_DIR $MIDOKUBE_LOG_DIR"

echo "Changing the permission of $MIDOKUBE_DIR and $MIDOKUBE_LOG_DIR"
$PSSH -h $MINION_LIST -x '"$SSH_OPT"' -i \
    "sudo chown -R tfukushima:tfukushima $MIDOKUBE_DIR $MIDOKUBE_LOG_DIR"

echo "Creating $MIDOKUBE_DIR/midokube"
$PSSH -h $MINION_LIST -x '"$SSH_OPT"' -i \
    sudo sh -c "cat > $MIDOKUBE_DIR/midokube <<'EOF'
#!/usr/bin/env bash

$MIDOKUBE_DIR/_midokube -logtostderr=false -log_dir=\"/var/log/midokube/\" \$@
EOF
"

if [[ "$DOES_COPY_BINARY" = "1" ]]; then
    echo "Deleting old binary"
    $PSSH -h ${MINION_LIST} -x '"$SSH_OPT"' -i \
        "test -f /home/$USER/midokube && sudo rm /home/$USER/midokube || echo -n ''"
        # "if [ -f \"/home/$USER/midokube\" ]; then \
             # sudo rm /home/$USER/midokube
        # fi"
    
    $PSSH -h ${MINION_LIST} -x '"$SSH_OPT"' -i \
        "test -f $MIDOKUBE_DIR/_midokube && sudo rm $MIDOKUBE_DIR/_midokube || echo -n ''"
        # "if [ -f \"$MIDOKUBE_DIR/_midokube\" ]; then
            # sudo rm $MIDOKUBE_DIR/_midokube \
        # fi"
    echo "Copying midokube binary"
    while read minion; do
        $SCP $EXECUTABLE $USER@$minion:/home/$USER/
    done < ${MINION_LIST}
fi

echo "Moving binary"
$PSSH -h ${MINION_LIST} -x '"$SSH_OPT"' -i \
    "sudo cp /home/$USER/midokube $MIDOKUBE_DIR/_midokube"

echo "Changing the permission of $MIDOKUBE_DIR and $MIDOKUBE_LOG_DIR"
$PSSH -h ${MINION_LIST} -x '"$SSH_OPT"' -i \
    "sudo chown -R tfukushima:tfukushima $MIDOKUBE_DIR $MIDOKUBE_LOG_DIR"

echo "Making $MIDOKUBE_DIR/_midokube and $MIDOKUBE_DIR/midokube executable"
$PSSH -h ${MINION_LIST} -x '"$SSH_OPT"' -i \
    "sudo chmod +x $MIDOKUBE_DIR/_midokube $MIDOKUBE_DIR/midokube"

echo "Restarting kubelet"
$PSSH -h ${MINION_LIST} -x '"$SSH_OPT"' -i \
    "sudo service kubelet restart"

echo "Checking kubelet statuses"
$PSSH -h ${MINION_LIST} -x '"$SSH_OPT"' -i \
    "sudo service kubelet status"
