#!/bin/bash

SLACK_HOOK=""

SLACK_HEADER="{\"username\": \"$(hostname)\",\"attachments\":["
SLACK_FOOTER="]}"

SLACK_ATTACHMENT_SECURITY_HEADER="{\"fallback\": \"List of available security updates\",\"color\": \"#f45c42\",\"title\": \"Security updates\",\"fields\": ["
SLACK_ATTACHMENT_VERSION_HEADER="{\"fallback\": \"List of available version updates\",\"color\": \"#f4d442\",\"title\": \"Version updates\",\"fields\": ["

SLACK_ATTACHMENT_SECURITY_BODY=$(apt-get --just-print upgrade 2>&1 | grep Inst | grep Security | sed -E "s/\[//g;s/\]//g;s/\(//g;s/\)//g" | awk '{print "{\"title\": \""$2"\", \"value\": \""$3" > "$4"\", \"short\": true},"}')
SLACK_ATTACHMENT_VERSION_BODY=$(apt-get --just-print upgrade 2>&1 | grep Inst | grep -v Security | sed -E "s/\[//g;s/\]//g;s/\(//g;s/\)//g" | awk '{print "{\"title\": \""$2"\", \"value\": \""$3" > "$4"\", \"short\": true},"}')

SLACK_ATTACHMENT_FOOTER="]}"

[[ (-z ${SLACK_ATTACHMENT_SECURITY_BODY}) && (-z ${SLACK_ATTACHMENT_VERSION_BODY}) ]] && exit 0

SLACK_ATTACHMENT_FINAL_BODY="}"

[[ -n ${SLACK_ATTACHMENT_SECURITY_BODY} ]] && SLACK_ATTACHMENT_FINAL_BODY="${SLACK_ATTACHMENT_SECURITY_HEADER}${SLACK_ATTACHMENT_SECURITY_BODY::-1}${SLACK_ATTACHMENT_FOOTER}"
[[ -n ${SLACK_ATTACHMENT_VERSION_BODY} ]] && SLACK_ATTACHMENT_FINAL_BODY="${SLACK_ATTACHMENT_VERSION_HEADER}${SLACK_ATTACHMENT_VERSION_BODY::-1}${SLACK_ATTACHMENT_FOOTER}"

SLACK_PAYLOAD="${SLACK_HEADER}${SLACK_ATTACHMENT_FINAL_BODY}${SLACK_FOOTER}"

curl -si -X POST --data-urlencode "payload=${SLACK_PAYLOAD}" ${SLACK_HOOK}

echo ""
echo "${SLACK_PAYLOAD}"