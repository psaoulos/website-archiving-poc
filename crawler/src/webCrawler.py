import requests
import logging
from src.fileSystem import FileSystem

class WebCrawler():
    def __init__(self,url):
        self.dir_name = "Page_Downloads"
        self.page_url = url
        self.visitedUrls = set()   
        FileSystem(self.dir_name)

    def set_page(self, url):
        self.page_url = url

    def get_page(self):
        try:
            page_html_content = self.get_html_content()
            page_links = self.get_links(page_html_content)
            if (len(page_links)>0):
                for i in page_links:
                    self.get_page(i)
            return None
        except Exception as e:
            print(e)
            return None

    def save_page_content(self, content, path):
        FileSystem.save_page(self,content,path)

    def get_html_content(self):    
        try:    
            html = requests.get(self.page_url)
        except Exception as e:    
            print(e)    
            return ""    
        return html.content.decode("UTF-8") 

    def get_links(self,page):
        return []