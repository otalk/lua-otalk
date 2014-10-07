#include <iostream>
#include "./include/LuaState.h"
#include "otalk.hpp"

OTalk::OTalk() {
    state.doFile("./wrapper.lua");
    verse = state["c"];
}

void OTalk::connect(std::string jid, std::string password) {
    jid = jid;
    password = password;
    state["connect"](jid, password);
}

lua::Value OTalk::joinRoom(std::string rjid, std::string nick) {
    return state["joinRoom"](rjid, nick);
}

void OTalk::hook(std::string name, std::function<void(lua::Value)> callback) {
    state["hook"](name, callback);
}

void OTalk::event(std::string name, lua::Value args) {
    state["event"](name, args);
}



