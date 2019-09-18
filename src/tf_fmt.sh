#!/bin/bash

function terraformFmt {

  cd ${GITHUB_WORKSPACE}/${tfWorkingDir}
  fmtOutput=$(terraform fmt -no-color -check -list -recursive 2>&1)
  fmtExitCode=${?}

  # All files are formatted correctly
  if [ "${fmtExitCode}" -eq 0 ]; then
    exit ${fmtExitCode} 
  fi

  # Exit if not a pull request event or if no comment is to be posted
  if [ "${GITHUB_EVENT_NAME}" != "pull_request" ] || [ ${tfPostComment} -eq 0 ]; then
    exit ${fmtExitCode}
  else
    if [ "${fmtExitCode}" -eq 2 ]; then
      fmtComment=$(echo -e "\`\`\`\n${fmtOutput}\n\`\`\`\n")
    else
      fmtComment=""
      for fmtFile in ${fmtOutput}; do
        fmtFileDiff=$(terraform fmt -no-color -write=false -diff "${fmtFile}" | sed -n '/@@.*/,//{/@@.*/d;p}')
        if [ "${tfWorkingDir}" == "" ]; then
          fmtRelativePath=${fmtFile}
        else
          fmtRelativePath=${tfWorkingDir}/${fmtFile}
        fi
        fmtComment=$(echo -e "${fmtComment}\n<details><summary><code>${fmtRelativePath}</code></summary>\n\n\`\`\`diff\n${fmtFileDiff}\n\`\`\`\n\n</details>\n\n")
      done
    fi
    fmtCommentWrapper=$(echo -e "#### \`terraform fmt\` Failed\n${fmtComment}\n\n*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`*\n")
    fmtCommentPayload=$(echo '{}' | jq --arg body "${fmtCommentWrapper}" '.body = $body')
    fmtCommentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
    curl -s -S --header "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data "${fmtCommentPayload}" "${fmtCommentsURL}" > /dev/null
    exit ${fmtExitCode}
  fi
}
