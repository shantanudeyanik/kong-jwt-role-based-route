package = "jwt-role-based-route"
version = "0.1-1"
rockspec_format = "3.0"
source = {
    url = "git://github.com/shantanudeyanik/kong-jwt-role-based-route",
    tag = "1.0.0",
    dir = "kong-jwt-role-based-route"
}
description = {
  summary = "A custom Kong plugin for role-based route authorization",
  homepage = "https://github.com/shantanudeyanik/kong-jwt-role-based-route",
  license = "Apache-2.0",
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.jwt-role-based-route.handler"] = "handler.lua",
    ["kong.plugins.jwt-role-based-route.schema"] = "schema.lua",
  },
}
