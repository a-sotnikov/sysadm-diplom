# Дипломная работа по профессии «Системный администратор» - Андрей Сотников

## Список использованного ПО

| SW | Версия |
| --- | --- |
| Ansible | 2.15.1 |
| Terraform | 1.5.1 |
| Fedora | 37 |

## План развертывания

0. Получение аутентификационного токена Yandex.Cloud для управления облачными ресурсами через Terraform.
1. Создание [ресурсов]( ##Используемые ресурсы Yandex.Cloud) при помощи Terraform.
2. В ходе развертывания инфрастурктуры на Bastion сервер устанавливаются Git и Ansible, передается файл конфигурации ansible.cfg, затем производится загрузка ролей из VCS (GitHub).
3. Подключение по SSH к Bastion серверу и запуск ролей Ansible производится вручную, но можно настроить автоматическую развертку при помощи CI/CD-инструментов (например, Jenkins). В таком случае, Ansible будет уже заранее установлен на сконфигурированном агенте, и не будет необходимости устанавливать на BastionHost какие-либо пакеты.
4. Запуск роли Web_servers для развертывания nginx на ВМ Web_servers и статики.
5. Запуск роли Monitoring для развертывания Prometherus и Grafana на одноименных ВМ, установка NodeExporter и NginxLogExporter на ВМ Web_Servers.
6. Запуск роли ELK для конфигурации ElasticSearch и Kibana на одноименных ВМ, установка FileBeat на ВМ Web_Servers.

## Роли Ansible

1. Web_servers - установка Nginx и статики, обновление статики
2. Monitoring - установка и настройка Prometheus, NodeExporter, NgninxlogExporter, Grafana, обновление их конфигурации
3. ELK - установка FileBeat, ElasticSearch, Kibana, обновление конфигурации

## Используемые ресурсы Yandex.Cloud

### Виртуальные машины

| Наименование | ППО | Внутренний FQDN | Подсеть |
| --- | --- | --- | --- |
| webserver-1 | Nginx | web1.dip.lom | subnet-a |
| webserver-2 | Nginx | web2.dip.lom | subnet-b |
| prometheus | prometheus | prometheus.dip.lom | subnet-b |
| grafana | grafana | grafana.dip.lom | subnet-b |
| elaticsearch | elaticsearch | es.dip.lom | subnet-a |
| kibana | kibana | kibana.dip.lom | subnet-a |
| bastion-host | - | bastion.dip.lom | subnet-b |

### Сети

| Наименование | IPv4 CIDR | Зона |
| --- | --- | --- |
| subnet-a | 192.168.10.0/24| ru-central1-a |
| subnet-b | 192.168.20.0/24 | ru-central1-b |

### L7 Балансировщик нагрузки

Состоит из целевой группы, в которую помещаются веб-серверы, бэкенд-группы, которая определяет настройки балансировки,
роутера, который определяет правила маршрутизации запросов в группу бэкенда и балансировщика, который принимает трафик и передает его собственно на эндпоинты бэкендов согласно настройкам обработчиков.
