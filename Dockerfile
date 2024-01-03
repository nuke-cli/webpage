FROM node:17-alpine

WORKDIR /app
COPY package.json ./
RUN yarn install
COPY . .
EXPOSE 8080
ENV HOST=0.0.0.0

CMD ["yarn", "start"]