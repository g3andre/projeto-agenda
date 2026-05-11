# syntax=docker/dockerfile:1

# Node 16: webpack 5 + css-loader 5.x falham no toolchain OpenSSL/postcss mais novos (Node 20+).
FROM node:16-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npx webpack --mode production

FROM node:20-alpine AS production

WORKDIR /app

ENV NODE_ENV=production

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY --from=builder /app/public ./public
COPY server.js routes.js ./
COPY src ./src

RUN chown -R node:node /app

USER node

EXPOSE 3030

CMD ["node", "server.js"]
