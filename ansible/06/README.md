## Домашнее задание к занятию 6 «Создание собственных модулей»

Презентация [cоздание собственных модулей](./6.Создание_собственных_модулей.pdf)

Полное описание типов module в [Ansible module architecture](https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_program_flow_modules.html#types-of-modules)

[Гайд о сохранении совместимости между разными версиями Python и единая база кода](http://python3porting.com/)

[Пример шаблона модуля](https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_modules_general.html#creating-a-module)

### Подготовка к выполнению

1. `cd ansible`.

![alt text](image.png)

2. `pip install -r requirements.txt`.

![alt text](image-1.png)

3. `. hacking/env-setup`.

![alt text](image-11.png)

4. `deactivate` 

![alt text](image-4.png)

5. `. venv/bin/activate && . hacking/env-setup`.

![alt text](image-10.png)

### Основная часть

1. Создаем файл модуля, редактируем под задачу и тестируем в playbook на выполнение.

![alt text](image-5.png)

2. Выполняем проверку на идемпотентность.

![alt text](image-12.png)

4. Создаем коллекцию, создаем роль для использования модуля, заполняем документацию и выполняем сборку.

![alt text](image-7.png)

5. Переносим архив во временную директорию, проверяем установку коллекции.

![alt text](image-13.png)

6. Редактируем основной playbook и выполняем запуск.

![alt text](image-9.png)

7. Принимаем изменения и отправляем в git.

[Ссылка на репозиорий с коллекцией](https://github.com/aleksey-dubrovin/SHDEVOPS-27/blob/main/ansible/06/my_own_namespace/yandex_cloud_elk/README.md)

[Ссылка на архив с коллекцией](https://github.com/aleksey-dubrovin/SHDEVOPS-27/blob/main/ansible/06/my_own_namespace/yandex_cloud_elk/my_own_namespace-yandex_cloud_elk-1.0.0.tar.gz)
