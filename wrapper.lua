-- Change these:
--
require "verse".init("client");

c = verse.new();
c:add_plugin("version");
c:add_plugin("groupchat");
c:add_plugin("disco");

local JingleMedia = require "jingleMedia";

local jingleSession = require "sessionManager";
jingleSession.init(verse, c, {
    createSession = function (meta)
        return JingleMedia:new(meta);
    end
});

--local xmlns_jingle = "urn:xmpp:jingle:1";

function startPeer(sdp, target)
end

function endPeer(session)
end

function getRooms()
end

function getParticipants(room)
end

--c:hook("iq/"..xmlns_jingle, handle_jingle)

function on(name, func)
    c:hook(name, function(...)
        func(arg);
    end)
end

function emit(name, ...)
    c:event(name, unpack(arg));
end

function joinRoom(name, nick)
    c:join_room(name, nick);
end

function log_out(txt)
    print("Out: "..txt);
end

function log_in(txt)
    print("In: "..txt);
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
    end);

    verse.loop()

end

