package.path = "./?.lua;./sdp-jingle-table/src/?.lua;" .. package.path;

local Jingle = require("basejingle");

local xmlns_jingle = "urn:xmpp:jingle:1";
local jingletolua = require("jingletolua");
jingletolua.init();

local JingleMedia = Jingle:new();

function JingleMedia:onSessionInitiate(req)
    local jingle_tag = req:get_child('jingle', xmlns_jingle);
    local sdp, intermediate = jingletolua.toSDP(jingle_tag);
    self.remote_state = intermediate;
    self.client:event("jingle/session-initiate-sdp", sdp, self.peer, self.sid);
    self.client:send(verse.reply(req));
    return true;
end

function JingleMedia:acceptSDP(sdp)
    local jingle = jingletolua.toJingle(sdp, 'responder');
    jingle.attr.initiator = self.peer;
    jingle.attr.responder = self.client.full;
    jingle.attr.action = 'session-accept';
    jingle.attr.sid = self.sid;
    local iq = self.verse.iq({
        to = self.peer,
        from = self.client.full,
        type = "set",
    });
    iq:add_child(jingle);
    self.client:send(iq);
end

function JingleMedia:initiateSDP(sdp)
    local jingle = jingletolua.toJingle(sdp, 'initiator');
    jingle.attr.responder = self.peer;
    jingle.attr.initiator = self.client.full;
    jingle.attr.action = 'session-initiate';
    jingle.attr.sid = self.sid;
    local iq = self.verse.iq({
        to = self.peer,
        from = self.client.full,
        type = "set",
    });
    iq:add_child(jingle);
    self.client:send(iq);
end

function JingleMedia:onSourceAdd(req)
    local jingle_tag = req:get_child('jingle', xmlns_jingle);
    local sdp, intermediate = jingletolua.toSDP(jingle_tag);
    --self.remote_state = intermediate;
    --self.remote_state = jingletolua.mergeSDP(self.remote_state, intermediate);
    self.client:event("jingle/source-add-sdp", sdp, self.peer, self.sid);
    self.client:send(verse.reply(req));
    return true;
end

function JingleMedia:onSourceRemove(req)
    local jingle_tag = req:get_child('jingle', xmlns_jingle);
    local sdp, intermediate = jingletolua.toSDP(jingle_tag);
    --self.remote_state = intermediate;
    --self.remote_state = jingletolua.mergeSDP(self.remote_state, intermediate);
    self.client:event("jingle/source-remove-sdp", sdp, self.peer, self.sid);
    self.client:send(verse.reply(req));
    return true
end


return JingleMedia;
