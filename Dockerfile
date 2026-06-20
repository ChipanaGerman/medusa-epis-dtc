FROM node:20-alpine
WORKDIR /app

RUN apk add --no-cache libc6-compat python3 make g++

COPY package.json package-lock.json* ./
RUN npm install --legacy-peer-deps

COPY . .

RUN npm run build

EXPOSE 9000

# Migra y luego inicia en modo producción
CMD sh -c "npx medusa db:migrate && npx medusa start"