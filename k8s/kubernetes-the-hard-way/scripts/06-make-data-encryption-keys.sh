#!/bin/sh

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

for instance in controller-0 controller-1 controller-2; do
    EXTERNAL_DNS=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${instance} Name=instance-state-name,Values=running | jq -r ".Reservations[0].Instances[0].PublicDnsName")
    scp encryption-config.yaml ${EXTERNAL_DNS}:~/
done
