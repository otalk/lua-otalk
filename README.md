lua-otalk (OTalk++)
=========

## requirements

* luasec
* luasocket
* lua-expat

init submodule

```
git submodule init
git submodule update
```

OTalk otalk;


otalk.hook("message", [](lua::Value args) -> void {
    lua::Value msg = args[1];
    std::cout << "Message From: " << msg["from"] << "\n";
});


otalk.connect("user@server", "password");

```

Read the example.cpp

##Spec

OTalk Class

The OTalk class provides a means of signaling for peerconnections as well as joining rooms, sending messages and presence, and anything else you might want to do with an XMPP connection.

OTalk provides bindings for function calls and hooks from the XMPP Lua Library "Verse".

###OTalk Methods

####OTalk() Constructor -> OTalk
Initiates the class and the Lua bindings

####connect(std::string jid, std::string password) -> void

Connect to an XMPP server with a user (jid) and password.
This function blocks the thread while the connection is open, but you may use hooks to get events and respond.

Paramaters:

* jid std::string - user@server/resource for connecting
* password std::string - password for user connection

####connect(std::string server) -> void

Connect to an XMPP server anonymously.
This function blocks the thread while the connection is open, but you make use hooks to get events and respond.

Parameters:

* server std::string - DNS (SRV, A, or CNAME) qualified servername to connect to.

####on(std::string eventName, function callback(lua::Value arguments) -> void)

Call a function on a specific eventname.
This uses into Lua Verse's "hook" system.

After connecting, the only way to interact with the XMPP system is from an event callback.
The first event is "ready" when the connection has been established.

Parameters:

* eventName: the name of the type of event you want to be called on
* callback: the function called whenever that event happens

Callback:

* arguments: a Lua table array of arguments passed from the event (each event has it's own signature)

```
otalk.on("ready", [&otalk](lua::Value args) -> void {
    otalk.sendPresence();
    otalk.joinRoom("someroom@someserver", "GreatestUser");
});
```

####emit(std::string eventName, lua::Value arguments) -> void

Parameters:

* eventName: Name of event to emit
* arguments: Lua Table of arguments
