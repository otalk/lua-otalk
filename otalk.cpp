#include <iostream>
#include "./include/LuaState.h"
#include "otalk.hpp"

OTalk::OTalk() {
    state.doFile("./wrapper.lua");
    connect = state["connect"];
    verse = state["c"];
    hook = state["hook"];
    event = state["event"];
}

