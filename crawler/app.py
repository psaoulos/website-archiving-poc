""" Entry file for application. """
from __future__ import print_function, unicode_literals
import os
import time
from modules import WebCrawler, Logger, Variables, FileSystem, Database

def main():
    """ Main app function. """
    FileSystem.init_folders()

    Variables.init_variables_from_env()
    my_crawler = WebCrawler.WebCrawler()
    my_crawler.set_page(Variables.WEBPAGE_URL)

    starttime = time.time()
    loop_over = False

    Database.init_database()
    my_crawler.get_root_page_links()

    while loop_over:
        time.sleep(60.0 - ((time.time() - starttime) % 60.0))

if __name__ == "__main__":
    print("Logs at: "+os.getcwd()+"/logs/app.log")
    Logger.init_logger()
    logger = Logger.get_logger()
    logger.info("Scrypt started!")
    main()
    logger.info("Scrypt finished!")
