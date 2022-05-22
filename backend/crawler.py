""" Entry file for thecrawler service. """
import time
import sys
from modules import WebCrawler, Variables, Logger


def crawler_main():
    """ Main crawler function. """
    env_variables = Variables()
    env_variables.init_variables_from_env()
    start_time = time.time()
    my_crawler.get_root_page_links()
    end_time = time.time()
    run_time = "{:.2f}".format(end_time - start_time)
    logger.debug(f"Ended a crawl after {run_time} seconds")


def main():
    """ Initialization function used to determine arguments passed from flask. """
    input_args = sys.argv
    repeat_times = 1
    interval_seconds = 60
    arguments_sum = len(input_args) - 1
    argument_index = 1
    crawl_url = ''
    try:
        logger.info(f"Crawler started for {repeat_times} itterations on!")
        while arguments_sum >= argument_index:
            if argument_index == 1:
                repeat_times = int(input_args[argument_index])
            elif argument_index == 2:
                interval_seconds = int(input_args[argument_index])
            elif argument_index == 3:
                crawl_url = str(input_args[argument_index])
            argument_index = argument_index + 1
        my_crawler.set_page(crawl_url)
        for index_y in range(repeat_times):
            logger.debug(f'Itteration {index_y+1} / {repeat_times} started')
            crawler_main()
            time.sleep(int(interval_seconds))
            logger.debug(f'Itteration {index_y+1} / {repeat_times} finished')
    except Exception as exc:
        logger.error(f"Error on crawler itteration, {exc}")
    logger.info(f"Crawler finished after {repeat_times} itterations!")


if __name__ == "__main__":
    Logger.init_logger()
    logger = Logger.get_logger()
    my_crawler = WebCrawler()
    main()
