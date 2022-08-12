# ptixiakiErgasia

A Website archive taking Crawler implementation compromised of the following docker containers:
  - **Backend Rest/API** written in Python using Flask
  - **Frontend** written in Dart using Flutter
  - **Database** using MariaDB 

---

## Deploy
1. Setup [Docker](https://docs.docker.com/get-started/)
2. Create a **.env** file on the project's root folder, alongside where the run_me.sh script is found
3. Input following values and change as needed
  >
  > ```
  > # The default site to crawl over
  > WEBPAGE_URL="https://www.in.gr/"
  > # The default threshold needed for an archive to be taken, 1 takes everything where 0.1 everything 90% different
  > DIFF_THRESHOLD="0.90",
  > # The IP of mariaDB, 'mariadb' if using docker-compose
  > MARIADB_IP="mariadb"
  > # User to be used by crawler
  > MARIADB_USER="DB_user"
  > # Password for MARIADB_USER
  > MARIADB_PASSWORD="AbcD34FER$%1"
  > # The mariaDB listening port
  > MARIADB_PORT="3306"
  > # The Database name to be used by crawler
  > MARIADB_DATABASE="crawlerDB"
  > # The root user's password
  > MARIADB_ROOT_PASSWORD="changeMe"
  > # Timezone to be used for datetime handling
  > TIME_ZONE="Europe/Athens"
  > ```
  >
  > Optional Enviromental Variables:
  >
  > ```
  > # Option to only recreate backend and skip script's init questions for faster redeployments
  > DEVELOP_MODE="true"
  > # Logging level for console output
  > CH_LEVEL="DEBUG"
  > # Logging level for file output
  > FH_LEVEL="DEBUG"
  > ```
  >
  > Available logging levels are:
  >
  > > CRITICAL \
  > > ERROR \
  > > WARNING \
  > > INFO \
  > > DEBUG
4. Fire up the Backend Flask server + MariaDB + Flutter Frontend using the included run_me.sh script
5. After the containers are up and running the crawler can be accessed **through: http://<server's ip>:8080**

---

## Troubleshooting

- This project uses a mariadb python package in order to save and read data from mariaDB, when run outside of docker and on linux OS **MariaDB database development files** are needed in order for the package to work. Run `sudo apt-get install -y libmariadb-dev` before installing python dependencies.

- Docker containers initialization error:

  ```
  ERROR: for crawler  Container "mariadb" is unhealthy.
  ERROR: Encountered errors while bringing up the project.
  ```

  Make sure you have specified **MARIADB_USER** and **MARIADB_PASSWORD** on .env file as they are required for mariadb container to fire up.
