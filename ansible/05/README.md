## Домашнее задание к занятию 5 «Тестирование roles»

[Playbook Testing](https://docs.ansible.com/projects/molecule/getting-started-playbooks/)
[TOX](https://tox.wiki/en/latest/)

### Подготовка к выполнению

1. Установите molecule и его драйвера:

```bash
pip3 install molecule molecule_docker molecule_podman
```
![alt text](image.png)

2. Выполните установк образа с podman, tox и несколькими пайтонами (3.7 и 3.9) внутри.

```bash
docker pull aragast/netology:latest
```
![alt text](image-1.png)

### Основная часть

1. Настройка окружения для теста и тестирование роли Clickhouse

```bash
mkdir -p roles inventories && touch ansible.cfg requirements.yml .gitignore
ansible-galaxy install -r requirements.yml -p ./roles
```
![alt text](image-2.png)

2. Настройка тестирования для роли Vector

```bash
molecule init scenario default
```
![alt text](image-3.png)

Структура директорий
![alt text](image-4.png)

3. Запуск сценария теста и проверка результатов Molecule

Проверка синтаксиса
```bash
molecule syntax
```
![alt text](image-8.png)

Тестирование
```bash
export ANSIBLE_ALLOW_BROKEN_CONDITIONALS=1
molecule test
```
![alt text](image-9.png)

4. Запуск сценария теста и проверка результатов Molecule

Запуск контейнера с TOX, где path_to_repo — путь до корня репозитория с vector-role на вашей файловой системе.
```bash
docker run --privileged=True -v <path_to_repo>:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash
```
![alt text](image-10.png)

Тестирование
```bash
[root@4f71948e8537 vector-role]# tox
```
![alt text](image-12.png)

Дистрибутивы на сайте https://packages.timber.io/vector/0.21.0/ не дотупны.