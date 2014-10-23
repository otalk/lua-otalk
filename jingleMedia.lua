package.path = "./?.lua;../sdp-jingle-table/src/?.lua;" .. package.path;

local Jingle = require("basejingle");

local xmlns_jingle = "urn:xmpp:jingle:1";
local jingletolua = require("jingletolua");
jingletolua.init();

local JingleMedia = Jingle:new();

function JingleMedia:onSessionInitiate(req)
    print("got to jingle media")
    local jingle_tag = req:get_child('jingle', xmlns_jingle);
    local sdp, intermediate = jingletolua.toSDP(jingle_tag);
    self.client:event("jingle/session-initiate-sdp", sdp, self.peer, self.sid);
    self.client:send(verse.reply(req));
    return true;
end

return JingleMedia;
