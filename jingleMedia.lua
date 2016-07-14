package.path = "./?.lua;./sdp-jingle-table/src/?.lua;" .. package.path;

local Jingle = require("basejingle");

local xmlns_jingle = "urn:xmpp:jingle:1";
local xmlns_jingle_rtp_info = "urn:xmpp:jingle:apps:rtp:info:1";
local jingletolua = require("jingletolua");
jingletolua.init();

local helpers = require "helpers"
local utils = require "utils"

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

function JingleMedia:extractMSIDFromJingle(jingle)
-- May change due to Firefox and https://github.com/otalk/sdp-jingle-json/issues/7
	local msid = ""

    for content in helpers.childtags(jingle, "content") do
		-- We don't need to check the description from a 'data' content, which would have an xmlns of 'http://talky.io/ns/datachannel'
    	local description = content:get_child("description", "urn:xmpp:jingle:apps:rtp:1")
    	if description then
			for source in helpers.childtags(description, "source") do
				for parameter in helpers.childtags(source, "parameter") do
					if parameter.attr.name and parameter.attr.name == "msid" then
						local value = parameter.attr.value
						local parts = utils.split(value, " ")
						if #parts > 0 then
							msid = parts[1]
						end
					end
				end
			end
		end
    end

    return msid
end

function JingleMedia:onSessionInitiate(req)
    self.client:send(verse.reply(req));
    local jingle_tag = req:get_child('jingle', xmlns_jingle);

    local msid = self:extractMSIDFromJingle(jingle_tag)

    local sdp, intermediate = jingletolua.toIncomingOfferSDP(jingle_tag);
    self.remote_state = intermediate;
    self.isPending = true;
    self.client:event("jingle/session-initiate-sdp", sdp, self.peer, self.sid, msid);
    return true;
end

function JingleMedia:acceptSDP(sdp)
    --print("acceptSDP: " .. sdp)
    local jingle, intermediate = jingletolua.toOutgoingAnswerJingle(sdp);
    --print("acceptSDP jingle:")
    --print(jingle)
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
    --print("Yay ICE!")
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
    --print("onTransportInfo:\n" .. sdp)
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
    --print("onSourceAdd")
    self.client:send(verse.reply(req));
    local jingle_tag = req:get_child('jingle', xmlns_jingle);
    local changesTable = jingletolua.jingleToTable(jingle_tag);
    local sourceAdded = false
    for i, content in ipairs(self.remote_state.contents) do
        --print("remote_state contents isn't empty in Lua land")
        local desc = content.description
        local ssrcs = desc.sources or {}
        local groups = desc.sourceGroups or {}

        for _, newContent in ipairs(changesTable.contents) do
            --print("there are new contents in Lua land")
            --print("content stuff: " .. newContent.creator .. ", " .. newContent.senders)
            --print("name: " .. content.name .. " - " .. newContent.name)
            if (content.name == newContent.name) then
                --print("names match in Lua land")
                local newContentsDesc = newContent.description

                local newSSRCs = newContentsDesc.sources or {}
                for _, newSSRC in pairs(newSSRCs) do
                    --print("A source was added in Lua land")
                    sourceAdded = true
                    table.insert(ssrcs, newSSRC)
                end

                local newGroups = newContentsDesc.sourceGroups or {}
                for _, newGroup in pairs(newGroups) do
                    --print("A source group was added in Lua land")
                    table.insert(groups, newGroup)
                end

                self.remote_state.contents[i].description.sources = ssrcs
                self.remote_state.contents[i].description.sourceGroups = groups
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
    self.client:send(verse.reply(req));
    local jingle_tag = req:get_child('jingle', xmlns_jingle);
    local changesTable = jingletolua.jingleToTable(jingle_tag);
    local sourceRemoved = false
    for i, content in ipairs(self.remote_state.contents) do
        local desc = content.description
        local ssrcs = desc.sources or {}
        local groups = desc.sourceGroups or {}

        for _, newContent in ipairs(changesTable.contents) do
            if (content.name == newContent.name) then
                local newContentsDesc = newContent.description
                local newSSRCs = newContentsDesc.sources or {}
                local newGroups = newContentsDesc.sourceGroups or {}

                for _, newSSRC in ipairs(newSSRCs) do
                	for j=#ssrcs,1,-1 do
						if ssrcs[j].ssrc == newSSRC.ssrc then
                            sourceRemoved = true
                            table.remove(ssrcs, j)
                        end
                	end
                end

                for l, newGroup in ipairs(newGroups) do
                    for m=#groups,1,-1 do
                        local group = groups[m]
                        local sources = groups.sources or {}
                        local newSources = newGroups.sources or {}
                        if newGroup.semantics == group.semantics and #newSources == #sources then
                            local same = true;
                            for n, newSource in ipairs(newSources) do
                                if newSource ~= sources[n] then
                                    same = false
                                end
                            end
                            if (same) then
                                table.remove(groups, m)
                            end
                        end
                    end
                end
            end

            self.remote_state.contents[i].description.sources = ssrcs
            self.remote_state.contents[i].description.sourceGroups = groups
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
        if child.attr.xmlns == xmlns_jingle_rtp_info then
        	local name = child.attr.name and child.attr.name or ""
            self.client:event("jingle/media-info/"..child.name, name, self.peer, self.sid);
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

function JingleMedia:active()
    self:sendMediaInfo('resume');
end

function JingleMedia:ring()
    self:sendMediaInfo('ring');
end

function JingleMedia:mute(creator, media)
	self:sendMediaInfo('mute', {name = media, creator = creator});
end

function JingleMedia:unmute(creator, media)
	self:sendMediaInfo('unmute', {name = media, creator = creator});
end

return JingleMedia;
