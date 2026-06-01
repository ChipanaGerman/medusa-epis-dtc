
import { loadEnv, defineConfig } from '@medusajs/framework/utils'
const STORE_CORS = process.env.STORE_CORS || "http://localhost:8000"
const ADMIN_CORS = process.env.ADMIN_CORS || "http://localhost:9000,http://localhost:5173"
loadEnv(process.env.NODE_ENV || 'development', process.cwd())

module.exports = defineConfig({
  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    http: {
      storeCors: process.env.STORE_CORS!,
      adminCors: process.env.ADMIN_CORS!,
      authCors: process.env.AUTH_CORS!,
      jwtSecret: process.env.JWT_SECRET || "supersecret",
      cookieSecret: process.env.COOKIE_SECRET || "supersecret",
    },
    databaseDriverOptions: {
      ssl: false,
      sslmode: "disable",
    },
    redisUrl: process.env.REDIS_URL,
  },
  admin: {
    vite: (config) => {
      return {
        server: {
          host: "0.0.0.0",
          hmr: {
            port: 5173,
            clientPort: 5173,
          },
        },
      }
    },
  },
})