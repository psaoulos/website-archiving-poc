""" Entry file for thecrawler service. """
from __future__ import print_function, unicode_literals
import os
import time
from modules import WebCrawler, Variables, Database, FileSystem, Logger

def main():
    """ Main crawler function. """
    env_variables = Variables()
    env_variables.init_variables_from_env()
    my_crawler = WebCrawler()
    my_crawler.set_page(env_variables.get_env_var("WEBPAGE_URL"))
    starttime = time.time()
    my_crawler.get_root_page_links()

if __name__ == "__main__":
    Logger.init_logger()
    logger = Logger.get_logger()
    logger.debug("Crawler started!")
    main()
    logger.info("Crawler finished!")
