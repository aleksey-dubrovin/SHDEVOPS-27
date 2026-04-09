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

![alt text](image-2.png)

4. `deactivate` 

![alt text](image-4.png)

5. `. venv/bin/activate && . hacking/env-setup`.

![alt text](image-3.png)

### Основная часть

1. Создаем файл модуля, редактируем под задачу и тестируем в playbook на выполнение.

![alt text](image-5.png)

2. Выполняем проверку на идемпотентность.

![alt text](image-6.png)

3. 