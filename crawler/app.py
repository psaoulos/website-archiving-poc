from __future__ import print_function, unicode_literals
import os
import time
import modules.Logger as Logger
from modules.WebCrawler import WebCrawler
import modules.Variables as Variables
import modules.FileSystem as FileSystem
import modules.Database as Database


def main():
    FileSystem.init_folders()

    Variables.init_variables_from_env()
    myCrawler = WebCrawler()
    myCrawler.set_page(Variables.WEBPAGE_URL)

    starttime = time.time()
    loop_over = False

    Database.init_database()
    myCrawler.get_root_page()

    while loop_over:  # TODO: add esc key hit listener
        time.sleep(60.0 - ((time.time() - starttime) % 60.0))



if __name__ == "__main__":
    print("Logs at: "+os.getcwd()+"/logs/app.log")
    Logger.init_logger()
    logger = Logger.get_logger()
    logger.info("Scrypt started!")
    main()
    logger.info("Scrypt finished!")
