#!/bin/sh

function terraformFmt {

  fmtOutput=$(terraform fmt -no-color -check -list -recursive ${tfWorkingDir})
  fmtExitCode=${?}
  echo "fmtOutput: ${fmtOutput}"

  # All files are formatted correctly
  if [ "${fmtExitCode}" -eq 0 ]; then
    exit ${fmtExitCode} 
  fi

  # Exit if not a pull request event or if no comment is to be posted
  if [ "${GITHUB_EVENT_NAME}" != "pull_request" ] || [ ${tfPostComment} -eq 0 ]; then
    echo "Terraform Format failed."
    exit ${fmtExitCode}
  else
    if [ "${fmtExitCode}" -eq 2 ]; then
      fmtComment=$(echo -e "\`\`\`\n${fmtOutput}\n\`\`\`\n")
      echo "fmtComment2: ${fmtComment}"
    else
      fmtComment=""
      for fmtFile in ${fmtOutput}; do
        echo "currentPath: ${tfWorkindDir}/${fmtFile}"
        fmtFileDiff=$(terraform fmt -no-color -write=false -diff "${tfWorkingDir}/${fmtFile}" | sed -n '/@@.*/,//{/@@.*/d;p}')
        fmtComment=$(echo -e "${fmtComment}\n<details><summary><code>${fmtFile}</code></summary>\n\n\`\`\`diff\n${fmtFileDiff}\n\`\`\`\n\n</details>\n\n")
      done
    fi
    echo "fmtComment: $fmtComment"
    fmtCommentWrapper=$(echo -e "#### \`terraform fmt\` Failed\n${fmtComment}\n\n*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`*\n")
    echo "fmtCommentWrapper: $fmtCommentWrapper"
    fmtCommentPayload=$(echo '{}' | jq --arg body "${fmtCommentWrapper}" '.body = $body')
    fmtCommentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
    echo "fmtCommentsURL: ${fmtCommentsURL}"
    curl -s -S --header "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data "${fmtCommentPayload}" "${fmtCommentsURL}" > /dev/null
    exit ${fmtExitCode}
  fi
}
