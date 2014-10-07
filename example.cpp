#include <iostream>
#include "otalk.hpp"

int main (int argc, char *argv[])
{
	OTalk otalk;
    if (argc == 3) {
        std::cout << "Connecting as: '" << argv[1] << "'\nPassword: '" << argv[2] << "'\n========\n";
        std::string jid = argv[1];
        std::string pass = argv[2];
        otalk.hook("custom", [](lua::Value args) -> void {
            std::cout << "GOT CUSTOM EVENT\n";
        });
        lua::State e_table;
        e_table.set("derp", lua::Table());
        e_table["derp"].set("name", "herrrp");
        otalk.event("custom", e_table["derp"]);
        otalk.verse["hook"](otalk.verse, "stanza", [](lua::Value stanza) -> void {
            std::cout << "------------\n";
            lua::Value from = stanza["attr"]["from"];
            if (from.is<lua::String>()) {
                std::cout << "From: " << stanza["attr"]["from"].toString() << "\n";
            } else {
                //std::cout << "Didn't have from\n";
            }
        });
        otalk.hook("ready", [&otalk](lua::Value args) -> void {
            std::cout << "======= Begin =======\n";
            //lua::Value room = otalk.state["joinRoom"]("test@conference.jabber.org", "TestBot213");
            auto room = otalk.joinRoom("test@conference.jabber.org", "TestBot213");
            std::cout << "not broken!\n";
        });
        otalk.hook("groupchat/joined", [&otalk](lua::Value args) -> void {
            lua::Value room = args[1];
            std::cout << "Joined room: " << room["jid"].toString() << "\n";
            room["send_message"](room, "Halloooo");
        });
        otalk.connect(jid, pass);
    } else {
        std::cout << "Usage: " << argv[0] << " [username@server] [password]\n";
    }
    return 0;
}
