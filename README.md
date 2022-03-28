# ptixiakiErgasia

This project uses docker containers in order to fire up a DB for data storage, the crawler inside a dedicated container and an optional admin panel for the DB.

---
## Deploy
>In order for the containers to work properly the following Enviromental Variables are needed to be added on a **.env** file on the project's root folder, where the run_me.sh script is found:
>
>```
>WEBPAGE_URL="www.in.gr"          # The site to crawl over
>MARIADB_IP="mariadb"             # The IP of mariaDB, 'mariadb' if using docker-compose
>MARIADB_USER="DB_user"           # User to be used by crawler
>MARIADB_PASSWORD="changeMe"      # Password for MARIADB_USER
>MARIADB_PORT="3306"              # The mariaDB listening port
>MARIADB_DATABASE="crawlerDB"     # The Database name to be used by crawler
>MARIADB_ROOT_PASSWORD="changeMe" # The root user's password
>```
>Optional Enviromental Variables:
>```
>CH_LEVEL="DEBUG"                 # Logging level for crawler container
>```
> Available logging levels are: 
>> CRITICAL \
>> ERROR \
>> WARNING \
>> INFO \
>> DEBUG 
>
> &nbsp;
---
## Troubleshooting

* This project uses a mariadb python package in order to save and read data from mariaDB, when run outside of docker and on linux OS **MariaDB database development files** are needed in order for the package to work. Run `sudo apt-get install -y libmariadb-dev` before installing python dependencies.

* Docker containers initialization error:
  
  ``` 
  ERROR: for crawler  Container "mariadb" is unhealthy. 
  ERROR: Encountered errors while bringing up the project. 
  ```
  Make sure you have specified **MARIADB_USER** and **MARIADB_PASSWORD** on .env file as they are required for mariadb container to fire up.
