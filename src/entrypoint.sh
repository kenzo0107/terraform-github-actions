#!/bin/bash

scriptDir=$(dirname ${0})

source ${scriptDir}/tf_fmt.sh

function parseInputs {
 
  # Required inputs
  if [ "${INPUT_TERRAFORM_VERSION}" != "" ]; then
    tfVersion=${INPUT_TERRAFORM_VERSION}
  else
    echo "Input terraform_version cannot be empty"
    exit 1
  fi

  if [ "${INPUT_TERRAFORM_SUBCOMMAND}" != "" ]; then
    tfSubcommand=${INPUT_TERRAFORM_SUBCOMMAND}
  else
    echo "Input terraform_subcommand cannot be empty"
    exit 1
  fi
 
  # Optional inputs
  if [ "${INPUT_TERRAFORM_WORKING_DIR}" == "" ] || [ "${INPUT_TERRAFORM_WORKING_DIR}" == "." ]; then
    tfWorkingDir="."
  else
    tfWorkingDir=${INPUT_TERRAFORM_WORKING_DIR}
  fi
  
  if [ "${INPUT_POST_COMMENT}" == "true" ] || [ "${INPUT_POST_COMMENT}" == "1" ]; then
    tfPostComment=1
  else
    tfPostComment=0
  fi
}


function installTerraform {
  url="https://releases.hashicorp.com/terraform/${tfVersion}/terraform_${tfVersion}_linux_amd64.zip"
  echo "Downloading Terraform v${tfVersion}"
  curl -s -L -o /tmp/terraform_${tfVersion} ${url}
  if [ "${?}" -ne 0 ]; then
    echo "Failed to download Terraform v${tfVersion}"
    exit 1
  fi
  unzip -d /usr/local/bin /tmp/terraform_${tfVersion}
  if [ "${?}" -ne 0 ]; then
    echo "Failed to unzip Terraform v${tfVersion}"
    exit 1
  fi
}

parseInputs

case "${tfSubcommand}" in
  fmt)
    printenv
    installTerraform
    terraformFmt
    ;;
  *)
    echo "Error: Must provide a valid value for terraform_subcommand"
    ;;
esac
