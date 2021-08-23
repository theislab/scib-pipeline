# run from (base) environment

SCRIPT_DIR=$(dirname $0)

if [ $# -eq 0 ]; then
  echo "No arguments: Provide the conda path of an existing conda environment"
  exit 1
fi

CONDA_PREFIX=$1

if [[ ! -d ${CONDA_PREFIX} ]]; then
  echo "Path ${CONDA_PREFIX} is not a directory"
  exit 1
fi

CONDA_DIR=${CONDA_PREFIX}/etc/conda

echo "cp activate_env_vars.sh ${CONDA_DIR}/activate.d/env_vars.sh"
mkdir -p ${CONDA_DIR}/activate.d/
cp ${SCRIPT_DIR}/env_vars_activate.sh ${CONDA_DIR}/activate.d/env_vars.sh

echo "cp deactivate_env_vars.sh ${CONDA_DIR}/deactivate.d/env_vars.sh"
mkdir -p ${CONDA_DIR}/deactivate.d/
cp ${SCRIPT_DIR}/env_vars_deactivate.sh ${CONDA_DIR}/deactivate.d/env_vars.sh
