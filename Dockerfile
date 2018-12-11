FROM node

RUN apt-get update && apt-get install -y postgresql-client
WORKDIR /opt/app
ADD . .

CMD COUNTRY=id npm run build
