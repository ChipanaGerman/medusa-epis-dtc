FROM node:20-alpine
WORKDIR /app

RUN apk add --no-cache libc6-compat python3 make g++

# Instalar pnpm
RUN corepack enable && corepack prepare pnpm@10.11.1 --activate

# Copiar archivos de configuración del monorepo
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./

# Copiar package.json del backend
COPY apps/backend/package.json ./apps/backend/

# Instalar dependencias
RUN pnpm install --frozen-lockfile

# Copiar código fuente del backend
COPY apps/backend ./apps/backend

WORKDIR /app/apps/backend

EXPOSE 9000
ENV NODE_ENV=production

CMD sh -c "pnpm medusa db:migrate && pnpm start"