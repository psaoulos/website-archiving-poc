""" Entry file for the application. """
from __future__ import print_function, unicode_literals
import subprocess
import os
from flask import Flask, jsonify, current_app, request
from flask_cors import CORS, cross_origin
from waitress import serve
from modules import WebCrawler, Variables, Database, FileSystem, Logger

SUB_PROCESS = None


def main():
    """ Main app function. """

    FileSystem.init_folders()
    env_variables = Variables()
    env_variables.init_variables_from_env()
    Database.init_database()

    app = Flask("crawler_backend")
    CORS(app)
    app.config['CORS_HEADERS'] = 'Content-Type'

    @app.route('/crawler/status', methods=['GET', 'POST'])
    @cross_origin()
    def crawler_status():
        response = None
        try:
            if SUB_PROCESS is None:
                response = jsonify(success=True, running=False)
            else:
                process_running = SUB_PROCESS.poll()
                if process_running is None:
                    response = jsonify(success=True, running=True)
                else:
                    response = jsonify(success=True, running=False)
        except Exception as exc:
            current_app.logger.error(exc)
            response = jsonify(success=False)
        return response

    @app.route('/crawler/start', methods=['GET', 'POST'])
    @cross_origin()
    def crawler_start():
        global SUB_PROCESS
        response = None
        repeat_times = 1
        interval_seconds = 600
        crawl_url = env_variables.get_env_var("WEBPAGE_URL")
        try:
            if 'repeat_times' in request.args:
                repeat_times = request.args.get('repeat_times')
            if 'interval_seconds' in request.args:
                interval_seconds = request.args.get('interval_seconds')
            if 'crawl_url' in request.args:
                crawl_url = request.args.get('crawl_url')
            current_app.logger.debug(
                f"Going to repeat {repeat_times} times by {interval_seconds} seconds interval on {crawl_url}.")
            SUB_PROCESS = subprocess.Popen(["python3", "crawler.py", str(
                repeat_times), str(interval_seconds), str(crawl_url)])
            Database.insert_new_crawl_task(
                SUB_PROCESS.pid, crawl_url, repeat_times, interval_seconds)
            response = jsonify(success=True, started=True)
        except Exception as exc:
            current_app.logger.error(exc)
            response = jsonify(success=False, started=False)
        return response

    @app.route('/crawler/stop', methods=['GET', 'POST'])
    @cross_origin()
    def crawler_stop():
        global SUB_PROCESS
        response = None
        try:
            if SUB_PROCESS is None:
                current_app.logger.info(
                    "No subprocess to kill.")
                response = jsonify(success=True, stopped=False)
            else:
                process_running = SUB_PROCESS.poll()
                if process_running is None:
                    # SUB_PROCESS.subprocess is alive
                    current_app.logger.info("Killing subprocess.")
                    SUB_PROCESS.kill()
                    SUB_PROCESS = None
                    response = jsonify(success=True, stopped=True)
                else:
                    current_app.logger.info(
                        "No subprocess to kill.")
                    response = jsonify(success=True, stopped=False)
        except Exception as exc:
            current_app.logger.error(exc)
            response = jsonify(success=False)
        return response

    serve(app, host="0.0.0.0", port=3000)


if __name__ == "__main__":
    print("Logs at: "+os.getcwd()+"/logs/app.log")
    Logger.init_logger()
    logger = Logger.get_logger()
    logger.info("Crawler Backend started!")
    main()
    logger.info("Crawler Backend finished!")
