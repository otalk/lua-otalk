#ifndef _OTALK_DEF
#define _OTALK_DEF

#include "LuaState.h"
#include <map>

class OTalk {
		std::string password;
	    std::function<void(std::string)> verse_hook;
	public:
        lua::Value verse;
        lua::State state;
		std::string jid;
		OTalk(std::string);
        void step();
        void connect(std::string, std::string);
        void connect(std::string);
        void close();
        //std::function<lua::Value(std::string, std::function<void(lua::Value)>)> hook;
        void on(std::string, std::function<void(lua::Value)>);
        //void emit(std::string, lua::Value);
        lua::Value emit;
        void checkTalkyVersion(std::string);
        lua::Value joinRoom(std::string, std::string, std::string);
        void leaveRoom(std::string);
        void setRoomKey(std::string, std::string);
        lua::Value getRooms();
        lua::Value getParticipants(std::string);
        void createSession(std::string sid, std::string peer);
        void startSDPSession(std::string, std::string);
        void acceptSDPSession(std::string, std::string);
        void addSource(std::string, std::string);
        void removeSource(std::string, std::string);
        void activateSession(std::string);
        void muteSession(std::string, std::string, std::string);
        void unmuteSession(std::string, std::string, std::string);
        void ringSession(std::string);
        void holdSession(std::string);
        void resumeSession(std::string);
        void endSession(std::string sid, std::string reason, bool notify);
        bool outgoingSessionExists(std::string jid);
        void endSessionsForJID(std::string jid, std::string reason, bool notify);
        void addCandidate(std::string, std::string, std::string, std::string);
        void logEvent(std::string eventName, std::string muc, std::string metadata);
};
#endif
