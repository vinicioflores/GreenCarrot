FROM node:8

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json /usr/src/app/


RUN npm config set proxy http://proxy-chain.intel.com:911  && npm config set https-proxy http://proxy-chain.intel.com:911 && npm install
# If you are building your code for production
# RUN npm install --only=production

# Bundle app source
COPY . /usr/src/app/

EXPOSE 3000

CMD [ "npm", "start" ]


