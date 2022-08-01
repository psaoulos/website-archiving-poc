""" Entry file for the crawler service. """
import time
import sys
import os
from modules import WebCrawler, Variables, Logger, Database


def crawler_main():
    """ Main crawler function. """
    start_time = time.time()
    my_crawler.get_root_page_links()
    Database.delete_links_found(my_crawler.get_root_page_url())
    end_time = time.time()
    run_time = "{:.2f}".format(end_time - start_time)
    logger.debug(f"[pid:{os.getpid()}] Ended a crawl after {run_time} seconds")


def main():
    """ Initialization function used to determine arguments passed from flask. """
    input_args = sys.argv
    repeat_times = 1
    interval_seconds = 60
    arguments_sum = len(input_args) - 1
    argument_index = 1
    diff_threshold = 1.0
    crawl_url = ''
    try:
        total_start_time = time.time()
        Variables.init_variables_from_env()
        while arguments_sum >= argument_index:
            if argument_index == 1:
                repeat_times = int(input_args[argument_index])
            elif argument_index == 2:
                interval_seconds = int(input_args[argument_index])
            elif argument_index == 3:
                diff_threshold = int(input_args[argument_index])
            elif argument_index == 4:
                crawl_url = str(input_args[argument_index])
            argument_index = argument_index + 1
        parent_crawler_id = Database.get_current_crawl_task_id(
            pid=int(os.getpid()), address=crawl_url, iterations=repeat_times, interval=interval_seconds)
        my_crawler.set_crawler_id(parent_crawler_id[0])
        my_crawler.set_root_page_url(crawl_url)
        my_crawler.set_diff_threshold(diff_threshold/100)
        my_crawler.set_iterations(repeat_times)
        my_crawler.set_iterations_interval(interval_seconds)
        logger.info(
            f"[pid:{os.getpid()}][crawler_id:{parent_crawler_id[0]}] Crawler started for {repeat_times}"
            f" itterations ({interval_seconds} seconds interval) on {crawl_url}!"
        )
        for index_y in range(repeat_times):
            logger.debug(
                f'[pid:{os.getpid()}] Itteration {index_y+1} / {repeat_times} started')
            crawler_main()
            logger.debug(
                f'[pid:{os.getpid()}] Itteration {index_y+1} / {repeat_times} finished')
            if index_y + 1 < repeat_times:
                time.sleep(int(interval_seconds))
                Database.increment_crawler_step(
                    os.getpid(), my_crawler.get_root_page_url())
            else:
                Database.update_finished_crawler(
                    my_crawler.get_crawler_id(), status="Finished")
    except Exception as exc:
        logger.error(
            f"[pid:{os.getpid()}] Error on crawler itteration, {exc}", exc_info=True)
    if os.path.isfile("./archive/temp.html"):
        # Deleting temp file used for calculating diff ratio between archives
        os.remove("./archive/temp.html")
    total_end_time = time.time()
    total_run_time = "{:.2f}".format(total_end_time - total_start_time)
    logger.info(
        f"[pid:{os.getpid()}] Crawler finished {repeat_times} itterations after {total_run_time} seconds!")


if __name__ == "__main__":
    Logger.init_logger()
    logger = Logger.get_logger()
    my_crawler = WebCrawler()
    main()
