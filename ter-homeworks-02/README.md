# Домашнее задание к занятию «Основы Terraform. Yandex Cloud»

## Задание 1

![alt text](image-7.png)

![alt text](image.png)

![alt text](image-1.png)

![alt text](image-3.png)

```bash
yc resource-manager folder add-access-binding b1glfq89j9n7quk0cnf0 --role admin --subject serviceAccount:ajekv8hrk7kan34m0ou4
```

![alt text](image-2.png)

**Исправлено название профиля standard-v4, так как было указано не верно. А так же было принято решение использовать профиль standard-v3, так как v4 не найден.**  
* Platform "standard-v4" not found

![alt text](image-4.png)

**Были найдены и исправлены следующие ошибки:**

* the specified number of cores is not available on platform "standard-v3"; allowed core number: 2, 4
* the specified core fraction is not available on platform "standard-v3"; allowed core fractions: 20, 50, 100

![alt text](image-5.png)

![alt text](image-6.png)

**Параметры использования ресурсов , в частности preemptible = true (прерываемость) и core_fraction=5 (гарантируема доля использования CPU) позволяют сэкономить бюджет на этапе развертывания и отладки, без изменения архитектуры ВМ.**

## Задание 2

<img width="1471" height="282" alt="image" src="https://github.com/user-attachments/assets/baafe380-8266-4b5a-ab09-ea882be8905d" />

## Задание 3

![alt text](image-8.png)

![alt text](image-9.png)

## Задание 4

![alt text](image-10.png)

![alt text](image-11.png)

![alt text](image-13.png)

## Задание 5

![alt text](image-14.png)

## Задание 6

![alt text](image-15.png)

## Дополнительное задание (со звёздочкой*)