package.path = "./?.lua;./sdp-jingle-table/src/?.lua;" .. package.path;

local Jingle = require("basejingle");

local xmlns_jingle = "urn:xmpp:jingle:1";
local xmlns_jingle_rtp_info = "urn:xmpp:jingle:apps:rtp:info:1";
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

function JingleMedia:removeSourceSDP(sdp)
    local iq, jingle = self:createSetSDP('source-remove', sdp);
    self.client:send(iq);
end

function JingleMedia:addSourceSDP(sdp)
    local iq, jingle = self.createSetSDP('source-add', sdp);
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

function JingleMedia:sendMediaInfo(tagname, attr)
    --<hold xmlns='urn:xmpp:jingle:apps:rtp:info:1'/>
    local iq, jingle = self:createInfo();
    local info = self.verse.stanza(tagname, {xmlns = xmlns_jingle_rtp_info});
    for attr_name, attr_value in pairs(attr) do
        info.attr[attr_name] = attr_value;
    end
    jingle:add_child(info);
    self.client:send(iq);
end

function JingleMedia:onSessionInfo(req)
    local jingle = req:get_child('jingle', xmlns_jingle);
    for child in jingle:children() do
        if child.xmlns == xmlns_jingle_rtp_info then
            self.client:event("jingle/media-info/"..child.name, child.attr.name);
        end
    end
    self.client:send(verse.reply(req));
    return true;
end

function JingleMedia:hold()
    self:sendMediaInfo('hold');
end

function JingleMedia:resume()
    self:sendMediaInfo('resume');
end

function JingleMedia:active()
    self:sendMediaInfo('resume');
end

function JingleMedia:mute(media)
    if (self.initiator) then
        self:sendMediaInfo('mute', {name = media, creator = 'initiator'});
    else
        self:sendMediaInfo('mute', {name = media, creator = 'responder'});
    end
end

function JingleMedia:unmute(media)
    if (self.initiator) then
        self:sendMediaInfo('unmute', {name = media, creator = 'initiator'});
    else
        self:sendMediaInfo('unmute', {name = media, creator = 'responder'});
    end
end

return JingleMedia;
