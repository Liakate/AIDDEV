-- AIDDEV compliance self-checks
AIDDEV = AIDDEV or {}
AIDDEV.Rules = AIDDEV.Rules or {}

AIDDEV = AIDDEV or {}
if not AIDDEV then return end
-- LuaLS environment setup for AIDDEV test harness
local basePath = arg[0]:gsub("[/\\]*[^/\\]-$", "")
package.path = "./script/?.lua;./script/?/init.lua;./test/?.lua;./test/?/init.lua;"
package.path = package.path .. basePath .. "/?.lua;"
package.path = package.path .. basePath .. "/?/init.lua"

_G.log = require "log"
local fs = require "bee.filesystem"

ROOT = fs.path(fs.exe_path():parent_path():parent_path():string())
TEST = true
DEVELOP = true
LUA_VER = "Lua 5.1"

require "Test-Helpers"

require "Test.Event-Tests"
require "Test.Message-Tests"
require "Test.TypeInjection-Tests"
