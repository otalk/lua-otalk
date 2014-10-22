local UUID = require("uuid");

local Jingle = {};

function Jingle:new(o)
    local o = o or {
        sid = "",
        peer = "",
        peerID = "",
        initiator = false,
        descriptionTypes = {},
        transportTypes = {},
    };
    o.sid = o.sid or UUID();
    o.peerID = o.peerID or o.peer;
    o.isInitiator = o.initator or false;
    o.isPending = false;
    o.isEnded = false;
    o.pendingAction = false;
    o.state = 'starting';
    o.connectionState = 'starting';
    o.descriptionTypes = o.descriptionTypes or {};
    o.pendingAction = false;

    setmetatable(o, self);
    self.__index = self;


    return o;
end


local ACTIONS = {};
ACTIONS["content-accept"] = 'onContentAccept';
ACTIONS['content-add'] = 'onContentAdd';
ACTIONS['content-modify'] = 'onConentModify';
ACTIONS['content-reject'] = 'onContentReject';
ACTIONS['content-remove'] = 'onContentRemove';
ACTIONS['description-info'] = 'onDescriptionInfo';
ACTIONS['security-info'] = 'onSecurityInfo';
ACTIONS['session-accept'] = 'onSessionAccept';
ACTIONS['session-info'] = 'onSessionInfo';
ACTIONS['session-initiate'] = 'onSessionInitiate';
ACTIONS['session-terminate'] = 'onSessionTerminate';
ACTIONS['transport-accept'] = 'onTransportAccept';
ACTIONS['transport-info'] = 'onTransportInfo';
ACTIONS['transport-reject'] = 'onTransportReject';
ACTIONS['transport-replace'] = 'onTransportReplace';
ACTIONS['source-add'] = 'onSourceAdd';
ACTIONS['source-remove'] = 'onSourceRemove';

local STATES = {
    starting = 'isStarting',
    pending = 'isPending',
    active = 'isActive',
    ended = 'isEnded',
    connecting = 'isConnecting',
    connected = 'isConnected',
    disconnected = 'isDisconnected',
    interrupted = 'isInterrupted',
};


function Jingle:initialize(peer, sid, sdp)
end

function Jingle:process(action, req)
    print("processing?");
    if ACTIONS[action] then
        print("1");
        return self[ACTIONS[action]](self, req);
    else
        print("nope");
    end
    print("happened?");
end

function Jingle:check(state)
    if states[state] then
        return self[states[state]];
    end
    return false;
end

function Jingle:onContentAccept(req)
    print("onContentAccept works!");
    print(self);
    print(req);
end

function Jingle:onContentAdd(req)
end

function Jingle:onContentModify(req)
end

function Jingle:onConnectReject(req)
end

function Jingle:onContentRemove(req)
end

function Jingle:onDescriptionInfo(req)
end

function Jingle:onSecurityInfo(req)
end

function Jingle:onSessionAccept(req)
end

function Jingle:onSessionInitiate(req)
end

function Jingle:onSessionTerminate(req)
end

function Jingle:onTransportAccept(req)
end

function Jingle:onTransportInfo(req)
end

function Jingle:onTransportReject(req)
end

function Jingle:onTransportReplace(req)
end

function Jingle:onSourceAdd(req)
end

function Jingle:onSourceRemove(req)
end

function Jingle:close(reason)
end

print("new jingle");
local x = Jingle:new();
print("processing");
x:process('content-accept', 'derp');

