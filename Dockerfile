FROM node:20-alpine3.20 AS builder
WORKDIR /app
RUN apk update && apk upgrade
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build


FROM nginx:1.27-alpine3.20 AS runtime
RUN apk update && apk upgrade
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost/health || exit 1
CMD ["nginx", "-g", "daemon off;"]