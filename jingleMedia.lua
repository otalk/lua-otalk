package.path = "./?.lua;./sdp-jingle-table/src/?.lua;" .. package.path;

local Jingle = require("basejingle");

local xmlns_jingle = "urn:xmpp:jingle:1";
local xmlns_jingle_rtp_info = "urn:xmpp:jingle:apps:rtp:info:1";
local jingletolua = require("jingletolua");
jingletolua.init();

local JingleMedia = Jingle:new();

function JingleMedia:onSessionAccept(req)
    self.client:send(verse.reply(req));
    local jingle_tag = req:get_child('jingle', xmlns_jingle);
    local sdp, intermediate = jingletolua.toIncomingAnswerSDP(jingle_tag);
    self.remote_state = intermediate;
    self.isPending = false;
    self.client:event("jingle/session-accept-sdp", sdp, self.peer, self.sid);
    return true;
end

function JingleMedia:onSessionInitiate(req)
    self.client:send(verse.reply(req));
    local jingle_tag = req:get_child('jingle', xmlns_jingle);
    local sdp, intermediate = jingletolua.toIncomingOfferSDP(jingle_tag);
    self.remote_state = intermediate;
    self.isPending = true;
    self.client:event("jingle/session-initiate-sdp", sdp, self.peer, self.sid);
    return true;
end

function JingleMedia:acceptSDP(sdp)
    print("acceptSDP: " .. sdp)
    local jingle, intermediate = jingletolua.toOutgoingAnswerJingle(sdp);
    print("acceptSDP jingle:")
    print(jingle)
    self.local_state = intermediate;
    self.isPending = false;
    jingle.attr.initiator = self.peer;
    jingle.attr.responder = self.client.full;
    jingle.attr.action = 'session-accept';
    jingle.attr.sid = self.sid;
    local iq = self.verse.iq({
        to = self.peer,
        from = self.client.full,
        type = "set",
    });
    iq:add_child(jingle);
    self.client:send(iq);
end

function JingleMedia:initiateSDP(sdp)
    local jingle, intermediate = jingletolua.toOutgoingOfferJingle(sdp);
    self.local_state = intermediate;
    self.isPending = true;
    jingle.attr.responder = self.peer;
    jingle.attr.initiator = self.client.full;
    jingle.attr.action = 'session-initiate';
    jingle.attr.sid = self.sid;
    local iq = self.verse.iq({
        to = self.peer,
        from = self.client.full,
        type = "set",
    });
    iq:add_child(jingle);
    self.client:send(iq);
end

function JingleMedia:removeSourceSDP(sdp)
    local iq, jingle = self:createSetSDP('source-remove', sdp);
    self.client:send(iq);
end

function JingleMedia:addSourceSDP(sdp)
    local iq, jingle = self.createSetSDP('source-add', sdp);
    self.client:send(iq);
end

function JingleMedia:addCandidate(mid, mline, candidate)
    print("Yay ICE!")
    candidate = "a=" .. candidate
    local candidateTable = jingletolua.toCandidateTable(candidate)
    local audio = { name = mid, 
        transport = {
            candidates = {
                candidateTable
            }
        }
    }
    local jingleTable = { contents = { audio }}

    local jingle = jingletolua.toJingle(jingleTable, 'initiator');
    jingle.attr.initiator = self.peer;
    jingle.attr.responder = self.client.full;
    jingle.attr.action = 'transport-info';
    jingle.attr.sid = self.sid;
    local iq = self.verse.iq({
        to = self.peer,
        from = self.client.full,
        type = "set",
    });
    iq:add_child(jingle);
    self.client:send(iq);
end

function JingleMedia:onTransportInfo(req)
    self.client:send(verse.reply(req));
    --TODO something something something
    local jingle_tag = req:get_child('jingle', xmlns_jingle);
    ---[[
    local sdp, jingleTable = jingletolua.toSDP(jingle_tag)
    print("onTransportInfo:\n" .. sdp)
    for _, content in pairs(jingleTable.contents) do
        if (content.transport) then
            for _, candidate in pairs(content.transport.candidates) do
                -- toSDP
                local sdp = jingletolua.toCandidateSDP(candidate)
                -- Drop a=
                sdp = string.sub(sdp, 3)
                -- emit mid, mline, sdp
                local mline = 0
                for i, oldContent in ipairs(self.remote_state.contents) do
                    if oldContent.name == content.name then
                        mline = i - 1
                        break
                    end
                end
                self.client:event("jingle/transport-candidate", content.name, mline, sdp, self.peer, self.sid);
            end
        end
    end
    --]]
    return true
end

function JingleMedia:onSourceAdd(req)
    print("onSourceAdd")
    self.client:send(verse.reply(req));
    local jingle_tag = req:get_child('jingle', xmlns_jingle);
    local changesTable = jingletolua.jingleToTable(jingle_tag);
    local sourceAdded = false
    for i, content in ipairs(self.remote_state.contents) do
        print("remote_state contents isn't empty in Lua land")
        local desc = content.description
        local ssrcs = desc.sources or {}

        for _, newContent in ipairs(changesTable.contents) do
            print("there are new contents in Lua land")
            print("content stuff: " .. newContent.creator .. ", " .. newContent.senders)
            print("name: " .. content.name .. " - " .. newContent.name)
            if (content.name == newContent.name) then
                print("names match in Lua land")
                local newContentsDesc = newContent.description
                local newSSRCs = newContentsDesc.sources or {}

                for _, newSSRC in pairs(newSSRCs) do
                    print("A source was added in Lua land")
                    sourceAdded = true
                    table.insert(ssrcs, newSSRC)
                end

                self.remote_state.contents[i].description.sources = ssrcs
            end
        end
    end

    if sourceAdded then
        local sdp = jingletolua.toIncomingSDPOffer(self.remote_state);
        self.client:event("jingle/source-add-sdp", sdp, self.peer, self.sid);
    end
    return true;
end

function JingleMedia:onSourceRemove(req)
    -- Also remove source groups
    self.client:send(verse.reply(req));
    local jingle_tag = req:get_child('jingle', xmlns_jingle);
    local changesTable = jingletolua.jingleToTable(jingle_tag);
    local sourceRemoved = false
    for i, content in ipairs(self.remote_state.contents) do
        local desc = content.description
        local ssrcs = desc.sources or {}

        for _, newContent in ipairs(changesTable.contents) do
            if (content.name == newContent.name) then
                local newContentsDesc = newContent.description
                local newSSRCs = newContentsDesc.sources or {}

                local indexes = {}
                for j=#ssrcs,1,-1 do
                    for _, newSSRC in ipairs(newSSRCs) do
                        if ssrcs[j].ssrc == newSSRC.ssrc then
                            sourceRemoved = true
                            table.insert(indexes, j)
                        end
                    end
                end
                for k=#indexes,1 do
                    table.remove(ssrcs, k)
                end
            end

            self.remote_state.contents[i].description.sources = ssrcs
        end
    end

    if sourceRemoved then
        local sdp = jingletolua.toIncomingSDPOffer(self.remote_state)
        self.client:event("jingle/source-remove-sdp", sdp, self.peer, self.sid);
    end
    return true
end

function JingleMedia:sendMediaInfo(tagname, attr)
    --<hold xmlns='urn:xmpp:jingle:apps:rtp:info:1'/>
    local iq, jingle = self:createInfo();
    local info = self.verse.stanza(tagname, {xmlns = xmlns_jingle_rtp_info});
    for attr_name, attr_value in pairs(attr) do
        info.attr[attr_name] = attr_value;
    end
    jingle:add_child(info);
    self.client:send(iq);
end

function JingleMedia:onSessionInfo(req)
    self.client:send(verse.reply(req));
    local jingle = req:get_child('jingle', xmlns_jingle);
    for child in jingle:children() do
        if child.xmlns == xmlns_jingle_rtp_info then
            self.client:event("jingle/media-info/"..child.name, child.attr.name);
        end
    end
    return true;
end

function JingleMedia:hold()
    self:sendMediaInfo('hold');
end

function JingleMedia:resume()
    self:sendMediaInfo('resume');
end

function JingleMedia:terminate(reason)
    self.client:send(self:createJingleStanza('session-terminate'));
end

function JingleMedia:active()
    self:sendMediaInfo('resume');
end

function JingleMedia:ring()
    self:sendMediaInfo('ring');
end

function JingleMedia:mute(media)
    if (self.initiator) then
        self:sendMediaInfo('mute', {name = media, creator = 'initiator'});
    else
        self:sendMediaInfo('mute', {name = media, creator = 'responder'});
    end
end

function JingleMedia:unmute(media)
    if (self.initiator) then
        self:sendMediaInfo('unmute', {name = media, creator = 'initiator'});
    else
        self:sendMediaInfo('unmute', {name = media, creator = 'responder'});
    end
end

return JingleMedia;
