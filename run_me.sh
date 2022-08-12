#!/bin/bash
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

# check if .env file exists
ROOT_ENV_FILE=.env
FRONTEND_ENV_FILE=./frontend/.env
root_env_exists=false
if test -f "$ROOT_ENV_FILE"; then
    echo "Found env ROOT_ENV_FILE."
    root_env_exists=true
    source .env
fi

for ARGUMENT in "$@"; do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)

    KEY_LENGTH=${#KEY}
    VALUE="${ARGUMENT:$KEY_LENGTH+1}"

    export "$KEY"="$VALUE"
done

if [ $# -eq 0 ] && [ -z "${DEVELOP_MODE}" ]; then
    # No arguments supplied to script
    DEVELOP_MODE=false
else
    if [ -z "${DEVELOP_MODE}" ]; then
        # Arguments passed but no DEVELOP_MODE found
        DEVELOP_MODE=false
    fi
fi

# if .env file exists ask user to confirm .env stated url
# -z is used to check for zero length
if [ -z "${WEBPAGE_URL}" ]; then
    ask_user=true
else
    if [ "$DEVELOP_MODE" = false ]; then
        echo "The default site you wish to crawl over is the following: $WEBPAGE_URL"
        select yn in "Yes" "No"; do
            case $yn in
            Yes)
                ask_user=false
                break
                ;;
            No)
                ask_user=true
                break
                ;;
            esac
        done
    else
        ask_user=false
    fi
fi

# get user input for site address
while $ask_user; do
    read -p "Enter site to crawl: " new_webpage
    echo "The default site you wish to crawl over is the following: $new_webpage"
    select yn in "Yes" "No"; do
        case $yn in
        Yes)
            if $root_env_exists; then
                if !([ -z "${WEBPAGE_URL}" ]); then
                    # using sed Unix utility to parse and transform .env text
                    sed -i '' -e "s*$WEBPAGE_URL*$new_webpage*g" $ROOT_ENV_FILE
                else
                    printf 'WEBPAGE_URL="'$new_webpage'"\n' >>$ROOT_ENV_FILE
                fi
            else
                # since .env does not exist create it
                printf 'WEBPAGE_URL="'$new_webpage'"\n' >>$ROOT_ENV_FILE
                source .env
            fi
            ask_user=false
            break
            ;;
        No)
            break
            ;;
        esac
    done
done

# Copy WEBPAGE_URL env variable to FRONTEND_ENV_FILE
if test -f "$FRONTEND_ENV_FILE"; then
    if grep -q "WEBPAGE_URL" $FRONTEND_ENV_FILE; then
        sed -i '' -e '/WEBPAGE_URL=/d' $FRONTEND_ENV_FILE
    fi
fi
printf 'WEBPAGE_URL="'$WEBPAGE_URL'"\n' >>$FRONTEND_ENV_FILE

# make database's container folder if not exists
mkdir -p database

# Install Frontend's dependencies and build it (skipped if in DEVELOP_MODE)
if [ "$DEVELOP_MODE" = false ]; then
    echo "Cleaning Frontend environment!"
    cd frontend
    flutter clean
    echo "Building Frontend!"
    flutter build web
    cd ..
fi

# optional scorched earth directive during development
# docker container stop $(docker container ls -aq)
# docker rm $(docker ps -a -q)

echo "Starting crawler for $WEBPAGE_URL!"
if [ "$DEVELOP_MODE" = true ]; then
    echo "Running on DEVELOP_MODE mode, skipping DB docker creation."

    # Check if DB container is not running
    if [ -z "$(docker ps -q -f name=ptixiaki_ergasia_db)" ]; then
        echo 'DB container not running, starting now.'
        docker-compose -f docker-compose-db-only.yml build && docker-compose -f docker-compose-db-only.yml up --detach
    fi
    docker-compose -f docker-compose-no-db.yml build && WEBPAGE_URL=$WEBPAGE_URL docker-compose -f docker-compose-no-db.yml up --detach
else
    # option -f specifies docker-compose file, --detach to not follow containers' cmd outputs
    docker-compose -f docker-compose-full.yml build && WEBPAGE_URL=$WEBPAGE_URL docker-compose -f docker-compose-full.yml up --detach
fi
