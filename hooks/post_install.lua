--- Called after the tool is installed.
--- Used to set up the correct directory structure for Android SDK.
--- @param ctx table
--- @field ctx.rootPath string The installation root path
--- @field ctx.sdkInfo table SDK information including version
function PLUGIN:PostInstall(ctx)
    local file = require("file")

    local root_path = ctx.rootPath

    -- Get the version from sdkInfo
    local version = nil
    for _, info in pairs(ctx.sdkInfo) do
        version = info.version
        break
    end

    if not version then
        error("Could not determine version from sdkInfo")
    end

    -- vfox extracts cmdline-tools contents directly to rootPath
    -- But Android SDK expects: ANDROID_HOME/cmdline-tools/VERSION/bin/sdkmanager
    -- So we need to reorganize: move rootPath/* to rootPath/cmdline-tools/VERSION/

    local temp_path = root_path .. "-temp"
    local parent_path = file.join_path(root_path, "cmdline-tools")
    local target_path = file.join_path(parent_path, version)

    -- Cross-platform file operations (works on Unix and Windows)
    local win = package.config:sub(1,1) == "\\"
    
    local function move(src, dst)
        if win then
            print('move "' .. src .. '" "' .. dst .. '"')
            return os.execute('move "' .. src .. '" "' .. dst .. '"')
        else
            return os.execute('mv "' .. src .. '" "' .. dst .. '"')
        end
    end
    
    local function mkdir(path)
        if win then
            os.execute('mkdir "' .. path .. '"')
        else
            os.execute('mkdir -p "' .. path .. '"')
        end
    end
    
    -- Move current rootPath to temp location
    move(root_path, temp_path)

    -- Recreate parent_path with proper structure
    mkdir(target_parent)

    -- Move temp to target
    move(temp_path, target_path)

    -- Verify installation
    if win then ext = ".bat" else ext = "" end
    local sdkmanager_path = file.join_path(target_path, "bin", "sdkmanager" .. ext)
    if not file.exists(sdkmanager_path) then
        error("Installation verification failed: sdkmanager not found at " .. sdkmanager_path)
    end

    -- Make sure binaries are executable (for Unix systems)
    if not win then
        os.execute("chmod +x " .. file.join_path(target_path, "bin", "*") .. " 2>/dev/null || true")
    end
end
