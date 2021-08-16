#!/bin/bash
export USER_ID=$(id -u);
export GROUP_ID=$(id -g);

# check if .env file exists
FILE=.env;
env_exists=false;
if test -f "$FILE"
then
    echo "Found env file.";
    env_exists=true;
    source .env
fi

# if .env file exists ask user to confirm .env stated url
if [ -z ${WEBPAGE_URL+x} ]; 
then 
    ask_user=true;
else 
    echo "The site you wish to crawl over is the following: $WEBPAGE_URL"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) ask_user=false; break;;
            No ) ask_user=true; break;;
        esac
    done
fi

# get user input for site address
while $ask_user
do
    read -p "Enter site to crawl: " new_webpage
    echo "The site you wish to crawl over is the following: $new_webpage"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) 
                if $env_exists;
                then
                    # update .env file with new url
                    sed -i -e "s*$WEBPAGE_URL*$new_webpage*g" $FILE
                else
                    # since .env does not exist export it
                    export WEBPAGE_URL=$new_webpage;
                fi
                ask_user=false; 
                break;;
            No ) 
                break;;
        esac
    done
done

# make database's container folder if not exists
mkdir -p database

# optional scorched earth directive
# docker container stop $(docker container ls -aq)
# docker rm $(docker ps -a -q)

# deploy
if $env_exists;
then
    echo "Starting crawler for $new_webpage!"
    docker-compose -f docker-compose-full.yml build && docker-compose -f docker-compose-full.yml up
    # docker-compose -f docker-compose-full.yml build && docker-compose -f docker-compose-full.yml up
else
echo "Starting crawler for $WEBPAGE_URL!"
    docker-compose -f docker-compose-full.yml build && WEBPAGE_URL=$WEBPAGE_URL docker-compose -f docker-compose-full.yml up
    # docker-compose -f docker-compose-full.yml build && docker-compose -f docker-compose-full.yml up
fi