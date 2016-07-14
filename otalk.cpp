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

void OTalk::close() {
	state["close"]();
}

void OTalk::on(std::string name, std::function<void(lua::Value)> callback) {
    state["on"](name, callback);
}

void OTalk::checkTalkyVersion(std::string mucHost) {
    state["checkTalkyVersion"](mucHost);
}

lua::Value OTalk::joinRoom(std::string rjid, std::string nick, std::string password) {
    return state["joinRoom"](rjid, nick, password);
}

void OTalk::leaveRoom(std::string message) {
    state["leaveRoom"](message);
}

void OTalk::setRoomKey(std::string rjid, std::string key) {
    state["setRoomKey"](rjid, key);
}

lua::Value OTalk::getRooms() {
    return state["getRooms"]();
}

lua::Value OTalk::getParticipants(std::string room) {
    return state["getParticipants"](room);
}

void OTalk::createSession(std::string sid, std::string peer) {
    state["createSession"](sid, peer);
}

void OTalk::startSDPSession(std::string sid, std::string sdp) {
    // state.lock();
    state["startSession"](sid, sdp);
    // state.unlock();
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

void OTalk::muteSession(std::string sid, std::string creator, std::string media) {
    state["muteSession"](sid, creator, media);
}

void OTalk::unmuteSession(std::string sid, std::string creator, std::string media) {
    state["unmuteSession"](sid, creator, media);
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

void OTalk::endSession(std::string sid, std::string reason, bool notify) {
    state["endSession"](sid, reason, notify);
}

bool OTalk::outgoingSessionExists(std::string jid) {
    bool sessionExists =state["outgoingSessionExistsForJID"](jid);
    return sessionExists;
}

void OTalk::endSessionsForJID(std::string jid, std::string reason, bool notify) {
    state["endSessionsForJID"](jid, reason, notify);
}

void OTalk::addCandidate(std::string sid, std::string mid, std::string mline, std::string candidate) {
    state["addCandidate"](sid, mid, mline, candidate);
}

void OTalk::logEvent(std::string eventName, std::string muc, std::string metadata) {
    state["logEvent"](eventName, muc, metadata);
}
