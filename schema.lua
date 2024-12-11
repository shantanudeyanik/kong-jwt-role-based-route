local typedefs = require "kong.db.schema.typedefs"

return {
  name = "jwt-role-based-route",
  fields = {
    {
      -- This plugin does not apply to consumers
      consumer = typedefs.no_consumer
    },
    {
      -- This plugin only runs within Nginx HTTP module
      protocols = typedefs.protocols_http
    },
    {
      config = {
        type = "record",
        fields = {
          {
            redis_host = {
              type = "string",
              required = true,
              default = "127.0.0.1"
            }
          },
          {
            redis_port = {
              type = "number",
              required = true,
              default = 6379
            }
          },
          {
            redis_timeout = {
              type = "number",
              required = true,
              default = 1000
            }
          },
          {
            role_array_var = {
              type = "string",
              required = true,
              default = "role"
            }
          }
        }
      }
    }
  }
}
