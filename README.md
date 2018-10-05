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
CMD ["npm", "start"] 
```

실행시 node를 찾을수가 없다. 이유는 alpine은 리눅스 기본 이미지이기 때문에 node가 포함되어 있지 않다.<br/> 
node:alpine을 지정해서 사용할 수 있다. 


```cmd
# Specify a base image
From node:alpine

# install some depenendencies
RUN npm install

# Default command
CMD ["npm", "start"] 
```

```
npm WARN saveError ENOENT: no such file or directory, open '/package.json'
npm notice created a lockfile as package-lock.json. You should commit this file.
npm WARN enoent ENOENT: no such file or directory, open '/package.json'
npm WARN !invalid#2 No description
npm WARN !invalid#2 No repository field.
npm WARN !invalid#2 No README data
npm WARN !invalid#2 No license field.
```

node:alpine container 에는 package.json 파일이 포함되어 있지 않다. 그래서 오류가 표시됨

해결방법 : Docker image에 파일을 복사하는 명령어를 붙인다. 

```cmd
# Specify a base image
FROM node:alpine

# install some depenendencies
COPY ./ ./
RUN npm install

# Default command
CMD ["npm", "start"] 
```

이지지를 commit 오류가 나올텐데 이미지를 생성하는 명령어를 붙여보자.

```cmd
>> docker build -t gdgbusan/simpleweb .

Sending build context to Docker daemon  66.05kB
Step 1/4 : FROM node:alpine
 ---> 5206c0dd451a
Step 2/4 : COPY ./ ./
 ---> Using cache
 ---> d0fe38353187
Step 3/4 : RUN npm install
 ---> Using cache
 ---> 893984d57822
Step 4/4 : CMD ["npm": "start"]
 ---> Using cache
 ---> e7716218c007
Successfully built e7716218c007
Successfully tagged gdgbusan/simpleweb:latest
```

```cmd
>> docker images

....
gdgbusan/simpleweb   latest              e7716218c007        2 minutes ago       72.9MB
....

```

이제 실행을 해보자. 

```cmd
docker run gdgbusan/simpleweb


> @ start /
> node index.js

Listening on port 8080
```

잘 되는 걸 확인 할 수 있다.

## 포트 바인딩 문제

Web에서 호출시 페이지를 찾을수 없는 오류가 나올것이다. <br/>
localhost 에서는 8080으로 호출하지만 docker 에는 8080으로 바인딩이 안되어 있기 때문에 오류가 나는 것이다.

```cmd
>> docker run -p 8080:8080 gdgbusan/simpleweb
```

## 작업 디렉토리 문제

빌드를 하는 경우 기존 파일이나 폴더등이 겹칠수 있는 문제가 발생할 수 있다. 

```cmd
>> docker run -it gdgbusan/simpleweb sh
/ # ls
Dockerfile         bin                etc                index.js           media              node_modules       package-lock.json  proc               run                srv                tmp                var
README.md          dev                home               lib                mnt                opt                package.json       root               sbin               sys                usr
```
위 내용에서 만약 lib 또는 usr 라는 폴더가 로컬에서 작업 디렉토리로 있는 경우 문제가 될 수 있다. 

### 해결 방안

작업 영역을 따로 지정해줘서 소스를 다 옮겨준다.

```cmd
.Dockerfile

# Specify a base image
FROM node:alpine

## Define WORKDIR
WORKDIR /user/app

# install some depenendencies
COPY ./ ./
RUN npm install

# Default command
CMD ["npm", "start"] 

```

```cmd
> docker run -it gdgbusan/simpleweb sh

/user/app # ls
Dockerfile         README.md          index.js           node_modules       package-lock.json  package.json

```

```/user/app``` 으로 들어간걸 볼수 있다. 

Container ID 를 이용해서 접속 할 수 있다. 
```cmd
>> docker ps
CONTAINER ID        IMAGE                COMMAND             CREATED             STATUS              PORTS                    NAMES
570087c1cc0d        gdgbusan/simpleweb   "npm start"         4 minutes ago       Up 4 minutes        0.0.0.0:8080->8080/tcp   sleepy_archimedes
>> docker exec -it 5700 sh
/user/app # ls
Dockerfile         README.md          index.js           node_modules       package-lock.json  package.json
```


