import requests
from lxml import html
import ssl
from urllib3 import poolmanager
import modules.Logger as Logger
import modules.FileSystem as FileSystem


class WebCrawler():
    def __init__(self):
        self.page_url = ""
        self.visitedUrls = set()
        self.logger = Logger.get_logger()

    def set_page(self, url):
        self.page_url = url
        self.logger.info(f"Setting root page to crawl: {url}")
        FileSystem.create_page_folder(url)

    def get_root_page(self):
        try:
            self.check_page_protocol()

            page_html_content = self.get_html_content(self.page_url)
            self.save_page_content(content=page_html_content, file_name=self.page_url, url=self.page_url)
            page_links = self.get_links(page_html_content)
        except Exception as e:
            self.logger.error(e)

    def save_page_content(self, content, file_name, url):
        FileSystem.save_page(
            content=content, file_name=file_name, url=url)
    
    def get_links(self, page_html_content):
        element_tree = html.fromstring(page_html_content)
        element_tree.make_links_absolute(self.page_url, resolve_base_href=True)
        links = list(element_tree.iterlinks())
        self.logger.debug(f"Found {len(links)} links under {self.page_url}. Going to clean.")
        clean_list = list()
        for link in links:
            # Returns every link found in page, Contains images too (src)
            # (<Element a at 0x7fa00824cbd0>, 'href', 'http://www.in.gr/epikoinonia/', 0)
            if link[1] == "href":
                if link[2].startswith(self.page_url):
                    clean_list.append(link[2])
        self.logger.debug(f"Going to iterate over {len(clean_list)}. Here goes nothing.")
        return clean_list

    def get_html_content(self, url):
        try:
            session = requests.session()
            session.mount("https://", TLSAdapter())
            html = session.get(url)
        except Exception as e:
            self.logger.error(e)
            return ""
        return html.content.decode("UTF-8")

    def check_page_protocol(self):
        """
        Checks if original url redirects to some other page, in order to update root link.
        """
        try:
            session = requests.session()
            session.mount("https://", TLSAdapter())
            html = session.get(self.page_url)
        except Exception as e:
            self.logger.error(e)
            return ""
        if html.url != self.page_url:
            self.logger.info(f"Original url redirects to {html.url}, updating root url.")
            self.page_url = html.url

class TLSAdapter(requests.adapters.HTTPAdapter):
    # Used to get content off https pages
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
