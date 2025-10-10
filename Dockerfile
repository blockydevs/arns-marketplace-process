# Minimal image for running Lua tests in this repository
# - Installs lua5.4 and luarocks
# - DOES NOT install external JSON libraries (dkjson/lua-cjson)
# - Prioritizes in-repo src/json.lua via LUA_PATH

FROM nickblah/lua:5.4-luarocks-bookworm

# Install required Lua rocks (target Lua 5.4 explicitly)
RUN luarocks install bint

# Default command: show lua version; CI will override with specific steps
CMD ["lua", "-v"]
