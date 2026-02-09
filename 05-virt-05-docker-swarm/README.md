## Оркестрация кластером Docker контейнеров на примере Docker Swarm

```
sudo apt-get install ca-certificates curl gnupg lsb-release

sudo apt-get update

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo   "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee \ /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo docker swarm init --advertise-addr 10.130.0.18

sudo docker swarm join --token SWMTKN-1-1st4kp8e6wtuv9k7rlmq7ne6129mywgbp2vbo7q8nfu5b2o7ll-dfibu865cbxsvkqeu2bgoe5aa 10.130.0.18:2377

```
