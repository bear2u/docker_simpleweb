# NodeJS 로 도커 시스템 구축

## package.json

```javascript
{
    "dependencies": {
        "express": "*"
    },
    "scripts": {
        "start": "node index.js"
    }
}
```

## index.js

```javascript
const express = require('express');

const app = express();

app.get('/', (req, res) => {
    res.send('Hi there');
});

app.listen(8080, () => {
    console.log('Listening on port 8080');
});
```

## Dockerfile

```cmd
# Specify a base image
From alpine

# install some depenendencies
RUN npm install

# Default command
CMD ["npm": "start"] 
```

실행시 node를 찾을수가 없다. 이유는 alpine은 리눅스 기본 이미지이기 때문에 node가 포함되어 있지 않다. 
node:alpine을 지정해서 사용할 수 있다. 
