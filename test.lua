
require "verse".init("client");

client = verse.new();
client:hook("incoming-raw", print, 1000);
client:hook("outgoing-raw", print, 1000);
client:connect_client("stage.talky.io");
verse:loop()
