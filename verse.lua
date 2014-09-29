package.preload['util.encodings']=(function(...)
local function e()
error("Function not implemented");
end
local t=require"mime";
module"encodings"
stringprep={};
base64={encode=t.b64,decode=e};
return _M;
end)
package.preload['util.hashes']=(function(...)
local e=require"util.sha1";
return{sha1=e.sha1};
end)
package.preload['util.sha1']=(function(...)
local h=string.len
local a=string.char
local g=string.byte
local k=string.sub
local s=math.floor
local t=require"bit"
local q=t.bnot
local e=t.band
local y=t.bor
local n=t.bxor
local o=t.lshift
local i=t.rshift
local m,l,d,u,c
local function p(t,e)
return o(t,e)+i(t,32-e)
end
local function f(i)
local t,o
local t=""
for n=1,8 do
o=e(i,15)
if(o<10)then
t=a(o+48)..t
else
t=a(o+87)..t
end
i=s(i/16)
end
return t
end
local function j(t)
local i,o
local n=""
i=h(t)*8
t=t..a(128)
o=56-e(h(t),63)
if(o<0)then
o=o+64
end
for e=1,o do
t=t..a(0)
end
for t=1,8 do
n=a(e(i,255))..n
i=s(i/256)
end
return t..n
end
local function b(f)
local r,t,o,i,w,h,s,v
local a,a
local a={}
while(f~="")do
for e=0,15 do
a[e]=0
for t=1,4 do
a[e]=a[e]*256+g(f,e*4+t)
end
end
for e=16,79 do
a[e]=p(n(n(a[e-3],a[e-8]),n(a[e-14],a[e-16])),1)
end
r=m
t=l
o=d
i=u
w=c
for d=0,79 do
if(d<20)then
h=y(e(t,o),e(q(t),i))
s=1518500249
elseif(d<40)then
h=n(n(t,o),i)
s=1859775393
elseif(d<60)then
h=y(y(e(t,o),e(t,i)),e(o,i))
s=2400959708
else
h=n(n(t,o),i)
s=3395469782
end
v=p(r,5)+h+w+s+a[d]
w=i
i=o
o=p(t,30)
t=r
r=v
end
m=e(m+r,4294967295)
l=e(l+t,4294967295)
d=e(d+o,4294967295)
u=e(u+i,4294967295)
c=e(c+w,4294967295)
f=k(f,65)
end
end
local function a(e,t)
e=j(e)
m=1732584193
l=4023233417
d=2562383102
u=271733878
c=3285377520
b(e)
local e=f(m)..f(l)..f(d)
..f(u)..f(c);
if t then
return e;
else
return(e:gsub("..",function(e)
return string.char(tonumber(e,16));
end));
end
end
_G.sha1={sha1=a};
return _G.sha1;
end)
package.preload['lib.adhoc']=(function(...)
local n,h=require"util.stanza",require"util.uuid";
local e="http://jabber.org/protocol/commands";
local i={}
local s={};
function _cmdtag(o,i,t,a)
local e=n.stanza("command",{xmlns=e,node=o.node,status=i});
if t then e.attr.sessionid=t;end
if a then e.attr.action=a;end
return e;
end
function s.new(e,a,t,o)
return{name=e,node=a,handler=t,cmdtag=_cmdtag,permission=(o or"user")};
end
function s.handle_cmd(o,s,a)
local e=a.tags[1].attr.sessionid or h.generate();
local t={};
t.to=a.attr.to;
t.from=a.attr.from;
t.action=a.tags[1].attr.action or"execute";
t.form=a.tags[1]:child_with_ns("jabber:x:data");
local t,h=o:handler(t,i[e]);
i[e]=h;
local a=n.reply(a);
if t.status=="completed"then
i[e]=nil;
cmdtag=o:cmdtag("completed",e);
elseif t.status=="canceled"then
i[e]=nil;
cmdtag=o:cmdtag("canceled",e);
elseif t.status=="error"then
i[e]=nil;
a=n.error_reply(a,t.error.type,t.error.condition,t.error.message);
s.send(a);
return true;
else
cmdtag=o:cmdtag("executing",e);
end
for t,e in pairs(t)do
if t=="info"then
cmdtag:tag("note",{type="info"}):text(e):up();
elseif t=="warn"then
cmdtag:tag("note",{type="warn"}):text(e):up();
elseif t=="error"then
cmdtag:tag("note",{type="error"}):text(e.message):up();
elseif t=="actions"then
local t=n.stanza("actions");
for a,e in ipairs(e)do
if(e=="prev")or(e=="next")or(e=="complete")then
t:tag(e):up();
else
module:log("error",'Command "'..o.name..
'" at node "'..o.node..'" provided an invalid action "'..e..'"');
end
end
cmdtag:add_child(t);
elseif t=="form"then
cmdtag:add_child((e.layout or e):form(e.values));
elseif t=="result"then
cmdtag:add_child((e.layout or e):form(e.values,"result"));
elseif t=="other"then
cmdtag:add_child(e);
end
end
a:add_child(cmdtag);
s.send(a);
return true;
end
return s;
end)
package.preload['util.rsm']=(function(...)
local s=require"util.stanza".stanza;
local t,o=tostring,tonumber;
local n=type;
local h=pairs;
local i='http://jabber.org/protocol/rsm';
local a={};
do
local e=a;
local function t(e)
return o((e:get_text()));
end
local function a(t)
return t:get_text();
end
e.after=a;
e.before=function(e)
local e=e:get_text();
return e==""or e;
end;
e.max=t;
e.index=t;
e.first=function(e)
return{index=o(e.attr.index);e:get_text()};
end;
e.last=a;
e.count=t;
end
local r=setmetatable({
first=function(a,e)
if n(e)=="table"then
a:tag("first",{index=e.index}):text(e[1]):up();
else
a:tag("first"):text(t(e)):up();
end
end;
before=function(a,e)
if e==true then
a:tag("before"):up();
else
a:tag("before"):text(t(e)):up();
end
end
},{
__index=function(e,a)
return function(o,e)
o:tag(a):text(t(e)):up();
end
end;
});
local function o(e)
local t={};
for o in e:childtags()do
local e=o.name;
local a=e and a[e];
if a then
t[e]=a(o);
end
end
return t;
end
local function n(t)
local e=s("set",{xmlns=i});
for t,o in h(t)do
if a[t]then
r[t](e,o);
end
end
return e;
end
local function t(e)
local e=e:get_child("set",i);
if e and#e.tags>0 then
return o(e);
end
end
return{parse=o,generate=n,get=t};
end)
package.preload['util.stanza']=(function(...)
local t=table.insert;
local e=table.concat;
local s=table.remove;
local y=table.concat;
local h=string.format;
local w=string.match;
local c=tostring;
local m=setmetatable;
local e=getmetatable;
local n=pairs;
local i=ipairs;
local o=type;
local e=next;
local e=print;
local e=unpack;
local v=string.gsub;
local e=string.char;
local f=string.find;
local e=os;
local u=not e.getenv("WINDIR");
local l,a;
if u then
local t,e=pcall(require,"util.termcolours");
if t then
l,a=e.getstyle,e.getstring;
else
u=nil;
end
end
local p="urn:ietf:params:xml:ns:xmpp-stanzas";
module"stanza"
stanza_mt={__type="stanza"};
stanza_mt.__index=stanza_mt;
local e=stanza_mt;
function stanza(a,t)
local t={name=a,attr=t or{},tags={}};
return m(t,e);
end
local r=stanza;
function e:query(e)
return self:tag("query",{xmlns=e});
end
function e:body(t,e)
return self:tag("body",e):text(t);
end
function e:tag(e,a)
local a=r(e,a);
local e=self.last_add;
if not e then e={};self.last_add=e;end
(e[#e]or self):add_direct_child(a);
t(e,a);
return self;
end
function e:text(t)
local e=self.last_add;
(e and e[#e]or self):add_direct_child(t);
return self;
end
function e:up()
local e=self.last_add;
if e then s(e);end
return self;
end
function e:reset()
self.last_add=nil;
return self;
end
function e:add_direct_child(e)
if o(e)=="table"then
t(self.tags,e);
end
t(self,e);
end
function e:add_child(t)
local e=self.last_add;
(e and e[#e]or self):add_direct_child(t);
return self;
end
function e:get_child(a,t)
for o,e in i(self.tags)do
if(not a or e.name==a)
and((not t and self.attr.xmlns==e.attr.xmlns)
or e.attr.xmlns==t)then
return e;
end
end
end
function e:get_child_text(t,e)
local e=self:get_child(t,e);
if e then
return e:get_text();
end
return nil;
end
function e:child_with_name(t)
for a,e in i(self.tags)do
if e.name==t then return e;end
end
end
function e:child_with_ns(t)
for a,e in i(self.tags)do
if e.attr.xmlns==t then return e;end
end
end
function e:children()
local e=0;
return function(t)
e=e+1
return t[e];
end,self,e;
end
function e:childtags(i,e)
e=e or self.attr.xmlns;
local t=self.tags;
local o,a=1,#t;
return function()
for a=o,a do
local t=t[a];
if(not i or t.name==i)
and(not e or e==t.attr.xmlns)then
o=a+1;
return t;
end
end
end;
end
function e:maptags(i)
local a,t=self.tags,1;
local n,o=#self,#a;
local e=1;
while t<=o do
if self[e]==a[t]then
local i=i(self[e]);
if i==nil then
s(self,e);
s(a,t);
n=n-1;
o=o-1;
else
self[e]=i;
a[e]=i;
end
e=e+1;
t=t+1;
end
end
return self;
end
local d
do
local e={["'"]="&apos;",["\""]="&quot;",["<"]="&lt;",[">"]="&gt;",["&"]="&amp;"};
function d(t)return(v(t,"['&<>\"]",e));end
_M.xml_escape=d;
end
local function s(a,e,h,o,r)
local i=0;
local s=a.name
t(e,"<"..s);
for a,n in n(a.attr)do
if f(a,"\1",1,true)then
local a,s=w(a,"^([^\1]*)\1?(.*)$");
i=i+1;
t(e," xmlns:ns"..i.."='"..o(a).."' ".."ns"..i..":"..s.."='"..o(n).."'");
elseif not(a=="xmlns"and n==r)then
t(e," "..a.."='"..o(n).."'");
end
end
local i=#a;
if i==0 then
t(e,"/>");
else
t(e,">");
for i=1,i do
local i=a[i];
if i.name then
h(i,e,h,o,a.attr.xmlns);
else
t(e,o(i));
end
end
t(e,"</"..s..">");
end
end
function e.__tostring(t)
local e={};
s(t,e,s,d,nil);
return y(e);
end
function e.top_tag(t)
local e="";
if t.attr then
for t,a in n(t.attr)do if o(t)=="string"then e=e..h(" %s='%s'",t,d(c(a)));end end
end
return h("<%s%s>",t.name,e);
end
function e.get_text(e)
if#e.tags==0 then
return y(e);
end
end
function e.get_error(a)
local o,t,e;
local a=a:get_child("error");
if not a then
return nil,nil,nil;
end
o=a.attr.type;
for a in a:childtags()do
if a.attr.xmlns==p then
if not e and a.name=="text"then
e=a:get_text();
elseif not t then
t=a.name;
end
if t and e then
break;
end
end
end
return o,t or"undefined-condition",e;
end
function e.__add(e,t)
return e:add_direct_child(t);
end
do
local e=0;
function new_id()
e=e+1;
return"lx"..e;
end
end
function preserialize(a)
local e={name=a.name,attr=a.attr};
for i,a in i(a)do
if o(a)=="table"then
t(e,preserialize(a));
else
t(e,a);
end
end
return e;
end
function deserialize(a)
if a then
local s=a.attr;
for e=1,#s do s[e]=nil;end
local h={};
for e in n(s)do
if f(e,"|",1,true)and not f(e,"\1",1,true)then
local t,a=w(e,"^([^|]+)|(.+)$");
h[t.."\1"..a]=s[e];
s[e]=nil;
end
end
for e,t in n(h)do
s[e]=t;
end
m(a,e);
for t,e in i(a)do
if o(e)=="table"then
deserialize(e);
end
end
if not a.tags then
local e={};
for n,i in i(a)do
if o(i)=="table"then
t(e,i);
end
end
a.tags=e;
end
end
return a;
end
local function s(a)
local o,i={},{};
for t,e in n(a.attr)do o[t]=e;end
local o={name=a.name,attr=o,tags=i};
for e=1,#a do
local e=a[e];
if e.name then
e=s(e);
t(i,e);
end
t(o,e);
end
return m(o,e);
end
clone=s;
function message(t,e)
if not e then
return r("message",t);
else
return r("message",t):tag("body"):text(e):up();
end
end
function iq(e)
if e and not e.id then e.id=new_id();end
return r("iq",e or{id=new_id()});
end
function reply(e)
return r(e.name,e.attr and{to=e.attr.from,from=e.attr.to,id=e.attr.id,type=((e.name=="iq"and"result")or e.attr.type)});
end
do
local a={xmlns=p};
function error_reply(e,o,i,t)
local e=reply(e);
e.attr.type="error";
e:tag("error",{type=o})
:tag(i,a):up();
if(t)then e:tag("text",a):text(t):up();end
return e;
end
end
function presence(e)
return r("presence",e);
end
if u then
local r=l("yellow");
local u=l("red");
local s=l("red");
local t=l("magenta");
local r=" "..a(r,"%s")..a(t,"=")..a(u,"'%s'");
local l=a(t,"<")..a(s,"%s").."%s"..a(t,">");
local s=l.."%s"..a(t,"</")..a(s,"%s")..a(t,">");
function e.pretty_print(e)
local t="";
for a,e in i(e)do
if o(e)=="string"then
t=t..d(e);
else
t=t..e:pretty_print();
end
end
local a="";
if e.attr then
for e,t in n(e.attr)do if o(e)=="string"then a=a..h(r,e,c(t));end end
end
return h(s,e.name,a,t,e.name);
end
function e.pretty_top_tag(e)
local t="";
if e.attr then
for e,a in n(e.attr)do if o(e)=="string"then t=t..h(r,e,c(a));end end
end
return h(l,e.name,t);
end
else
e.pretty_print=e.__tostring;
e.pretty_top_tag=e.top_tag;
end
return _M;
end)
package.preload['util.timer']=(function(...)
local u=require"net.server".addtimer;
local o=require"net.server".event;
local l=require"net.server".event_base;
local d=math.min
local c=math.huge
local r=require"socket".gettime;
local s=table.insert;
local e=table.remove;
local e,n=ipairs,pairs;
local h=type;
local i={};
local a={};
module"timer"
local t;
if not o then
function t(e,o)
local i=r();
e=e+i;
if e>=i then
s(a,{e,o});
else
local e=o();
if e and h(e)=="number"then
return t(e,o);
end
end
end
u(function()
local o=r();
if#a>0 then
for t,e in n(a)do
s(i,e);
end
a={};
end
local e=c;
for r,a in n(i)do
local n,s=a[1],a[2];
if n<=o then
i[r]=nil;
local a=s(o);
if h(a)=="number"then
t(a,s);
e=d(e,a);
end
else
e=d(e,n-o);
end
end
return e;
end);
else
local a=(o.core and o.core.LEAVE)or-1;
function t(o,t)
local e;
e=l:addevent(nil,0,function()
local t=t();
if t then
return 0,t;
elseif e then
return a;
end
end
,o);
end
end
add_task=t;
return _M;
end)
package.preload['util.termcolours']=(function(...)
local l,r=table.concat,table.insert;
local t,d=string.char,string.format;
local h=ipairs;
local s=io.write;
local e;
if os.getenv("WINDIR")then
e=require"util.windows";
end
local o=e and e.get_consolecolor and e.get_consolecolor();
module"termcolours"
local n={
reset=0;bright=1,dim=2,underscore=4,blink=5,reverse=7,hidden=8;
black=30;red=31;green=32;yellow=33;blue=34;magenta=35;cyan=36;white=37;
["black background"]=40;["red background"]=41;["green background"]=42;["yellow background"]=43;["blue background"]=44;["magenta background"]=45;["cyan background"]=46;["white background"]=47;
bold=1,dark=2,underline=4,underlined=4,normal=0;
}
local i={
["0"]=o,
["1"]=7+8,
["1;33"]=2+4+8,
["1;31"]=4+8
}
local a=t(27).."[%sm%s"..t(27).."[0m";
function getstring(e,t)
if e then
return d(a,e,t);
else
return t;
end
end
function getstyle(...)
local e,t={...},{};
for a,e in h(e)do
e=n[e];
if e then
r(t,e);
end
end
return l(t,";");
end
local a="0";
function setstyle(e)
e=e or"0";
if e~=a then
s("\27["..e.."m");
a=e;
end
end
if e then
function setstyle(t)
t=t or"0";
if t~=a then
e.set_consolecolor(i[t]or o);
a=t;
end
end
if not o then
function setstyle(e)end
end
end
return _M;
end)
package.preload['util.uuid']=(function(...)
local e=math.random;
local a=tostring;
local e=os.time;
local n=os.clock;
local i=require"util.hashes".sha1;
module"uuid"
local t=0;
local function o()
local e=e();
if t>=e then e=t+1;end
t=e;
return e;
end
local function e(e)
return i(e..n()..a({}),true);
end
local t=e(o());
local function a(a)
t=e(t..a);
end
local function e(e)
if#t<e then a(o());end
local a=t:sub(0,e);
t=t:sub(e+1);
return a;
end
local function t()
return("%x"):format(e(1):byte()%4+8);
end
function generate()
return e(8).."-"..e(4).."-4"..e(3).."-"..(t())..e(3).."-"..e(12);
end
seed=a;
return _M;
end)
package.preload['net.dns']=(function(...)
local n=require"socket";
local j=require"util.timer";
local e,y=pcall(require,"util.windows");
local E=(e and y)or os.getenv("WINDIR");
local c,_,w,a,i=
coroutine,io,math,string,table;
local p,h,o,m,r,v,q,x,t,e,z=
ipairs,next,pairs,print,setmetatable,tostring,assert,error,unpack,select,type;
local e={
get=function(t,...)
local a=e('#',...);
for a=1,a do
t=t[e(a,...)];
if t==nil then break;end
end
return t;
end;
set=function(t,...)
local n=e('#',...);
local s,o=e(n-1,...);
local a,i;
for n=1,n-2 do
local n=e(n,...)
local e=t[n]
if o==nil then
if e==nil then
return;
elseif h(e,h(e))then
a=nil;i=nil;
elseif a==nil then
a=t;i=n;
end
elseif e==nil then
e={};
t[n]=e;
end
t=e
end
if o==nil and a then
a[i]=nil;
else
t[s]=o;
return o;
end
end;
};
local d,l=e.get,e.set;
local k=15;
module('dns')
local t=_M;
local s=i.insert
local function u(e)
return(e-(e%256))/256;
end
local function b(e)
local t={};
for o,e in o(e)do
t[o]=e;
t[e]=e;
t[a.lower(e)]=e;
end
return t;
end
local function f(i)
local e={};
for o,i in o(i)do
local t=a.char(u(o),o%256);
e[o]=t;
e[i]=t;
e[a.lower(i)]=t;
end
return e;
end
t.types={
'A','NS','MD','MF','CNAME','SOA','MB','MG','MR','NULL','WKS',
'PTR','HINFO','MINFO','MX','TXT',
[28]='AAAA',[29]='LOC',[33]='SRV',
[252]='AXFR',[253]='MAILB',[254]='MAILA',[255]='*'};
t.classes={'IN','CS','CH','HS',[255]='*'};
t.type=b(t.types);
t.class=b(t.classes);
t.typecode=f(t.types);
t.classcode=f(t.classes);
local function g(e,o,i)
if a.byte(e,-1)~=46 then e=e..'.';end
e=a.lower(e);
return e,t.type[o or'A'],t.class[i or'IN'];
end
local function b(t,a,s)
a=a or n.gettime();
for o,e in o(t)do
if e.tod then
e.ttl=w.floor(e.tod-a);
if e.ttl<=0 then
i.remove(t,o);
return b(t,a,s);
end
elseif s=='soft'then
q(e.ttl==0);
t[o]=nil;
end
end
end
local e={};
e.__index=e;
e.timeout=k;
local function k(e)
local e=e.type and e[e.type:lower()];
if z(e)~="string"then
return"<UNKNOWN RDATA TYPE>";
end
return e;
end
local f={
LOC=e.LOC_tostring;
MX=function(e)
return a.format('%2i %s',e.pref,e.mx);
end;
SRV=function(e)
local e=e.srv;
return a.format('%5d %5d %5d %s',e.priority,e.weight,e.port,e.target);
end;
};
local q={};
function q.__tostring(e)
local t=(f[e.type]or k)(e);
return a.format('%2s %-5s %6i %-28s %s',e.class,e.type,e.ttl,e.name,t);
end
local k={};
function k.__tostring(t)
local e={};
for a,t in o(t)do
s(e,v(t)..'\n');
end
return i.concat(e);
end
local f={};
function f.__tostring(t)
local a=n.gettime();
local e={};
for i,t in o(t)do
for i,t in o(t)do
for o,t in o(t)do
b(t,a);
s(e,v(t));
end
end
end
return i.concat(e);
end
function e:new()
local t={active={},cache={},unsorted={}};
r(t,e);
r(t.cache,f);
r(t.unsorted,{__mode='kv'});
return t;
end
function t.random(...)
w.randomseed(w.floor(1e4*n.gettime()));
t.random=w.random;
return t.random(...);
end
local function w(e)
e=e or{};
e.id=e.id or t.random(0,65535);
e.rd=e.rd or 1;
e.tc=e.tc or 0;
e.aa=e.aa or 0;
e.opcode=e.opcode or 0;
e.qr=e.qr or 0;
e.rcode=e.rcode or 0;
e.z=e.z or 0;
e.ra=e.ra or 0;
e.qdcount=e.qdcount or 1;
e.ancount=e.ancount or 0;
e.nscount=e.nscount or 0;
e.arcount=e.arcount or 0;
local t=a.char(
u(e.id),e.id%256,
e.rd+2*e.tc+4*e.aa+8*e.opcode+128*e.qr,
e.rcode+16*e.z+128*e.ra,
u(e.qdcount),e.qdcount%256,
u(e.ancount),e.ancount%256,
u(e.nscount),e.nscount%256,
u(e.arcount),e.arcount%256
);
return t,e.id;
end
local function u(t)
local e={};
for t in a.gmatch(t,'[^.]+')do
s(e,a.char(a.len(t)));
s(e,t);
end
s(e,a.char(0));
return i.concat(e);
end
local function z(o,a,e)
o=u(o);
a=t.typecode[a or'a'];
e=t.classcode[e or'in'];
return o..a..e;
end
function e:byte(e)
e=e or 1;
local t=self.offset;
local o=t+e-1;
if o>#self.packet then
x(a.format('out of bounds: %i>%i',o,#self.packet));
end
self.offset=t+e;
return a.byte(self.packet,t,o);
end
function e:word()
local e,t=self:byte(2);
return 256*e+t;
end
function e:dword()
local o,a,t,e=self:byte(4);
return 16777216*o+65536*a+256*t+e;
end
function e:sub(e)
e=e or 1;
local t=a.sub(self.packet,self.offset,self.offset+e-1);
self.offset=self.offset+e;
return t;
end
function e:header(t)
local e=self:word();
if not self.active[e]and not t then return nil;end
local e={id=e};
local t,a=self:byte(2);
e.rd=t%2;
e.tc=t/2%2;
e.aa=t/4%2;
e.opcode=t/8%16;
e.qr=t/128;
e.rcode=a%16;
e.z=a/16%8;
e.ra=a/128;
e.qdcount=self:word();
e.ancount=self:word();
e.nscount=self:word();
e.arcount=self:word();
for a,t in o(e)do e[a]=t-t%1;end
return e;
end
function e:name()
local t,a=nil,0;
local e=self:byte();
local o={};
while e>0 do
if e>=192 then
a=a+1;
if a>=20 then x('dns error: 20 pointers');end;
local e=((e-192)*256)+self:byte();
t=t or self.offset;
self.offset=e+1;
else
s(o,self:sub(e)..'.');
end
e=self:byte();
end
self.offset=t or self.offset;
return i.concat(o);
end
function e:question()
local e={};
e.name=self:name();
e.type=t.type[self:word()];
e.class=t.class[self:word()];
return e;
end
function e:A(e)
local t,i,o,n=self:byte(4);
e.a=a.format('%i.%i.%i.%i',t,i,o,n);
end
function e:AAAA(a)
local e={};
for t=1,a.rdlength,2 do
local t,a=self:byte(2);
i.insert(e,("%02x%02x"):format(t,a));
end
e=i.concat(e,":"):gsub("%f[%x]0+(%x)","%1");
local t={};
for e in e:gmatch(":[0:]+:")do
i.insert(t,e)
end
if#t==0 then
a.aaaa=e;
return
elseif#t>1 then
i.sort(t,function(e,t)return#e>#t end);
end
a.aaaa=e:gsub(t[1],"::",1):gsub("^0::","::"):gsub("::0$","::");
end
function e:CNAME(e)
e.cname=self:name();
end
function e:MX(e)
e.pref=self:word();
e.mx=self:name();
end
function e:LOC_nibble_power()
local e=self:byte();
return((e-(e%16))/16)*(10^(e%16));
end
function e:LOC(e)
e.version=self:byte();
if e.version==0 then
e.loc=e.loc or{};
e.loc.size=self:LOC_nibble_power();
e.loc.horiz_pre=self:LOC_nibble_power();
e.loc.vert_pre=self:LOC_nibble_power();
e.loc.latitude=self:dword();
e.loc.longitude=self:dword();
e.loc.altitude=self:dword();
end
end
local function u(e,i,t)
e=e-2147483648;
if e<0 then i=t;e=-e;end
local n,t,o;
o=e%6e4;
e=(e-o)/6e4;
t=e%60;
n=(e-t)/60;
return a.format('%3d %2d %2.3f %s',n,t,o/1e3,i);
end
function e.LOC_tostring(e)
local t={};
s(t,a.format(
'%s    %s    %.2fm %.2fm %.2fm %.2fm',
u(e.loc.latitude,'N','S'),
u(e.loc.longitude,'E','W'),
(e.loc.altitude-1e7)/100,
e.loc.size/100,
e.loc.horiz_pre/100,
e.loc.vert_pre/100
));
return i.concat(t);
end
function e:NS(e)
e.ns=self:name();
end
function e:SOA(e)
end
function e:SRV(e)
e.srv={};
e.srv.priority=self:word();
e.srv.weight=self:word();
e.srv.port=self:word();
e.srv.target=self:name();
end
function e:PTR(e)
e.ptr=self:name();
end
function e:TXT(e)
e.txt=self:sub(self:byte());
end
function e:rr()
local e={};
r(e,q);
e.name=self:name(self);
e.type=t.type[self:word()]or e.type;
e.class=t.class[self:word()]or e.class;
e.ttl=65536*self:word()+self:word();
e.rdlength=self:word();
if e.ttl<=0 then
e.tod=self.time+30;
else
e.tod=self.time+e.ttl;
end
local a=self.offset;
local t=self[t.type[e.type]];
if t then t(self,e);end
self.offset=a;
e.rdata=self:sub(e.rdlength);
return e;
end
function e:rrs(t)
local e={};
for t=1,t do s(e,self:rr());end
return e;
end
function e:decode(t,o)
self.packet,self.offset=t,1;
local t=self:header(o);
if not t then return nil;end
local t={header=t};
t.question={};
local i=self.offset;
for e=1,t.header.qdcount do
s(t.question,self:question());
end
t.question.raw=a.sub(self.packet,i,self.offset-1);
if not o then
if not self.active[t.header.id]or not self.active[t.header.id][t.question.raw]then
return nil;
end
end
t.answer=self:rrs(t.header.ancount);
t.authority=self:rrs(t.header.nscount);
t.additional=self:rrs(t.header.arcount);
return t;
end
e.delays={1,3};
function e:addnameserver(e)
self.server=self.server or{};
s(self.server,e);
end
function e:setnameserver(e)
self.server={};
self:addnameserver(e);
end
function e:adddefaultnameservers()
if E then
if y and y.get_nameservers then
for t,e in p(y.get_nameservers())do
self:addnameserver(e);
end
end
if not self.server or#self.server==0 then
self:addnameserver("208.67.222.222");
self:addnameserver("208.67.220.220");
end
else
local e=_.open("/etc/resolv.conf");
if e then
for e in e:lines()do
e=e:gsub("#.*$","")
:match('^%s*nameserver%s+(.*)%s*$');
if e then
e:gsub("%f[%d.](%d+%.%d+%.%d+%.%d+)%f[^%d.]",function(e)
self:addnameserver(e)
end);
end
end
end
if not self.server or#self.server==0 then
self:addnameserver("127.0.0.1");
end
end
end
function e:getsocket(t)
self.socket=self.socket or{};
self.socketset=self.socketset or{};
local e=self.socket[t];
if e then return e;end
local a;
e,a=n.udp();
if not e then
return nil,a;
end
if self.socket_wrapper then e=self.socket_wrapper(e,self);end
e:settimeout(0);
e:setsockname('*',0);
e:setpeername(self.server[t],53);
self.socket[t]=e;
self.socketset[e]=t;
return e;
end
function e:voidsocket(e)
if self.socket[e]then
self.socketset[self.socket[e]]=nil;
self.socket[e]=nil;
elseif self.socketset[e]then
self.socket[self.socketset[e]]=nil;
self.socketset[e]=nil;
end
end
function e:socket_wrapper_set(e)
self.socket_wrapper=e;
end
function e:closeall()
for t,e in p(self.socket)do
self.socket[t]=nil;
self.socketset[e]=nil;
e:close();
end
end
function e:remember(e,t)
local a,i,o=g(e.name,e.type,e.class);
if t~='*'then
t=i;
local t=d(self.cache,o,'*',a);
if t then s(t,e);end
end
self.cache=self.cache or r({},f);
local a=d(self.cache,o,t,a)or
l(self.cache,o,t,a,r({},k));
s(a,e);
if t=='MX'then self.unsorted[a]=true;end
end
local function s(t,e)
return(t.pref==e.pref)and(t.mx<e.mx)or(t.pref<e.pref);
end
function e:peek(a,t,o)
a,t,o=g(a,t,o);
local e=d(self.cache,o,t,a);
if not e then return nil;end
if b(e,n.gettime())and t=='*'or not h(e)then
l(self.cache,o,t,a,nil);
return nil;
end
if self.unsorted[e]then i.sort(e,s);end
return e;
end
function e:purge(e)
if e=='soft'then
self.time=n.gettime();
for t,e in o(self.cache or{})do
for t,e in o(e)do
for t,e in o(e)do
b(e,self.time,'soft')
end
end
end
else self.cache=r({},f);end
end
function e:query(t,e,a)
t,e,a=g(t,e,a)
if not self.server then self:adddefaultnameservers();end
local s=z(t,e,a);
local o=self:peek(t,e,a);
if o then return o;end
local i,o=w();
local i={
packet=i..s,
server=self.best_server,
delay=1,
retry=n.gettime()+self.delays[1]
};
self.active[o]=self.active[o]or{};
self.active[o][s]=i;
local n=c.running();
if n then
l(self.wanted,a,e,t,n,true);
end
local o,h=self:getsocket(i.server)
if not o then
return nil,h;
end
o:send(i.packet)
if j and self.timeout then
local r=#self.server;
local s=1;
j.add_task(self.timeout,function()
if d(self.wanted,a,e,t,n)then
if s<r then
s=s+1;
self:servfail(o);
i.server=self.best_server;
o,h=self:getsocket(i.server);
if o then
o:send(i.packet);
return self.timeout;
end
end
self:cancel(a,e,t,n,true);
end
end)
end
return true;
end
function e:servfail(e)
local a=self.socketset[e]
self:voidsocket(e);
self.time=n.gettime();
for e,t in o(self.active)do
for o,e in o(t)do
if e.server==a then
e.server=e.server+1
if e.server>#self.server then
e.server=1;
end
e.retries=(e.retries or 0)+1;
if e.retries>=#self.server then
t[o]=nil;
else
local t=self:getsocket(e.server);
if t then t:send(e.packet);end
end
end
end
end
if a==self.best_server then
self.best_server=self.best_server+1;
if self.best_server>#self.server then
self.best_server=1;
end
end
end
function e:settimeout(e)
self.timeout=e;
end
function e:receive(t)
self.time=n.gettime();
t=t or self.socket;
local e;
for a,t in o(t)do
if self.socketset[t]then
local t=t:receive();
if t then
e=self:decode(t);
if e and self.active[e.header.id]
and self.active[e.header.id][e.question.raw]then
for a,t in o(e.answer)do
if t.name:sub(-#e.question[1].name,-1)==e.question[1].name then
self:remember(t,e.question[1].type)
end
end
local t=self.active[e.header.id];
t[e.question.raw]=nil;
if not h(t)then self.active[e.header.id]=nil;end
if not h(self.active)then self:closeall();end
local e=e.question[1];
local t=d(self.wanted,e.class,e.type,e.name);
if t then
for t in o(t)do
l(self.yielded,t,e.class,e.type,e.name,nil);
if c.status(t)=="suspended"then c.resume(t);end
end
l(self.wanted,e.class,e.type,e.name,nil);
end
end
end
end
end
return e;
end
function e:feed(a,t,e)
self.time=n.gettime();
local e=self:decode(t,e);
if e and self.active[e.header.id]
and self.active[e.header.id][e.question.raw]then
for a,t in o(e.answer)do
self:remember(t,e.question[1].type);
end
local t=self.active[e.header.id];
t[e.question.raw]=nil;
if not h(t)then self.active[e.header.id]=nil;end
if not h(self.active)then self:closeall();end
local e=e.question[1];
if e then
local t=d(self.wanted,e.class,e.type,e.name);
if t then
for t in o(t)do
l(self.yielded,t,e.class,e.type,e.name,nil);
if c.status(t)=="suspended"then c.resume(t);end
end
l(self.wanted,e.class,e.type,e.name,nil);
end
end
end
return e;
end
function e:cancel(t,a,i,e,o)
local t=d(self.wanted,t,a,i);
if t then
if o then
c.resume(e);
end
t[e]=nil;
end
end
function e:pulse()
while self:receive()do end
if not h(self.active)then return nil;end
self.time=n.gettime();
for i,t in o(self.active)do
for a,e in o(t)do
if self.time>=e.retry then
e.server=e.server+1;
if e.server>#self.server then
e.server=1;
e.delay=e.delay+1;
end
if e.delay>#self.delays then
t[a]=nil;
if not h(t)then self.active[i]=nil;end
if not h(self.active)then return nil;end
else
local t=self.socket[e.server];
if t then t:send(e.packet);end
e.retry=self.time+self.delays[e.delay];
end
end
end
end
if h(self.active)then return true;end
return nil;
end
function e:lookup(e,t,a)
self:query(e,t,a)
while self:pulse()do
local e={}
for t,a in p(self.socket)do
e[t]=a
end
n.select(e,nil,4)
end
return self:peek(e,t,a);
end
function e:lookupex(o,t,e,a)
return self:peek(t,e,a)or self:query(t,e,a);
end
function e:tohostname(e)
return t.lookup(e:gsub("(%d+)%.(%d+)%.(%d+)%.(%d+)","%4.%3.%2.%1.in-addr.arpa."),"PTR");
end
local i={
qr={[0]='query','response'},
opcode={[0]='query','inverse query','server status request'},
aa={[0]='non-authoritative','authoritative'},
tc={[0]='complete','truncated'},
rd={[0]='recursion not desired','recursion desired'},
ra={[0]='recursion not available','recursion available'},
z={[0]='(reserved)'},
rcode={[0]='no error','format error','server failure','name error','not implemented'},
type=t.type,
class=t.class
};
local function s(t,e)
return(i[e]and i[e][t[e]])or'';
end
function e.print(t)
for o,e in o{'id','qr','opcode','aa','tc','rd','ra','z',
'rcode','qdcount','ancount','nscount','arcount'}do
m(a.format('%-30s','header.'..e),t.header[e],s(t.header,e));
end
for t,e in p(t.question)do
m(a.format('question[%i].name         ',t),e.name);
m(a.format('question[%i].type         ',t),e.type);
m(a.format('question[%i].class        ',t),e.class);
end
local h={name=1,type=1,class=1,ttl=1,rdlength=1,rdata=1};
local e;
for n,i in o({'answer','authority','additional'})do
for n,t in o(t[i])do
for h,o in o({'name','type','class','ttl','rdlength'})do
e=a.format('%s[%i].%s',i,n,o);
m(a.format('%-30s',e),t[o],s(t,o));
end
for t,o in o(t)do
if not h[t]then
e=a.format('%s[%i].%s',i,n,t);
m(a.format('%-30s  %s',v(e),v(o)));
end
end
end
end
end
function t.resolver()
local t={active={},cache={},unsorted={},wanted={},yielded={},best_server=1};
r(t,e);
r(t.cache,f);
r(t.unsorted,{__mode='kv'});
return t;
end
local e=t.resolver();
t._resolver=e;
function t.lookup(...)
return e:lookup(...);
end
function t.tohostname(...)
return e:tohostname(...);
end
function t.purge(...)
return e:purge(...);
end
function t.peek(...)
return e:peek(...);
end
function t.query(...)
return e:query(...);
end
function t.feed(...)
return e:feed(...);
end
function t.cancel(...)
return e:cancel(...);
end
function t.settimeout(...)
return e:settimeout(...);
end
function t.socket_wrapper_set(...)
return e:socket_wrapper_set(...);
end
return t;
end)
package.preload['net.adns']=(function(...)
local c=require"net.server";
local o=require"net.dns";
local e=require"util.logger".init("adns");
local t,t=table.insert,table.remove;
local n,s,l=coroutine,tostring,pcall;
local function u(a,a,t,e)return(e-t)+1;end
module"adns"
function lookup(d,t,h,r)
return n.wrap(function(a)
if a then
e("debug","Records for %s already cached, using those...",t);
d(a);
return;
end
e("debug","Records for %s not in cache, sending query (%s)...",t,s(n.running()));
local i,a=o.query(t,h,r);
if i then
n.yield({r or"IN",h or"A",t,n.running()});
e("debug","Reply for %s (%s)",t,s(n.running()));
end
if i then
i,a=l(d,o.peek(t,h,r));
else
e("error","Error sending DNS query: %s",a);
i,a=l(d,nil,a);
end
if not i then
e("error","Error in DNS response handler: %s",s(a));
end
end)(o.peek(t,h,r));
end
function cancel(t,a,i)
e("warn","Cancelling DNS lookup for %s",s(t[3]));
o.cancel(t[1],t[2],t[3],t[4],a);
end
function new_async_socket(a,i)
local s="<unknown>";
local n={};
local t={};
function n.onincoming(a,e)
if e then
o.feed(t,e);
end
end
function n.ondisconnect(a,o)
if o then
e("warn","DNS socket for %s disconnected: %s",s,o);
local t=i.server;
if i.socketset[a]==i.best_server and i.best_server==#t then
e("error","Exhausted all %d configured DNS servers, next lookup will try %s again",#t,t[1]);
end
i:servfail(a);
end
end
t=c.wrapclient(a,"dns",53,n);
if not t then
e("warn","handler is nil");
end
t.settimeout=function()end
t.setsockname=function(e,...)return a:setsockname(...);end
t.setpeername=function(e,...)s=(...);local a=a:setpeername(...);e:set_send(u);return a;end
t.connect=function(e,...)return a:connect(...)end
t.send=function(t,o)
local t=a.getpeername;
e("debug","Sending DNS query to %s",(t and t(a))or"<unconnected>");
return a:send(o);
end
return t;
end
o.socket_wrapper_set(new_async_socket);
return _M;
end)
package.preload['net.server']=(function(...)
local s=function(e)
return _G[e]
end
local re=function(e)
for t,a in pairs(e)do
e[t]=nil
end
end
local H,e=require("util.logger").init("socket"),table.concat;
local i=function(...)return H("debug",e{...});end
local se=function(...)return H("warn",e{...});end
local e=collectgarbage
local he=1
local R=s"type"
local j=s"pairs"
local ce=s"ipairs"
local p=s"tonumber"
local l=s"tostring"
local e=s"collectgarbage"
local o=s"os"
local t=s"table"
local a=s"string"
local e=s"coroutine"
local Y=o.difftime
local W=math.min
local ue=math.huge
local le=t.concat
local t=t.remove
local de=a.len
local ve=a.sub
local be=e.wrap
local pe=e.yield
local q=s"ssl"
local z=s"socket"or require"socket"
local P=z.gettime
local ye=(q and q.wrap)
local we=z.bind
local fe=z.sleep
local me=z.select
local e=(q and q.newcontext)
local J
local V
local X
local G
local B
local Z
local m
local ee
local oe
local ie
local ne
local Q
local h
local te
local e
local L
local ae
local v
local r
local F
local d
local n
local x
local b
local w
local f
local a
local o
local g
local M
local C
local N
local S
local K
local u
local E
local _
local T
local O
local A
local U
local D
local k
local I
v={}
r={}
d={}
F={}
n={}
b={}
w={}
x={}
a=0
o=0
g=0
M=0
C=0
N=1
S=0
E=51e3*1024
_=25e3*1024
T=12e5
O=6e4
A=6*60*60
U=false
k=1e3
I=30
ie=function(f,t,y,u,v,m,c)
c=c or k
local s=0
local w,e=f.onconnect,f.ondisconnect
local p=t.accept
local e={}
e.shutdown=function()end
e.ssl=function()
return m~=nil
end
e.sslctx=function()
return m
end
e.remove=function()
s=s-1
end
e.close=function()
for a,e in j(n)do
if e.serverport==u then
e.disconnect(e,"server closed")
e:close(true)
end
end
t:close()
o=h(d,t,o)
a=h(r,t,a)
n[t]=nil
e=nil
t=nil
i"server.lua: closed server handler and removed sockets from list"
end
e.ip=function()
return y
end
e.serverport=function()
return u
end
e.socket=function()
return t
end
e.readbuffer=function()
if s>c then
i("server.lua: refused new client connection: server full")
return false
end
local t,n=p(t)
if t then
local o,a=t:getpeername()
t:settimeout(0)
local t,n,e=L(e,f,t,o,u,a,v,m)
if e then
return false
end
s=s+1
i("server.lua: accepted new client connection from ",l(o),":",l(a)," to ",l(u))
if w then
return w(t);
end
return;
elseif n then
i("server.lua: error with new client connection: ",l(n))
return false
end
end
return e
end
L=function(V,v,t,H,K,N,A,z)
t:settimeout(0)
local y
local T
local j
local S
local L=v.onincoming
local F=v.onstatus
local g=v.ondisconnect
local P=v.ondrain
local p={}
local c=0
local B
local R
local W
local s=0
local k=false
local O=false
local Y,D=0,0
local E=E
local _=_
local e=p
e.dispatch=function()
return L
end
e.disconnect=function()
return g
end
e.setlistener=function(a,t)
L=t.onincoming
g=t.ondisconnect
F=t.onstatus
P=t.ondrain
end
e.getstats=function()
return D,Y
end
e.ssl=function()
return S
end
e.sslctx=function()
return z
end
e.send=function(n,i,o,a)
return y(t,i,o,a)
end
e.receive=function(o,a)
return T(t,o,a)
end
e.shutdown=function(a)
return j(t,a)
end
e.setoption=function(i,a,o)
if t.setoption then
return t:setoption(a,o);
end
return false,"setoption not implemented";
end
e.close=function(u,l)
if not e then return true;end
a=h(r,t,a)
b[e]=nil
if c~=0 then
if not(l or R)then
e.sendbuffer()
if c~=0 then
if e then
e.write=nil
end
B=true
return false
end
else
y(t,le(p,"",1,c),1,s)
end
end
if t then
f=j and j(t)
t:close()
o=h(d,t,o)
n[t]=nil
t=nil
else
i"server.lua: socket already closed"
end
if e then
w[e]=nil
x[e]=nil
e=nil
end
if V then
V.remove()
end
i"server.lua: closed client handler and removed socket from list"
return true
end
e.ip=function()
return H
end
e.serverport=function()
return K
end
e.clientport=function()
return N
end
local x=function(i,a)
s=s+de(a)
if s>E then
x[e]="send buffer exceeded"
e.write=G
return false
elseif t and not d[t]then
o=m(d,t,o)
end
c=c+1
p[c]=a
if e then
w[e]=w[e]or u
end
return true
end
e.write=x
e.bufferqueue=function(t)
return p
end
e.socket=function(a)
return t
end
e.set_mode=function(a,t)
A=t or A
return A
end
e.set_send=function(a,t)
y=t or y
return y
end
e.bufferlen=function(o,t,a)
E=a or E
_=t or _
return s,_,E
end
e.lock_read=function(i,o)
if o==true then
local o=a
a=h(r,t,a)
b[e]=nil
if a~=o then
k=true
end
elseif o==false then
if k then
k=false
a=m(r,t,a)
b[e]=u
end
end
return k
end
e.pause=function(t)
return t:lock_read(true);
end
e.resume=function(t)
return t:lock_read(false);
end
e.lock=function(i,a)
e.lock_read(a)
if a==true then
e.write=G
local a=o
o=h(d,t,o)
w[e]=nil
if o~=a then
O=true
end
elseif a==false then
e.write=x
if O then
O=false
x("")
end
end
return k,O
end
local b=function()
local a,t,o=T(t,A)
if not t or(t=="wantread"or t=="timeout")then
local o=a or o or""
local a=de(o)
if a>_ then
g(e,"receive buffer exceeded")
e:close(true)
return false
end
local a=a*he
D=D+a
C=C+a
b[e]=u
return L(e,o,t)
else
i("server.lua: client ",l(H),":",l(N)," read error: ",l(t))
R=true
g(e,t)
f=e and e:close()
return false
end
end
local w=function()
local m,a,n,r,v;
local v;
if t then
r=le(p,"",1,c)
m,a,n=y(t,r,1,s)
v=(m or n or 0)*he
Y=Y+v
M=M+v
f=U and re(p)
else
m,a,v=false,"closed",0;
end
if m then
c=0
s=0
o=h(d,t,o)
w[e]=nil
if P then
P(e)
end
f=W and e:starttls(nil)
f=B and e:close()
return true
elseif n and(a=="timeout"or a=="wantwrite")then
r=ve(r,n+1,s)
p[1]=r
c=1
s=s-n
w[e]=u
return true
else
i("server.lua: client ",l(H),":",l(N)," write error: ",l(a))
R=true
g(e,a)
f=e and e:close()
return false
end
end
local s;
function e.set_sslctx(y,t)
z=t;
local c,u
s=be(function(n)
local t
for s=1,I do
o=(u and h(d,n,o))or o
a=(c and h(r,n,a))or a
c,u=nil,nil
f,t=n:dohandshake()
if not t then
i("server.lua: ssl handshake done")
e.readbuffer=b
e.sendbuffer=w
f=F and F(e,"ssl-handshake-complete")
if y.autostart_ssl and v.onconnect then
v.onconnect(y);
end
a=m(r,n,a)
return true
else
if t=="wantwrite"then
o=m(d,n,o)
u=true
elseif t=="wantread"then
a=m(r,n,a)
c=true
else
break;
end
t=nil;
pe()
end
end
i("server.lua: ssl handshake error: ",l(t or"handshake too long"))
g(e,"ssl handshake failed")
f=e and e:close(true)
return false
end
)
end
if q then
e.starttls=function(f,u)
if u then
e:set_sslctx(u);
end
if c>0 then
i"server.lua: we need to do tls, but delaying until send buffer empty"
W=true
return
end
i("server.lua: attempting to start tls on "..l(t))
local u,c=t
t,c=ye(t,z)
if not t then
i("server.lua: error while starting tls on client: ",l(c or"unknown error"))
return nil,c
end
t:settimeout(0)
y=t.send
T=t.receive
j=J
n[t]=e
a=m(r,t,a)
a=h(r,u,a)
o=h(d,u,o)
n[u]=nil
e.starttls=nil
W=nil
S=true
e.readbuffer=s
e.sendbuffer=s
s(t)
end
e.readbuffer=b
e.sendbuffer=w
if z then
i"server.lua: auto-starting ssl negotiation..."
e.autostart_ssl=true;
e:starttls(z);
end
else
e.readbuffer=b
e.sendbuffer=w
end
y=t.send
T=t.receive
j=(S and J)or t.shutdown
n[t]=e
a=m(r,t,a)
return e,t
end
J=function()
end
G=function()
return false
end
m=function(t,a,e)
if not t[a]then
e=e+1
t[e]=a
t[a]=e
end
return e;
end
h=function(e,a,t)
local i=e[a]
if i then
e[a]=nil
local o=e[t]
e[t]=nil
if o~=a then
e[o]=i
e[i]=o
end
return t-1
end
return t
end
Q=function(e)
o=h(d,e,o)
a=h(r,e,a)
n[e]=nil
e:close()
end
local function c(a,t,o)
local e;
local i=t.sendbuffer;
function t.sendbuffer()
i();
if e and t.bufferlen()<o then
a:lock_read(false);
e=nil;
end
end
local i=a.readbuffer;
function a.readbuffer()
i();
if not e and t.bufferlen()>=o then
e=true;
a:lock_read(true);
end
end
end
ee=function(t,e,d,l,h)
local o
if R(d)~="table"then
o="invalid listener table"
end
if R(e)~="number"or not(e>=0 and e<=65535)then
o="invalid port"
elseif v[t..":"..e]then
o="listeners on '["..t.."]:"..e.."' already exist"
elseif h and not q then
o="luasec not found"
end
if o then
se("server.lua, [",t,"]:",e,": ",o)
return nil,o
end
t=t or"*"
local o,s=we(t,e)
if s then
se("server.lua, [",t,"]:",e,": ",s)
return nil,s
end
local s,d=ie(d,o,t,e,l,h,k)
if not s then
o:close()
return nil,d
end
o:settimeout(0)
a=m(r,o,a)
v[t..":"..e]=s
n[o]=s
i("server.lua: new "..(h and"ssl "or"").."server listener on '[",t,"]:",e,"'")
return s
end
oe=function(t,e)
return v[t..":"..e];
end
te=function(t,e)
local a=v[t..":"..e]
if not a then
return nil,"no server found on '["..t.."]:"..l(e).."'"
end
a:close()
v[t..":"..e]=nil
return true
end
Z=function()
for t,e in j(n)do
e:close()
n[t]=nil
end
a=0
o=0
g=0
v={}
r={}
d={}
F={}
n={}
end
ne=function()
return N,S,E,_,T,O,A,U,k,I
end
ae=function(e)
if R(e)~="table"then
return nil,"invalid settings table"
end
N=p(e.timeout)or N
S=p(e.sleeptime)or S
E=p(e.maxsendlen)or E
_=p(e.maxreadlen)or _
T=p(e.checkinterval)or T
O=p(e.sendtimeout)or O
A=p(e.readtimeout)or A
U=e.cleanqueue
k=e._maxclientsperserver or k
I=e._maxsslhandshake or I
return true
end
B=function(e)
if R(e)~="function"then
return nil,"invalid listener function"
end
g=g+1
F[g]=e
return true
end
X=function()
return C,M,a,o,g
end
local t;
local function l(e)
t=not not e;
end
V=function(a)
if t then return"quitting";end
if a then t="once";end
local e=ue;
repeat
local a,o,s=me(r,d,W(N,e))
for e,t in ce(o)do
local e=n[t]
if e then
e.sendbuffer()
else
Q(t)
i"server.lua: found no handler and closed socket (writelist)"
end
end
for t,e in ce(a)do
local t=n[e]
if t then
t.readbuffer()
else
Q(e)
i"server.lua: found no handler and closed socket (readlist)"
end
end
for e,t in j(x)do
e.disconnect()(e,t)
e:close(true)
end
re(x)
u=P()
if u-D>=W(e,1)then
e=ue;
for t=1,g do
local t=F[t](u)
if t then e=W(e,t);end
end
D=u
else
e=e-(u-D);
end
fe(S)
until t;
if a and t=="once"then t=nil;return;end
return"quitting"
end
local function r()
return V(true);
end
local function y()
return"select";
end
local i=function(t,e,r,a,s,i)
local e=L(nil,a,t,e,r,"clientport",s,i)
n[t]=e
if not i then
o=m(d,t,o)
if a.onconnect then
local i=e.sendbuffer;
e.sendbuffer=function()
o=h(d,t,o);
e.sendbuffer=i;
a.onconnect(e);
if#e:bufferqueue()>0 then
return i();
end
end
end
end
return e,t
end
local a=function(a,o,n,h,r)
local t,e=z.tcp()
if e then
return nil,e
end
t:settimeout(0)
f,e=t:connect(a,o)
if e then
local e=i(t,a,o,n)
else
L(nil,n,t,a,o,"clientport",h,r)
end
end
s"setmetatable"(n,{__mode="k"})
s"setmetatable"(b,{__mode="k"})
s"setmetatable"(w,{__mode="k"})
D=P()
K=P()
B(function()
local e=Y(u-K)
if e>T then
K=u
for e,t in j(w)do
if Y(u-t)>O then
e.disconnect()(e,"send timeout")
e:close(true)
end
end
for e,t in j(b)do
if Y(u-t)>A then
e.disconnect()(e,"read timeout")
e:close()
end
end
end
end
)
local function t(e)
local t=H;
if e then
H=e;
end
return t;
end
return{
addclient=a,
wrapclient=i,
loop=V,
link=c,
step=r,
stats=X,
closeall=Z,
addtimer=B,
addserver=ee,
getserver=oe,
setlogger=t,
getsettings=ne,
setquitting=l,
removeserver=te,
get_backend=y,
changesettings=ae,
}
end)
package.preload['util.xmppstream']=(function(...)
local e=require"lxp";
local t=require"util.stanza";
local m=t.stanza_mt;
local o=tostring;
local h=table.insert;
local c=table.concat;
local g=table.remove;
local f=setmetatable;
local u=require"util.logger".init("xmppstream");
local p=pcall(e.new,{StartDoctypeDecl=false});
if not p then
u("warn","The version of LuaExpat on your system leaves Prosody "
.."vulnerable to denial-of-service attacks. You should upgrade to "
.."LuaExpat 1.1.1 or higher as soon as possible. See "
.."http://prosody.im/doc/depends#luaexpat for more information.");
end
local y=error;
module"xmppstream"
local w=e.new;
local b={
["http://www.w3.org/XML/1998/namespace"]="xml";
};
local a="http://etherx.jabber.org/streams";
local s="\1";
local l="^([^"..s.."]*)"..s.."?(.*)$";
_M.ns_separator=s;
_M.ns_pattern=l;
function new_sax_handlers(t,e)
local i={};
local k=t.log or u;
local v=e.streamopened;
local w=e.streamclosed;
local r=e.error or function(t,e)y("XML stream error: "..o(e));end;
local q=e.handlestanza;
local a=e.stream_ns or a;
local d=e.stream_tag or"stream";
if a~=""then
d=a..s..d;
end
local x=a..s..(e.error_tag or"error");
local j=e.default_ns;
local s={};
local o,e={};
local n=0;
function i:StartElement(u,a)
if e and#o>0 then
h(e,c(o));
o={};
end
local i,o=u:match(l);
if o==""then
i,o="",i;
end
if i~=j or n>0 then
a.xmlns=i;
n=n+1;
end
for e=1,#a do
local t=a[e];
a[e]=nil;
local e,o=t:match(l);
if o~=""then
e=b[e];
if e then
a[e..":"..o]=a[t];
a[t]=nil;
end
end
end
if not e then
if t.notopen then
if u==d then
n=0;
if v then
v(t,a);
end
else
r(t,"no-stream");
end
return;
end
if i=="jabber:client"and o~="iq"and o~="presence"and o~="message"then
r(t,"invalid-top-level-element");
end
e=f({name=o,attr=a,tags={}},m);
else
h(s,e);
local t=e;
e=f({name=o,attr=a,tags={}},m);
h(t,e);
h(t.tags,e);
end
end
function i:CharacterData(t)
if e then
h(o,t);
end
end
function i:EndElement(a)
if n>0 then
n=n-1;
end
if e then
if#o>0 then
h(e,c(o));
o={};
end
if#s==0 then
if a~=x then
q(t,e);
else
r(t,"stream-error",e);
end
e=nil;
else
e=g(s);
end
else
if a==d then
if w then
w(t);
end
else
local a,e=a:match(l);
if e==""then
a,e="",a;
end
r(t,"parse-error","unexpected-element-close",e);
end
e,o=nil,{};
s={};
end
end
local function a(e)
r(t,"parse-error","restricted-xml","Restricted XML, see RFC 6120 section 11.1.");
if not e.stop or not e:stop()then
y("Failed to abort parsing");
end
end
if p then
i.StartDoctypeDecl=a;
end
i.Comment=a;
i.ProcessingInstruction=a;
local function a()
e,o=nil,{};
s={};
end
local function o(a,e)
t=e;
k=e.log or u;
end
return i,{reset=a,set_session=o};
end
function new(e,t)
local t,a=new_sax_handlers(e,t);
local e=w(t,s);
local o=e.parse;
return{
reset=function()
e=w(t,s);
o=e.parse;
a.reset();
end,
feed=function(a,t)
return o(e,t);
end,
set_session=a.set_session;
};
end
return _M;
end)
package.preload['util.jid']=(function(...)
local a=string.match;
local s=require"util.encodings".stringprep.nodeprep;
local h=require"util.encodings".stringprep.nameprep;
local r=require"util.encodings".stringprep.resourceprep;
local n={
[" "]="\\20";['"']="\\22";
["&"]="\\26";["'"]="\\27";
["/"]="\\2f";[":"]="\\3a";
["<"]="\\3c";[">"]="\\3e";
["@"]="\\40";["\\"]="\\5c";
};
local o={};
for e,t in pairs(n)do o[t]=e;end
module"jid"
local function t(e)
if not e then return;end
local o,t=a(e,"^([^@/]+)@()");
local t,i=a(e,"^([^@/]+)()",t)
if o and not t then return nil,nil,nil;end
local a=a(e,"^/(.+)$",i);
if(not t)or((not a)and#e>=i)then return nil,nil,nil;end
return o,t,a;
end
split=t;
function bare(e)
local t,e=t(e);
if t and e then
return t.."@"..e;
end
return e;
end
local function i(e)
local a,e,t=t(e);
if e then
e=h(e);
if not e then return;end
if a then
a=s(a);
if not a then return;end
end
if t then
t=r(t);
if not t then return;end
end
return a,e,t;
end
end
prepped_split=i;
function prep(e)
local a,e,t=i(e);
if e then
if a then
e=a.."@"..e;
end
if t then
e=e.."/"..t;
end
end
return e;
end
function join(a,e,t)
if a and e and t then
return a.."@"..e.."/"..t;
elseif a and e then
return a.."@"..e;
elseif e and t then
return e.."/"..t;
elseif e then
return e;
end
return nil;
end
function compare(a,e)
local o,i,n=t(a);
local e,a,t=t(e);
if((e~=nil and e==o)or e==nil)and
((a~=nil and a==i)or a==nil)and
((t~=nil and t==n)or t==nil)then
return true
end
return false
end
function escape(e)return e and(e:gsub(".",n));end
function unescape(e)return e and(e:gsub("\\%x%x",o));end
return _M;
end)
package.preload['util.events']=(function(...)
local i=pairs;
local s=table.insert;
local r=table.sort;
local h=setmetatable;
local n=next;
module"events"
function new()
local t={};
local e={};
local function o(o,a)
local e=e[a];
if not e or n(e)==nil then return;end
local t={};
for e in i(e)do
s(t,e);
end
r(t,function(a,t)return e[a]>e[t];end);
o[a]=t;
return t;
end;
h(t,{__index=o});
local function s(o,i,n)
local a=e[o];
if a then
a[i]=n or 0;
else
a={[i]=n or 0};
e[o]=a;
end
t[o]=nil;
end;
local function h(a,i)
local o=e[a];
if o then
o[i]=nil;
t[a]=nil;
if n(o)==nil then
e[a]=nil;
end
end
end;
local function o(e)
for t,e in i(e)do
s(t,e);
end
end;
local function n(e)
for e,t in i(e)do
h(e,t);
end
end;
local function a(e,...)
local e=t[e];
if e then
for t=1,#e do
local e=e[t](...);
if e~=nil then return e;end
end
end
end;
return{
add_handler=s;
remove_handler=h;
add_handlers=o;
remove_handlers=n;
fire_event=a;
_handlers=t;
_event_map=e;
};
end
return _M;
end)
package.preload['util.dataforms']=(function(...)
local e=setmetatable;
local t,i=pairs,ipairs;
local r,h,l=tostring,type,next;
local s=table.concat;
local u=require"util.stanza";
local d=require"util.jid".prep;
module"dataforms"
local c='jabber:x:data';
local n={};
local t={__index=n};
function new(a)
return e(a,t);
end
function from_stanza(e)
local o={
title=e:get_child_text("title");
instructions=e:get_child_text("instructions");
};
for t in e:childtags("field")do
local a={
name=t.attr.var;
label=t.attr.label;
type=t.attr.type;
required=t:get_child("required")and true or nil;
value=t:get_child_text("value");
};
o[#o+1]=a;
if a.type then
local e={};
if a.type:match"list%-"then
for t in t:childtags("option")do
e[#e+1]={label=t.attr.label,value=t:get_child_text("value")};
end
for t in t:childtags("value")do
e[#e+1]={label=t.attr.label,value=t:get_text(),default=true};
end
elseif a.type:match"%-multi"then
for t in t:childtags("value")do
e[#e+1]=t.attr.label and{label=t.attr.label,value=t:get_text()}or t:get_text();
end
if a.type=="text-multi"then
a.value=s(e,"\n");
else
a.value=e;
end
end
end
end
return new(o);
end
function n.form(t,a,e)
local e=u.stanza("x",{xmlns=c,type=e or"form"});
if t.title then
e:tag("title"):text(t.title):up();
end
if t.instructions then
e:tag("instructions"):text(t.instructions):up();
end
for t,o in i(t)do
local t=o.type or"text-single";
e:tag("field",{type=t,var=o.name,label=o.label});
local a=(a and a[o.name])or o.value;
if a then
if t=="hidden"then
if h(a)=="table"then
e:tag("value")
:add_child(a)
:up();
else
e:tag("value"):text(r(a)):up();
end
elseif t=="boolean"then
e:tag("value"):text((a and"1")or"0"):up();
elseif t=="fixed"then
elseif t=="jid-multi"then
for a,t in i(a)do
e:tag("value"):text(t):up();
end
elseif t=="jid-single"then
e:tag("value"):text(a):up();
elseif t=="text-single"or t=="text-private"then
e:tag("value"):text(a):up();
elseif t=="text-multi"then
for t in a:gmatch("([^\r\n]+)\r?\n*")do
e:tag("value"):text(t):up();
end
elseif t=="list-single"then
local o=false;
for a,t in i(a)do
if h(t)=="table"then
e:tag("option",{label=t.label}):tag("value"):text(t.value):up():up();
if t.default and(not o)then
e:tag("value"):text(t.value):up();
o=true;
end
else
e:tag("option",{label=t}):tag("value"):text(r(t)):up():up();
end
end
elseif t=="list-multi"then
for a,t in i(a)do
if h(t)=="table"then
e:tag("option",{label=t.label}):tag("value"):text(t.value):up():up();
if t.default then
e:tag("value"):text(t.value):up();
end
else
e:tag("option",{label=t}):tag("value"):text(r(t)):up():up();
end
end
end
end
if o.required then
e:tag("required"):up();
end
e:up();
end
return e;
end
local e={};
function n.data(t,s)
local n={};
local a={};
for o,t in i(t)do
local o;
for e in s:childtags()do
if t.name==e.attr.var then
o=e;
break;
end
end
if not o then
if t.required then
a[t.name]="Required value missing";
end
else
local e=e[t.type];
if e then
n[t.name],a[t.name]=e(o,t.required);
end
end
end
if l(a)then
return n,a;
end
return n;
end
e["text-single"]=
function(t,a)
local t=t:get_child_text("value");
if t and#t>0 then
return t
elseif a then
return nil,"Required value missing";
end
end
e["text-private"]=
e["text-single"];
e["jid-single"]=
function(t,o)
local a=t:get_child_text("value")
local t=d(a);
if t and#t>0 then
return t
elseif a then
return nil,"Invalid JID: "..a;
elseif o then
return nil,"Required value missing";
end
end
e["jid-multi"]=
function(o,i)
local t={};
local a={};
for e in o:childtags("value")do
local e=e:get_text();
local o=d(e);
t[#t+1]=o;
if e and not o then
a[#a+1]=("Invalid JID: "..e);
end
end
if#t>0 then
return t,(#a>0 and s(a,"\n")or nil);
elseif i then
return nil,"Required value missing";
end
end
e["list-multi"]=
function(a,o)
local t={};
for e in a:childtags("value")do
t[#t+1]=e:get_text();
end
return t,(o and#t==0 and"Required value missing"or nil);
end
e["text-multi"]=
function(a,t)
local t,a=e["list-multi"](a,t);
if t then
t=s(t,"\n");
end
return t,a;
end
e["list-single"]=
e["text-single"];
local a={
["1"]=true,["true"]=true,
["0"]=false,["false"]=false,
};
e["boolean"]=
function(t,o)
local t=t:get_child_text("value");
local a=a[t~=nil and t];
if a~=nil then
return a;
elseif t then
return nil,"Invalid boolean representation";
elseif o then
return nil,"Required value missing";
end
end
e["hidden"]=
function(e)
return e:get_child_text("value");
end
return _M;
end)
package.preload['util.caps']=(function(...)
local l=require"util.encodings".base64.encode;
local d=require"util.hashes".sha1;
local n,h,s=table.insert,table.sort,table.concat;
local r=ipairs;
module"caps"
function calculate_hash(e)
local a,o,i={},{},{};
for t,e in r(e)do
if e.name=="identity"then
n(a,(e.attr.category or"").."\0"..(e.attr.type or"").."\0"..(e.attr["xml:lang"]or"").."\0"..(e.attr.name or""));
elseif e.name=="feature"then
n(o,e.attr.var or"");
elseif e.name=="x"and e.attr.xmlns=="jabber:x:data"then
local t={};
local o;
for a,e in r(e.tags)do
if e.name=="field"and e.attr.var then
local a={};
for t,e in r(e.tags)do
e=#e.tags==0 and e:get_text();
if e then n(a,e);end
end
h(a);
if e.attr.var=="FORM_TYPE"then
o=a[1];
elseif#a>0 then
n(t,e.attr.var.."\0"..s(a,"<"));
else
n(t,e.attr.var);
end
end
end
h(t);
t=s(t,"<");
if o then t=o.."\0"..t;end
n(i,t);
end
end
h(a);
h(o);
h(i);
if#a>0 then a=s(a,"<"):gsub("%z","/").."<";else a="";end
if#o>0 then o=s(o,"<").."<";else o="";end
if#i>0 then i=s(i,"<"):gsub("%z","<").."<";else i="";end
local e=a..o..i;
local t=l(d(e));
return t,e;
end
return _M;
end)
package.preload['util.vcard']=(function(...)
local n=require"util.stanza";
local a,d=table.insert,table.concat;
local r=type;
local e,h,f=next,pairs,ipairs;
local l,c,u,m;
local w="\n";
local i;
local function e()
error"Not implemented"
end
local function e()
error"Not implemented"
end
local function y(e)
return e:gsub("[,:;\\]","\\%1"):gsub("\n","\\n");
end
local function p(e)
return e:gsub("\\?[\\nt:;,]",{
["\\\\"]="\\",
["\\n"]="\n",
["\\r"]="\r",
["\\t"]="\t",
["\\:"]=":",
["\\;"]=";",
["\\,"]=",",
[":"]="\29",
[";"]="\30",
[","]="\31",
});
end
local function s(t)
local a=n.stanza(t.name,{xmlns="vcard-temp"});
local e=i[t.name];
if e=="text"then
a:text(t[1]);
elseif r(e)=="table"then
if e.types and t.TYPE then
if r(t.TYPE)=="table"then
for o,e in h(e.types)do
for o,t in h(t.TYPE)do
if t:upper()==e then
a:tag(e):up();
break;
end
end
end
else
a:tag(t.TYPE:upper()):up();
end
end
if e.props then
for o,e in h(e.props)do
if t[e]then
a:tag(e):up();
end
end
end
if e.value then
a:tag(e.value):text(t[1]):up();
elseif e.values then
local o=e.values;
local i=o.behaviour=="repeat-last"and o[#o];
for o=1,#t do
a:tag(e.values[o]or i):text(t[o]):up();
end
end
end
return a;
end
local function o(t)
local e=n.stanza("vCard",{xmlns="vcard-temp"});
for a=1,#t do
e:add_child(s(t[a]));
end
return e;
end
function m(e)
if not e[1]or e[1].name then
return o(e)
else
local t=n.stanza("xCard",{xmlns="vcard-temp"});
for a=1,#e do
t:add_child(o(e[a]));
end
return t;
end
end
function l(t)
t=t
:gsub("\r\n","\n")
:gsub("\n ","")
:gsub("\n\n+","\n");
local h={};
local e;
for t in t:gmatch("[^\n]+")do
local t=p(t);
local s,t,n=t:match("^([-%a]+)(\30?[^\29]*)\29(.*)$");
n=n:gsub("\29",":");
if#t>0 then
local o={};
for a,i,n in t:gmatch("\30([^=]+)(=?)([^\30]*)")do
a=a:upper();
local e={};
for t in n:gmatch("[^\31]+")do
e[#e+1]=t
e[t]=true;
end
if i=="="then
o[a]=e;
else
o[a]=true;
end
end
t=o;
end
if s=="BEGIN"and n=="VCARD"then
e={};
h[#h+1]=e;
elseif s=="END"and n=="VCARD"then
e=nil;
elseif e and i[s]then
local o=i[s];
local i={name=s};
e[#e+1]=i;
local s=e;
e=i;
if o.types then
for o,a in f(o.types)do
local a=a:lower();
if(t.TYPE and t.TYPE[a]==true)
or t[a]==true then
e.TYPE=a;
end
end
end
if o.props then
for o,a in f(o.props)do
if t[a]then
if t[a]==true then
e[a]=true;
else
for o,t in f(t[a])do
e[a]=t;
end
end
end
end
end
if o=="text"or o.value then
a(e,n);
elseif o.values then
local t="\30"..n;
for t in t:gmatch("\30([^\30]*)")do
a(e,t);
end
end
e=s;
end
end
return h;
end
local function n(t)
local e={};
for a=1,#t do
e[a]=y(t[a]);
end
e=d(e,";");
local a="";
for t,e in h(t)do
if r(t)=="string"and t~="name"then
a=a..(";%s=%s"):format(t,r(e)=="table"and d(e,",")or e);
end
end
return("%s%s:%s"):format(t.name,a,e)
end
local function o(t)
local e={};
a(e,"BEGIN:VCARD")
for o=1,#t do
a(e,n(t[o]));
end
a(e,"END:VCARD")
return d(e,w);
end
function c(e)
if e[1]and e[1].name then
return o(e)
else
local t={};
for a=1,#e do
t[a]=o(e[a]);
end
return d(t,w);
end
end
local function n(o)
local t=o.name;
local e=i[t];
local t={name=t};
if e=="text"then
t[1]=o:get_text();
elseif r(e)=="table"then
if e.value then
t[1]=o:get_child_text(e.value)or"";
elseif e.values then
local e=e.values;
if e.behaviour=="repeat-last"then
for e=1,#o.tags do
a(t,o.tags[e]:get_text()or"");
end
else
for i=1,#e do
a(t,o:get_child_text(e[i])or"");
end
end
elseif e.names then
local e=e.names;
for a=1,#e do
if o:get_child(e[a])then
t[1]=e[a];
break;
end
end
end
if e.props_verbatim then
for e,a in h(e.props_verbatim)do
t[e]=a;
end
end
if e.types then
local e=e.types;
t.TYPE={};
for i=1,#e do
if o:get_child(e[i])then
a(t.TYPE,e[i]:lower());
end
end
if#t.TYPE==0 then
t.TYPE=nil;
end
end
if e.props then
local e=e.props;
for i=1,#e do
local e=e[i]
local o=o:get_child_text(e);
if o then
t[e]=t[e]or{};
a(t[e],o);
end
end
end
else
return nil
end
return t;
end
local function o(e)
local e=e.tags;
local t={};
for o=1,#e do
a(t,n(e[o]));
end
return t
end
function u(e)
if e.attr.xmlns~="vcard-temp"then
return nil,"wrong-xmlns";
end
if e.name=="xCard"then
local t={};
local a=e.tags;
for e=1,#a do
t[e]=o(a[e]);
end
return t
elseif e.name=="vCard"then
return o(e)
end
end
i={
VERSION="text",
FN="text",
N={
values={
"FAMILY",
"GIVEN",
"MIDDLE",
"PREFIX",
"SUFFIX",
},
},
NICKNAME="text",
PHOTO={
props_verbatim={ENCODING={"b"}},
props={"TYPE"},
value="BINVAL",
},
BDAY="text",
ADR={
types={
"HOME",
"WORK",
"POSTAL",
"PARCEL",
"DOM",
"INTL",
"PREF",
},
values={
"POBOX",
"EXTADD",
"STREET",
"LOCALITY",
"REGION",
"PCODE",
"CTRY",
}
},
LABEL={
types={
"HOME",
"WORK",
"POSTAL",
"PARCEL",
"DOM",
"INTL",
"PREF",
},
value="LINE",
},
TEL={
types={
"HOME",
"WORK",
"VOICE",
"FAX",
"PAGER",
"MSG",
"CELL",
"VIDEO",
"BBS",
"MODEM",
"ISDN",
"PCS",
"PREF",
},
value="NUMBER",
},
EMAIL={
types={
"HOME",
"WORK",
"INTERNET",
"PREF",
"X400",
},
value="USERID",
},
JABBERID="text",
MAILER="text",
TZ="text",
GEO={
values={
"LAT",
"LON",
},
},
TITLE="text",
ROLE="text",
LOGO="copy of PHOTO",
AGENT="text",
ORG={
values={
behaviour="repeat-last",
"ORGNAME",
"ORGUNIT",
}
},
CATEGORIES={
values="KEYWORD",
},
NOTE="text",
PRODID="text",
REV="text",
SORTSTRING="text",
SOUND="copy of PHOTO",
UID="text",
URL="text",
CLASS={
names={
"PUBLIC",
"PRIVATE",
"CONFIDENTIAL",
},
},
KEY={
props={"TYPE"},
value="CRED",
},
DESC="text",
};
i.LOGO=i.PHOTO;
i.SOUND=i.PHOTO;
return{
from_text=l;
to_text=c;
from_xep54=u;
to_xep54=m;
lua_to_text=c;
lua_to_xep54=m;
text_to_lua=l;
text_to_xep54=function(...)return m(l(...));end;
xep54_to_lua=u;
xep54_to_text=function(...)return c(u(...))end;
};
end)
package.preload['util.logger']=(function(...)
local e=pcall;
local e=string.find;
local e,n,e=ipairs,pairs,setmetatable;
module"logger"
local e,t={},{};
local a={};
local o;
function init(e)
local s=o(e,"debug");
local i=o(e,"info");
local n=o(e,"warn");
local a=o(e,"error");
local e=#e;
return function(e,t,...)
if e=="debug"then
return s(t,...);
elseif e=="info"then
return i(t,...);
elseif e=="warn"then
return n(t,...);
elseif e=="error"then
return a(t,...);
end
end
end
function o(i,o)
local a=t[o];
if not a then
a={};
t[o]=a;
end
local e=e[i];
local e=function(t,...)
if e then
for a=1,#e do
if e[a](i,o,t,...)==false then
return;
end
end
end
for e=1,#a do
a[e](i,o,t,...);
end
end
return e;
end
function reset()
for t in n(e)do e[t]=nil;end
for t,e in n(t)do
for t=1,#e do
e[t]=nil;
end
end
for e in n(a)do a[e]=nil;end
end
function add_level_sink(e,a)
if not t[e]then
t[e]={a};
else
t[e][#t[e]+1]=a;
end
end
function add_name_sink(t,a,o)
if not e[t]then
e[t]={a};
else
e[t][#e[t]+1]=a;
end
end
function add_name_pattern_sink(e,t,o)
if not a[e]then
a[e]={t};
else
a[e][#a[e]+1]=t;
end
end
_M.new=o;
return _M;
end)
package.preload['util.datetime']=(function(...)
local e=os.date;
local n=os.time;
local u=os.difftime;
local t=error;
local r=tonumber;
module"datetime"
function date(t)
return e("!%Y-%m-%d",t);
end
function datetime(t)
return e("!%Y-%m-%dT%H:%M:%SZ",t);
end
function time(t)
return e("!%H:%M:%S",t);
end
function legacy(t)
return e("!%Y%m%dT%H:%M:%S",t);
end
function parse(a)
if a then
local i,s,h,l,d,t,o;
i,s,h,l,d,t,o=a:match("^(%d%d%d%d)-?(%d%d)-?(%d%d)T(%d%d):(%d%d):(%d%d)%.?%d*([Z+%-].*)$");
if i then
local u=u(n(e("*t")),n(e("!*t")));
local a=0;
if o~=""and o~="Z"then
local o,t,e=o:match("([+%-])(%d%d):?(%d*)");
if not o then return;end
if#e~=2 then e="0";end
t,e=r(t),r(e);
a=t*60*60+e*60;
if o=="-"then a=-a;end
end
t=(t+u)-a;
return n({year=i,month=s,day=h,hour=l,min=d,sec=t,isdst=false});
end
end
end
return _M;
end)
package.preload['verse.plugins.tls']=(function(...)
local a=require"verse";
local t="urn:ietf:params:xml:ns:xmpp-tls";
function a.plugins.tls(e)
local function i(o)
if e.authenticated then return;end
if o:get_child("starttls",t)and e.conn.starttls then
e:debug("Negotiating TLS...");
e:send(a.stanza("starttls",{xmlns=t}));
return true;
elseif not e.conn.starttls and not e.secure then
e:warn("SSL libary (LuaSec) not loaded, so TLS not available");
elseif not e.secure then
e:debug("Server doesn't offer TLS :(");
end
end
local function a(t)
if t.name=="proceed"then
e:debug("Server says proceed, handshake starting...");
e.conn:starttls({mode="client",protocol="sslv23",options="no_sslv2"},true);
end
end
local function o(t)
if t=="ssl-handshake-complete"then
e.secure=true;
e:debug("Re-opening stream...");
e:reopen();
end
end
e:hook("stream-features",i,400);
e:hook("stream/"..t,a);
e:hook("status",o,400);
return true;
end
end)
package.preload['verse.plugins.sasl']=(function(...)
local i=require"mime".b64;
local o="urn:ietf:params:xml:ns:xmpp-sasl";
function verse.plugins.sasl(e)
local function n(t)
if e.authenticated then return;end
e:debug("Authenticating with SASL...");
local t,a
if e.username then
t="PLAIN"
a=i("\0"..e.username.."\0"..e.password);
else
t="ANONYMOUS"
end
e:debug("Selecting %s mechanism...",t);
local t=verse.stanza("auth",{xmlns=o,mechanism=t});
if a then
t:text(a);
end
e:send(t);
return true;
end
local function i(t)
if t.name=="success"then
e.authenticated=true;
e:event("authentication-success");
elseif t.name=="failure"then
local a=t.tags[1];
local t=t:get_child_text("text");
e:event("authentication-failure",{condition=a.name,text=t});
end
e:reopen();
return true;
end
e:hook("stream-features",n,300);
e:hook("stream/"..o,i);
return true;
end
end)
package.preload['verse.plugins.bind']=(function(...)
local t=require"verse";
local i=require"util.jid";
local a="urn:ietf:params:xml:ns:xmpp-bind";
function t.plugins.bind(e)
local function o(o)
if e.bound then return;end
e:debug("Binding resource...");
e:send_iq(t.iq({type="set"}):tag("bind",{xmlns=a}):tag("resource"):text(e.resource),
function(t)
if t.attr.type=="result"then
local t=t
:get_child("bind",a)
:get_child_text("jid");
e.username,e.host,e.resource=i.split(t);
e.jid,e.bound=t,true;
e:event("bind-success",{jid=t});
elseif t.attr.type=="error"then
local a=t:child_with_name("error");
local a,t,o=t:get_error();
e:event("bind-failure",{error=t,text=o,type=a});
end
end);
end
e:hook("stream-features",o,200);
return true;
end
end)
package.preload['verse.plugins.session']=(function(...)
local t=require"verse";
local a="urn:ietf:params:xml:ns:xmpp-session";
function t.plugins.session(e)
local function i(o)
local o=o:get_child("session",a);
if o and not o:get_child("optional")then
local function o(o)
e:debug("Establishing Session...");
e:send_iq(t.iq({type="set"}):tag("session",{xmlns=a}),
function(t)
if t.attr.type=="result"then
e:event("session-success");
elseif t.attr.type=="error"then
local a=t:child_with_name("error");
local o,a,t=t:get_error();
e:event("session-failure",{error=a,text=t,type=o});
end
end);
return true;
end
e:hook("bind-success",o);
end
end
e:hook("stream-features",i);
return true;
end
end)
package.preload['verse.plugins.legacy']=(function(...)
local i=require"verse";
local n=require"util.uuid".generate;
local o="jabber:iq:auth";
function i.plugins.legacy(e)
function handle_auth_form(t)
local a=t:get_child("query",o);
if t.attr.type~="result"or not a then
local t,a,o=t:get_error();
e:debug("warn","%s %s: %s",t,a,o);
end
local t={
username=e.username;
password=e.password;
resource=e.resource or n();
digest=false,sequence=false,token=false;
};
local o=i.iq({to=e.host,type="set"})
:tag("query",{xmlns=o});
if#a>0 then
for a in a:childtags()do
local a=a.name;
local i=t[a];
if i then
o:tag(a):text(t[a]):up();
elseif i==nil then
local t="feature-not-implemented";
e:event("authentication-failure",{condition=t});
return false;
end
end
else
for t,e in pairs(t)do
if e then
o:tag(t):text(e):up();
end
end
end
e:send_iq(o,function(a)
if a.attr.type=="result"then
e.resource=t.resource;
e.jid=t.username.."@"..e.host.."/"..t.resource;
e:event("authentication-success");
e:event("bind-success",e.jid);
else
local a,t,a=a:get_error();
e:event("authentication-failure",{condition=t});
end
end);
end
function handle_opened(t)
if not t.version then
e:send_iq(i.iq({type="get"})
:tag("query",{xmlns="jabber:iq:auth"})
:tag("username"):text(e.username),
handle_auth_form);
end
end
e:hook("opened",handle_opened);
end
end)
package.preload['verse.plugins.compression']=(function(...)
local t=require"verse";
local i=require"zlib";
local e="http://jabber.org/features/compress"
local a="http://jabber.org/protocol/compress"
local e="http://etherx.jabber.org/streams";
local e=9;
local function r(o)
local i,e=pcall(i.deflate,e);
if i==false then
local t=t.stanza("failure",{xmlns=a}):tag("setup-failed");
o:send(t);
o:error("Failed to create zlib.deflate filter: %s",tostring(e));
return
end
return e
end
local function d(e)
local i,o=pcall(i.inflate);
if i==false then
local t=t.stanza("failure",{xmlns=a}):tag("setup-failed");
e:send(t);
e:error("Failed to create zlib.inflate filter: %s",tostring(o));
return
end
return o
end
local function l(e,i)
function e:send(o)
local i,o,n=pcall(i,tostring(o),'sync');
if i==false then
e:close({
condition="undefined-condition";
text=o;
extra=t.stanza("failure",{xmlns=a}):tag("processing-failed");
});
e:warn("Compressed send failed: %s",tostring(o));
return;
end
e.conn:write(o);
end;
end
local function h(e,n)
local s=e.data
e.data=function(i,o)
e:debug("Decompressing data...");
local n,o,h=pcall(n,o);
if n==false then
e:close({
condition="undefined-condition";
text=o;
extra=t.stanza("failure",{xmlns=a}):tag("processing-failed");
});
stream:warn("%s",tostring(o));
return;
end
return s(i,o);
end;
end
function t.plugins.compression(e)
local function i(o)
if not e.compressed then
local o=o:child_with_name("compression");
if o then
for o in o:children()do
local o=o[1]
if o=="zlib"then
e:send(t.stanza("compress",{xmlns=a}):tag("method"):text("zlib"))
e:debug("Enabled compression using zlib.")
return true;
end
end
session:debug("Remote server supports no compression algorithm we support.")
end
end
end
local function o(a)
if a.name=="compressed"then
e:debug("Activating compression...")
local a=r(e);
if not a then return end
local t=d(e);
if not t then return end
l(e,a);
h(e,t);
e.compressed=true;
e:reopen();
elseif a.name=="failure"then
e:warn("Failed to establish compression");
end
end
e:hook("stream-features",i,250);
e:hook("stream/"..a,o);
end
end)
package.preload['verse.plugins.smacks']=(function(...)
local n=require"verse";
local h=socket.gettime;
local s="urn:xmpp:sm:2";
function n.plugins.smacks(e)
local t={};
local o=0;
local r=h();
local a;
local i=0;
local function d(t)
if t.attr.xmlns=="jabber:client"or not t.attr.xmlns then
i=i+1;
e:debug("Increasing handled stanzas to %d for %s",i,t:top_tag());
end
end
function outgoing_stanza(o)
if o.name and not o.attr.xmlns then
t[#t+1]=tostring(o);
r=h();
if not a then
a=true;
e:debug("Waiting to send ack request...");
n.add_task(1,function()
if#t==0 then
a=false;
return;
end
local o=h()-r;
if o<1 and#t<10 then
return 1-o;
end
e:debug("Time up, sending <r>...");
a=false;
e:send(n.stanza("r",{xmlns=s}));
end);
end
end
end
local function h()
e:debug("smacks: connection lost");
e.stream_management_supported=nil;
if e.resumption_token then
e:debug("smacks: have resumption token, reconnecting in 1s...");
e.authenticated=nil;
n.add_task(1,function()
e:connect(e.connect_host or e.host,e.connect_port or 5222);
end);
return true;
end
end
local function r()
e.resumption_token=nil;
e:unhook("disconnected",h);
end
local function l(a)
if a.name=="r"then
e:debug("Ack requested... acking %d handled stanzas",i);
e:send(n.stanza("a",{xmlns=s,h=tostring(i)}));
elseif a.name=="a"then
local a=tonumber(a.attr.h);
if a>o then
local i=#t;
for a=o+1,a do
table.remove(t,1);
end
e:debug("Received ack: New ack: "..a.." Last ack: "..o.." Unacked stanzas now: "..#t.." (was "..i..")");
o=a;
else
e:warn("Received bad ack for "..a.." when last ack was "..o);
end
elseif a.name=="enabled"then
if a.attr.id then
e.resumption_token=a.attr.id;
e:hook("closed",r,100);
e:hook("disconnected",h,100);
end
elseif a.name=="resumed"then
local a=tonumber(a.attr.h);
if a>o then
local i=#t;
for a=o+1,a do
table.remove(t,1);
end
e:debug("Received ack: New ack: "..a.." Last ack: "..o.." Unacked stanzas now: "..#t.." (was "..i..")");
o=a;
end
for a=1,#t do
e:send(t[a]);
end
t={};
e:debug("Resumed successfully");
e:event("resumed");
else
e:warn("Don't know how to handle "..s.."/"..a.name);
end
end
local function a()
if not e.smacks then
e:debug("smacks: sending enable");
e:send(n.stanza("enable",{xmlns=s,resume="true"}));
e.smacks=true;
e:hook("stanza",d);
e:hook("outgoing",outgoing_stanza);
end
end
local function o(t)
if t:get_child("sm",s)then
e.stream_management_supported=true;
if e.smacks and e.bound then
e:debug("Resuming stream with %d handled stanzas",i);
e:send(n.stanza("resume",{xmlns=s,
h=i,previd=e.resumption_token}));
return true;
else
e:hook("bind-success",a,1);
end
end
end
e:hook("stream-features",o,250);
e:hook("stream/"..s,l);
end
end)
package.preload['verse.plugins.keepalive']=(function(...)
local t=require"verse";
function t.plugins.keepalive(e)
e.keepalive_timeout=e.keepalive_timeout or 300;
t.add_task(e.keepalive_timeout,function()
e.conn:write(" ");
return e.keepalive_timeout;
end);
end
end)
package.preload['verse.plugins.disco']=(function(...)
local a=require"verse";
local r=require("mime").b64;
local s=require("util.sha1").sha1;
local n="http://jabber.org/protocol/caps";
local e="http://jabber.org/protocol/disco";
local o=e.."#info";
local i=e.."#items";
function a.plugins.disco(e)
e:add_plugin("presence");
local t={
__index=function(t,e)
local a={identities={},features={}};
if e=="identities"or e=="features"then
return t[false][e]
end
t[e]=a;
return a;
end,
};
local h={
__index=function(t,a)
local e={};
t[a]=e;
return e;
end,
};
e.disco={
cache={},
info=setmetatable({
[false]={
identities={
{category='client',type='pc',name='Verse'},
},
features={
[n]=true,
[o]=true,
[i]=true,
},
},
},t);
items=setmetatable({[false]={}},h);
};
e.caps={}
e.caps.node='http://code.matthewwild.co.uk/verse/'
local function h(t,e)
if t.category<e.category then
return true;
elseif e.category<t.category then
return false;
end
if t.type<e.type then
return true;
elseif e.type<t.type then
return false;
end
if(not t['xml:lang']and e['xml:lang'])or
(e['xml:lang']and t['xml:lang']<e['xml:lang'])then
return true
end
return false
end
local function d(e,t)
return e.var<t.var
end
local function l(t)
local o=e.disco.info[t or false].identities;
table.sort(o,h)
local a={};
for e in pairs(e.disco.info[t or false].features)do
a[#a+1]={var=e};
end
table.sort(a,d)
local e={};
for a,t in pairs(o)do
e[#e+1]=table.concat({
t.category,t.type or'',
t['xml:lang']or'',t.name or''
},'/');
end
for a,t in pairs(a)do
e[#e+1]=t.var
end
e[#e+1]='';
e=table.concat(e,'<');
return(r(s(e)))
end
setmetatable(e.caps,{
__call=function(...)
local t=l()
e.caps.hash=t;
return a.stanza('c',{
xmlns=n,
hash='sha-1',
node=e.caps.node,
ver=t
})
end
})
function e:set_identity(t,a)
self.disco.info[a or false].identities={t};
e:resend_presence();
end
function e:add_identity(a,t)
local t=self.disco.info[t or false].identities;
t[#t+1]=a;
e:resend_presence();
end
function e:add_disco_feature(t,a)
local t=t.var or t;
self.disco.info[a or false].features[t]=true;
e:resend_presence();
end
function e:remove_disco_feature(t,a)
local t=t.var or t;
self.disco.info[a or false].features[t]=nil;
e:resend_presence();
end
function e:add_disco_item(t,e)
local e=self.disco.items[e or false];
e[#e+1]=t;
end
function e:remove_disco_item(a,e)
local e=self.disco.items[e or false];
for t=#e,1,-1 do
if e[t]==a then
table.remove(e,t);
end
end
end
function e:jid_has_identity(e,t,a)
local o=self.disco.cache[e];
if not o then
return nil,"no-cache";
end
local e=self.disco.cache[e].identities;
if a then
return e[t.."/"..a]or false;
end
for e in pairs(e)do
if e:match("^(.*)/")==t then
return true;
end
end
end
function e:jid_supports(e,t)
local e=self.disco.cache[e];
if not e or not e.features then
return nil,"no-cache";
end
return e.features[t]or false;
end
function e:get_local_services(a,o)
local e=self.disco.cache[self.host];
if not(e)or not(e.items)then
return nil,"no-cache";
end
local t={};
for i,e in ipairs(e.items)do
if self:jid_has_identity(e.jid,a,o)then
table.insert(t,e.jid);
end
end
return t;
end
function e:disco_local_services(a)
self:disco_items(self.host,nil,function(t)
if not t then
return a({});
end
local e=0;
local function o()
e=e-1;
if e==0 then
return a(t);
end
end
for a,t in ipairs(t)do
if t.jid then
e=e+1;
self:disco_info(t.jid,nil,o);
end
end
if e==0 then
return a(t);
end
end);
end
function e:disco_info(e,t,s)
local a=a.iq({to=e,type="get"})
:tag("query",{xmlns=o,node=t});
self:send_iq(a,function(n)
if n.attr.type=="error"then
return s(nil,n:get_error());
end
local a,i={},{};
for e in n:get_child("query",o):childtags()do
if e.name=="identity"then
a[e.attr.category.."/"..e.attr.type]=e.attr.name or true;
elseif e.name=="feature"then
i[e.attr.var]=true;
end
end
if not self.disco.cache[e]then
self.disco.cache[e]={nodes={}};
end
if t then
if not self.disco.cache[e].nodes[t]then
self.disco.cache[e].nodes[t]={nodes={}};
end
self.disco.cache[e].nodes[t].identities=a;
self.disco.cache[e].nodes[t].features=i;
else
self.disco.cache[e].identities=a;
self.disco.cache[e].features=i;
end
return s(self.disco.cache[e]);
end);
end
function e:disco_items(t,o,n)
local a=a.iq({to=t,type="get"})
:tag("query",{xmlns=i,node=o});
self:send_iq(a,function(e)
if e.attr.type=="error"then
return n(nil,e:get_error());
end
local a={};
for e in e:get_child("query",i):childtags()do
if e.name=="item"then
table.insert(a,{
name=e.attr.name;
jid=e.attr.jid;
node=e.attr.node;
});
end
end
if not self.disco.cache[t]then
self.disco.cache[t]={nodes={}};
end
if o then
if not self.disco.cache[t].nodes[o]then
self.disco.cache[t].nodes[o]={nodes={}};
end
self.disco.cache[t].nodes[o].items=a;
else
self.disco.cache[t].items=a;
end
return n(a);
end);
end
e:hook("iq/"..o,function(i)
local t=i.tags[1];
if i.attr.type=='get'and t.name=="query"then
local t=t.attr.node;
local n=e.disco.info[t or false];
if t and t==e.caps.node.."#"..e.caps.hash then
n=e.disco.info[false];
end
local n,s=n.identities,n.features
local t=a.reply(i):tag("query",{
xmlns=o,
node=t,
});
for a,e in pairs(n)do
t:tag('identity',e):up()
end
for a in pairs(s)do
t:tag('feature',{var=a}):up()
end
e:send(t);
return true
end
end);
e:hook("iq/"..i,function(o)
local t=o.tags[1];
if o.attr.type=='get'and t.name=="query"then
local n=e.disco.items[t.attr.node or false];
local t=a.reply(o):tag('query',{
xmlns=i,
node=t.attr.node
})
for a=1,#n do
t:tag('item',n[a]):up()
end
e:send(t);
return true
end
end);
local t;
e:hook("ready",function()
if t then return;end
t=true;
e:disco_local_services(function(t)
for t,a in ipairs(t)do
local t=e.disco.cache[a.jid];
if t then
for t in pairs(t.identities)do
local t,o=t:match("^(.*)/(.*)$");
e:event("disco/service-discovered/"..t,{
type=o,jid=a.jid;
});
end
end
end
e:event("ready");
end);
return true;
end,50);
e:hook("presence-out",function(t)
if not t:get_child("c",n)then
t:reset():add_child(e:caps()):reset();
end
end,10);
end
end)
package.preload['verse.plugins.version']=(function(...)
local o=require"verse";
local a="jabber:iq:version";
local function i(t,e)
t.name=e.name;
t.version=e.version;
t.platform=e.platform;
end
function o.plugins.version(e)
e.version={set=i};
e:hook("iq/"..a,function(t)
if t.attr.type~="get"then return;end
local t=o.reply(t)
:tag("query",{xmlns=a});
if e.version.name then
t:tag("name"):text(tostring(e.version.name)):up();
end
if e.version.version then
t:tag("version"):text(tostring(e.version.version)):up()
end
if e.version.platform then
t:tag("os"):text(e.version.platform);
end
e:send(t);
return true;
end);
function e:query_version(i,t)
t=t or function(t)return e:event("version/response",t);end
e:send_iq(o.iq({type="get",to=i})
:tag("query",{xmlns=a}),
function(o)
if o.attr.type=="result"then
local e=o:get_child("query",a);
local o=e and e:get_child_text("name");
local a=e and e:get_child_text("version");
local e=e and e:get_child_text("os");
t({
name=o;
version=a;
platform=e;
});
else
local a,e,o=o:get_error();
t({
error=true;
condition=e;
text=o;
type=a;
});
end
end);
end
return true;
end
end)
package.preload['verse.plugins.ping']=(function(...)
local a=require"verse";
local i="urn:xmpp:ping";
function a.plugins.ping(e)
function e:ping(t,o)
local n=socket.gettime();
e:send_iq(a.iq{to=t,type="get"}:tag("ping",{xmlns=i}),
function(e)
if e.attr.type=="error"then
local a,e,i=e:get_error();
if e~="service-unavailable"and e~="feature-not-implemented"then
o(nil,t,{type=a,condition=e,text=i});
return;
end
end
o(socket.gettime()-n,t);
end);
end
e:hook("iq/"..i,function(t)
return e:send(a.reply(t));
end);
return true;
end
end)
package.preload['verse.plugins.uptime']=(function(...)
local o=require"verse";
local t="jabber:iq:last";
local function a(t,e)
t.starttime=e.starttime;
end
function o.plugins.uptime(e)
e.uptime={set=a};
e:hook("iq/"..t,function(a)
if a.attr.type~="get"then return;end
local t=o.reply(a)
:tag("query",{seconds=tostring(os.difftime(os.time(),e.uptime.starttime)),xmlns=t});
e:send(t);
return true;
end);
function e:query_uptime(i,a)
a=a or function(t)return e:event("uptime/response",t);end
e:send_iq(o.iq({type="get",to=i})
:tag("query",{xmlns=t}),
function(e)
local t=e:get_child("query",t);
if e.attr.type=="result"then
local e=tonumber(t.attr.seconds);
a({
seconds=e or nil;
});
else
local o,t,e=e:get_error();
a({
error=true;
condition=t;
text=e;
type=o;
});
end
end);
end
return true;
end
end)
package.preload['verse.plugins.blocking']=(function(...)
local a=require"verse";
local o="urn:xmpp:blocking";
function a.plugins.blocking(e)
e.blocking={};
function e.blocking:block_jid(i,t)
e:send_iq(a.iq{type="set"}
:tag("block",{xmlns=o})
:tag("item",{jid=i})
,function()return t and t(true);end
,function()return t and t(false);end
);
end
function e.blocking:unblock_jid(i,t)
e:send_iq(a.iq{type="set"}
:tag("unblock",{xmlns=o})
:tag("item",{jid=i})
,function()return t and t(true);end
,function()return t and t(false);end
);
end
function e.blocking:unblock_all_jids(t)
e:send_iq(a.iq{type="set"}
:tag("unblock",{xmlns=o})
,function()return t and t(true);end
,function()return t and t(false);end
);
end
function e.blocking:get_blocked_jids(t)
e:send_iq(a.iq{type="get"}
:tag("blocklist",{xmlns=o})
,function(e)
local a=e:get_child("blocklist",o);
if not a then return t and t(false);end
local e={};
for t in a:childtags()do
e[#e+1]=t.attr.jid;
end
return t and t(e);
end
,function(e)return t and t(false);end
);
end
end
end)
package.preload['verse.plugins.jingle']=(function(...)
local o=require"verse";
local e=require"util.sha1".sha1;
local e=require"util.timer";
local a=require"util.uuid".generate;
local i="urn:xmpp:jingle:1";
local h="urn:xmpp:jingle:errors:1";
local t={};
t.__index=t;
local e={};
local e={};
function o.plugins.jingle(e)
e:hook("ready",function()
e:add_disco_feature(i);
end,10);
function e:jingle(i)
return o.eventable(setmetatable(base or{
role="initiator";
peer=i;
sid=a();
stream=e;
},t));
end
function e:register_jingle_transport(e)
end
function e:register_jingle_content_type(e)
end
local function u(n)
local s=n:get_child("jingle",i);
local a=s.attr.sid;
local r=s.attr.action;
local a=e:event("jingle/"..a,n);
if a==true then
e:send(o.reply(n));
return true;
end
if r~="session-initiate"then
local t=o.error_reply(n,"cancel","item-not-found")
:tag("unknown-session",{xmlns=h}):up();
e:send(t);
return;
end
local l=s.attr.sid;
local a=o.eventable{
role="receiver";
peer=n.attr.from;
sid=l;
stream=e;
};
setmetatable(a,t);
local d;
local r,h;
for t in s:childtags()do
if t.name=="content"and t.attr.xmlns==i then
local i=t:child_with_name("description");
local o=i.attr.xmlns;
if o then
local e=e:event("jingle/content/"..o,a,i);
if e then
r=e;
end
end
local o=t:child_with_name("transport");
local i=o.attr.xmlns;
h=e:event("jingle/transport/"..i,a,o);
if r and h then
d=t;
break;
end
end
end
if not r then
e:send(o.error_reply(n,"cancel","feature-not-implemented","The specified content is not supported"));
return true;
end
if not h then
e:send(o.error_reply(n,"cancel","feature-not-implemented","The specified transport is not supported"));
return true;
end
e:send(o.reply(n));
a.content_tag=d;
a.creator,a.name=d.attr.creator,d.attr.name;
a.content,a.transport=r,h;
function a:decline()
end
e:hook("jingle/"..l,function(e)
if e.attr.from~=a.peer then
return false;
end
local e=e:get_child("jingle",i);
return a:handle_command(e);
end);
e:event("jingle",a);
return true;
end
function t:handle_command(a)
local t=a.attr.action;
e:debug("Handling Jingle command: %s",t);
if t=="session-terminate"then
self:destroy();
elseif t=="session-accept"then
self:handle_accepted(a);
elseif t=="transport-info"then
e:debug("Handling transport-info");
self.transport:info_received(a);
elseif t=="transport-replace"then
e:error("Peer wanted to swap transport, not implemented");
else
e:warn("Unhandled Jingle command: %s",t);
return nil;
end
return true;
end
function t:send_command(a,t,e)
local t=o.iq({to=self.peer,type="set"})
:tag("jingle",{
xmlns=i,
sid=self.sid,
action=a,
initiator=self.role=="initiator"and self.stream.jid or nil,
responder=self.role=="responder"and self.jid or nil,
}):add_child(t);
if not e then
self.stream:send(t);
else
self.stream:send_iq(t,e);
end
end
function t:accept(t)
local a=o.iq({to=self.peer,type="set"})
:tag("jingle",{
xmlns=i,
sid=self.sid,
action="session-accept",
responder=e.jid,
})
:tag("content",{creator=self.creator,name=self.name});
local o=self.content:generate_accept(self.content_tag:child_with_name("description"),t);
a:add_child(o);
local t=self.transport:generate_accept(self.content_tag:child_with_name("transport"),t);
a:add_child(t);
local t=self;
e:send_iq(a,function(a)
if a.attr.type=="error"then
local a,t,a=a:get_error();
e:error("session-accept rejected: %s",t);
return false;
end
t.transport:connect(function(a)
e:warn("CONNECTED (receiver)!!!");
t.state="active";
t:event("connected",a);
end);
end);
end
e:hook("iq/"..i,u);
return true;
end
function t:offer(t,a)
local e=o.iq({to=self.peer,type="set"})
:tag("jingle",{xmlns=i,action="session-initiate",
initiator=self.stream.jid,sid=self.sid});
e:tag("content",{creator=self.role,name=t});
local t=self.stream:event("jingle/describe/"..t,a);
if not t then
return false,"Unknown content type";
end
e:add_child(t);
local t=self.stream:event("jingle/transport/".."urn:xmpp:jingle:transports:s5b:1",self);
self.transport=t;
e:add_child(t:generate_initiate());
self.stream:debug("Hooking %s","jingle/"..self.sid);
self.stream:hook("jingle/"..self.sid,function(e)
if e.attr.from~=self.peer then
return false;
end
local e=e:get_child("jingle",i);
return self:handle_command(e)
end);
self.stream:send_iq(e,function(e)
if e.attr.type=="error"then
self.state="terminated";
local e,a,t=e:get_error();
return self:event("error",{type=e,condition=a,text=t});
end
end);
self.state="pending";
end
function t:terminate(e)
local e=o.stanza("reason"):tag(e or"success");
self:send_command("session-terminate",e,function(e)
self.state="terminated";
self.transport:disconnect();
self:destroy();
end);
end
function t:destroy()
self:event("terminated");
self.stream:unhook("jingle/"..self.sid,self.handle_command);
end
function t:handle_accepted(e)
local e=e:child_with_name("transport");
self.transport:handle_accepted(e);
self.transport:connect(function(e)
self.stream:debug("CONNECTED (initiator)!")
self.state="active";
self:event("connected",e);
end);
end
function t:set_source(a,o)
local function t()
local e,i=a();
if e and e~=""then
self.transport.conn:send(e);
elseif e==""then
return t();
elseif e==nil then
if o then
self:terminate();
end
self.transport.conn:unhook("drained",t);
a=nil;
end
end
self.transport.conn:hook("drained",t);
t();
end
function t:set_sink(t)
self.transport.conn:hook("incoming-raw",t);
self.transport.conn:hook("disconnected",function(e)
self.stream:debug("Closing sink...");
local e=e.reason;
if e=="closed"then e=nil;end
t(nil,e);
end);
end
end)
package.preload['verse.plugins.jingle_ft']=(function(...)
local s=require"verse";
local n=require"ltn12";
local h=package.config:sub(1,1);
local a="urn:xmpp:jingle:apps:file-transfer:1";
local i="http://jabber.org/protocol/si/profile/file-transfer";
function s.plugins.jingle_ft(t)
t:hook("ready",function()
t:add_disco_feature(a);
end,10);
local o={type="file"};
function o:generate_accept(t,e)
if e and e.save_file then
self.jingle:hook("connected",function()
local e=n.sink.file(io.open(e.save_file,"w+"));
self.jingle:set_sink(e);
end);
end
return t;
end
local o={__index=o};
t:hook("jingle/content/"..a,function(t,e)
local e=e:get_child("offer"):get_child("file",i);
local e={
name=e.attr.name;
size=tonumber(e.attr.size);
};
return setmetatable({jingle=t,file=e},o);
end);
t:hook("jingle/describe/file",function(e)
local t;
if e.timestamp then
t=os.date("!%Y-%m-%dT%H:%M:%SZ",e.timestamp);
end
return s.stanza("description",{xmlns=a})
:tag("offer")
:tag("file",{xmlns=i,
name=e.filename,
size=e.size,
date=t,
hash=e.hash,
})
:tag("desc"):text(e.description or"");
end);
function t:send_file(a,t)
local e,o=io.open(t);
if not e then return e,o;end
local o=e:seek("end",0);
e:seek("set",0);
local i=n.source.file(e);
local e=self:jingle(a);
e:offer("file",{
filename=t:match("[^"..h.."]+$");
size=o;
});
e:hook("connected",function()
e:set_source(i,true);
end);
return e;
end
end
end)
package.preload['verse.plugins.jingle_s5b']=(function(...)
local a=require"verse";
local o="urn:xmpp:jingle:transports:s5b:1";
local r="http://jabber.org/protocol/bytestreams";
local n=require"util.sha1".sha1;
local d=require"util.uuid".generate;
local function h(e,n)
local function s()
e:unhook("connected",s);
return true;
end
local function i(t)
e:unhook("incoming-raw",i);
if t:sub(1,2)~="\005\000"then
return e:event("error","connection-failure");
end
e:event("connected");
return true;
end
local function a(o)
e:unhook("incoming-raw",a);
if o~="\005\000"then
local t="version-mismatch";
if o:sub(1,1)=="\005"then
t="authentication-failure";
end
return e:event("error",t);
end
e:send(string.char(5,1,0,3,#n)..n.."\0\0");
e:hook("incoming-raw",i,100);
return true;
end
e:hook("connected",s,200);
e:hook("incoming-raw",a,100);
e:send("\005\001\000");
end
local function s(o,e,i)
local e=a.new(nil,{
streamhosts=e,
current_host=0;
});
local function t(a)
if a then
return o(nil,a.reason);
end
if e.current_host<#e.streamhosts then
e.current_host=e.current_host+1;
e:debug("Attempting to connect to "..e.streamhosts[e.current_host].host..":"..e.streamhosts[e.current_host].port.."...");
local a,t=e:connect(
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port
);
if not a then
e:debug("Error connecting to proxy (%s:%s): %s",
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port,
t
);
else
e:debug("Connecting...");
end
h(e,i);
return true;
end
e:unhook("disconnected",t);
return o(nil);
end
e:hook("disconnected",t,100);
e:hook("connected",function()
e:unhook("disconnected",t);
o(e.streamhosts[e.current_host],e);
end,100);
t();
return e;
end
function a.plugins.jingle_s5b(e)
e:hook("ready",function()
e:add_disco_feature(o);
end,10);
local t={};
function t:generate_initiate()
self.s5b_sid=d();
local i=a.stanza("transport",{xmlns=o,
mode="tcp",sid=self.s5b_sid});
local t=0;
for a,o in pairs(e.proxy65.available_streamhosts)do
t=t+1;
i:tag("candidate",{jid=a,host=o.host,
port=o.port,cid=a,priority=t,type="proxy"}):up();
end
e:debug("Have %d proxies",t)
return i;
end
function t:generate_accept(e)
local t={};
self.s5b_peer_candidates=t;
self.s5b_mode=e.attr.mode or"tcp";
self.s5b_sid=e.attr.sid or self.jingle.sid;
for e in e:childtags()do
t[e.attr.cid]={
type=e.attr.type;
jid=e.attr.jid;
host=e.attr.host;
port=tonumber(e.attr.port)or 0;
priority=tonumber(e.attr.priority)or 0;
cid=e.attr.cid;
};
end
local e=a.stanza("transport",{xmlns=o});
return e;
end
function t:connect(i)
e:warn("Connecting!");
local t={};
for a,e in pairs(self.s5b_peer_candidates or{})do
t[#t+1]=e;
end
if#t>0 then
self.connecting_peer_candidates=true;
local function h(e,t)
self.jingle:send_command("transport-info",a.stanza("content",{creator=self.creator,name=self.name})
:tag("transport",{xmlns=o,sid=self.s5b_sid})
:tag("candidate-used",{cid=e.cid}));
self.onconnect_callback=i;
self.conn=t;
end
local e=n(self.s5b_sid..self.peer..e.jid,true);
s(h,t,e);
else
e:warn("Actually, I'm going to wait for my peer to tell me its streamhost...");
self.onconnect_callback=i;
end
end
function t:info_received(t)
e:warn("Info received");
local h=t:child_with_name("content");
local i=h:child_with_name("transport");
if i:get_child("candidate-used")and not self.connecting_peer_candidates then
local t=i:child_with_name("candidate-used");
if t then
local function d(i,e)
if self.jingle.role=="initiator"then
self.jingle.stream:send_iq(a.iq({to=i.jid,type="set"})
:tag("query",{xmlns=r,sid=self.s5b_sid})
:tag("activate"):text(self.jingle.peer),function(i)
if i.attr.type=="result"then
self.jingle:send_command("transport-info",a.stanza("content",h.attr)
:tag("transport",{xmlns=o,sid=self.s5b_sid})
:tag("activated",{cid=t.attr.cid}));
self.conn=e;
self.onconnect_callback(e);
else
self.jingle.stream:error("Failed to activate bytestream");
end
end);
end
end
self.jingle.stream:debug("CID: %s",self.jingle.stream.proxy65.available_streamhosts[t.attr.cid]);
local t={
self.jingle.stream.proxy65.available_streamhosts[t.attr.cid];
};
local e=n(self.s5b_sid..e.jid..self.peer,true);
s(d,t,e);
end
elseif i:get_child("activated")then
self.onconnect_callback(self.conn);
end
end
function t:disconnect()
if self.conn then
self.conn:close();
end
end
function t:handle_accepted(e)
end
local t={__index=t};
e:hook("jingle/transport/"..o,function(e)
return setmetatable({
role=e.role,
peer=e.peer,
stream=e.stream,
jingle=e,
},t);
end);
end
end)
package.preload['verse.plugins.proxy65']=(function(...)
local e=require"util.events";
local r=require"util.uuid";
local h=require"util.sha1";
local i={};
i.__index=i;
local o="http://jabber.org/protocol/bytestreams";
local n;
function verse.plugins.proxy65(t)
t.proxy65=setmetatable({stream=t},i);
t.proxy65.available_streamhosts={};
local e=0;
t:hook("disco/service-discovered/proxy",function(a)
if a.type=="bytestreams"then
e=e+1;
t:send_iq(verse.iq({to=a.jid,type="get"})
:tag("query",{xmlns=o}),function(a)
e=e-1;
if a.attr.type=="result"then
local e=a:get_child("query",o)
:get_child("streamhost").attr;
t.proxy65.available_streamhosts[e.jid]={
jid=e.jid;
host=e.host;
port=tonumber(e.port);
};
end
if e==0 then
t:event("proxy65/discovered-proxies",t.proxy65.available_streamhosts);
end
end);
end
end);
t:hook("iq/"..o,function(a)
local e=verse.new(nil,{
initiator_jid=a.attr.from,
streamhosts={},
current_host=0;
});
for t in a.tags[1]:childtags()do
if t.name=="streamhost"then
table.insert(e.streamhosts,t.attr);
end
end
local function o()
if e.current_host<#e.streamhosts then
e.current_host=e.current_host+1;
e:connect(
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port
);
n(t,e,a.tags[1].attr.sid,a.attr.from,t.jid);
return true;
end
e:unhook("disconnected",o);
t:send(verse.error_reply(a,"cancel","item-not-found"));
end
function e:accept()
e:hook("disconnected",o,100);
e:hook("connected",function()
e:unhook("disconnected",o);
local e=verse.reply(a)
:tag("query",a.tags[1].attr)
:tag("streamhost-used",{jid=e.streamhosts[e.current_host].jid});
t:send(e);
end,100);
o();
end
function e:refuse()
end
t:event("proxy65/request",e);
end);
end
function i:new(t,s)
local e=verse.new(nil,{
target_jid=t;
bytestream_sid=r.generate();
});
local a=verse.iq{type="set",to=t}
:tag("query",{xmlns=o,mode="tcp",sid=e.bytestream_sid});
for t,e in ipairs(s or self.proxies)do
a:tag("streamhost",e):up();
end
self.stream:send_iq(a,function(a)
if a.attr.type=="error"then
local o,a,t=a:get_error();
e:event("connection-failed",{conn=e,type=o,condition=a,text=t});
else
local a=a.tags[1]:get_child("streamhost-used");
if not a then
end
e.streamhost_jid=a.attr.jid;
local a,i;
for o,t in ipairs(s or self.proxies)do
if t.jid==e.streamhost_jid then
a,i=t.host,t.port;
break;
end
end
if not(a and i)then
end
e:connect(a,i);
local function a()
e:unhook("connected",a);
local t=verse.iq{to=e.streamhost_jid,type="set"}
:tag("query",{xmlns=o,sid=e.bytestream_sid})
:tag("activate"):text(t);
self.stream:send_iq(t,function(t)
if t.attr.type=="result"then
e:event("connected",e);
else
end
end);
return true;
end
e:hook("connected",a,100);
n(self.stream,e,e.bytestream_sid,self.stream.jid,t);
end
end);
return e;
end
function n(i,e,o,t,a)
local i=h.sha1(o..t..a);
local function o()
e:unhook("connected",o);
return true;
end
local function a(t)
e:unhook("incoming-raw",a);
if t:sub(1,2)~="\005\000"then
return e:event("error","connection-failure");
end
e:event("connected");
return true;
end
local function t(o)
e:unhook("incoming-raw",t);
if o~="\005\000"then
local t="version-mismatch";
if o:sub(1,1)=="\005"then
t="authentication-failure";
end
return e:event("error",t);
end
e:send(string.char(5,1,0,3,#i)..i.."\0\0");
e:hook("incoming-raw",a,100);
return true;
end
e:hook("connected",o,200);
e:hook("incoming-raw",t,100);
e:send("\005\001\000");
end
end)
package.preload['verse.plugins.jingle_ibb']=(function(...)
local e=require"verse";
local i=require"util.encodings".base64;
local s=require"util.uuid".generate;
local n="urn:xmpp:jingle:transports:ibb:1";
local o="http://jabber.org/protocol/ibb";
assert(i.encode("This is a test.")=="VGhpcyBpcyBhIHRlc3Qu","Base64 encoding failed");
assert(i.decode("VGhpcyBpcyBhIHRlc3Qu")=="This is a test.","Base64 decoding failed");
local t=table.concat
local a={};
local t={__index=a};
local function h(a)
local t=setmetatable({stream=a},t)
t=e.eventable(t);
return t;
end
function a:initiate(a,e,t)
self.block=2048;
self.stanza=t or'iq';
self.peer=a;
self.sid=e or tostring(self):match("%x+$");
self.iseq=0;
self.oseq=0;
local e=function(e)
return self:feed(e)
end
self.feeder=e;
print("Hooking incomming IQs");
local a=self.stream;
a:hook("iq/"..o,e)
if t=="message"then
a:hook("message",e)
end
end
function a:open(t)
self.stream:send_iq(e.iq{to=self.peer,type="set"}
:tag("open",{
xmlns=o,
["block-size"]=self.block,
sid=self.sid,
stanza=self.stanza
})
,function(e)
if t then
if e.attr.type~="error"then
t(true)
else
t(false,e:get_error())
end
end
end);
end
function a:send(n)
local a=self.stanza;
local t;
if a=="iq"then
t=e.iq{type="set",to=self.peer}
elseif a=="message"then
t=e.message{to=self.peer}
end
local e=self.oseq;
self.oseq=e+1;
t:tag("data",{xmlns=o,sid=self.sid,seq=e})
:text(i.encode(n));
if a=="iq"then
self.stream:send_iq(t,function(e)
self:event(e.attr.type=="result"and"drained"or"error");
end)
else
stream:send(t)
self:event("drained");
end
end
function a:feed(t)
if t.attr.from~=self.peer then return end
local a=t[1];
if a.attr.sid~=self.sid then return end
local n;
if a.name=="open"then
self:event("connected");
self.stream:send(e.reply(t))
return true
elseif a.name=="data"then
local o=t:get_child_text("data",o);
local a=tonumber(a.attr.seq);
local n=self.iseq;
if o and a then
if a~=n then
self.stream:send(e.error_reply(t,"cancel","not-acceptable","Wrong sequence. Packet lost?"))
self:close();
self:event("error");
return true;
end
self.iseq=a+1;
local a=i.decode(o);
if self.stanza=="iq"then
self.stream:send(e.reply(t))
end
self:event("incoming-raw",a);
return true;
end
elseif a.name=="close"then
self.stream:send(e.reply(t))
self:close();
return true
end
end
function a:close()
self.stream:unhook("iq/"..o,self.feeder)
self:event("disconnected");
end
function e.plugins.jingle_ibb(a)
a:hook("ready",function()
a:add_disco_feature(n);
end,10);
local t={};
function t:_setup()
local e=h(self.stream);
e.sid=self.sid or e.sid;
e.stanza=self.stanza or e.stanza;
e.block=self.block or e.block;
e:initiate(self.peer,self.sid,self.stanza);
self.conn=e;
end
function t:generate_initiate()
print("ibb:generate_initiate() as "..self.role);
local t=s();
self.sid=t;
self.stanza='iq';
self.block=2048;
local e=e.stanza("transport",{xmlns=n,
sid=self.sid,stanza=self.stanza,["block-size"]=self.block});
return e;
end
function t:generate_accept(t)
print("ibb:generate_accept() as "..self.role);
local e=t.attr;
self.sid=e.sid or self.sid;
self.stanza=e.stanza or self.stanza;
self.block=e["block-size"]or self.block;
self:_setup();
return t;
end
function t:connect(t)
if not self.conn then
self:_setup();
end
local e=self.conn;
print("ibb:connect() as "..self.role);
if self.role=="initiator"then
e:open(function(a,...)
assert(a,table.concat({...},", "));
t(e);
end);
else
t(e);
end
end
function t:info_received(e)
print("ibb:info_received()");
end
function t:disconnect()
if self.conn then
self.conn:close()
end
end
function t:handle_accepted(e)end
local t={__index=t};
a:hook("jingle/transport/"..n,function(e)
return setmetatable({
role=e.role,
peer=e.peer,
stream=e.stream,
jingle=e,
},t);
end);
end
end)
package.preload['verse.plugins.pubsub']=(function(...)
local h=require"verse";
local e=require"util.jid".bare;
local s=table.insert;
local o="http://jabber.org/protocol/pubsub";
local n="http://jabber.org/protocol/pubsub#owner";
local a="http://jabber.org/protocol/pubsub#event";
local e="http://jabber.org/protocol/pubsub#errors";
local e={};
local i={__index=e};
function h.plugins.pubsub(e)
e.pubsub=setmetatable({stream=e},i);
e:hook("message",function(t)
local o=t.attr.from;
for t in t:childtags("event",a)do
local t=t:get_child("items");
if t then
local a=t.attr.node;
for t in t:childtags("item")do
e:event("pubsub/event",{
from=o;
node=a;
item=t;
});
end
end
end
end);
return true;
end
function e:create(a,t,e)
return self:service(a):node(t):create(nil,e);
end
function e:subscribe(a,o,e,t)
return self:service(a):node(o):subscribe(e,nil,t);
end
function e:publish(i,o,e,t,a)
return self:service(i):node(o):publish(e,nil,t,a);
end
local a={};
local t={__index=a};
function e:service(e)
return setmetatable({stream=self.stream,service=e},t)
end
local function t(i,t,s,a,r,n,e)
local t=h.iq{type=i or"get",to=t}
:tag("pubsub",{xmlns=s or o})
if a then t:tag(a,{node=r,jid=n});end
if e then t:tag("item",{id=e~=true and e or nil});end
return t;
end
function a:subscriptions(e)
self.stream:send_iq(t(nil,self.service,nil,"subscriptions")
,e and function(t)
if t.attr.type=="result"then
local t=t:get_child("pubsub",o);
local t=t and t:get_child("subscriptions");
local a={};
if t then
for e in t:childtags("subscription")do
local t=self:node(e.attr.node)
t.subscription=e;
t.subscribed_jid=e.attr.jid;
s(a,t);
end
end
e(a);
else
e(false,t:get_error());
end
end or nil);
end
function a:affiliations(a)
self.stream:send_iq(t(nil,self.service,nil,"affiliations")
,a and function(e)
if e.attr.type=="result"then
local e=e:get_child("pubsub",o);
local e=e and e:get_child("affiliations")or{};
local t={};
if e then
for e in e:childtags("affiliation")do
local a=self:node(e.attr.node)
a.affiliation=e;
s(t,a);
end
end
a(t);
else
a(false,e:get_error());
end
end or nil);
end
function a:nodes(a)
self.stream:disco_items(self.service,nil,function(e,...)
if e then
for t=1,#e do
e[t]=self:node(e[t].node);
end
end
a(e,...)
end);
end
local e={};
local o={__index=e};
function a:node(e)
return setmetatable({stream=self.stream,service=self.service,node=e},o)
end
function i:__call(e,t)
local e=self:service(e);
return t and e:node(t)or e;
end
function e:hook(a,o)
self._hooks=self._hooks or setmetatable({},{__mode='kv'});
local function t(e)
if(not e.service or e.from==self.service)and e.node==self.node then
return a(e)
end
end
self._hooks[a]=t;
self.stream:hook("pubsub/event",t,o);
return t;
end
function e:unhook(e)
if e then
local e=self._hooks[e];
self.stream:unhook("pubsub/event",e);
elseif self._hooks then
for e in pairs(self._hooks)do
self.stream:unhook("pubsub/event",e);
end
end
end
function e:create(a,e)
if a~=nil then
error("Not implemented yet.");
else
self.stream:send_iq(t("set",self.service,nil,"create",self.node),e);
end
end
function e:configure(e,a)
if e~=nil then
error("Not implemented yet.");
end
self.stream:send_iq(t("set",self.service,nil,e==nil and"default"or"configure",self.node),a);
end
function e:publish(i,o,e,a)
if o~=nil then
error("Node configuration is not implemented yet.");
end
self.stream:send_iq(t("set",self.service,nil,"publish",self.node,nil,i or true)
:add_child(e)
,a);
end
function e:subscribe(e,a,o)
e=e or self.stream.jid;
if a~=nil then
error("Subscription configuration is not implemented yet.");
end
self.stream:send_iq(t("set",self.service,nil,"subscribe",self.node,e,id)
,o);
end
function e:subscription(e)
error("Not implemented yet.");
end
function e:affiliation(e)
error("Not implemented yet.");
end
function e:unsubscribe(e,a)
e=e or self.subscribed_jid or self.stream.jid;
self.stream:send_iq(t("set",self.service,nil,"unsubscribe",self.node,e)
,a);
end
function e:configure_subscription(e,e)
error("Not implemented yet.");
end
function e:items(a,e)
if a then
self.stream:send_iq(t("get",self.service,nil,"items",self.node)
,e);
else
self.stream:disco_items(self.service,self.node,e);
end
end
function e:item(a,e)
self.stream:send_iq(t("get",self.service,nil,"items",self.node,nil,a)
,e);
end
function e:retract(e,a)
self.stream:send_iq(t("set",self.service,nil,"retract",self.node,nil,e)
,a);
end
function e:purge(a,e)
assert(not a,"Not implemented yet.");
self.stream:send_iq(t("set",self.service,n,"purge",self.node)
,e);
end
function e:delete(a,e)
assert(not a,"Not implemented yet.");
self.stream:send_iq(t("set",self.service,n,"delete",self.node)
,e);
end
end)
package.preload['verse.plugins.pep']=(function(...)
local t=require"verse";
local e="http://jabber.org/protocol/pubsub";
local e=e.."#event";
function t.plugins.pep(e)
e:add_plugin("disco");
e:add_plugin("pubsub");
e.pep={};
e:hook("pubsub/event",function(t)
return e:event("pep/"..t.node,{from=t.from,item=t.item.tags[1]});
end);
function e:hook_pep(t,o,i)
local a=e.events._handlers["pep/"..t];
if not(a)or#a==0 then
e:add_disco_feature(t.."+notify");
end
e:hook("pep/"..t,o,i);
end
function e:unhook_pep(t,a)
e:unhook("pep/"..t,a);
local a=e.events._handlers["pep/"..t];
if not(a)or#a==0 then
e:remove_disco_feature(t.."+notify");
end
end
function e:publish_pep(t,a)
return e.pubsub:service(nil):node(a or t.attr.xmlns):publish(nil,nil,t)
end
end
end)
package.preload['verse.plugins.adhoc']=(function(...)
local o=require"verse";
local n=require"lib.adhoc";
local t="http://jabber.org/protocol/commands";
local s="jabber:x:data";
local a={};
a.__index=a;
local i={};
function o.plugins.adhoc(e)
e:add_plugin("disco");
e:add_disco_feature(t);
function e:query_commands(a,o)
e:disco_items(a,t,function(a)
e:debug("adhoc list returned")
local t={};
for o,a in ipairs(a)do
t[a.node]=a.name;
end
e:debug("adhoc calling callback")
return o(t);
end);
end
function e:execute_command(i,t,o)
local e=setmetatable({
stream=e,jid=i,
command=t,callback=o
},a);
return e:execute();
end
local function s(t,e)
if not(e)or e=="user"then return true;end
if type(e)=="function"then
return e(t);
end
end
function e:add_adhoc_command(o,a,s,h)
i[a]=n.new(o,a,s,h);
e:add_disco_item({jid=e.jid,node=a,name=o},t);
return i[a];
end
local function h(t)
local a=t.tags[1];
local a=a.attr.node;
local a=i[a];
if not a then return;end
if not s(t.attr.from,a.permission)then
e:send(o.error_reply(t,"auth","forbidden","You don't have permission to execute this command"):up()
:add_child(a:cmdtag("canceled")
:tag("note",{type="error"}):text("You don't have permission to execute this command")));
return true
end
return n.handle_cmd(a,{send=function(t)return e:send(t)end},t);
end
e:hook("iq/"..t,function(e)
local a=e.attr.type;
local t=e.tags[1].name;
if a=="set"and t=="command"then
return h(e);
end
end);
end
function a:_process_response(e)
if e.attr.type=="error"then
self.status="canceled";
self.callback(self,{});
return;
end
local e=e:get_child("command",t);
self.status=e.attr.status;
self.sessionid=e.attr.sessionid;
self.form=e:get_child("x",s);
self.note=e:get_child("note");
self.callback(self);
end
function a:execute()
local e=o.iq({to=self.jid,type="set"})
:tag("command",{xmlns=t,node=self.command});
self.stream:send_iq(e,function(e)
self:_process_response(e);
end);
end
function a:next(e)
local t=o.iq({to=self.jid,type="set"})
:tag("command",{
xmlns=t,
node=self.command,
sessionid=self.sessionid
});
if e then t:add_child(e);end
self.stream:send_iq(t,function(e)
self:_process_response(e);
end);
end
end)
package.preload['verse.plugins.presence']=(function(...)
local a=require"verse";
function a.plugins.presence(e)
e.last_presence=nil;
e:hook("presence-out",function(t)
if not t.attr.to then
e.last_presence=t;
end
end,1);
function e:resend_presence()
if last_presence then
e:send(last_presence);
end
end
function e:set_status(t)
local a=a.presence();
if type(t)=="table"then
if t.show then
a:tag("show"):text(t.show):up();
end
if t.prio then
a:tag("priority"):text(tostring(t.prio)):up();
end
if t.msg then
a:tag("status"):text(t.msg):up();
end
end
e:send(a);
end
end
end)
package.preload['verse.plugins.private']=(function(...)
local t=require"verse";
local a="jabber:iq:private";
function t.plugins.private(o)
function o:private_set(i,o,e,n)
local t=t.iq({type="set"})
:tag("query",{xmlns=a});
if e then
if e.name==i and e.attr and e.attr.xmlns==o then
t:add_child(e);
else
t:tag(i,{xmlns=o})
:add_child(e);
end
end
self:send_iq(t,n);
end
function o:private_get(o,i,n)
self:send_iq(t.iq({type="get"})
:tag("query",{xmlns=a})
:tag(o,{xmlns=i}),
function(e)
if e.attr.type=="result"then
local e=e:get_child("query",a);
local e=e:get_child(o,i);
n(e);
end
end);
end
end
end)
package.preload['verse.plugins.roster']=(function(...)
local i=require"verse";
local r=require"util.jid".bare;
local a="jabber:iq:roster";
local n="urn:xmpp:features:rosterver";
local o=table.insert;
function i.plugins.roster(t)
local s=false;
local e={
items={};
ver="";
};
t.roster=e;
t:hook("stream-features",function(e)
if e:get_child("ver",n)then
s=true;
end
end);
local function h(t)
local e=i.stanza("item",{xmlns=a});
for a,t in pairs(t)do
if a~="groups"then
e.attr[a]=t;
else
for a=1,#t do
e:tag("group"):text(t[a]):up();
end
end
end
return e;
end
local function d(t)
local e={};
local a={};
e.groups=a;
local i=t.attr.jid;
for t,a in pairs(t.attr)do
if t~="xmlns"then
e[t]=a
end
end
for e in t:childtags("group")do
o(a,e:get_text())
end
return e;
end
function e:load(t)
e.ver,e.items=t.ver,t.items;
end
function e:dump()
return{
ver=e.ver,
items=e.items,
};
end
function e:add_contact(n,s,o,e)
local o={jid=n,name=s,groups=o};
local a=i.iq({type="set"})
:tag("query",{xmlns=a})
:add_child(h(o));
t:send_iq(a,function(t)
if not e then return end
if t.attr.type=="result"then
e(true);
else
local t,a,o=t:get_error();
e(nil,{t,a,o});
end
end);
end
function e:delete_contact(o,n)
o=(type(o)=="table"and o.jid)or o;
local s={jid=o,subscription="remove"}
if not e.items[o]then return false,"item-not-found";end
t:send_iq(i.iq({type="set"})
:tag("query",{xmlns=a})
:add_child(h(s)),
function(e)
if not n then return end
if e.attr.type=="result"then
n(true);
else
local a,e,t=e:get_error();
n(nil,{a,e,t});
end
end);
end
local function h(t)
local t=d(t);
e.items[t.jid]=t;
end
local function d(t)
local a=e.items[t];
e.items[t]=nil;
return a;
end
function e:fetch(o)
t:send_iq(i.iq({type="get"}):tag("query",{xmlns=a,ver=s and e.ver or nil}),
function(t)
if t.attr.type=="result"then
local t=t:get_child("query",a);
if t then
e.items={};
for t in t:childtags("item")do
h(t)
end
e.ver=t.attr.ver or"";
end
o(e);
else
local t,e,a=stanza:get_error();
o(nil,{t,e,a});
end
end);
end
t:hook("iq/"..a,function(o)
local s,n=o.attr.type,o.attr.from;
if s=="set"and(not n or n==r(t.jid))then
local s=o:get_child("query",a);
local n=s and s:get_child("item");
if n then
local i,a;
local o=n.attr.jid;
if n.attr.subscription=="remove"then
i="removed"
a=d(o);
else
i=e.items[o]and"changed"or"added";
h(n)
a=e.items[o];
end
e.ver=s.attr.ver;
if a then
t:event("roster/item-"..i,a);
end
end
t:send(i.reply(o))
return true;
end
end);
end
end)
package.preload['verse.plugins.register']=(function(...)
local t=require"verse";
local i="jabber:iq:register";
function t.plugins.register(e)
local function a(o)
if o:get_child("register","http://jabber.org/features/iq-register")then
local t=t.iq({to=e.host_,type="set"})
:tag("query",{xmlns=i})
:tag("username"):text(e.username):up()
:tag("password"):text(e.password):up();
if e.register_email then
t:tag("email"):text(e.register_email):up();
end
e:send_iq(t,function(t)
if t.attr.type=="result"then
e:event("registration-success");
else
local o,t,a=t:get_error();
e:debug("Registration failed: %s",t);
e:event("registration-failure",{type=o,condition=t,text=a});
end
end);
else
e:debug("In-band registration not offered by server");
e:event("registration-failure",{condition="service-unavailable"});
end
e:unhook("stream-features",a);
return true;
end
e:hook("stream-features",a,310);
end
end)
package.preload['verse.plugins.groupchat']=(function(...)
local i=require"verse";
local e=require"events";
local n=require"util.jid";
local a={};
a.__index=a;
local h="urn:xmpp:delay";
local s="http://jabber.org/protocol/muc";
function i.plugins.groupchat(o)
o:add_plugin("presence")
o.rooms={};
o:hook("stanza",function(e)
local a=n.bare(e.attr.from);
if not a then return end
local t=o.rooms[a]
if not t and e.attr.to and a then
t=o.rooms[e.attr.to.." "..a]
end
if t and t.opts.source and e.attr.to~=t.opts.source then return end
if t then
local i=select(3,n.split(e.attr.from));
local n=e:get_child_text("body");
local o=e:get_child("delay",h);
local a={
room_jid=a;
room=t;
sender=t.occupants[i];
nick=i;
body=n;
stanza=e;
delay=(o and o.attr.stamp);
};
local t=t:event(e.name,a);
return t or(e.name=="message")or nil;
end
end,500);
function o:join_room(n,h,t)
if not h then
return false,"no nickname supplied"
end
t=t or{};
local e=setmetatable(i.eventable{
stream=o,jid=n,nick=h,
subject=nil,
occupants={},
opts=t,
},a);
if t.source then
self.rooms[t.source.." "..n]=e;
else
self.rooms[n]=e;
end
local a=e.occupants;
e:hook("presence",function(o)
local t=o.nick or h;
if not a[t]and o.stanza.attr.type~="unavailable"then
a[t]={
nick=t;
jid=o.stanza.attr.from;
presence=o.stanza;
};
local o=o.stanza:get_child("x",s.."#user");
if o then
local e=o:get_child("item");
if e and e.attr then
a[t].real_jid=e.attr.jid;
a[t].affiliation=e.attr.affiliation;
a[t].role=e.attr.role;
end
end
if t==e.nick then
e.stream:event("groupchat/joined",e);
else
e:event("occupant-joined",a[t]);
end
elseif a[t]and o.stanza.attr.type=="unavailable"then
if t==e.nick then
e.stream:event("groupchat/left",e);
if e.opts.source then
self.rooms[e.opts.source.." "..n]=nil;
else
self.rooms[n]=nil;
end
else
a[t].presence=o.stanza;
e:event("occupant-left",a[t]);
a[t]=nil;
end
end
end);
e:hook("message",function(a)
local t=a.stanza:get_child_text("subject");
if not t then return end
t=#t>0 and t or nil;
if t~=e.subject then
local o=e.subject;
e.subject=t;
return e:event("subject-changed",{from=o,to=t,by=a.sender,event=a});
end
end,2e3);
local t=i.presence():tag("x",{xmlns=s}):reset();
self:event("pre-groupchat/joining",t);
e:send(t)
self:event("groupchat/joining",e);
return e;
end
o:hook("presence-out",function(e)
if not e.attr.to then
for a,t in pairs(o.rooms)do
t:send(e);
end
e.attr.to=nil;
end
end);
end
function a:send(e)
if e.name=="message"and not e.attr.type then
e.attr.type="groupchat";
end
if e.name=="presence"then
e.attr.to=self.jid.."/"..self.nick;
end
if e.attr.type=="groupchat"or not e.attr.to then
e.attr.to=self.jid;
end
if self.opts.source then
e.attr.from=self.opts.source
end
self.stream:send(e);
end
function a:send_message(e)
self:send(i.message():tag("body"):text(e));
end
function a:set_subject(e)
self:send(i.message():tag("subject"):text(e));
end
function a:leave(t)
self.stream:event("groupchat/leaving",self);
local e=i.presence({type="unavailable"});
if t then
e:tag("status"):text(t);
end
self:send(e);
end
function a:admin_set(e,t,a,o)
self:send(i.iq({type="set"})
:query(s.."#admin")
:tag("item",{nick=e,[t]=a})
:tag("reason"):text(o or""));
end
function a:set_role(a,t,e)
self:admin_set(a,"role",t,e);
end
function a:set_affiliation(t,a,e)
self:admin_set(t,"affiliation",a,e);
end
function a:kick(e,t)
self:set_role(e,"none",t);
end
function a:ban(e,t)
self:set_affiliation(e,"outcast",t);
end
end)
package.preload['verse.plugins.vcard']=(function(...)
local i=require"verse";
local o=require"util.vcard";
local t="vcard-temp";
function i.plugins.vcard(a)
function a:get_vcard(n,e)
a:send_iq(i.iq({to=n,type="get"})
:tag("vCard",{xmlns=t}),e and function(a)
local i,i;
vCard=a:get_child("vCard",t);
if a.attr.type=="result"and vCard then
vCard=o.from_xep54(vCard)
e(vCard)
else
e(false)
end
end or nil);
end
function a:set_vcard(e,n)
local t;
if type(e)=="table"and e.name then
t=e;
elseif type(e)=="string"then
t=o.to_xep54(o.from_text(e)[1]);
elseif type(e)=="table"then
t=o.to_xep54(e);
error("Converting a table to vCard not implemented")
end
if not t then return false end
a:debug("setting vcard to %s",tostring(t));
a:send_iq(i.iq({type="set"})
:add_child(t),n);
end
end
end)
package.preload['verse.plugins.vcard_update']=(function(...)
local n=require"verse";
local e,i="vcard-temp","vcard-temp:x:update";
local e,t=pcall(function()return require("util.hashes").sha1;end);
if not e then
e,t=pcall(function()return require("util.sha1").sha1;end);
if not e then
error("Could not find a sha1()")
end
end
local s=t;
local e,t=pcall(function()
local e=require("util.encodings").base64.decode;
assert(e("SGVsbG8=")=="Hello")
return e;
end);
if not e then
e,t=pcall(function()return require("mime").unb64;end);
if not e then
error("Could not find a base64 decoder")
end
end
local h=t;
function n.plugins.vcard_update(e)
e:add_plugin("vcard");
e:add_plugin("presence");
local t;
function update_vcard_photo(o)
local a;
for e=1,#o do
if o[e].name=="PHOTO"then
a=o[e][1];
break
end
end
if a then
local a=s(h(a),true);
t=n.stanza("x",{xmlns=i})
:tag("photo"):text(a);
e:resend_presence()
else
t=nil;
end
end
local a=e.set_vcard;
local a;
e:hook("ready",function(t)
if a then return;end
a=true;
e:get_vcard(nil,function(t)
if t then
update_vcard_photo(t)
end
e:event("ready");
end);
return true;
end,3);
e:hook("presence-out",function(e)
if t and not e:get_child("x",i)then
e:add_child(t);
end
end,10);
end
end)
package.preload['verse.plugins.carbons']=(function(...)
local o=require"verse";
local a="urn:xmpp:carbons:2";
local r="urn:xmpp:forward:0";
local s=os.time;
local h=require"util.datetime".parse;
local n=require"util.jid".bare;
function o.plugins.carbons(e)
local t={};
t.enabled=false;
e.carbons=t;
function t:enable(i)
e:send_iq(o.iq{type="set"}
:tag("enable",{xmlns=a})
,function(e)
local e=e.attr.type=="result";
if e then
t.enabled=true;
end
if i then
i(e);
end
end or nil);
end
function t:disable(i)
e:send_iq(o.iq{type="set"}
:tag("disable",{xmlns=a})
,function(e)
local e=e.attr.type=="result";
if e then
t.enabled=false;
end
if i then
i(e);
end
end or nil);
end
local o;
e:hook("bind-success",function()
o=n(e.jid);
end);
e:hook("message",function(i)
local t=i:get_child(nil,a);
if i.attr.from==o and t then
local o=t.name;
local t=t:get_child("forwarded",r);
local a=t and t:get_child("message","jabber:client");
local t=t:get_child("delay","urn:xmpp:delay");
local t=t and t.attr.stamp;
t=t and h(t);
if a then
return e:event("carbon",{
dir=o,
stanza=a,
timestamp=t or s(),
});
end
end
end,1);
end
end)
package.preload['verse.plugins.archive']=(function(...)
local i=require"verse";
local a=require"util.stanza";
local e="urn:xmpp:mam:0"
local r="urn:xmpp:forward:0";
local c="urn:xmpp:delay";
local n=require"util.uuid".generate;
local m=require"util.datetime".parse;
local o=require"util.datetime".datetime;
local t=require"util.dataforms".new;
local d=require"util.rsm";
local u={};
local l=t{
{name="FORM_TYPE";type="hidden";value=e;};
{name="with";type="jid-single";};
{name="start";type="text-single"};
{name="end";type="text-single";};
};
function i.plugins.archive(h)
function h:query_archive(i,t,h)
local n=n();
local s=a.iq{type="set",to=i}
:tag("query",{xmlns=e,queryid=n});
local a,i=tonumber(t["start"]),tonumber(t["end"]);
t["start"]=a and o(a);
t["end"]=i and o(i);
s:add_child(l:form(t,"submit"));
s:add_child(d.generate(t));
local t={};
local function i(o)
local a=o:get_child("fin",e)
if a and a.attr.queryid==n then
local e=d.get(a);
for a,e in pairs(e or u)do t[a]=e;end
self:unhook("message",i);
h(t);
return true
end
local e=o:get_child("result",e);
if e and e.attr.queryid==n then
local a=e:get_child("forwarded",r);
a=a or o:get_child("forwarded",r);
local i=e.attr.id;
local e=a:get_child("delay",c);
local o=e and m(e.attr.stamp)or nil;
local e=a:get_child("message","jabber:client")
t[#t+1]={id=i,stamp=o,message=e};
return true
end
end
self:hook("message",i,1);
self:send_iq(s,function(e)
if e.attr.type=="error"then
self:warn(table.concat({e:get_error()}," "))
self:unhook("message",i);
h(false,e:get_error())
end
return true
end);
end
local i={
always=true,[true]="always",
never=false,[false]="never",
roster="roster",
}
local function s(t)
local e={};
local a=t.attr.default;
if a then
e[false]=i[a];
end
local a=t:get_child("always");
if a then
for t in a:childtags("jid")do
local t=t:get_text();
e[t]=true;
end
end
local t=t:get_child("never");
if t then
for t in t:childtags("jid")do
local t=t:get_text();
e[t]=false;
end
end
return e;
end
local function n(o)
local t
t,o[false]=o[false],nil;
if t~=nil then
t=i[t];
end
local i=a.stanza("prefs",{xmlns=e,default=t})
local t=a.stanza("always");
local e=a.stanza("never");
for a,o in pairs(o)do
(o and t or e):tag("jid"):text(a):up();
end
return i:add_child(t):add_child(e);
end
function h:archive_prefs_get(t)
self:send_iq(a.iq{type="get"}:tag("prefs",{xmlns=e}),
function(e)
if e and e.attr.type=="result"and e.tags[1]then
local a=s(e.tags[1]);
t(a,e);
else
t(nil,e);
end
end);
end
function h:archive_prefs_set(t,e)
self:send_iq(a.iq{type="set"}:add_child(n(t)),e);
end
end
end)
package.preload['net.httpclient_listener']=(function(...)
local i=require"util.logger".init("httpclient_listener");
local o,s=table.concat,table.insert;
local n=require"net.connlisteners".register;
local a={};
local e={};
local t={default_port=80,default_mode="*a"};
function t.onconnect(t)
local e=a[t];
local a={e.method or"GET"," ",e.path," HTTP/1.1\r\n"};
if e.query then
s(a,4,"?"..e.query);
end
t:write(o(a));
local a={[2]=": ",[4]="\r\n"};
for e,i in pairs(e.headers)do
a[1],a[3]=e,i;
t:write(o(a));
end
t:write("\r\n");
if e.body then
t:write(e.body);
end
end
function t.onincoming(o,t)
local e=a[o];
if not e then
i("warn","Received response from connection %s with no request attached!",tostring(o));
return;
end
if t and e.reader then
e:reader(t);
end
end
function t.ondisconnect(t,e)
local e=a[t];
if e and e.conn then
e:reader(nil);
end
a[t]=nil;
end
function t.register_request(t,e)
i("debug","Attaching request %s to connection %s",tostring(e.id or e),tostring(t));
a[t]=e;
end
n("httpclient",t);
end)
package.preload['net.connlisteners']=(function(...)
local l=(CFG_SOURCEDIR or".").."/net/";
local d=require"net.server";
local o=require"util.logger".init("connlisteners");
local s=tostring;
local u=type
local r=ipairs
local h,i,n=
dofile,xpcall,error
local c=debug.traceback;
module"connlisteners"
local e={};
function register(t,a)
if e[t]and e[t]~=a then
o("debug","Listener %s is already registered, not registering any more",t);
return false;
end
e[t]=a;
o("debug","Registered connection listener %s",t);
return true;
end
function deregister(t)
e[t]=nil;
end
function get(t)
local a=e[t];
if not a then
local n,i=i(function()h(l..t:gsub("[^%w%-]","_").."_listener.lua")end,c);
if not n then
o("error","Error while loading listener '%s': %s",s(t),s(i));
return nil,i;
end
a=e[t];
end
return a;
end
function start(i,e)
local t,a=get(i);
if not t then
n("No such connection module: "..i..(a and(" ("..a..")")or""),0);
end
local o=(e and e.interface)or t.default_interface or"*";
if u(o)=="string"then o={o};end
local h=(e and e.port)or t.default_port or n("Can't start listener "..i.." because no port was specified, and it has no default port",0);
local s=(e and e.mode)or t.default_mode or 1;
local n=(e and e.ssl)or nil;
local i=e and e.type=="ssl";
if i and not n then
return nil,"no ssl context";
end
ok,a=true,{};
for e,o in r(o)do
local e
e,a[o]=d.addserver(o,h,t,s,i and n or nil);
ok=ok and e;
end
return ok,a;
end
return _M;
end)
package.preload['util.httpstream']=(function(...)
local t=coroutine;
local s=tonumber;
local d=t.create(function()end);
t.resume(d);
module("httpstream")
local function c(u,o,d)
local e=t.yield();
local function i()
local a=e:find("\r\n",nil,true);
while not a do
e=e..t.yield();
a=e:find("\r\n",nil,true);
end
local t=e:sub(1,a-1);
e=e:sub(a+2);
return t;
end
local function r(a)
while#e<a do
e=e..t.yield();
end
local t=e:sub(1,a);
e=e:sub(a+1);
return t;
end
local function h()
local a={};
while true do
local e=i();
if e==""then break;end
local e,o=e:match("^([^%s:]+): *(.*)$");
if not e then t.yield("invalid-header-line");end
e=e:lower();
a[e]=a[e]and a[e]..","..o or o;
end
return a;
end
if not o or o=="server"then
while true do
local e=i();
local o,e,i=e:match("^(%S+)%s+(%S+)%s+HTTP/(%S+)$");
if not o then t.yield("invalid-status-line");end
e=e:gsub("^//+","/");
local a=h();
local t=s(a["content-length"]);
t=t or 0;
local t=r(t);
u({
method=o;
path=e;
httpversion=i;
headers=a;
body=t;
});
end
elseif o=="client"then
while true do
local a=i();
local l,a,o=a:match("^HTTP/(%S+)%s+(%d%d%d)%s+(.*)$");
a=s(a);
if not a then t.yield("invalid-status-line");end
local n=h();
local d=not
((d and d().method=="HEAD")
or(a==204 or a==304 or a==301)
or(a>=100 and a<200));
local o;
if d then
local a=s(n["content-length"]);
if n["transfer-encoding"]=="chunked"then
o="";
while true do
local e=i():match("^%x+");
if not e then t.yield("invalid-chunk-size");end
e=s(e,16)
if e==0 then break;end
o=o..r(e);
if i()~=""then t.yield("invalid-chunk-ending");end
end
local e=h();
elseif a then
o=r(a);
else
repeat
local t=t.yield();
e=e..t;
until t=="";
o,e=e,"";
end
end
u({
code=a;
httpversion=l;
headers=n;
body=o;
responseversion=l;
responseheaders=n;
});
end
else t.yield("unknown-parser-type");end
end
function new(i,a,o,n)
local e=t.create(c);
t.resume(e,i,o,n)
return{
feed=function(n,i)
if not i then
if o=="client"then t.resume(e,"");end
e=d;
return a();
end
local o,t=t.resume(e,i);
if t then
e=d;
return a(t);
end
end;
};
end
return _M;
end)
package.preload['net.http']=(function(...)
local c=require"socket"
local m=require"mime"
local f=require"socket.url"
local s=require"util.httpstream".new;
local u=require"net.server"
local e=require"net.connlisteners".get;
local i=e("httpclient")or error("No httpclient listener!");
local o,y=table.insert,table.concat;
local n,w=pairs,ipairs;
local d,r,v,p,h,a,t=
tonumber,tostring,xpcall,select,debug.traceback,string.char,string.format;
local l=require"util.logger".init("http");
module"http"
function urlencode(e)return e and(e:gsub("%W",function(e)return t("%%%02x",e:byte());end));end
function urldecode(e)return e and(e:gsub("%%(%x%x)",function(e)return a(d(e,16));end));end
local function e(e)
return e and(e:gsub("%W",function(e)
if e~=" "then
return t("%%%02x",e:byte());
else
return"+";
end
end));
end
function formencode(t)
local a={};
if t[1]then
for i,t in w(t)do
o(a,e(t.name).."="..e(t.value));
end
else
for t,i in n(t)do
o(a,e(t).."="..e(i));
end
end
return y(a,"&");
end
function formdecode(e)
if not e:match("=")then return urldecode(e);end
local a={};
for t,e in e:gmatch("([^=&]*)=([^&]*)")do
t,e=t:gsub("%+","%%20"),e:gsub("%+","%%20");
t,e=urldecode(t),urldecode(e);
o(a,{name=t,value=e});
a[t]=e;
end
return a;
end
local function y(e,a,t)
if not e.parser then
if not a then return;end
local function o(t)
if e.callback then
for a,t in n(t)do e[a]=t;end
e.callback(t.body,t.code,e,t);
e.callback=nil;
end
destroy_request(e);
end
local function a(t)
if e.callback then
e.callback(t or"connection-closed",0,e);
e.callback=nil;
end
destroy_request(e);
end
local function t()
return e;
end
e.parser=s(o,a,"client",t);
end
e.parser:feed(a);
end
local function w(e)l("error","Traceback[http]: %s: %s",r(e),h());end
function request(e,t,h)
local e=f.parse(e);
if not(e and e.host)then
h(nil,0,e);
return nil,"invalid-url";
end
if not e.path then
e.path="/";
end
local s,a,o;
a={
["Host"]=e.host;
["User-Agent"]="Prosody XMPP Server";
};
if e.userinfo then
a["Authorization"]="Basic "..m.b64(e.userinfo);
end
if t then
e.onlystatus=t.onlystatus;
o=t.body;
if o then
s="POST";
a["Content-Length"]=r(#o);
a["Content-Type"]="application/x-www-form-urlencoded";
end
if t.method then s=t.method;end
if t.headers then
for t,e in n(t.headers)do
a[t]=e;
end
end
end
e.method,e.headers,e.body=s,a,o;
local n=e.scheme=="https";
local o=d(e.port)or(n and 443 or 80);
local t=c.tcp();
t:settimeout(10);
local s,a=t:connect(e.host,o);
if not s and a~="timeout"then
h(nil,0,e);
return nil,a;
end
e.handler,e.conn=u.wrapclient(t,e.host,o,i,"*a",n and{mode="client",protocol="sslv23"});
e.write=function(...)return e.handler:write(...);end
e.callback=function(i,t,a,o)l("debug","Calling callback, status %s",t or"---");return p(2,v(function()return h(i,t,a,o)end,w));end
e.reader=y;
e.state="status";
i.register_request(e.handler,e);
return e;
end
function destroy_request(e)
if e.conn then
e.conn=nil;
e.handler:close()
i.ondisconnect(e.handler,"closed");
end
end
_M.urlencode=urlencode;
return _M;
end)
package.preload['verse.bosh']=(function(...)
local r=require"util.xmppstream".new;
local h=require"util.stanza";
require"net.httpclient_listener";
local o=require"net.http";
local e=setmetatable({},{__index=verse.stream_mt});
e.__index=e;
local s="http://etherx.jabber.org/streams";
local n="http://jabber.org/protocol/httpbind";
local i=5;
function verse.new_bosh(a,t)
local t={
bosh_conn_pool={};
bosh_waiting_requests={};
bosh_rid=math.random(1,999999);
bosh_outgoing_buffer={};
bosh_url=t;
conn={};
};
function t:reopen()
self.bosh_need_restart=true;
self:flush();
end
local t=verse.new(a,t);
return setmetatable(t,e);
end
function e:connect()
self:_send_session_request();
end
function e:send(e)
self:debug("Putting into BOSH send buffer: %s",tostring(e));
self.bosh_outgoing_buffer[#self.bosh_outgoing_buffer+1]=h.clone(e);
self:flush();
end
function e:flush()
if self.connected
and#self.bosh_waiting_requests<self.bosh_max_requests
and(#self.bosh_waiting_requests==0
or#self.bosh_outgoing_buffer>0
or self.bosh_need_restart)then
self:debug("Flushing...");
local e=self:_make_body();
local t=self.bosh_outgoing_buffer;
for a,o in ipairs(t)do
e:add_child(o);
t[a]=nil;
end
self:_make_request(e);
else
self:debug("Decided not to flush.");
end
end
function e:_make_request(a)
local e,t=o.request(self.bosh_url,{body=tostring(a)},function(o,e,t)
if e~=0 then
self.inactive_since=nil;
return self:_handle_response(o,e,t);
end
local e=os.time();
if not self.inactive_since then
self.inactive_since=e;
elseif e-self.inactive_since>self.bosh_max_inactivity then
return self:_disconnected();
else
self:debug("%d seconds left to reconnect, retrying in %d seconds...",
self.bosh_max_inactivity-(e-self.inactive_since),i);
end
timer.add_task(i,function()
self:debug("Retrying request...");
for e,a in ipairs(self.bosh_waiting_requests)do
if a==t then
table.remove(self.bosh_waiting_requests,e);
break;
end
end
self:_make_request(a);
end);
end);
if e then
table.insert(self.bosh_waiting_requests,e);
else
self:warn("Request failed instantly: %s",t);
end
end
function e:_disconnected()
self.connected=nil;
self:event("disconnected");
end
function e:_send_session_request()
local e=self:_make_body();
e.attr.hold="1";
e.attr.wait="60";
e.attr["xml:lang"]="en";
e.attr.ver="1.6";
e.attr.from=self.jid;
e.attr.to=self.host;
e.attr.secure='true';
o.request(self.bosh_url,{body=tostring(e)},function(e,t)
if t==0 then
return self:_disconnected();
end
local e=self:_parse_response(e)
if not e then
self:warn("Invalid session creation response");
self:_disconnected();
return;
end
self.bosh_sid=e.attr.sid;
self.bosh_wait=tonumber(e.attr.wait);
self.bosh_hold=tonumber(e.attr.hold);
self.bosh_max_inactivity=tonumber(e.attr.inactivity);
self.bosh_max_requests=tonumber(e.attr.requests)or self.bosh_hold;
self.connected=true;
self:event("connected");
self:_handle_response_payload(e);
end);
end
function e:_handle_response(a,t,e)
if self.bosh_waiting_requests[1]~=e then
self:warn("Server replied to request that wasn't the oldest");
for t,a in ipairs(self.bosh_waiting_requests)do
if a==e then
self.bosh_waiting_requests[t]=nil;
break;
end
end
else
table.remove(self.bosh_waiting_requests,1);
end
local e=self:_parse_response(a);
if e then
self:_handle_response_payload(e);
end
self:flush();
end
function e:_handle_response_payload(t)
local e=t.tags;
for t=1,#e do
local e=e[t];
if e.attr.xmlns==s then
self:event("stream-"..e.name,e);
elseif e.attr.xmlns then
self:event("stream/"..e.attr.xmlns,e);
else
self:event("stanza",e);
end
end
if t.attr.type=="terminate"then
self:_disconnected({reason=t.attr.condition});
end
end
local a={
stream_ns="http://jabber.org/protocol/httpbind",stream_tag="body",
default_ns="jabber:client",
streamopened=function(e,t)e.notopen=nil;e.payload=verse.stanza("body",t);return true;end;
handlestanza=function(t,e)t.payload:add_child(e);end;
};
function e:_parse_response(e)
self:debug("Parsing response: %s",e);
if e==nil then
self:debug("%s",debug.traceback());
self:_disconnected();
return;
end
local t={notopen=true,stream=self};
local a=r(t,a);
a:feed(e);
return t.payload;
end
function e:_make_body()
self.bosh_rid=self.bosh_rid+1;
local e=verse.stanza("body",{
xmlns=n;
content="text/xml; charset=utf-8";
sid=self.bosh_sid;
rid=self.bosh_rid;
});
if self.bosh_need_restart then
self.bosh_need_restart=nil;
e.attr.restart='true';
end
return e;
end
end)
package.preload['verse.client']=(function(...)
local t=require"verse";
local o=t.stream_mt;
local s=require"util.jid".split;
local h=require"net.adns";
local e=require"lxp";
local a=require"util.stanza";
t.message,t.presence,t.iq,t.stanza,t.reply,t.error_reply=
a.message,a.presence,a.iq,a.stanza,a.reply,a.error_reply;
local r=require"util.xmppstream".new;
local n="http://etherx.jabber.org/streams";
local function d(t,e)
return t.priority<e.priority or(t.priority==e.priority and t.weight>e.weight);
end
local i={
stream_ns=n,
stream_tag="stream",
default_ns="jabber:client"};
function i.streamopened(e,t)
e.stream_id=t.id;
if not e:event("opened",t)then
e.notopen=nil;
end
return true;
end
function i.streamclosed(e)
e.notopen=true;
if not e.closed then
e:send("</stream:stream>");
e.closed=true;
end
e:event("closed");
return e:close("stream closed")
end
function i.handlestanza(t,e)
if e.attr.xmlns==n then
return t:event("stream-"..e.name,e);
elseif e.attr.xmlns then
return t:event("stream/"..e.attr.xmlns,e);
end
return t:event("stanza",e);
end
function i.error(a,t,e)
if a:event(t,e)==nil then
local t=e:get_child(nil,"urn:ietf:params:xml:ns:xmpp-streams");
local e=e:get_child_text("text","urn:ietf:params:xml:ns:xmpp-streams");
error(t.name..(e and": "..e or""));
end
end
function o:reset()
if self.stream then
self.stream:reset();
else
self.stream=r(self,i);
end
self.notopen=true;
return true;
end
function o:connect_client(e,a)
self.jid,self.password=e,a;
self.username,self.host,self.resource=s(e);
self:add_plugin("tls");
self:add_plugin("sasl");
self:add_plugin("bind");
self:add_plugin("session");
function self.data(t,e)
local t,a=self.stream:feed(e);
if t then return;end
self:debug("debug","Received invalid XML (%s) %d bytes: %s",tostring(a),#e,e:sub(1,300):gsub("[\r\n]+"," "));
self:close("xml-not-well-formed");
end
self:hook("connected",function()self:reopen();end);
self:hook("incoming-raw",function(e)return self.data(self.conn,e);end);
self.curr_id=0;
self.tracked_iqs={};
self:hook("stanza",function(t)
local e,a=t.attr.id,t.attr.type;
if e and t.name=="iq"and(a=="result"or a=="error")and self.tracked_iqs[e]then
self.tracked_iqs[e](t);
self.tracked_iqs[e]=nil;
return true;
end
end);
self:hook("stanza",function(e)
local a;
if e.attr.xmlns==nil or e.attr.xmlns=="jabber:client"then
if e.name=="iq"and(e.attr.type=="get"or e.attr.type=="set")then
local o=e.tags[1]and e.tags[1].attr.xmlns;
if o then
a=self:event("iq/"..o,e);
if not a then
a=self:event("iq",e);
end
end
if a==nil then
self:send(t.error_reply(e,"cancel","service-unavailable"));
return true;
end
else
a=self:event(e.name,e);
end
end
return a;
end,-1);
self:hook("outgoing",function(e)
if e.name then
self:event("stanza-out",e);
end
end);
self:hook("stanza-out",function(e)
if not e.attr.xmlns then
self:event(e.name.."-out",e);
end
end);
local function e()
self:event("ready");
end
self:hook("session-success",e,-1)
self:hook("bind-success",e,-1);
local t=self.close;
function self:close(e)
self.close=t;
if not self.closed then
self:send("</stream:stream>");
self.closed=true;
else
return self:close(e);
end
end
local function t()
self:connect(self.connect_host or self.host,self.connect_port or 5222);
end
if not(self.connect_host or self.connect_port)then
h.lookup(function(a)
if a then
local e={};
self.srv_hosts=e;
for a,t in ipairs(a)do
table.insert(e,t.srv);
end
table.sort(e,d);
local a=e[1];
self.srv_choice=1;
if a then
self.connect_host,self.connect_port=a.target,a.port;
self:debug("Best record found, will connect to %s:%d",self.connect_host or self.host,self.connect_port or 5222);
end
self:hook("disconnected",function()
if self.srv_hosts and self.srv_choice<#self.srv_hosts then
self.srv_choice=self.srv_choice+1;
local e=e[self.srv_choice];
self.connect_host,self.connect_port=e.target,e.port;
t();
return true;
end
end,1e3);
self:hook("connected",function()
self.srv_hosts=nil;
end,1e3);
end
t();
end,"_xmpp-client._tcp."..(self.host)..".","SRV");
else
t();
end
end
function o:reopen()
self:reset();
self:send(a.stanza("stream:stream",{to=self.host,["xmlns:stream"]='http://etherx.jabber.org/streams',
xmlns="jabber:client",version="1.0"}):top_tag());
end
function o:send_iq(e,a)
local t=self:new_id();
self.tracked_iqs[t]=a;
e.attr.id=t;
self:send(e);
end
function o:new_id()
self.curr_id=self.curr_id+1;
return tostring(self.curr_id);
end
end)
package.preload['verse.component']=(function(...)
local a=require"verse";
local o=a.stream_mt;
local h=require"util.jid".split;
local e=require"lxp";
local t=require"util.stanza";
local r=require"util.sha1".sha1;
a.message,a.presence,a.iq,a.stanza,a.reply,a.error_reply=
t.message,t.presence,t.iq,t.stanza,t.reply,t.error_reply;
local d=require"util.xmppstream".new;
local s="http://etherx.jabber.org/streams";
local i="jabber:component:accept";
local n={
stream_ns=s,
stream_tag="stream",
default_ns=i};
function n.streamopened(e,t)
e.stream_id=t.id;
if not e:event("opened",t)then
e.notopen=nil;
end
return true;
end
function n.streamclosed(e)
return e:event("closed");
end
function n.handlestanza(t,e)
if e.attr.xmlns==s then
return t:event("stream-"..e.name,e);
elseif e.attr.xmlns or e.name=="handshake"then
return t:event("stream/"..(e.attr.xmlns or i),e);
end
return t:event("stanza",e);
end
function o:reset()
if self.stream then
self.stream:reset();
else
self.stream=d(self,n);
end
self.notopen=true;
return true;
end
function o:connect_component(e,n)
self.jid,self.password=e,n;
self.username,self.host,self.resource=h(e);
function self.data(t,e)
local a,t=self.stream:feed(e);
if a then return;end
o:debug("debug","Received invalid XML (%s) %d bytes: %s",tostring(t),#e,e:sub(1,300):gsub("[\r\n]+"," "));
o:close("xml-not-well-formed");
end
self:hook("incoming-raw",function(e)return self.data(self.conn,e);end);
self.curr_id=0;
self.tracked_iqs={};
self:hook("stanza",function(e)
local t,a=e.attr.id,e.attr.type;
if t and e.name=="iq"and(a=="result"or a=="error")and self.tracked_iqs[t]then
self.tracked_iqs[t](e);
self.tracked_iqs[t]=nil;
return true;
end
end);
self:hook("stanza",function(e)
local t;
if e.attr.xmlns==nil or e.attr.xmlns=="jabber:client"then
if e.name=="iq"and(e.attr.type=="get"or e.attr.type=="set")then
local o=e.tags[1]and e.tags[1].attr.xmlns;
if o then
t=self:event("iq/"..o,e);
if not t then
t=self:event("iq",e);
end
end
if t==nil then
self:send(a.error_reply(e,"cancel","service-unavailable"));
return true;
end
else
t=self:event(e.name,e);
end
end
return t;
end,-1);
self:hook("opened",function(e)
print(self.jid,self.stream_id,e.id);
local e=r(self.stream_id..n,true);
self:send(t.stanza("handshake",{xmlns=i}):text(e));
self:hook("stream/"..i,function(e)
if e.name=="handshake"then
self:event("authentication-success");
end
end);
end);
local function e()
self:event("ready");
end
self:hook("authentication-success",e,-1);
self:connect(self.connect_host or self.host,self.connect_port or 5347);
self:reopen();
end
function o:reopen()
self:reset();
self:send(t.stanza("stream:stream",{to=self.jid,["xmlns:stream"]='http://etherx.jabber.org/streams',
xmlns=i,version="1.0"}):top_tag());
end
function o:close(e)
if not self.notopen then
self:send("</stream:stream>");
end
local t=self.conn.disconnect();
self.conn:close();
t(conn,e);
end
function o:send_iq(e,a)
local t=self:new_id();
self.tracked_iqs[t]=a;
e.attr.id=t;
self:send(e);
end
function o:new_id()
self.curr_id=self.curr_id+1;
return tostring(self.curr_id);
end
end)
pcall(require,"luarocks.require");
pcall(require,"ssl");
local a=require"net.server";
local n=require"util.events";
local o=require"util.logger";
module("verse",package.seeall);
local e=_M;
_M.server=a;
local t={};
t.__index=t;
stream_mt=t;
e.plugins={};
function e.init(...)
for e=1,select("#",...)do
local t=pcall(require,"verse."..select(e,...));
if not t then
error("Verse connection module not found: verse."..select(e,...));
end
end
return e;
end
local i=0;
function e.new(o,a)
local t=setmetatable(a or{},t);
i=i+1;
t.id=tostring(i);
t.logger=o or e.new_logger("stream"..t.id);
t.events=n.new();
t.plugins={};
t.verse=e;
return t;
end
e.add_task=require"util.timer".add_task;
e.logger=o.init;
e.new_logger=o.init;
e.log=e.logger("verse");
local function i(a,...)
local e,t,o=0,{...},select('#',...);
return(a:gsub("%%(.)",function(a)if e<=o then e=e+1;return tostring(t[e]);end end));
end
function e.set_log_handler(e,t)
t=t or{"debug","info","warn","error"};
o.reset();
if io.type(e)=="file"then
local a=e;
function e(t,e,o)
a:write(t,"\t",e,"\t",o,"\n");
end
end
if e then
local function n(a,o,t,...)
return e(a,o,i(t,...));
end
for t,e in ipairs(t)do
o.add_level_sink(e,n);
end
end
end
function _default_log_handler(a,o,t)
return io.stderr:write(a,"\t",o,"\t",t,"\n");
end
e.set_log_handler(_default_log_handler,{"error"});
local function o(t)
e.log("error","Error: %s",t);
e.log("error","Traceback: %s",debug.traceback());
end
function e.set_error_handler(e)
o=e;
end
function e.loop()
return xpcall(a.loop,o);
end
function e.step()
return xpcall(a.step,o);
end
function e.quit()
return a.setquitting(true);
end
function t:listen(e,t)
e=e or"localhost";
t=t or 0;
local a,o=a.addserver(e,t,new_listener(self,"server"),"*a");
if a then
self:debug("Bound to %s:%s",e,t);
self.server=a;
end
return a,o;
end
function t:connect(t,o)
t=t or"localhost";
o=tonumber(o)or 5222;
local i=socket.tcp()
i:settimeout(0);
local n,e=i:connect(t,o);
if not n and e~="timeout"then
self:warn("connect() to %s:%d failed: %s",t,o,e);
return self:event("disconnected",{reason=e})or false,e;
end
local t=a.wrapclient(i,t,o,new_listener(self),"*a");
if not t then
self:warn("connection initialisation failed: %s",e);
return self:event("disconnected",{reason=e})or false,e;
end
self:set_conn(t);
return true;
end
function t:set_conn(t)
self.conn=t;
self.send=function(a,e)
self:event("outgoing",e);
e=tostring(e);
self:event("outgoing-raw",e);
return t:write(e);
end;
end
function t:close(t)
if not self.conn then
e.log("error","Attempt to close disconnected connection - possibly a bug");
return;
end
local e=self.conn.disconnect();
self.conn:close();
e(self.conn,t);
end
function t:debug(...)
return self.logger("debug",...);
end
function t:info(...)
return self.logger("info",...);
end
function t:warn(...)
return self.logger("warn",...);
end
function t:error(...)
return self.logger("error",...);
end
function t:event(e,...)
self:debug("Firing event: "..tostring(e));
return self.events.fire_event(e,...);
end
function t:hook(e,...)
return self.events.add_handler(e,...);
end
function t:unhook(t,e)
return self.events.remove_handler(t,e);
end
function e.eventable(e)
e.events=n.new();
e.hook,e.unhook=t.hook,t.unhook;
local t=e.events.fire_event;
function e:event(e,...)
return t(e,...);
end
return e;
end
function t:add_plugin(t)
if self.plugins[t]then return true;end
if require("verse.plugins."..t)then
local a,e=e.plugins[t](self);
if a~=false then
self:debug("Loaded %s plugin",t);
self.plugins[t]=true;
else
self:warn("Failed to load %s plugin: %s",t,e);
end
end
return self;
end
function new_listener(t)
local a={};
function a.onconnect(a)
if t.server then
local e=e.new();
a:setlistener(new_listener(e));
e:set_conn(a);
t:event("connected",{client=e});
else
t.connected=true;
t:event("connected");
end
end
function a.onincoming(a,e)
t:event("incoming-raw",e);
end
function a.ondisconnect(e,a)
if e~=t.conn then return end
t.connected=false;
t:event("disconnected",{reason=a});
end
function a.ondrain(e)
t:event("drained");
end
function a.onstatus(a,e)
t:event("status",e);
end
return a;
end
return e;
