local plugin_dir = assert(arg[1], "plugin directory argument is required")
local mirror_url = assert(os.getenv("ANDROID_SDK_MIRROR_URL"), "mirror URL must be set")

local resource = assert(io.open(plugin_dir .. "/test/resources/repository2-3.xml", "r"))
local repository_xml = resource:read("*a")
resource:close()

local requested_urls = {}
package.preload.http = function()
    return {
        get = function(options)
            table.insert(requested_urls, options.url)
            return {
                status_code = 200,
                body = repository_xml,
            }
        end,
    }
end

PLUGIN = {}
assert(loadfile(plugin_dir .. "/hooks/available.lua"))()
local versions = PLUGIN:Available({})
assert(#versions == 2, "available hook should parse the mirror response")
assert(requested_urls[1] == mirror_url .. "/repository2-3.xml", "available hook ignored mirror URL")

RUNTIME = {
    osType = "linux",
    archType = "x86_64",
}
PLUGIN = {}
assert(loadfile(plugin_dir .. "/hooks/pre_install.lua"))()
local result = PLUGIN:PreInstall({ version = "13.0" })
assert(requested_urls[2] == mirror_url .. "/repository2-3.xml", "pre-install hook ignored mirror URL")
assert(
    result.url == mirror_url .. "/commandlinetools-linux-13.0.zip",
    "pre-install hook did not resolve the download against the mirror URL"
)
