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
    o.isInitiator = o.initiator or false;
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
        if not self[ACTIONS[action]] then
            print("We don't have one of those!");
            self.client:send(req:error_reply('modify', 'feature-not-implemented'));
            return true;
        else
            return self[ACTIONS[action]](self, req);
        end
    else
        print("Invalid action.");
        self.client:send(req:error_reply('cancel', 'bad-request'));
        return true;
    end
end


function Jingle:createJingleStanzaSDP(action, sdp)
    local jingle = {};
    if (self.initiator) then
        jingle = jingletolua.toJingle(sdp, 'initiator');
        jingle.attr.responder = self.peer;
        jingle.attr.initiator = self.client.full;
    else
        jingle = jingletolua.toJingle(sdp, 'initiator');
        jingle.attr.initiator = self.peer;
        jingle.attr.responder = self.client.full;
    end
    jingle.attr.action = action;
    jingle.attr.sid = self.sid;
    return jingle;
end

function Jingle:createJingleStanza(action)
    local jingle = self.verse.stanza('jingle', {
        xmlns = "urn:xmpp:jingle:1",
        action = action,
        sid = self.sid,
    });
    if (self.initiator) then
        jingle.attr.initiator = self.client.full;
    else
        jingle.attr.initiator = self.peer;
    end
    return jingle;
end

function Jingle:createIqStanza(st_type)
    local iq = self.verse.iq({
        to = self.peer,
        from = self.client.full,
        type = st_type or "set",
    });
    return iq;
end

function Jingle:createSetSDP(action, sdp)
    local jingle = self:createJingleStanzaSDP(action, sdp);
    local iq = self:createIqStanza();
    iq:add_child(jingle);
    return iq, jingle;
end

function Jingle:createInfo()
    local jingle = self:createJingleStanza('session-info');
    local iq = self:createIqStanza();
    iq:add_child(jingle);
    return iq, jingle;
end

function Jingle:check(state)
    if STATES[state] then
        return self[STATES[state]];
    end
    print("State not found.");
    return false;
end


function Jingle:onContentAdd(req)
end

function Jingle:onDescriptionInfo(req)
            self.client:send(
                req:error_reply('modify', 'feature-notimplemented')
                    :tag("out-of-order", {xmlns = xmlns_jingle_error})
                    :up()
            );
end

function Jingle:onTransportInfo(req)
end

function Jingle:onSessionInfo(req)
end

function Jingle:onSessionAccept(req)
end

function Jingle:onTransportReplace(req)
end

function Jingle:onSessionTerminate(req)
    print("Received session terminate")
end

function Jingle:endSession(reason)
end

return Jingle;
