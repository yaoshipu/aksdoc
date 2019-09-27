FROM node:12.8.0-alpine

RUN npm i docsify-cli -g

RUN docsify init ./docs

ADD docs/ ./docs

CMD ["docsify", "serve", "./docs", "-p", "80"]

EXPOSE 80