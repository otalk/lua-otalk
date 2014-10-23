#include <iostream>
#include "otalk.hpp"

int main (int argc, char *argv[])
{
	OTalk otalk;
    if (argc > 1) {
        std::cout << "Connecting as: '" << argv[1] << "n";
        std::string jid = argv[1];
        std::string pass;
        if (argc > 2) {
            pass = argv[2];
        } else {
            pass = "";
        }

        otalk.on("custom", [](lua::Value args) -> void {
            std::cout << "GOT CUSTOM EVENT " << args.length() << "\n";
            for (int i = 1; i <= args.length(); i++) {
                std::cout << "arg[" << i << "] " << args[i].toString() << "\n";
            }
        });

        otalk.emit("custom", "a", "b", "c");

        otalk.on("stanza", [](lua::Value args) -> void {
            //std::cout << "length: " << args.length() << "\n";
            if (args.length() > 0) {
                lua::Value from = args[1]["attr"]["from"];
                if (from.is<lua::String>()) {
                    //std::cout << "Got stanza from: " << from.toString() << "\n";
                } else {
                    //std::cout << "Didn't have from (bind?) \n";
                }
            }
        });

        otalk.on("ready", [&otalk](lua::Value args) -> void {
            std::cout << "======= Begin =======\n";
            auto room = otalk.joinRoom("fritzyroom3@stage-conference.talky.io", "testbot2");
        });

        otalk.on("groupchat/joined", [&otalk](lua::Value args) -> void {
            lua::Value room = args[1];
            std::cout << "Joined room: " << room["jid"].toString() << "\n";
            //room["send_message"](room, "Halloooo");
        });

        otalk.on("jingle/session-initiate-sdp", [&otalk](lua::Value args) -> void {
            std::cout << "C++ got SDP!\n" << args[1].toString() << "\n" << args[2].toString() << "\n" << args[3].toString() << "\n";
        });

        if (pass.length() == 0) {
            std::cout << "Connecting anonymously\n";
            otalk.connect(jid);
        } else {
            otalk.connect(jid, pass);
        }
        return 0;

    } else {
        std::cout << "Usage: " << argv[0] << " [username@][server] [password]\n";
        return 1;
    }
}
