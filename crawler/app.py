""" Entry file for application. """
from __future__ import print_function, unicode_literals
import os
import time
from modules import WebCrawler, Variables, Database, FileSystem, Logger

def main():
    """ Main app function. """
    FileSystem.init_folders()

    env_variables = Variables()
    env_variables.init_variables_from_env()

    my_crawler = WebCrawler()
    my_crawler.set_page(env_variables.get_env_var("WEBPAGE_URL"))

    starttime = time.time()
    loop_over = False

    Database.init_database()
    my_crawler.get_root_page_links()
    while loop_over:
        # Database.clean_table("links_table")
        time.sleep(60.0 - ((time.time() - starttime) % 60.0))

if __name__ == "__main__":
    print("Logs at: "+os.getcwd()+"/logs/app.log")
    Logger.init_logger()
    logger = Logger.get_logger()
    logger.info("Scrypt started!")
    main()
    logger.info("Scrypt finished!")
