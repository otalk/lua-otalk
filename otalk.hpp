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
        //std::function<lua::Value(std::string, std::function<void(lua::Value)>)> hook;
        void hook(std::string, std::function<void(lua::Value)>);
        void event(std::string, lua::Value);
        lua::Value joinRoom(std::string, std::string);
};
#endif
