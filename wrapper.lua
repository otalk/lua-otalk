local c = {};
local JingleMedia = {};
local jingleSession = {};
local verse = {};

function init(path)
    package.path = path..'/?.lua;' .. package.path;
    verse = require "verse".init("client");
    verse.require "net.server".changesettings({timeout = 0})
    c = verse.new();
    c:add_plugin("version");
    c:add_plugin("groupchat");
    c:add_plugin("disco");

    JingleMedia = require "jingleMedia";
    jingleSession = require "sessionManager";
    jingleSession.init(verse, c, {
        createSession = function (meta)
            return JingleMedia:new(meta);
        end
    });
end

function acceptSession(sid, sdp)
    local sess = jingleSession.getSessionBySID(sid);
    sess:acceptSDP(sdp);
end

function initiateSession(sid, peer, sdp)
    local sess = jingleSession.newSession({
        sid = sid,
        peer = peer,
        initiator = true,
    });
    sess:initiateSDP(sdp);
end

function addSource(sid, sdp)
    local sess = jingleSession.getSessionBySID(sid);
    sess:addSource(sdp);
end

function removeSource(sid, sdp)
    local sess = jingleSession.getSessionBySID(sid);
    sess:removeSource(sdp);
end

function addCandidate(sid, mid, mline, candidate)
    local sess = jingleSession.getSessionBySID(sid);
    sess:addCandidate(mid, mline, candidate);
end

function activateSession(sid)
    local sess = jingleSession.getSessionBySID(sid);
    sess:active();
end

function holdSession(sid)
    local sess = jingleSession.getSessionBySID(sid);
    sess:hold();
end

function resumeSession(sid)
    local sess = jingleSession.getSessionBySID(sid);
    sess:resume();
end

function muteSession(sid, media)
    local sess = jingleSession.getSessionBySID(sid);
    sess:mute(media);
end

function unmuteSession(sid, media)
    local sess = jingleSession.getSessionBySID(sid);
    sess:unmute(media);
end

function ringSession(sid)
    local sess = jingleSession.getSessionBySID(sid);
    sess:ring();
end

function emit(name, ...)
    c:event(name, unpack(arg));
end

function joinRoom(room, nick)
    c:join_room(room, nick);
end

function leaveRoom(room)
end

function getRooms()
end

function getParticipants(room)
end

function messageRoom(room, msg)
end

function sendPrivateMessage(room, nick, msg)
end

function log_out(txt)
    print("Out: "..txt);
end

function log_in(txt)
    print("In: "..txt);
end

function on(name, func)
    c:hook(name, function(...)
        func(arg);
    end)
end

function connect(jid, password)
    -- local jid, password = "user@server", "your-password";

    -- This line squishes verse each time you run,
    -- handy if you're hacking on Verse itself
    --os.execute("squish --minify-level=none verse");


    -- Add some hooks for debugging
    c:hook("opened", function () print("Stream opened!") end);
    c:hook("closed", function () print("Stream closed!") end);
    --c:hook("stanza", function (stanza) print("Stanza:", stanza) end);

    -- This one prints all received data
    c:hook("incoming-raw", log_in);
    c:hook("outgoing-raw", log_out);

    -- Print a message after authentication
    c:hook("authentication-success", function () print("Logged in!"); end);
    c:hook("authentication-failure", function (err) print("Failed to log in! Error: "..tostring(err.condition)); end);

    -- Print a message and exit when disconnected
    c:hook("disconnected", function () print("Disconnected!"); os.exit(); end);

    -- Now, actually start the connection:
    c:connect_client(jid, password);

    -- Catch the "ready" event to know when the stream is ready to use
    c:hook("ready", function ()
        c.version:set{ name = "verse++ 1.0" };
        --c:query_version(c.jid, function (v) print("I am using "..(v.name or "<unknown>")); end);
        c:send(verse.presence())
    end);

    --verse.loop()

end

function step()
    verse.step()
end
