#ifndef _OTALK_DEF
#define _OTALK_DEF

#include "./include/LuaState.h"
#include <map>

class OTalk {
		std::string password;
	    std::function<void(std::string)> verse_hook;
	public:
        lua::Value verse;
        lua::State state;
		std::string jid;
		OTalk();
        void connect(std::string, std::string);
        void connect(std::string);
        //std::function<lua::Value(std::string, std::function<void(lua::Value)>)> hook;
        void on(std::string, std::function<void(lua::Value)>);
        //void emit(std::string, lua::Value);
        lua::Value emit;
        lua::Value joinRoom(std::string, std::string);
        void leaveRoom(std::string);
        lua::Value getRooms();
        lua::Value getParticipants(std::string);
        void initiateSDPSession(std::string, std::string, std::string);
        void acceptSDPSession(std::string, std::string);
};
#endif
