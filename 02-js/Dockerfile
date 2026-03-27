# npm Alpine Linux version
FROM node:20-alpine

# set working directory in the container
WORKDIR /app

# copy package.json and package-lock.json to the container
COPY package*.json ./

# install dependencies
RUN npm install

# copy the rest of the code to the container
COPY . .

# Default command that will run when you start the container:
# Runs the script that copies files to the /out directory
CMD ["npm", "run", "deploy:docker"]