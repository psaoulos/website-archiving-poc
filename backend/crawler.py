""" Entry file for thecrawler service. """
import time
import sys
from modules import WebCrawler, Variables, Logger


def main():
    """ Main crawler function. """
    env_variables = Variables()
    env_variables.init_variables_from_env()
    my_crawler = WebCrawler()
    my_crawler.set_page(env_variables.get_env_var("WEBPAGE_URL"))
    start_time = time.time()
    my_crawler.get_root_page_links()
    end_time = time.time()
    run_time = "{:.2f}".format(end_time - start_time)
    logger.debug(f"Ended a crawl after {run_time} seconds")


if __name__ == "__main__":
    Logger.init_logger()
    logger = Logger.get_logger()
    logger.debug("Crawler started!")
    inputArgs = sys.argv
    repeat_times = 1
    interval_seconds = 60
    arguments_sum = len(sys.argv) - 1
    argument_index = 1
    try:
        while arguments_sum >= argument_index:
            if argument_index == 1:
                repeat_times = int(sys.argv[argument_index])
            elif argument_index == 2:
                interval_seconds = int(sys.argv[argument_index])
            argument_index = argument_index + 1
        for y in range(repeat_times):
            logger.info(f'Itteration {y+1} out of {repeat_times}')
            main()
            time.sleep(float(interval_seconds))
    except Exception as exc:
        logger.error(f"Error on crawler itteration, {exc}")
    logger.info("Crawler finished!")
