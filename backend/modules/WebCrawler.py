""" Module containting the core webcrawler functionality. """
import ssl
import re
import requests
from urllib3 import poolmanager
from bs4 import BeautifulSoup, SoupStrainer
from modules import Logger, FileSystem, Database

logger = Logger.get_logger()


class WebCrawler():
    """ The core webcrawler functionality. """

    def __init__(self):
        self.page_url = ""
        self.visited_urls = set()

    def set_page(self, url):
        """ Setter for the root page of the site to crawl. """
        self.page_url = url
        logger.debug(f"Setting root page to crawl: {url}")

    def get_root_page_links(self):
        """ Get and insert to DB all links found on root page. """
        try:
            self.check_page_protocol()
            FileSystem.create_page_folder(self.page_url)

            page_html_content = self.get_html_content(self.page_url)
            self.save_page_content(
                content=page_html_content, url=self.page_url)
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
                if link['href'].startswith(self.page_url) and link['href'] != self.page_url:
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
    def save_page_content(content, url):
        """ Save page html content to file system. """
        FileSystem.save_page(
            content=BeautifulSoup(content, "html.parser").prettify(),
            url=url,
            encoding=WebCrawler.get_encoding(content)
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
