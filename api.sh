#!/usr/bin/env bash


# check Rundeck Access token is set

if [ -z "$RUNDECK_TOKEN" ]; then
	echo "Please set the RUNDECK_TOKEN environment variable"
	exit 1
fi

# Check URL is set
if [ -z "$RUNDECK_URL" ]; then
	echo "Please set the RUNDECK_URL environment variable"
	exit 1
fi

curl -X POST ${RUNDECK_TOKEN}/api/30/project/anvils/scm/import/plugin/git-import/setup\?authtoken\=${RUNDECK_TOKEN} -H "Content-Type: application/json" --data '{"config": {
    "url": "https://github.com/git/repo/templates.git",
    "fetchAutomatically": "true",
    "pullAutomatically": "true",
    "dir": "/var/rundeck/projects/anvils/scm",
    "filePattern": ".*.yaml",
    "importUuidBehavior": "remove",
    "useFilePattern": "true",
    "strictHostKeyChecking": "no",
    "sshPrivateKeyPath": "keys/rundeck-private-key",
    "format": "yaml",
    "branch": "master",
    "gitPasswordPath": "",
    "pathTemplate": "${job.group}${job.name}-${job.id}.${config.format}"
  },
  "enabled": true,
  "integration": "import",
  "project": "anvils",
  "type": "git-import"
}'

generate_post_data() {
# Get list of jobs to import
  ITEMS=$(curl -s -X GET ${RUNDECK_TOKEN}/api/30/project/anvils/scm/import/action/import-all/input\?authtoken\=${RUNDECK_TOKEN} -H "Accept: application/json" | jq '[.importItems[] | select(.status == "IMPORT_NEEDED") | .itemId]')
  cat <<EOF
{"input":{
"message":"\$commitMessage"
},
"jobs":[],
"items":${ITEMS},
"deleted":[]
}
}
EOF
}


# curl -s -X GET ${RUNDECK_TOKEN}/api/30/project/anvils/scm/import/action/import-all/input\?authtoken\=${RUNDECK_TOKEN} -H "Accept: application/json" | jq '.{} | '

curl -X POST ${RUNDECK_TOKEN}/api/30/project/anvils/scm/import/action/import-all\?authtoken\=${RUNDECK_TOKEN} -H "Content-Type: application/json" --data "$(generate_post_data)"

exit
