local env_parser = {}

-- Parse .env file content
local function parseEnvContent(content)
    local env = {}
    for line in content:gmatch("[^\r\n]+") do
        -- Skip comments and empty lines
        if not line:match("^%s*#") and not line:match("^%s*$") then
            local key, value = line:match("^([^=]+)=(.+)$")
            if key and value then
                -- Trim whitespace
                key = key:match("^%s*(.-)%s*$")
                value = value:match("^%s*(.-)%s*$")
                -- Remove quotes if present
                value = value:gsub('^["\'](.*)["\']$', '%1')
                env[key] = value
            end
        end
    end
    return env
end

-- Read .env file
local function readEnvFile(filename)
    local file = io.open(filename, "r")
    if file then
        local content = file:read("*all")
        file:close()
        return parseEnvContent(content)
    end
    return {}
end

-- Get environment variable with fallback sources
function env_parser.getEnvVar(name, options)
    options = options or {}
    local required = options.required or false
    local default = options.default
    local envFile = options.envFile or '.env'
    
    -- Try to get from os.getenv first
    local value = os.getenv(name)
    
    -- If not found in os.getenv, try reading from .env file
    if not value or value == '' then
        local envVars = readEnvFile(envFile)
        value = envVars[name]
    end
    
    -- If still not found and required, throw error
    if (not value or value == '') and required then
        error(string.format("Required environment variable '%s' not found in os.getenv or %s", name, envFile))
    end
    
    -- If not found and not required, return default
    if not value or value == '' then
        return default
    end
    
    return value
end

-- Get multiple environment variables at once
function env_parser.getEnvVars(vars)
    local result = {}
    for name, options in pairs(vars) do
        result[name] = env_parser.getEnvVar(name, options)
    end
    return result
end

-- Validate that all required environment variables are present
function env_parser.validateRequired(vars)
    local missing = {}
    for name, options in pairs(vars) do
        if options.required then
            local value = env_parser.getEnvVar(name, options)
            if not value or value == '' then
                table.insert(missing, name)
            end
        end
    end
    
    if #missing > 0 then
        error(string.format("Missing required environment variables: %s", table.concat(missing, ", ")))
    end
    
    return true
end

-- Load all environment variables from .env file into os.environ (if possible)
function env_parser.loadEnvFile(filename)
    filename = filename or '.env'
    local envVars = readEnvFile(filename)
    
    -- Note: In Lua, we can't directly modify os.environ, but we can return the parsed vars
    return envVars
end

return env_parser 