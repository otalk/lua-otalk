-- Change these:
--
require "verse".init("client");

c = verse.new();
c:add_plugin("version");
c:add_plugin("groupchat");

function hook(name, func)
    print("setting up hook: "..name);
    c:hook(name, function(...)
        for i, v in ipairs(arg) do
            print(i, v)
        end
        func(arg);
    end)
end

function event(name, ...)
    c:event(name, arg);
end

function joinRoom(name, nick)
    c:join_room(name, nick);
end

function connect(jid, password)
    -- local jid, password = "user@server", "your-password";

    -- This line squishes verse each time you run,
    -- handy if you're hacking on Verse itself
    --os.execute("squish --minify-level=none verse");


    -- Add some hooks for debugging
    c:hook("opened", function () print("Stream opened!") end);
    c:hook("closed", function () print("Stream closed!") end);
    c:hook("stanza", function (stanza) print("Stanza:", stanza) end);

    -- This one prints all received data
    c:hook("incoming-raw", print, 1000);

    -- Print a message after authentication
    c:hook("authentication-success", function () print("Logged in!"); end);
    c:hook("authentication-failure", function (err) print("Failed to log in! Error: "..tostring(err.condition)); end);

    -- Print a message and exit when disconnected
    c:hook("disconnected", function () print("Disconnected!"); os.exit(); end);

    -- Now, actually start the connection:
    c:connect_client(jid, password);

    -- Catch the "ready" event to know when the stream is ready to use
    c:hook("ready", function ()
        print("Stream ready!");
        c.version:set{ name = "verse++ 1.0" };
        --c:query_version(c.jid, function (v) print("I am using "..(v.name or "<unknown>")); end);
    end);

    print("Starting loop...")
    verse.loop()

end
print("end lua");
