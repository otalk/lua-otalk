lua-otalk
=========

## requirements

* luasec
* luasocket
* lua-expat


```c++
OTalk otalk;


otalk.hook("message", [](lua::Value args) -> void {
    lua::Value msg = args[1];
    std::cout << "Message From: " << msg["from"] << "\n";
});


otalk.connect("user@server", "password");
```

Read the example.cpp
