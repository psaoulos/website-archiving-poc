""" Module containting the core webcrawler functionality. """
import ssl
import re
import os
import requests
from urllib3 import poolmanager
from bs4 import BeautifulSoup, SoupStrainer
from modules import Logger, FileSystem, Database

logger = Logger.get_logger()


class WebCrawler():
    """ The core webcrawler functionality. """

    def __init__(self):
        self.crawler_id = 0
        self.page_url = ""
        self.visited_urls = set()
        self.diff_threshold = 0.95
        self.iterations = 0
        self.iteration_interval = 0

    def set_crawler_id(self, new_id):
        """ Setter for the crawl id assigned on crawl task creation. """
        if new_id is not None:
            self.crawler_id = new_id
            logger.debug(f"Setting crawler id: {new_id}")
        else:
            logger.error("Got no results from db after searching for crawler id")

    def get_crawler_id(self):
        """ Getter for the crawl id assigned on crawl task creation. """
        return self.crawler_id

    def set_root_page_url(self, url):
        """ Setter for the root page of the site to crawl. """
        self.page_url = url
        logger.debug(f"Setting root page to crawl: {url}")

    def get_root_page_url(self):
        """ Getter for the root page of the site to crawl. """
        return self.page_url

    def set_iterations(self, iterations):
        """ Setter for the requested iterations. """
        self.iterations = iterations

    def set_iterations_interval(self, interval):
        """ Setter for the requested iteration interval. """
        self.iteration_interval = interval

    def set_diff_threshold(self, value):
        """ Setter for the difference threshold needed in order for a page archive to be taken. """
        self.diff_threshold = 1.0 - value
        logger.debug(f"Setting diff threshold: {1.0 - value}")

    def get_root_page_links(self):
        """ Get and insert to DB all links found on root page. """
        try:
            self.check_page_protocol()
            FileSystem.create_page_folder(self.page_url)

            page_html_content = self.get_html_content(self.page_url)

            last_archive = Database.get_last_archive_entry(self.page_url)
            if last_archive is None:
                logger.debug(
                    "First crawl for requested address, gonna save archive.")
                self.save_page_content(
                    content=page_html_content, url=self.page_url, dif_ratio=None, crawler_id=self.crawler_id)
            else:
                percentage = FileSystem.calculate_content_difference(
                    file_a_location=last_archive[0],
                    content_b=BeautifulSoup(
                        page_html_content, "html.parser").prettify(),
                    encoding_a=last_archive[2],
                    encoding_b=WebCrawler.get_encoding(page_html_content)
                )
                if percentage <= self.diff_threshold:
                    self.save_page_content(
                        content=page_html_content, url=self.page_url, dif_ratio=percentage, crawler_id=self.crawler_id)
                else:
                    logger.debug(
                        "Crawled file diff threshold is same or greater from the minimum, skipping.")

            page_links = self.get_links(page_html_content)
            Database.insert_links_found(self.page_url, page_links)
        except Exception as ex:
            logger.error(ex)

    def get_links(self, page_html_content):
        """ Get links from page html content. """
        links = BeautifulSoup(
            page_html_content, "html.parser", parse_only=SoupStrainer("a"))
        logger.debug(
            f"Found {len(links)} links under {self.page_url}. Going to clean.")
        clean_list = []
        for link in links:
            if link.has_attr('href'):
                if (
                    (link['href'].startswith(self.page_url) and link['href'] != self.page_url)
                    or (link['href'].startswith('/') and link['href'] != '/')
                ):
                    clean_list.append(link['href'])
        logger.debug(
            f"Going to iterate over {len(clean_list)}. Here goes nothing.")
        return clean_list

    def check_page_protocol(self):
        """
        Checks if original url redirects to some other page, in order to update root link.
        """
        try:
            session = requests.session()
            session.mount("https://", TLSAdapter())
            page_session = session.get(self.page_url)
            session.close()
        except Exception as ex:
            logger.error(ex)
            return
        if page_session.url != self.page_url:
            logger.debug(
                f"Original url redirects to {page_session.url}, updating root url.")
            self.page_url = page_session.url
            Database.update_new_crawl_task_address(address= page_session.url, iterations= self.iterations, interval= self.iteration_interval, pid=int(os.getpid()))

    @staticmethod
    def get_html_content(url):
        """ Get raw html content from page url. """
        try:
            session = requests.session()
            session.mount("https://", TLSAdapter())
            page_html = session.get(url)
            session.close()
        except Exception as ex:
            logger.error(ex)
            return ""
        return page_html.content

    @staticmethod
    def save_page_content(content, url, dif_ratio, crawler_id):
        """ Save page html content to file system. """
        FileSystem.save_page(
            content=BeautifulSoup(content, "html.parser").prettify(),
            url=url,
            encoding=WebCrawler.get_encoding(content),
            dif_ratio=dif_ratio,
            crawler_id=crawler_id
        )

    @staticmethod
    def get_encoding(content):
        """
        Checks and returns the page's prefered encoding.
        """
        soup = BeautifulSoup(content, "html.parser")
        if soup and soup.meta:
            encod = soup.meta.get('charset')
            if encod is None:
                encod = soup.meta.get('content-type')
                if encod is None:
                    content = soup.meta.get('content')
                    match = re.search('charset=(.*)', content)
                    if match:
                        encod = match.group(1)
                    else:
                        logger.error('unable to find encoding')
                        raise ValueError('unable to find encoding')
        else:
            logger.error('unable to find encoding')
            raise ValueError('unable to find encoding')
        logger.debug(f'Page\'s prefered encoding is {encod}')
        return encod


class TLSAdapter(requests.adapters.HTTPAdapter):
    """ Overriden to get content off https pages. """

    def init_poolmanager(self, connections, maxsize, block=False):
        """Create and initialize the urllib3 PoolManager."""
        ctx = ssl.create_default_context()
        ctx.set_ciphers('DEFAULT@SECLEVEL=1')
        self.poolmanager = poolmanager.PoolManager(
            num_pools=connections,
            maxsize=maxsize,
            block=block,
            ssl_version=ssl.PROTOCOL_TLS,
            ssl_context=ctx)
