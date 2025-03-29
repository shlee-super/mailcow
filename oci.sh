#!/bin/bash

# Define the compartment OCID
COMPARTMENT_OCID="ocid1.tenancy.oc1..aaaaaaaak4fkxtchmmfzxbifkhtmjl5rgzna3ivz5xznbcxtlznwb3yk6i5a"

# Mailcow API key
MAILCOW_API_KEY="MHAf1HXUHP9NNkp"

# Get the list of all mailboxes from Mailcow
MAILBOXES=$(curl -s --insecure -X GET "https://localhost/api/v1/get/mailbox/all" \
  -H "X-API-Key: $MAILCOW_API_KEY" | jq -r '.[].username')

# Get the list of approved senders from OCI
OCI_SENDERS=$(oci email sender list --compartment-id $COMPARTMENT_OCID | jq -r '.data[]."email-address"')

# Convert OCI senders to an array
OCI_SENDERS_ARRAY=($OCI_SENDERS)

# Loop through each mailbox and check if it's in the OCI approved senders list
for MAILBOX in $MAILBOXES; do
  if [[ ! " ${OCI_SENDERS_ARRAY[@]} " =~ " ${MAILBOX} " ]]; then
    # If the mailbox is not in the OCI approved senders list, add it
    oci email sender create --compartment-id $COMPARTMENT_OCID --email-address $MAILBOX
    echo "Added $MAILBOX to OCI approved senders."
  fi
done