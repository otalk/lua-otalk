#include <iostream>
#include "./include/LuaState.h"
#include "otalk.hpp"

OTalk::OTalk(std::string path) {
    state.doFile(path + "/wrapper.lua");
    state["init"](path);
    verse = state["c"];
    emit = state["emit"];
}

void OTalk::step() {
    state["step"]();
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

void OTalk::on(std::string name, std::function<void(lua::Value)> callback) {
    state["on"](name, callback);
}

lua::Value OTalk::joinRoom(std::string rjid, std::string nick, std::string password) {
    return state["joinRoom"](rjid, nick, password);
}

void OTalk::leaveRoom(std::string room) {
    state["leaveRoom"](room);
}

void OTalk::setRoomKey(std::string rjid, std::string key) {
    return state["setRoomKey"](rjid, key);
}

lua::Value OTalk::getRooms() {
    return state["getRooms"]();
}

lua::Value OTalk::getParticipants(std::string room) {
    return state["getParticipants"](room);
}

void OTalk::initiateSDPSession(std::string sid, std::string peer, std::string sdp) {
    state["initiateSession"](sid, peer, sdp);
}

void OTalk::acceptSDPSession(std::string sid, std::string sdp) {
    state["acceptSession"](sid, sdp);
}

void OTalk::addSource(std::string sid, std::string sdp) {
    state["addSource"](sid, sdp);
}

void OTalk::removeSource(std::string sid, std::string sdp) {
    state["removeSource"](sid, sdp);
}

void OTalk::activateSession(std::string sid) {
    state["activateSession"](sid);
}

void OTalk::muteSession(std::string sid, std::string media) {
    state["muteSession"](sid, media);
}

void OTalk::unmuteSession(std::string sid, std::string media) {
    state["unmuteSession"](sid, media);
}

void OTalk::ringSession(std::string sid) {
    state["ringSession"](sid);
}

void OTalk::holdSession(std::string sid) {
    state["holdSession"](sid);
}

void OTalk::resumeSession(std::string sid) {
    state["resumeSession"](sid);
}

void OTalk::addCandidate(std::string sid, std::string mid, std::string mline, std::string candidate) {
    state["addCandidate"](sid, mid, mline, candidate);
}
