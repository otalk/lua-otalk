#include <iostream>
#include "./include/LuaState.h"
#include "otalk.hpp"

OTalk::OTalk() {
    state.doFile("./wrapper.lua");
    verse = state["c"];
    emit = state["emit"];
}

void OTalk::connect(std::string jid) {
    jid = jid;
    //connecting anonymously
    state["connect"](jid);
}

void OTalk::connect(std::string jid, std::string password) {
    jid = jid;
    password = password;
    state["connect"](jid, password);
}

lua::Value OTalk::joinRoom(std::string rjid, std::string nick) {
    return state["joinRoom"](rjid, nick);
}

void OTalk::on(std::string name, std::function<void(lua::Value)> callback) {
    state["on"](name, callback);
}

/*
void OTalk::emit(std::string name, lua::Value args) {
    state["emit"](name, args);
}
*/

void OTalk::leaveRoom(std::string room) {
    state["leaveRoom"](room);
}

lua::Value OTalk::getRooms() {
    return state["getRooms"]();
}

lua::Value OTalk::getParticipants(std::string room) {
    return state["getParticipants"](room);
}

void OTalk::initiateSDPSession(std::string sid, std::string peer, std::string sdp) {
    state["initiateSDPSession"](sid, peer, sdp);
}

void OTalk::acceptSDPSession(std::string sid, std::string sdp) {
    state["acceptSDPSession"](sid, sdp);
}
