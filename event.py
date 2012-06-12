#import ESP3Radio from esp3
import threading

__author__ = 'raimondi'

class Event(object):
    # Event id (from database)
    BUTTON_PRESSED_EVENT = 1
    BUTTON_RELEASED_EVENT = 2

    def __init__(self, id, ts):
        self.id = id
        self.timeStamp = ts


class ButtonEvent(Event):

    def __init__(self, id, ts, sensor, button = -1):
        super(ButtonEvent, self).__init__(id, ts)
        self.sensor = sensor
        self.button = button

    @classmethod
    def buttonPressed(cls, ts, sensor, button):
        return cls(cls.BUTTON_PRESSED_EVENT, ts, sensor, button)

    @classmethod
    def buttonReleased(cls, ts, sensor):
        return cls(cls.BUTTON_RELEASED_EVENT, ts, sensor)


def startEventHandler(inQueue, outQueue):
    # start receiver thread
    et = threading.Thread(target=eventHandler,  args=(inQueue, outQueue))
    et.setDaemon(True)
    et.start()

def eventHandler(inQueue, outQueue):

    while True:
        # get radio packets
        pkt = inQueue.get()
        # transform radio packets into events
        events = pkt.toEvents()
        for e in events:
            # put events on outQueue
            outQueue.put(e)

