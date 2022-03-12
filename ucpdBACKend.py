import firebase_admin
import json
from firebase_admin import db
from firebase_admin import credentials
from time import time, sleep
from datetime import datetime

cred = credentials.Certificate("/Users/liamwebster/Documents/Projects/BearTransit/beartransit-firebase-adminsdk-5k8ju-8ccf6d56aa.json")
firebase_admin = firebase_admin.initialize_app(cred, {'databaseURL': 'https://beartransit-default-rtdb.firebaseio.com/'})

ref = db.reference("ucpdmarkers")
ucpdmarkers = ref.get()

with open("/Users/liamwebster/Documents/Projects/BearTransit/ucpdMarkers.json", "r") as f:
	    file_contents = json.load(f)


#function that uses gmail api to check in on UCPD alerts
def checkemail():
    return False

#function that is called if new UCPD alert is sent 
#Then gathers that info and consolidates it into json format
def getUCPDmarks():
    data = {
	    "Mark1":
	    {
		    "description": "The Fellowship of the",
		    "lat": 37.87414537699706,
		    "long": -122.26610000564193,
		    "time": "10:57am"
	    },
    }
    return data

def addMarkers(data):
    ref.update(data)

def deleteMarkers():
    now = datetime.now()
    current_time = now.strftime("%H:%M:%S")
    for key, value in ucpdmarkers.items():
	    if(int(value["time"][0:1]) - int(current_time[0:1]) > 2):
		    ref.child(key).set({})


def main():
    while True: 
        sleep(120 - time() % 1)
        if checkemail():
            data = getUCPDmarks()
            addMarkers(data)
            deleteMarkers()

if __name__ == "__main__":
    main()
