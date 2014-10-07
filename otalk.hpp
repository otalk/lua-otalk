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
        std::function<lua::Value(std::string, std::string)> connect;
        std::function<lua::Value(std::string, std::function<void(lua::Value)>)> hook;
        std::function<lua::Value(std::string, lua::Value)> event;
};
#endif
