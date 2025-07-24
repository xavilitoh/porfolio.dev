FROM node:20-alpine AS base
WORKDIR /app
# Copiamos solo los archivos de dependencias para instalar módulos
COPY package.json package-lock.json ./

# Instalamos dependencias de producción
FROM base AS prod-deps
RUN npm install --production

# Instalamos todas las dependencias para el build
FROM base AS build-deps
RUN npm install

# Copiamos el código fuente y construimos la app
FROM build-deps AS build
COPY . .
RUN npm run build

# Imagen final, solo con lo necesario para producción
FROM node:20-alpine AS runtime
WORKDIR /app
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
ENV HOST=0.0.0.0
ENV PORT=4321
EXPOSE 4321
CMD ["node", "./dist/server/entry.mjs"]