#!/usr/bin/env sh
# . -e<environment>
CURRENT_DIR=`PWD`

cleanup() {
  cd $CURRENT_DIR
  rm terraform/main.tf
}

handle_apply() {
  commands=(refresh validate apply)

  for command in "${commands[@]}"
  do
    terraform $command \
      -var-file=$CURRENT_DIR/secrets/environments/$ENV.tfvars
  done
}

handler() {
  cd $CURRENT_DIR/terraform
  cp ./environments/$ENV/main.tf .

  terraform init \
    -backend-config=$CURRENT_DIR/secrets/backend/$ENV.tfvars \
    -var-file=$CURRENT_DIR/secrets/environments/$ENV.tfvars
  terraform workspace select $ENV

  handle_apply

  terraform output -json > $CURRENT_DIR/terraform/output/$ENV.json

  cleanup
}

while getopts ":e:" opt; do
  case $opt in
    e) ENV="$OPTARG"
    ;;
  esac
done

handler
