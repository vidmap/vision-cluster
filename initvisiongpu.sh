#!/bin/bash

if [[ ! "$1" =~ [0-9]+ ]]
then
  echo "This script initializes a visiongpu machine that was just wiped."
  echo "Prerequisites:"
  echo "  (1) a krb5.keytab file for the machine (saved by wipevisiongpu)"
  echo "  (2) a local ansible installation, ansible 2.3 or better"
  echo
  echo "Usage: $0 server-number"
  exit 1
fi

SERVERNUM=$(printf '%02d' $1)
SHORTSERVER=visiongpu${SERVERNUM}
SERVERNAME=${SHORTSERVER}.csail.mit.edu
SERVERIP=$(host ${SERVERNAME} | sed 's/.* //')

# STEP 1: fix up known_hosts
echo "Refreshing local known_hosts."
ssh-keygen -q -R ${SHORTSERVER} > /dev/null 2>&1
ssh-keygen -q -R ${SERVERNAME} > /dev/null 2>&1
ssh-keygen -q -R ${SERVERIP} > /dev/null 2>&1
ssh-keygen -q -R ${SHORTSERVER},${SERVERIP} > /dev/null 2>&1
ssh-keyscan -H ${SHORTSERVER},${SERVERIP} \
    >> ${HOME}/.ssh/known_hosts 2> /dev/null
ssh-keyscan -H ${SERVERIP} >> ${HOME}/.ssh/known_hosts 2> /dev/null
ssh-keyscan -H ${SHORTSERVER} >> ${HOME}/.ssh/known_hosts 2> /dev/null
ssh-keyscan -H ${SERVERNAME} >> ${HOME}/.ssh/known_hosts 2> /dev/null

# STEP 2: restore the krb5.keytab if we have it
KEYTABDIR=${HOME}/.keytabs/${SERVERNAME}
if ! ssh -x visiongpu15 ls /etc/krb5.keytab > /dev/null
then
    if [ ! -f ${KEYTABDIR}/krb5.keytab ]
    then
        echo "Missing ${KEYTABDIR}/krb5.keytab"
        echo "May not be able to ssh."
    else
        echo "Kerberos keytab must be restored; manual password needed"
        ssh -o GSSAPIKeyExchange=no -t -x $SERVERNAME \
            sudo cp ${KEYTABDIR}/krb5.keytab /etc/krb5.keytab
        if [ $? -eq 0 ]
        then
            echo "krb5.keytab restored."
        fi
    fi
fi

# STEP 3: run ansible
if [ -z $(grep ${SHORTSERVER} hosts) ]
then
    echo "${SHORTSERVER} is not listed in hosts inventory."
    echo "Ansible will not run."
else
    echo "Running ansible."
fi

ansible-playbook --limit localhost,${SHORTSERVER} vision.yml
