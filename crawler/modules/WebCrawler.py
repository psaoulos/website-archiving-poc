import requests
import logging
from lxml import html
import ssl
from urllib3 import poolmanager
import modules.FileSystem as FileSystem


class WebCrawler():
    def __init__(self, url):
        self.page_url = url
        self.visitedUrls = set()

    def set_page(self, url):
        self.page_url = url
        FileSystem.create_page_folder(url)

    def get_pages(self):
        try:
            page_html_content = self.get_html_content()
            self.save_page_content(
                content=page_html_content, file_name=self.page_url, url=self.page_url)
            page_links = self.get_links(page=page_html_content)
            if (len(page_links) > 0):
                for i in page_links:
                    self.get_page(i)
            return None
        except Exception as e:
            print(e)
            return None

    def save_page_content(self, content, file_name, url):
        FileSystem.save_page(
            content=content, file_name=file_name, url=url)

    def get_html_content(self):
        try:
            print("scrapping")
            session = requests.session()
            session.mount('https://', TLSAdapter())
            html = session.get("http://www.in.gr")
        except Exception as e:
            print(e)
            return ""
        return html.content.decode("UTF-8")

    def get_links(self, page):
        return []


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
