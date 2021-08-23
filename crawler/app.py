from __future__ import print_function, unicode_literals
import os
import time
from modules.WebCrawler import WebCrawler
import modules.FileSystem as FileSystem
import modules.Logger as Logger


def main():
    FileSystem.init_folders()

    myCrawler = WebCrawler()
    if "WEBPAGE_URL" in os.environ:
        logger.debug("Using WEBPAGE_URL env var.")
        webpage = os.getenv('WEBPAGE_URL').strip()
        if webpage is not None:
            if webpage.startswith("http://") or webpage.startswith("http://"):
                myCrawler.set_page(webpage)
            else:
                logger.debug("WEBPAGE_URL env var does not specify http/https, defaulting to http.")
                myCrawler.set_page(f"http://{webpage}")
        else:
            logger.debug("WEBPAGE_URL env var returned None, defaulting.")
            myCrawler.set_page("https://www.in.gr/")
    else:
        logger.debug("No WEBPAGE_URL env var found, defaulting.")
        myCrawler.set_page("https://www.in.gr/")
    starttime = time.time()
    loop_over = False

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
