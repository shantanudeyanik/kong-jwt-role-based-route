-- local BasePlugin = require "kong.plugins.base_plugin"
local redis = require "resty.redis"
local cjson = require "cjson.safe"
local jwt = require "resty.jwt"

-- local RoleHandler = BasePlugin:extend()

local RoleHandler = {
  VERSION = "0.1-1",
  PRIORITY = 900  
}

-- function RoleHandler:new()
--   RoleHandler.super.new(self, "jwt-role-based-route")
-- end

function RoleHandler:access(conf)
--  RoleHandler.super.access(self)

  -- Helper function for error responses
  local function respond_with_error(status, message, details)
    kong.response.exit(status, { error = message, details = details })
  end

  -- Retrieve Authorization header
  local auth_header = kong.request.get_header("authorization")
  if not auth_header then
    respond_with_error(401, "Authorization header missing")
  end

  -- Extract Bearer token
  -- local token = string.match(auth_header, "[Bb]earer%s+(.+)")
  local token = string.match(auth_header, "[Bb]earer%s+(.+)") and string.match(auth_header, "[Bb]earer%s+(.+)"):match("^%s*(.-)%s*$")
  if not token then
    respond_with_error(400, "Invalid Authorization header format")
  end

  -- Decode JWT (no verification)
  local jwt_obj = jwt:load_jwt(token)
  if not jwt_obj or not jwt_obj.payload then
    respond_with_error(401, "Invalid token")
  end

  -- Extract role from the token payload
  local role_array_var = conf.role_array_var
  local role = jwt_obj.payload[role_array_var]
  if not role then
    respond_with_error(403, "Role not found in token")
  end

  -- Connect to Redis
  local red = redis:new()
  red:set_timeout(conf.redis_timeout)

  local ok, err = red:connect(conf.redis_host, conf.redis_port)
  if not ok then
    respond_with_error(500, "Failed to connect to Redis", err)
  end

  -- Fetch allowed routes for the role
  local allowed_routes_json, err = red:get("role:" .. role)
  red:set_keepalive(10000, 100)  -- Release connection back to the pool

  if not allowed_routes_json or allowed_routes_json == ngx.null then
    respond_with_error(403, "No routes defined for role", { role = role })
  end

  -- Decode the allowed routes JSON
  local allowed_routes, decode_err = cjson.decode(allowed_routes_json)
  if not allowed_routes then
    respond_with_error(500, "Failed to decode routes", decode_err)
  end

  -- Check if the current route is allowed
  local current_route = kong.request.get_path()
  local is_allowed = false

  for _, route in ipairs(allowed_routes) do
    if route == current_route then
      is_allowed = true
      break
    end
  end

  if not is_allowed then
    respond_with_error(403, "Access denied", { role = role, route = current_route })
  end

  -- Allow access
  kong.response.set_header("X-Role", role)
end

return RoleHandler
