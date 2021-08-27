# ptixiakiErgasia

This project uses docker containers in order to fire up a DB for data storage, the crawler inside a dedicated container and an optional admin panel for the DB. As a result in order to 


Troubleshooting
ERROR: Command errored out with exit status 1: python setup.py egg_info Check the logs for full command output.
This project uses a mariadb python package in order to save and read data from mariaDB, when run outside of docker and on linux os MariaDB database development files are needed in order for the package to work. Run sudo apt-get install -y libmariadb-dev before installing python dependencies.