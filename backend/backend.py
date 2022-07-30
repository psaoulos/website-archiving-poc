""" Entry file for the application. """
from __future__ import print_function, unicode_literals
import subprocess
import os
from datetime import date
from flask import Flask, jsonify, current_app, request
from flask_cors import CORS, cross_origin
from waitress import serve
from modules import Variables, Database, FileSystem, Logger

SUB_PROCESS = None
SUB_PROCESS_ADDRESS = None


def main():
    """ Main app function. """

    FileSystem.init_folders()
    env_variables = Variables()
    env_variables.init_variables_from_env()
    Database.init_database()

    app = Flask("crawler_backend")
    CORS(app)
    app.config['CORS_HEADERS'] = 'Content-Type'

    @app.route('/crawler/status', methods=['GET'])
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

    @app.route('/crawler/start', methods=['POST'])
    @cross_origin()
    def crawler_start():
        global SUB_PROCESS
        global SUB_PROCESS_ADDRESS
        response = None
        force_start = False
        repeat_times = 1
        interval_seconds = 600
        diff_threshold = 95
        crawl_url = env_variables.get_env_var("WEBPAGE_URL")
        try:
            if 'force_start' in request.json:
                force_start = request.json.get('force_start')

            if SUB_PROCESS is not None:
                process_running = SUB_PROCESS.poll()
                if process_running is None:
                    if force_start is True:
                        current_app.logger.info(
                            "Got force_start True, killing old crawler.")
                        proccess_id = SUB_PROCESS.pid
                        crawl_url = SUB_PROCESS_ADDRESS
                        SUB_PROCESS.kill()
                        SUB_PROCESS = None
                        SUB_PROCESS_ADDRESS = None
                        Database.update_finished_crawler(
                            process_id=proccess_id, address=crawl_url, status="Stopped")
                    else:
                        return jsonify(success=True, started=False)

            if 'repeat_times' in request.json:
                repeat_times = request.json.get('repeat_times')
            if 'interval_seconds' in request.json:
                interval_seconds = request.json.get('interval_seconds')
            if 'diff_threshold' in request.json:
                diff_threshold = request.json.get('diff_threshold')
            if 'crawl_url' in request.json:
                crawl_url = request.json.get('crawl_url')
            current_app.logger.debug(
                f"Going to repeat {repeat_times} times by {interval_seconds} seconds interval on {crawl_url} "
                f"using a {diff_threshold}% threshold. "
            )
            SUB_PROCESS = subprocess.Popen(["python3", "crawler.py", str(
                repeat_times), str(interval_seconds), str(diff_threshold), str(crawl_url)])
            SUB_PROCESS_ADDRESS = crawl_url
            Database.insert_new_crawl_task(
                SUB_PROCESS.pid, crawl_url, repeat_times, interval_seconds)
            response = jsonify(success=True, started=True)
        except Exception as exc:
            current_app.logger.error(exc)
            response = jsonify(success=False, started=False)
        return response

    @app.route('/crawler/stop', methods=['GET'])
    @cross_origin()
    def crawler_stop():
        global SUB_PROCESS
        global SUB_PROCESS_ADDRESS
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
                    proccess_id = SUB_PROCESS.pid
                    crawl_url = SUB_PROCESS_ADDRESS
                    SUB_PROCESS.kill()
                    SUB_PROCESS = None
                    SUB_PROCESS_ADDRESS = None
                    Database.update_finished_crawler(
                        process_id=proccess_id, address=crawl_url, status="Stopped")
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
