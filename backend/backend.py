""" Entry file for the application. """
from __future__ import print_function, unicode_literals
import difflib
import subprocess
import urllib.parse
import os
from datetime import date
from flask import Flask, render_template, jsonify, current_app, request
from flask_socketio import SocketIO, emit, disconnect
from flask_cors import CORS, cross_origin

from modules import Variables, Database, FileSystem, Logger

SUB_PROCESS = None
SUB_PROCESS_CRAWLER_ID = None
SOCKET_CONNECTED_USERS = 0


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
        global SOCKET_CONNECTED_USERS
        try:
            SOCKET_CONNECTED_USERS += 1
            current_app.logger.debug(
                "New websocket client connected, total:"+str(SOCKET_CONNECTED_USERS))
        except Exception:
            current_app.logger.debug("New websocket client failed to connect")
            disconnect()
            return False

    @socketio.on("disconnect", namespace="/getlogs")
    def disconnected():
        global SOCKET_CONNECTED_USERS
        if SOCKET_CONNECTED_USERS > 0:
            SOCKET_CONNECTED_USERS -= 1
        current_app.logger.debug(
            "Websocket client disconnected, total:" + str(SOCKET_CONNECTED_USERS))

    @socketio.on("frontend_request", namespace="/getlogs")
    def logs_requested(message):
        emit_logs()

    @socketio.on_error(namespace="/getlogs")
    def on_error(error):
        current_app.logger.error(error)

    def emit_logs():
        """ Used to send the first logs update after client connection. """
        emit_logs_update()
        if SOCKET_CONNECTED_USERS == 1:
            emit_logs_recursively()

    def emit_logs_recursively():
        """ Used to send the logs updaterecursively. """
        socketio.sleep(15)
        if SOCKET_CONNECTED_USERS > 0:
            emit_logs_update()
            emit_logs_recursively()

    def emit_logs_update():
        """ Helper function for generating the logs html and emit it. """
        with open('./templates/logs_content.html', 'r', encoding='utf-8') as template_file:
            with open('./logs/crawler_backend.log', 'r', encoding='utf-8') as logs_file:
                temp = template_file.read().replace(
                    "{{_logs_}}", logs_file.read())
                data = {'logs': urllib.parse.quote(temp)}
                emit('logs_update', data, broadcast=True)

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

    @app.route('/results/getalladdresses', methods=['GET'])
    @cross_origin()
    def crawler_results_getalladdresses():
        response = None
        try:
            result = Database.get_addresses_and_archive_sum()
            response = jsonify(success=True, addresses=result)
        except Exception as exc:
            current_app.logger.error(exc)
            response = jsonify(success=False)
        return response

    @app.route('/results/getearliestarchive', methods=['POST'])
    @cross_origin()
    def crawler_results_getearliestarchive():
        response = None
        root_address = None
        try:
            if 'root_address' in request.json:
                root_address = request.json.get('root_address')
            if root_address is None:
                response = jsonify(success=False)
            else:
                result = Database.get_first_archive_taken(root_address)
                response = jsonify(success=True, archive=result)
        except Exception as exc:
            current_app.logger.error(exc, exc_info=True)
            response = jsonify(success=False)
        return response

    @app.route('/results/getlatestarchive', methods=['POST'])
    @cross_origin()
    def crawler_results_getlatestarchive():
        response = None
        root_address = None
        try:
            if 'root_address' in request.json:
                root_address = request.json.get('root_address')
            if root_address is None:
                response = jsonify(success=False)
            else:
                result = Database.get_last_archive_taken(root_address)
                response = jsonify(success=True, archive=result)
        except Exception as exc:
            current_app.logger.error(exc, exc_info=True)
            response = jsonify(success=False)
        return response

    @app.route('/results/getallarchive', methods=['POST'])
    @cross_origin()
    def crawler_results_getallarchive():
        response = None
        root_address = None
        try:
            if 'root_address' in request.json:
                root_address = request.json.get('root_address')
                result = Database.get_all_archives(root_address)
                response = jsonify(success=True, archives=result)
        except Exception as exc:
            current_app.logger.error(exc, exc_info=True)
            response = jsonify(success=False)
        return response

    @app.route('/results/generatehtml/<first_archive_id>/<second_archive_id>', methods=['GET'])
    @cross_origin()
    def crawler_results_html(first_archive_id=None, second_archive_id=None):
        response = None
        if first_archive_id is None or second_archive_id is None:
            response = jsonify(success=False)
        else:
            try:
                locations = Database.get_archives_location_from_id(first_archive_id, second_archive_id)
                if len(locations) == 2:
                    with open(locations[0][0], 'r', encoding='utf-8') as file_a:
                        with open(locations[1][0], 'r', encoding='utf-8') as file_b:
                            diff = difflib.HtmlDiff(wrapcolumn=60)
                            diff._styles = diff._styles + """
                                    table.diff {
                                        font-family:Courier;
                                        border:medium;
                                        margin-left: auto;
                                        margin-right: auto;
                                    }
                                    """
                            result = diff.make_file(file_a, file_b, context=True)
                            float_ratio = FileSystem.calculate_file_difference(locations[0][0], locations[1][0])
                            percentage = (1 - round(float_ratio, 6)) * 100
                            return render_template('archive_diffs.html', generated=result, ratio=percentage)
                else:
                    current_app.logger.error(f"Databse returned {len(locations)} locations, need exactly 2 to run.")
                    response = jsonify(success=False)
            except Exception as exc:
                current_app.logger.error(exc)
                response = jsonify(success=False)
        return response

    @cross_origin()
    def crawler_results():
        response = None
        try:
            with open('./logs/temp.html', 'r', encoding='utf-8') as logs_file:
                return render_template('archive_diffs.html', text=logs_file.read())
        except Exception as exc:
            current_app.logger.error(exc)
            response = jsonify(success=False)
        return response

    socketio.run(app, host='0.0.0.0', port=3000)


if __name__ == "__main__":
    print("Logs at: "+os.getcwd()+"/logs/app.log")
    Logger.init_logger()
    logger = Logger.get_logger()
    logger.info("Crawler Backend started!")
    main()
    logger.info("Crawler Backend finished!")
