# Use official Node.js base image
FROM node:18

WORKDIR /usr/src/app

COPY server.js .

EXPOSE 8081

# Command to run app
CMD ["node", "server.js"]
