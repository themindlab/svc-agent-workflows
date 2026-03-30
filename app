import_experiment () {
    if [ -z "$1" ]
    then
        echo "You must supply a filename (including the .rds extension)"
    else
        if [ -z $2 ]; then
            BATCH_SIZE=50
        else
            BATCH_SIZE=$2
        fi
        local $(cat .env | grep EXPERIMENT_IMPORTER_PORT | awk '/=/ {print $1}')
        curl -X POST -H "Content-Type: application/json" \
            -d "{ \"filename\": \"$1\", \"batch_size\": $BATCH_SIZE }" \
            localhost:$EXPERIMENT_IMPORTER_PORT/importExperiment
    fi

}

if [ $# -gt 0 ]; then

  if [ "$1" = "build" ]; then
    docker compose build --build-arg ENV="development" agent-server
  
  elif [ "$1" = "up" ]; then
    docker compose up -d
  
  elif [ "$1" = "pull" ]; then
    docker compose pull 

  elif [ "$1" = "ci_up" ]; then
    docker compose -f ./docker-compose.yaml --verbose up -d

  elif [ "$1" = "down" ]; then
    docker compose down
  
  elif [ "$1" = "start" ]; then
    docker compose exec agent-server python -u -m  run_service

  elif [ "$1" = "test" ]; then
    if [ ! -z "$2" ]; then
      shift 1
      docker compose exec -e PYTHONPATH=. \
        agent-server \
        pytest "$@"
    else
      docker compose exec -e PYTHONPATH=. \
        agent-server \
        pytest ./tests
    fi

  elif [ "$1" = "bash" ]; then
    docker compose exec -it agent-server bash
  
  elif [ "$1" = "init-modules" ]; then
    git submodule update --init --recursive --remote

  elif [ "$1" = "import-experiment" ]; then
      shift 1
      import_experiment $@

  elif [ "$1" = "purge" ]; then
    curl -X POST -H "Content-Type: application/json" -d '{"confirmation":"not_safe"}' localhost:5000/purge

  else
    echo "command not recognised"
  fi
else
  echo "No command supplied"
fi