A detailed description and instructions for artifact execution are provided in `README.md`.

#### Run from Docker Hub
```bash
docker run --privileged --cap-add=ALL -it -v /dev:/dev -v /lib/modules:/lib/modules chappie-fse20
```

#### Build and Run locally
```bash
docker build -t chappie-fse20 .
docker run --privileged --cap-add=ALL -it -v /dev:/dev -v /lib/modules:/lib/modules chappie-fse20
```
