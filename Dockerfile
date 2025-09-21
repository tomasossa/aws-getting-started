FROM node:lts-alpine AS base
WORKDIR /app

FROM base AS build
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build


FROM base AS app
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./

USER node

ENTRYPOINT ["node", "dist/index.js"]
