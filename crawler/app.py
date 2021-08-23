from __future__ import print_function, unicode_literals
import os
import time
from modules.WebCrawler import WebCrawler
import modules.FileSystem as FileSystem
import modules.Logger as Logger
from PyInquirer import prompt, print_json


def main():
    FileSystem.init_folders()

    myCrawler = WebCrawler()
    if "WEBPAGE_URL" in os.environ:
        logger.debug("Using WEBPAGE_URL env var.")
        webpage = os.getenv('WEBPAGE_URL')
        if webpage is not None:
            if webpage.startswith("http://") or webpage.startswith("http://"):
                myCrawler.set_page(webpage)
            else:
                myCrawler.set_page(f"http://{webpage}")
        else:
            logger.debug("WEBPAGE_URL env var returned None, defaulting.")
            myCrawler.set_page("https://www.in.gr/")
    else:
        logger.debug("No WEBPAGE_URL env var found, defaulting.")
        myCrawler.set_page("https://www.in.gr/")
    starttime = time.time()
    loop_over = True
    while loop_over:  # TODO: add esc key hit listener
        myCrawler.get_pages()
        time.sleep(60.0 - ((time.time() - starttime) % 60.0))


def ask_for_url():
    questions = [
        {
            'type': 'input',
            'name': 'site_addr',
            'message': 'What site should the crawler crawl over? (default: "https://www.in.gr/")',
        }
    ]
    return prompt(questions)

if __name__ == "__main__":
    print("Logs at: "+os.getcwd()+"/logs/app.log")
    Logger.init_logger()
    logger = Logger.get_logger()
    logger.info("Scrypt started!")
    main()
    logger.info("Scrypt finished!")
