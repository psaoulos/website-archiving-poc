from __future__ import print_function, unicode_literals
import os,logging,time
from src.webCrawler import WebCrawler
from src.fileSystem import FileSystem
from PyInquirer import prompt, print_json

def main():
    print("Logs at: "+os.getcwd()+"/logs/app.log")

    answers = ask_for_url()
    print(answers)  # use the answers as input for your app
    myCrawler = WebCrawler("https://www.in.gr/")
    if answers["site_addr"] != "":
        myCrawler.set_page(answers["site_addr"])
    starttime=time.time()
    loop_over = True
    while loop_over: # TODO: add esc key hit listener
        myCrawler.get_page()
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
    
def init_logger():
    logger = logging.getLogger("crawler_logger")
    logger.setLevel(logging.DEBUG)
    # Format for our loglines
    formatter = logging.Formatter("%(asctime)s %(name)s - %(levelname)s - %(message)s")
    # Setup console logging
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)
    ch.setFormatter(formatter)
    logger.addHandler(ch)
    # Setup file logging as well
    if not os.path.exists('./logs'):
        os.makedirs('./logs')
        logger.info(f"Logs Folder did not exist, creating!")
    fh = logging.FileHandler("./logs/app.log", mode='w')
    fh.setLevel(logging.DEBUG)
    fh.setFormatter(formatter)
    logger.addHandler(fh)
    return logger

if __name__ == "__main__":
    logger = init_logger()
    logger.debug("Scrypt started!")
    main()
    logger.debug("Scrypt finished!")