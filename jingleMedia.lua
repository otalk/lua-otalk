--package.path = "../convert-jingle-lua/src/?.lua;../sdp-jingle-table/src/?.lua;" .. package.path;
local Jingle = require("jingle");

local JingleMedia = Jingle:new();

function JingleMedia:onSessionInitiate(req)
    print("got to jingle media")
    self.client:send(verse.reply(req));
    return true;
end

return JingleMedia;
