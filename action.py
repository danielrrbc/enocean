__author__ = 'raimondi'

class Action(object):
    # Action id (from database)
    ON_ACTION = 1
    OFF_ACTION = 2
    TOGGLE_ACTION = 3

    def __init__(self, id, actuator, enoceanId = None, button = None):
        self.id = id
        self.actuator = actuator
        self.enOceanId = enoceanId
        self.button = button

    def isSendRadioMessage(self):
        return self.enOceanId is not None