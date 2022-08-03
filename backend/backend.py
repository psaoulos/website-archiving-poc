""" Entry file for the application. """
from __future__ import print_function, unicode_literals
import subprocess
import urllib.parse
import json
import os
from datetime import date
from flask import Flask, render_template, jsonify, current_app, request
from flask_socketio import SocketIO, emit, disconnect
from flask_cors import CORS, cross_origin

from modules import Variables, Database, FileSystem, Logger

SUB_PROCESS = None
SUB_PROCESS_CRAWLER_ID = None


def main():
    """ Main app function. """

    FileSystem.init_folders()
    env_variables = Variables()
    env_variables.init_variables_from_env()
    Database.init_database()

    app = Flask("crawler_backend")
    CORS(app)
    app.config['CORS_HEADERS'] = 'Content-Type'
    app.config['SECRET_KEY'] = 'secret!'
    # socketio = SocketIO(app, logger=True, engineio_logger=True, debug=True)  # All the loggers
    socketio = SocketIO(app, cors_allowed_origins='*')

    @socketio.on("connect", namespace="/getlogs")
    def connected():
        emitLogsUpdates()
        try:
            current_app.logger.info("New websocket client connected")
        except Exception:
            current_app.logger.info("New websocket client failed to connect")
            disconnect()
            return False

    @socketio.on("disconnect", namespace="/getlogs")
    def disconnected():
        current_app.logger.info("Websocket client disconnected")

    @socketio.on("frontend_request", namespace="/getlogs")
    def logs_requested(message):
        current_app.logger.info(
            "Websocket logs requested, received json:"+str(message))
        emit('backend_response',
             {'logs': 'some data'})

    @socketio.on_error(namespace="/getlogs")
    def on_error(error):
        current_app.logger.error(error)

    def emitLogsUpdates():
        with open('./templates/logs_content.html', 'r', encoding='utf-8') as logs_file:
            data = json.dumps(urllib.parse.quote(logs_file.read()))
            current_app.logger.info(
                "emmiting"+data)
            emit('logs_update', data)

    @app.route('/crawler/status', methods=['GET'])
    @cross_origin()
    def crawler_status():
        response = None
        crawler_status = []
        try:
            if SUB_PROCESS is None:
                response = jsonify(success=True, running=False,
                                   crawlers=crawler_status)
            else:
                process_running = SUB_PROCESS.poll()
                if process_running is None:
                    crawler_status = Database.get_active_crawlers()
                    response = jsonify(
                        success=True, running=True, crawlers=crawler_status)
                else:
                    response = jsonify(
                        success=True, running=False, crawlers=crawler_status)
        except Exception as exc:
            current_app.logger.error(exc, exc_info=True)
            response = jsonify(success=False)
        return response

    @app.route('/crawler/start', methods=['POST'])
    @cross_origin()
    def crawler_start():
        global SUB_PROCESS
        global SUB_PROCESS_CRAWLER_ID
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
                        SUB_PROCESS.kill()
                        Database.update_finished_crawler(
                            crawler_id=SUB_PROCESS_CRAWLER_ID, status="Stopped")
                        SUB_PROCESS = None
                        SUB_PROCESS_CRAWLER_ID = None
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
            crawler_id = Database.insert_new_crawl_task(
                crawl_url, repeat_times, interval_seconds)
            SUB_PROCESS_CRAWLER_ID = crawler_id
            SUB_PROCESS = subprocess.Popen(["python3", "crawler.py", str(
                repeat_times), str(interval_seconds), str(diff_threshold), str(crawl_url)])
            Database.update_new_crawl_task_pid(
                crawler_id, int(SUB_PROCESS.pid))
            response = jsonify(success=True, started=True)
        except Exception as exc:
            current_app.logger.error(exc, exc_info=True)
            response = jsonify(success=False, started=False)
        return response

    @app.route('/crawler/stop', methods=['GET'])
    @cross_origin()
    def crawler_stop():
        global SUB_PROCESS
        global SUB_PROCESS_CRAWLER_ID
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
                    Database.update_finished_crawler(
                        crawler_id=SUB_PROCESS_CRAWLER_ID, status="Stopped")
                    SUB_PROCESS = None
                    SUB_PROCESS_CRAWLER_ID = None
                    response = jsonify(success=True, stopped=True)
                else:
                    current_app.logger.info(
                        "No subprocess to kill.")
                    response = jsonify(success=True, stopped=False)
        except Exception as exc:
            current_app.logger.error(exc, exc_info=True)
            response = jsonify(success=False)
        return response

    @app.route('/getlogs', methods=['GET'])
    @cross_origin()
    def backend_get_logs():
        response = None
        try:
            with open('./logs/crawler_backend.log', 'r', encoding='utf-8') as logs_file:
                return render_template('logs_content.html', text=logs_file.read())
        except Exception as exc:
            current_app.logger.error(exc)
            response = jsonify(success=False)
        return response
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
