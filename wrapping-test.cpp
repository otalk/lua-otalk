#include <lua.hpp>
#include "LuaBridge/LuaBridge.h"

using namespace luabridge;

int main ()
{
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    luaL_dofile(L, "wrapping-test.lua");
    return 0;
}
