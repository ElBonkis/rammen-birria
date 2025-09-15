FROM node:20
WORKDIR /app

COPY package.json package-lock.json* ./

RUN npm ci || npm i

COPY . .

EXPOSE 5173

