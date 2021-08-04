from datetime import datetime
import os,logging,time

class FileSystem():
    def __init__(self,dir_name):
        self.dir_names = dir_name
        self.make_folders()

    def make_folders(self):
        # Create directory
        try:
            os.mkdir("./archive")
            print("Directory " , "./crawler/archive" ,  " Created ") 
        except FileExistsError:
            print("Directory " , "./crawler/archive" ,  " already exists")
        os.chdir("./archive")
        try:
            # Create target Directory
            print(self.dir_names)
            os.mkdir(self.dir_names)
            print("Directory " , self.dir_names ,  " Created ") 
        except FileExistsError:
            print("Directory " , self.dir_names ,  " already exists")

        os.chdir(self.dir_names)
        subDirName = datetime.today().strftime('%d-%m')
        try:
            os.mkdir(subDirName)
            print("Sub Folder created!")
        except FileExistsError:
            print("Sub Folder exists!")

        os.chdir(subDirName)
    
    def save_page(self,content,path):
        fileName = datetime.today().strftime("%H:%M")
        current_folder = str(os.getcwdb()).split("/")
        current_folder = current_folder[-1].replace("'","")
        if current_folder != datetime.today().strftime('%d-%m'):
            self.make_folders
        print(os.getcwdb())
        print(current_folder)
        f = open(f"{fileName}.html", "w")
        f.write(str(content))
        f.close()
