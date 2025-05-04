
# Docker 기반 환경을 구성해 두었습니다.
## build
* 우선 build 명령어를 통해서 docker image를 만들어야 합니다.
* image_name은 편한대로 지정해 주시면 됩니다.  저는 rl 이라는 이름을 사용했습니다.
  - 명령어: ```docker build -t {image_name}:{tag} .```
  - 예시: ```docker build -t rl .```
* ```docker images``` 명령어를 통해서 image가 잘 생성되었는지 확인합니다.

## 실행
* Dockerfile은 jupyter lab에 대한 환경만 설정하고 있습니다.  
* 파일이나 결과물은 현재 폴더에 저장되어야 하기 때문에 현재 폴더에 대한 공유가 필요합니다. (필요시 폴더는 적당히 조절해 주세요 ㅎ)  
  - ```docker run -d --rm -p {port}:8888 -v $(pwd):/app --name {container_name} {image_name}:{tag}```
  - 예시: ```docker run -d --rm -p 8080:8888 -v $(pwd):/app --name jupyter rl:latest```
* jupyter 접속시에 token 필요하니 로그를 통해서 확인해 주세요.
  - ```docker logs {container_name} 2>&1 | grep token | cut -d '=' -f 2 | uniq```
  - 예시: ```docker logs jupyter 2>&1 | grep token | cut -d '=' -f 2 | uniq```

## 종료
```docker stop {container_name}```
