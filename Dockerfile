# Specify a base image
From node:alpine

# install some depenendencies
RUN npm install

# Default command
CMD ["npm": "start"] 