telecomtest
===========

Linux version of Atlant telecom test batch script

Использование
===========

Запустить скрипт с привилегиями пользователя 'root':

 sudo sh telecom.sh

Конфигурирование
===========

Переменными окружения:

 EXTRAPING=yes -- включить дополнительное агрессивное "тестирование" канала с помошью ping

 PINGTRIES=20 -- количество пингов (50 по умолчанию)

 VERBOSE=no -- не выводить на экран результат работы команд.

 LOGDIR=/tmp -- где сохранять результаты (в текущей директории по умолчанию)

Пример запуска от рута:

 sudo su -c "EXTRAPING=no PINGTRIES=2 VERBOSE=no sh telecomtest.sh"
