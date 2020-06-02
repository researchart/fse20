#!/usr/bin/env python3

# mkvirtualenv --python=/usr/bin/python3 qvtrace-wrapper
# pip install requests websocket-client

ROOT_URI='http://localhost:2999/api/'
WS_URI="ws://localhost:2999/websocket/validation"

import requests
import json
import sys
import asyncio
import threading

# Copyright by University of Luxembourg 2019-2020. Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg.
# Copyright by University of Luxembourg 2019-2020. Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg.
# Copyright by University of Luxembourg 2019-2020. Developed by Shiva Nejati,snejati@uottawa.ca University of Luxembourg.
# Copyright by University of Luxembourg 2019-2020. Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg.

################################################################
# The only reason to set up the websocket so early is to grab
# a session id which should be supplied with every request.
################################################################

import websocket
import time

class Globals:
    session_id = None
    last_result = None
    ws = None
    model_id = None
    ready = threading.Event()
    analysis_complete = threading.Event()

def on_message(ws, message):
    msg = json.loads(message)
    action = msg['action']
    if action == 'session_id':
        Globals.session_id = msg['message']
        Globals.ready.set()
    elif action == 'analysis_start':
        Globals.last_result = None
        print("Analysis started on session %s" % Globals.session_id)
    elif action == 'constraint_update':
        Globals.last_result = msg['details']
    elif action == 'analysis_end':
        result = Globals.last_result
        Globals.last_result = None
        f = open('message.txt', 'a')
        f.write(str(msg)+"\n")
        f.close()
        Globals.analysis_complete.set()
    elif action == 'console_message':
        f = open('message.txt', 'a')
        f.write(str(msg)+"\n")
        f.close()
    elif action == 'analysis_summary':
        pass
    else:
        print("Ignored msg: %s" % msg)
        f = open('message.txt', 'a')
        f.write(str(msg)+"\n")
        f.close()


def on_error(ws, error):
    if "0" == ("%s" % error):
        pass  # this was due to exit(0)
    else:
        print(" on_error (%s) ===> %s" % (type(error), error))

def on_close(ws):
    pass

def on_open(ws):
    pass

if __name__ == "__main__":
    websocket.enableTrace(False)
    Globals.ws = websocket.WebSocketApp(WS_URI,
                              on_message = on_message,
                              on_error = on_error,
                              on_close = on_close)
    Globals.ws.on_open = on_open
    wst = threading.Thread(target=Globals.ws.run_forever)
    wst.daemon = True
    wst.start()

def headers():
    return {'QVtrace-session-id': Globals.session_id,
            'QVtrace-client-timezone': 'America/Halifax'}

def upload_model(mdl, mat):
    files = {'qvt-model': open(mdl, 'rb'),
             'qvt-data': open(mat, 'rb')}
    print("Uploading %s with data file %s" % (mdl, mat))
    r = requests.post(ROOT_URI + "upload_model", files=files, headers=headers())
    if 200 != r.status_code:
        print(r)
        sys.exit(1)
    Globals.model_id = r.json()['id']
    print("Uploaded")

def analyze(qct):
    ################################################################
    # Upload the constraints and attach them to an existing model.  This discards
    # any previous constraint attached to the same model.
    ################################################################
    model_id = Globals.model_id

    files = {'qvt-invariant': open(qct, 'rb')}

    print("Uploading qct: %s %s" % (model_id, qct))
    r = requests.post(ROOT_URI + "models/%s/upload_constraints" % model_id, files=files, headers=headers())
    assert 200 == r.status_code
    ################################################################
    Globals.ws.send(json.dumps({'action': 'validate_constraints',
                                'params': {'id': model_id,
                                           # Set constraint_id to analyze the nth constraint only
                                           'constraint_id': None}}))

    Globals.analysis_complete.wait()
    Globals.analysis_complete.clear()
    print("Analyzed")

if __name__ == "__main__":
    while(True):
        turn="Matlab";
        while "Matlab" in turn:
            f = open('turn.txt', 'r');
            turn=f.readline();
            f.close();
            time.sleep(1)
            print('Waiting for matlab');
    
        if "LoadModel" in turn:
            print('Load Model');
            upload_model("./model.mdl","./model.mat")
            print('Load Done');
            f = open('turn.txt', 'w');
            f.write("Matlab");
            f.close()
        elif "QvCheck" in turn:
            print('Checking')
            analyze("./qct.qct")
            print('Done checking');
            f = open('turn.txt', 'w');
            f.write("Matlab");
            f.close();
        else:
            f = open('turn.txt', 'w');
            f.write("Matlab");
            f.close()


