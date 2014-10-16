#include <iostream>
#include "otalk.hpp"

int main (int argc, char *argv[])
{
	OTalk otalk;
    if (argc > 1) {
        std::cout << "Connecting as: '" << argv[1] << "'\nPassword: '" << argv[2] << "'\n========\n";
        std::string jid = argv[1];
        std::string pass = "";
        //std::string pass = argv[2];
        otalk.on("custom", [](lua::Value args) -> void {
            std::cout << "GOT CUSTOM EVENT " << args.length() << "\n";
            for (int i = 1; i <= args.length(); i++) {
                std::cout << "arg[" << i << "] " << args[i].toString() << "\n";
            }
        });
        //lua::State e_table;
        //e_table.doString("derp = {'a', 'b', 'c'}");
        otalk.emit("custom", "a", "b", "c");
        otalk.on("stanza", [](lua::Value args) -> void {
            std::cout << "length: " << args.length() << "\n";
            if (args.length() > 0) {
                lua::Value from = args[1]["attr"]["from"];
                if (from.is<lua::String>()) {
                    std::cout << "x-x-x From: " << from.toString() << "\n";
                } else {
                    //std::cout << "Didn't have from\n";
                }
            }
        });
        otalk.on("ready", [&otalk](lua::Value args) -> void {
            std::cout << "======= Begin =======\n";
            //lua::Value room = otalk.state["joinRoom"]("test@conference.jabber.org", "TestBot213");
            auto room = otalk.joinRoom("fritzyroom3@stage-conference.talky.io", "d9d42630-5317-11e4-916c-0800200c9a66");
            std::cout << "not broken!\n";
        });
        otalk.on("groupchat/joined", [&otalk](lua::Value args) -> void {
            lua::Value room = args[1];
            std::cout << "Joined room: " << room["jid"].toString() << "\n";
            //room["send_message"](room, "Halloooo");
        });
        if (pass.length() == 0) {
            std::cout << "Connecting anonymously\n";
            otalk.connect(jid);
        } else {
            otalk.connect(jid);
        }
    } else {
        std::cout << "Usage: " << argv[0] << " [username@server] [password]\n";
    }
    return 0;
}
