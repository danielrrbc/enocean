import serial
import checksum
import datetime,  struct
import  threading,  struct
from event import ButtonEvent

class ESP3BasePacket(object):
    
    def __init__(self, pktType, data, optData = bytearray(0)):
        self.pktType = pktType
        self.data = data
        self.optData = optData 
        self.timeStamp = datetime.datetime.now()
        self.initFromData()
        
    def initFromData(self):
        pass
        
    @classmethod
    def fromData(cls,  data, optData = bytearray(0)):
        return cls(cls.typeId,  data,  optData)
        
    # serialize packet header and compute checksum
    def  _header(self):
        # Create header form data length and packet type
        header = bytearray(struct.pack('>HBB', 
                                        len(self.data),  
                                        len(self.optData),  
                                        self.pktType))
        # compute checksum
        crc = checksum.crc8(0xff)
        crc.update(header)
        header.append(crc.sum)   
        # sync byte (not included in checksum)
        header.insert(0,  0x55)
        return header

    # serialize entier packet
    def serialize(self):
        # serialize header
        pkt = self._header()
        
        # compute checksum over data
        crc = checksum.crc8(0xff)
        crc.update(self.data)
        crc.update(self.optData)
        
        # append data and opt. data (if any)
        if len(self.data) > 0:
            pkt = pkt + self.data
        if len(self.optData) > 0:
            pkt = pkt + self.optData
        
        # finaly add data checksum
        pkt.append(crc.sum)
        return pkt
        
    def _printBaseInfo(self):
        s =   '\nESP3 packet type: 0x{0:02x} ({1})\n'.format(self.pktType, self.__class__.__name__)
        s += 'Data length     : {0:d}\n'.format(len(self.data))
        s += 'Opt. data length: {0:d}\n'.format(len(self.optData))
        return s

    def _printContent(self):
        return ''
        
    def __str__(self):
        return self._printBaseInfo() + self._printContent()
        
    @classmethod
    def factory(cls,  pktType,  data,  optData):
        if pktType == ESP3Radio.typeId: 
            return ESP3Radio.fromData(data, optData)
        if pktType == ESP3Response.typeId:
            return ESP3Response.fromData(data,  optData)
        # add all other packet type
        else:
            # fall back for unknown packets
            return ESP3BasePacket(pktType,  data,  optData)
  

class ESP3Radio(ESP3BasePacket):
    
    typeId = 0x01

    def initFromData(self):
        self.choice = self.data[0]        
        (self.senderId,  self.status)= struct.unpack('>IB',  str(self.data[len(self.data)-5:len(self.data)]))
        (self.subTelNum,  self.destId,  self.dBm,  self.SecurityLevel) = struct.unpack('>BIBB',  str(self.optData))
        self.repeatCount = self.status & 0x0F
        # T21 and NU flags as tuple
        self.flags = ((self.status >> 5) & 0x01, (self.status >> 4) & 0x01)

    def toEvents(self):
        # act upon choice
        if self.choice == 0xf6:
            if self.flags == (1, 1):
                # one or more buttons pressed
                btn = self.data[1]
                events = (ButtonEvent.buttonPressed(self.timeStamp, self.senderId, (btn >> 5) & 0x7), )
                if btn & 0x01:
                    # 2nd button pressed
                    events += (ButtonEvent.buttonPressed(self.timeStamp, self.senderId, (btn >> 1) & 0x7), )
                # return event tuple
                return events
            elif self.flags == (1, 0):
                # buttons released (one or more)
                return ButtonEvent.buttonReleased(self.timeStamp, self.senderId),

        # fallback return empty tuple
        return ()

    def _printContent(self):    
        s = '**** Data ****\n'    
        s += 'Choice          : 0x{0:x}\n'.format(self.data[0])
        for x in range(1, len(self.data)-5):
            s += 'Data Byte {1:d}     : {0:08b}b\n'.format(self.data[x],  x)
        s +=  'Sender ID       : 0x{0:08x}\n'.format(int(str(self.data[len(self.data)-5:len(self.data)-1]).encode('hex'), 16))
        s +=  'Status          : {0:08b}b\n'.format(self.data[len(self.data)-1])
        s +=  '**** Optional Data ****\n'
        if len(self.optData) > 0:
            s +=  'SubTelNum       : {0:d}\n'.format(self.subTelNum)
            s +=  'Destination ID: 0x{0:08x}\n'.format(self.destId)
            s +=  'dBm             : {0:d}\n'.format(self.dBm)
            s +=  'Security Level  : {0:d}\n'.format(self.SecurityLevel)
        else:
            s +=  'None\n'
        return s

class ESP3Response(ESP3BasePacket):

    typeId = 0x02

class ESP3CommonCommand(ESP3BasePacket):

    typeId = 0x05

    @classmethod
    def withCommand(cls,  cmd,  cmdData = bytearray(0),  optData = bytearray(0)):
        data = bytearray(struct.pack('B',  cmd)) + cmdData
        return cls.fromData(data,  optData)



class States:  
  Idle, Sync, Data, OptData, Chk = range(5)

global sp, rxState

def connect(aPort,  aBaudrate=57600):
    """

    """
    global sp, rxState
    sp = serial.Serial(aPort,  aBaudrate,  timeout = 1)
    rxState = States.Idle

def disconnect():
    sp.close()

def sendPacket(pkt):
    spkt = str(pkt.serialize())
    sp.write(spkt)

def receivePacket():
    # initialize some local variables
    pcktType = 0
    PcktData = None
    OptData = None
    optLength = 0

    # number of bytes to receive as next
    n = 1
    rxState = States.Idle

    while 1:
        data = sp.read(n)

        if len(data) == n:
            # received enough bytes
            data = bytearray(data)

            if rxState == States.Idle:
                if data[0] == 0x55:
                    rxState = States.Sync
                    # next we want to receive 4 header bytes + 1 crc
                    n = 5

            elif rxState == States.Sync:
                crc = checksum.crc8(0xff)
                crc.update(data)
                if crc.valid():
                    # extract header
                    dataLength = (data[0] << 8) + data[1]
                    optLength = data[2]
                    pcktType = data[3]
                    # proceed to next rxState
                    rxState = States.Data
                    n = dataLength
                else:
                    # Go back to idle (could be improved)
                    rxState = States.Idle
                    n = 1

            elif rxState == States.Data:
                PcktData = data
                # proceed to next rxState
                rxState = States.OptData
                n = optLength

            elif rxState == States.OptData:
                OptData = data
                # proceed to next rxState
                rxState = States.Chk
                n = 1

            elif rxState == States.Chk:
                # verify data
                crc = checksum.crc8(0xff)
                crc.update(PcktData)
                crc.update(OptData)
                crc.update(data)
                if crc.valid():
                    return ESP3BasePacket.factory(pcktType, PcktData, OptData)

                # packet completed => back to idle
                rxState = States.Idle
                n = 1

            else:
                # timeout => back to idle
                rxState = States.Idle
                n = 1


def startRadioReceiver(queues):
    """
    start receiver thread
    """
    rt = threading.Thread(target=radioReceiver,  args=(queues, ))
    rt.setDaemon(True)
    rt.start()
    return rt


def radioReceiver(queues):
    while True:
        pkt = receivePacket()
        if pkt:
            try:
                # try to get queue for packet
                queues[pkt.typeId].put(pkt)
                print 'Packet on specific queue'
            except KeyError:
                # put on default queue (which must exist!)
                queues['default'].put(pkt)
                print 'Packet on default queue'
