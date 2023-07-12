# Дипломная работа по профессии «Системный администратор» - Андрей Сотников

## Список использованного ПО

| SW | Версия |
| --- | --- |
| Ansible | 2.15.1 |
| Terraform | 1.5.1 |
| Fedora | 37 |

## Роли Ansible

1. Web_servers - установка Nginx и статики, обновление статики
2. Monitoring - установка и настройка Prometheus, NodeExporter, NgninxlogExporter, Grafana, обновление их конфигурации
3. ELK - установка FileBeat, ElasticSearch, Kibana, обновление конфигурации

## План развертывания

1. Terraform - создание виртуальных машин, подсетей, DNS и других ресурсов.
2. Установка Ansible на BastionHost, загрузка ролей и конфигурации через Git.
3. Запуск роли Web_servers для развертывания nginx на ВМ Web_servers и статики.
4. Запуск роли Monitoring для развертывания Prometherus и Grafana на одноименных ВМ, установка NodeExporter и NginxLogExporter на ВМ Web_Servers.
5. Запуск роли ELK для конфигурации ElasticSearch и Kibana на одноименных ВМ, установка FileBeat на ВМ Web_Servers.

## Состав

Виртуальные машины:
2 веб сервера
вм прометеус
вм графана
вм эластик (докер)
вм кибана (докер)
вм бастион
балансировщик
