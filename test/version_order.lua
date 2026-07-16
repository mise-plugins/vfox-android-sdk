local plugin_dir = assert(arg[1], "plugin directory argument is required")

local repository_xml = [[
<sdk-repository>
  <remotePackage path="cmdline-tools;1.0"></remotePackage>
  <remotePackage path="cmdline-tools;9.0"></remotePackage>
  <remotePackage path="cmdline-tools;10.0"></remotePackage>
  <remotePackage path="cmdline-tools;22.0"></remotePackage>
  <remotePackage path="cmdline-tools;2.1"></remotePackage>
  <remotePackage path="cmdline-tools;latest"></remotePackage>
</sdk-repository>
]]

package.preload.http = function()
    return {
        get = function()
            return {
                status_code = 200,
                body = repository_xml,
            }
        end,
    }
end

package.preload.env = function()
    return {}
end

PLUGIN = {}
assert(loadfile(plugin_dir .. "/hooks/available.lua"))()
local versions = PLUGIN:Available({})
local expected = { "22.0", "10.0", "9.0", "2.1", "1.0" }

assert(#versions == #expected, "available hook returned an unexpected number of versions")
for index, expected_version in ipairs(expected) do
    assert(
        versions[index].version == expected_version,
        "version at index "
            .. index
            .. " should be "
            .. expected_version
            .. ", got "
            .. tostring(versions[index].version)
    )
end
