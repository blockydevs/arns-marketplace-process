package = "arns-marketplace-process"
version = "0.1.0-1"

description = {
  summary = "ARnS Marketplace AO process modules",
  detailed = [[
ARnS Marketplace process implementation for AO. This rock provides the core
Lua modules used to run the marketplace, including order management, activity
tracking, auctions, and utilities.
  ]],
  homepage = "https://github.com/ArweaveTeam/arns-marketplace-process",
  license = "MIT",
}

source = {
  dir = ".",
  url = "https://github.com/blockydevs/arns-marketplace-process"
}

dependencies = {
  "lua >= 5.4",
  "bint",
  "json-lua",
}

build = {
  type = "builtin",
  modules = {
    ["activity"] = "src/activity.lua",
    ["dutch_auction"] = "src/dutch_auction.lua",
    ["english_auction"] = "src/english_auction.lua",
    ["fixed_price"] = "src/fixed_price.lua",
    ["process"] = "src/process.lua",
    ["ucm"] = "src/ucm.lua",
    ["utils"] = "src/utils.lua",
  }
}
