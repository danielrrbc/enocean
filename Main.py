import esp3
import  Queue,  sqlite3
from event import startEventHandler, ButtonEvent, Event
from action import Action

def logRadio(pkt):
    userData = pkt.data[1:len(pkt.data) - 5]
    cur.execute("""\
    INSERT INTO RadioLog
        (Choice, Data, SenderId, Status, SubTelNum, DestinationId,
        dBm, SecurityLevel, TimeStamp)
    VALUES
        ({0:d}, X'{1}', {2:d}, {3:d}, {4:d}, {5:d}, {6:d}, {7:d}, '{8}')\
    """.format(pkt.choice,  str(userData).encode('hex'),  pkt.senderId,
        pkt.status,  pkt.subTelNum,  pkt.destId,  pkt.dBm,
        pkt.SecurityLevel,  pkt.timeStamp))

    conn.commit()

def mapEvent(e):
    result = ()
    if isinstance(e, ButtonEvent):
        cond = ""
        if e.id == Event.BUTTON_PRESSED_EVENT:
            # search for mappings with button number
            cond = "AND SensorButton = {0:d}".format(e.button)

        sql = """\
        SELECT ActionId, ActuatorId, EnOceanId, ActionButton
        FROM xEventAction
            WHERE
                SensorId = {0:d}
            AND
                EventTypId = {1:d}
            {2:s};
            """.format(e.sensor, e.id, cond)


        for row in conn.execute(sql):
            result += (Action(row[0], row[1], row[2], row[3]), )

    return result

def runAction(a):
    if a.isSendRadioMessage():
        # send radio message
        pass

    if a.id == Action.ON_ACTION:
        new_state = '1'
    elif a.id == Action.TOGGLE_ACTION:
        new_state = 'not State'
    else:
        new_state = '0'

    cur.execute("UPDATE Actuators SET 'State' = {0:s};".format(new_state))
    conn.commit()

# Initialize communication
esp3.connect('COM15')

# connect to database
conn = sqlite3.connect('C:/Users/raimondi/Dropbox/Projekte/EnOcean/Database')

cur = conn.cursor()

# Create queues for reader
# One queue for radio messages from reader into core
qRadio = Queue.Queue()
# One queue for ESP3 responses
qResponse = Queue.Queue()
# Create event queue
qEvent = Queue.Queue()

# build dict based on packet type
queues = dict({esp3.ESP3Radio.typeId: qRadio, 
                    esp3.ESP3Response.typeId: qResponse, 
                    'default': qResponse})      # default queue for unknown packet types

running = True
print 'Starting reader..'
esp3.startRadioReceiver(queues)
print 'Reader started..'

print 'Starting event handler..'
startEventHandler(qRadio, qEvent)
print 'Event handler started..'

# send initialization packet to query base id
esp3.sendPacket(esp3.ESP3CommonCommand.withCommand(0x8))
# receive response
pkt = qResponse.get()
print pkt

base_id = 0xff9c9180
base = bytearray()
base.append(0xff)
base.append(0x9c)
base.append(0x91)
base.append(0x80)

while running:
    # get next event
    e = qEvent.get()

    for a in mapEvent(e):
        runAction(a)


esp3.disconnect()