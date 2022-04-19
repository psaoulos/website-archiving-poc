""" Entry file for the application. """
from __future__ import print_function, unicode_literals
import subprocess
from flask import Flask, jsonify, current_app
from flask_cors import CORS, cross_origin
from waitress import serve
import os
import time
from modules import WebCrawler, Variables, Database, FileSystem, Logger

sub_process = None

def main():
    """ Main app function. """
    
    FileSystem.init_folders()
    env_variables = Variables()
    env_variables.init_variables_from_env()
    Database.init_database()

    app = Flask("crawler_backend")
    CORS(app, support_credentials=False)

    @app.route('/crawler/start', methods = ['GET', 'POST'])
    @cross_origin(supports_credentials=False)
    def crawler_start():
        global sub_process
        logger = Logger.get_logger()
        response = None
        try:
            sub_process = subprocess.Popen(["python3","crawler.py"])
            response = jsonify(success=True)
        except:
            response = jsonify(success=False)
        return response
    
    @app.route('/crawler/stop', methods = ['GET', 'POST'])
    @cross_origin(supports_credentials=False)
    def crawler_stop():
        global sub_process
        logger = Logger.get_logger()
        response = None
        try:
            if sub_process is not None:
                current_app.logger.info("Killing subprocess.")
                sub_process.kill()
                sub_process = None
            else:
                current_app.logger.info("No subprocess to kill, try calling start endpoint first.")
            response = jsonify(success=True)
        except:
            response = jsonify(success=False)
        return response
    
    serve(app, host="0.0.0.0", port=3000)

if __name__ == "__main__":
    print("Logs at: "+os.getcwd()+"/logs/app.log")
    Logger.init_logger()
    logger = Logger.get_logger()
    logger.info("Backend started!")
    main()
    logger.info("Backend finished!")