local c = {};
local JingleMedia = {};
local jingleSession = {};
local verse = {};
local utils = {};
local room

function init(path)
    package.path = path..'/?.lua;' .. package.path;
    utils = require "utils";
    verse = require "verse".init("client");
    verse.require "net.server".changesettings({timeout = 0.0 });
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
    if sess then
        sess:acceptSDP(sdp);
    end
end

function createSession(sid, peer)
    --print("New Session from Lua: " .. sid .. ":" .. peer)
    jingleSession.newSession({
        sid = sid,
        peer = peer,
        initiator = true,
    });
end

function startSession(sid, sdp)
    local sess = jingleSession.getSessionBySID(sid);
    if sess then
        sess:initiateSDP(sdp);
    end
end

function addSource(sid, sdp)
    local sess = jingleSession.getSessionBySID(sid);
    if sess then
        sess:addSource(sdp);
    end
end

function removeSource(sid, sdp)
    local sess = jingleSession.getSessionBySID(sid);
    if sess then
        sess:removeSource(sdp);
    end
end

function addCandidate(sid, mid, mline, candidate)
    local sess = jingleSession.getSessionBySID(sid);
    if sess then
        sess:addCandidate(mid, mline, candidate);
    end
end

function activateSession(sid)
    local sess = jingleSession.getSessionBySID(sid);
    if sess then
        sess:active();
    end
end

function holdSession(sid)
    local sess = jingleSession.getSessionBySID(sid);
    if sess then
        sess:hold();
    end
end

function resumeSession(sid)
    local sess = jingleSession.getSessionBySID(sid);
    if sess then
        sess:resume();
    end
end

function endSession(sid, reason, notify)
    jingleSession.endSessionBySID(sid, reason, notify);
end

function muteSession(sid, creator, media)
    local sess = jingleSession.getSessionBySID(sid);
    if sess then
        sess:mute(creator, media);
    end
end

function unmuteSession(sid, creator, media)
    local sess = jingleSession.getSessionBySID(sid);
    if sess then
        sess:unmute(creator, media);
    end
end

function ringSession(sid)
    local sess = jingleSession.getSessionBySID(sid);
    if sess then
        sess:ring();
    end
end

function outgoingSessionExistsForJID(jid)
    local sessions = jingleSession.getSessionsByJID(jid);
    if not sessions then
        return false
    end

    local sessionExists
    for _, session in ipairs(sessions) do
        --print("Session from Lua: " .. session.sid .. ":" .. session.peer)
        if session.initiator == true then
            sessionExists = true
            break
        end
    end
    return sessionExists
end

function endSessionsForJID(jid, reason, notify)
    jingleSession.endSessionsForJID(jid, reason, notify)
end

function emit(name, ...)
    c:event(name, unpack(arg));
end

function joinRoom(roomName, nick, key)
	room = nil
    if key then
        room = c:join_room(roomName, nick, {
            password = key
        });
    else
        room = c:join_room(roomName, nick);
    end

    if room then
        room:hook("message", function (event)
            if event.body then
                emit("message", event.body)
            end
        end)
    end
end

function setRoomKey(room, key)
    c:set_room_password(room, key);
end

function leaveRoom(message)
	if room then
		room:leave(message)
	end
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
    print(os.date("%H:%M:%S").." Out: "..txt);
end

function log_in(txt)
    print(os.date("%H:%M:%S").." In: "..txt);
end

function on(name, func)
    c:hook(name, function(...)
        func(arg);
    end)
end

function checkTalkyVersion(mucHost)
	c:query_version(mucHost, function (result)
		if result.error or result.name ~= "Talky" then
			emit("talkyVersion", "notTalkyService")
		else
			emit("talkyVersion", tostring(result.version))
		end
	end)
end

function logEvent(eventName, muc, metadataJSON)
    local parts = utils.split(muc, "@")
    local message = verse.message({to = parts[2]})
                        :tag("log", {xmlns = "urn:xmpp:eventlog", id = "ios-ui-metric-" .. eventName, subject = parts[1]})
                            :tag("tag", {name = eventName, value = 1}):up()
    local parser = require "json"
    local metadata = parser.decode(metadataJSON)
    if metadata ~= nil then
        for name, value in pairs(metadata) do
            message = message:tag("tag", {name = name, value = value}):up()
        end
    end
    c:send(message)
end

function presenceChanged(presenceInfo)
    local presence = presenceInfo.presence

    local isEntering
    if "unavailable" == presence.attr["type"] then
        isEntering = "false"
    else
        isEntering = "true"
    end

    local canUseBridge
    local conf = presence:get_child("conf", "http://andyet.net/xmlns/mmuc")
    if conf then
        local bridged = conf.attr["bridged"]
        if bridged == "true" or bridged == "1" then
            canUseBridge = "true"
        else
            canUseBridge = "false"
        end
    else
        canUseBridge = "false"
    end

    local media = {}
    for mediaStream in presence:childtags("mediastream", "http://andyet.net/xmlns/mmuc") do
    	local stream = {}
        stream.msid = mediaStream.attr["msid"]
        stream.audio = mediaStream.attr["audio"]
        stream.video = mediaStream.attr["video"]
        table.insert(media, stream)
    end

    emit("presenceChanged", presenceInfo.jid, isEntering, canUseBridge, media)
end

function close()
	c:close()
end

function connect(jid, password)
    -- local jid, password = "user@server", "your-password";

    -- This line squishes verse each time you run,
    -- handy if you're hacking on Verse itself
    --os.execute("squish --minify-level=none verse");


    c:hook("occupant-joined", presenceChanged)
    c:hook("occupant-left", presenceChanged)
    c:hook("occupant-presence-changed", presenceChanged)

    -- Add some hooks for debugging
    --c:hook("opened", function () print("Stream opened!") end);
    --c:hook("closed", function () print("Stream closed!") end);
    --c:hook("stanza", function (stanza) print("Stanza:", stanza) end);

    -- This one prints all received data
    --c:hook("incoming-raw", log_in);
    --c:hook("outgoing-raw", log_out);

    -- Print a message after authentication
    --c:hook("authentication-success", function () print("Logged in!"); end);
    --c:hook("authentication-failure", function (err) print("Failed to log in! Error: "..tostring(err.condition)); end);
    c:hook("authentication-failure", function () emit("disconnected"); end);

    -- Print a message and exit when disconnected
--    c:hook("disconnected", function () print("Disconnected!"); os.exit(); end);

    -- Now, actually start the connection:
    c:connect_client(jid, password);

    -- Catch the "ready" event to know when the stream is ready to use
    c:hook("ready", function ()
        c.version:set{ name = "verse++ 1.0" };
        --c:query_version(c.jid, function (v) print("I am using "..(v.name or "<unknown>")); end);
    end);

--    verse.loop()

end

function step()
    verse.step()
end
