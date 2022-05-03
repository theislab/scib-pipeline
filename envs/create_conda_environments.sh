#!/bin/bash
set -e

usage() {
  cat <<EOF
usage: $0 options

Set up environments for scib-pipeline

OPTIONS:
   -h     Show this message
   -r     R version to determine which environments should be installed
   -m     Command to install conda packages, either 'mamba' or 'conda' (default: mamba)
   -q     Quiet installation
EOF
}

SCRIPT_DIR=$(dirname $0)
MAMBA_CMD='mamba'
R_VERSION=
QUIET=""

while getopts "hr:m:q" OPTION; do
  case $OPTION in
  h)
    usage
    exit 1
    ;;
  r)
    R_VERSION=$OPTARG
    ;;
  m)
    MAMBA_CMD=$OPTARG
    ;;
  q)
    QUIET="-q"
    ;;
  ?)
    usage
    exit
    ;;
  esac
done

# Check R version
if [[ -z $R_VERSION ]] || [ "$R_VERSION" != "3.6" ] && [ "$R_VERSION" != "4.0" ]; then
  echo "Invalid R version $R_VERSION"
  usage
  exit 1
fi

ALL_ENVS=$($MAMBA_CMD env list)

# Create all conda envs and set environment variables
for env in "scib-pipeline-R${R_VERSION}" "scib-R${R_VERSION}"; do

  # Check if environment already exists andd create/update accordingly
  if [[ $ALL_ENVS == *"$env"* ]]
  then
    echo "Update $env..."
    $MAMBA_CMD env update $QUIET -f "envs/${env}.yml"
  else
    echo "Create $env..."
    $MAMBA_CMD env create $QUIET -f "envs/${env}.yml"
  fi

  if [ "$QUIET" != "-q" ]; then
    # list all pip dependencies
    conda run -n $env pip list
  fi

  # Set environment variables
  prefix=$($MAMBA_CMD env list | grep "${env} " | awk -F'[ ]' '{print $(NF)}')

  if [[ -z $prefix ]]; then
    echo "Error: empty conda prefix for $env"
    exit 1
  fi

  echo "Set environment variable scripts for CONDA_PREFIX: ${prefix}"
  bash "$SCRIPT_DIR"/set_vars.sh "${prefix}"
done

# List all environments
$MAMBA_CMD env list

# Install R packages
echo "Install R packages through R"

echo "scib pipeline environment..."
conda run -n "scib-pipeline-R${R_VERSION}" --no-capture-output \
 Rscript -e "remotes::install_github('theislab/kBET', quiet=TRUE)"

echo "scib R environment..."
conda run -n "scib-R${R_VERSION}" --no-capture-output \
 Rscript "$SCRIPT_DIR/install_R_methods.R" -d "$SCRIPT_DIR/dependencies-R${R_VERSION}.tsv" $QUIET

echo "Done."
