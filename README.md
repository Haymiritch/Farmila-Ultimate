https://www.blast.hk/threads/164838/
https://www.blast.hk/threads/164838/
https://www.blast.hk/threads/164838/

Новая, почти полностью переделанная версия старого мусорного Farmila V5
Изменены тг уведы, чат хуки, добавлены новые функции (по мере возможности был вырезан калл из кода)
Скрипт практически полностью автоматизирован и подходит для запуска на VDS Серверах / Основных ПК

В комплект идёт скрипт на Python для автоматического запуска ботов на все 24 сервера (Для Windows и Linux, требуется)

Требования: raksamp lite (коробка), effil, sampev (в коробке), addon (в коробке), samp-store for rakbot/raksamp, requests, ffi (в коробке), inicfg
За актуальными изменениями следите тут: https://t.me/farmila777 (там же и все подробности)


Спойлер: Функционал
Авто регистрация/Авто логин
Авто ввод промокода/Авто ввод реферала
Авто-выставление на сампстор
Авто маршрут по месту спавна
Авторегистрация новых акков после получения бана, деморгана
Обширные телеграм уведы
Защита от фейк детектов по чату
Запуск окон на все сервера разом
Гибкая настройка в .ini
Поддержка proxy
Логирование акков в файл

Slap fix and Anim fix by dimiano
Маршрут плеер by ulong | shamanije

Спойлер: Туториал по запуску на Linux (через терминал)
Вставляем в терминал эту всю огромную ОДНУ строку (это одна строка, не 3!!!):
sudo apt update && sudo apt upgrade && sudo dpkg --add-architecture i386 && wget -qO- https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add - && sudo apt install software-properties-common && sudo apt-add-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -cs) main" && sudo apt update && sudo apt install --install-recommends winehq-stable && sudo apt install python && sudo apt install python3 && sudo apt install tmux

После того как все установилось, прописуем в терминал:
reboot
..для перезагрузки операционной системы

Как только перезагрузилась система, вставляем в терминал:
wget https://github.com/Haymiritch/Farmila-Ultimate

Как только скачалось, пишем:
cd Farmila-Ultimate
cd config
nano Farmila_Settings.ini
и настраиваем скрипт под себя! Читайте спойлер "Настройка и запуск"

Настроили скрипт? Продолжаем
cd ..
python3 AutoServers_LINUX.py
И боты сами запускаются на 24 сервера аризоны, удачи!

Что-то не получилось? Мы не виноваты что Вы установили Linux!

Спойлер: Туториал по запуску на Windows
Если вам лень все скачивать по одному файлу и переносить в раксамп (это делается 1 минуту) либо же Вы тупой, то просто скачайте весь архив Farmila_Ultimate.zip (если его админы не удалили конечно) и распаковываем его куда угодно, далее смотрим спойлер "Настройка и запуск"

А так, вот туториал:
Скачиваем все библиотеки из требований, переносим их все по пути raksamp/scripts/lib
Далее скачиваем слап фикс v1 от Димиано: https://www.blast.hk/threads/158370/
Скачиваем аним фикс от Димиано: https://www.blast.hk/threads/159029/

Далее скачиваем Farmila_Ultimate.lua из темы
Переносим это все в папку scripts
Далее AutoServers_WINDOWS.py, переносим в папку раксампа
Скачиваем архив nujnoe.zip из темы, перемещаем папки из архива в раксамп
Переходим к спойлеру "Настройка и запуск"

Спойлер: Настройка и запуск
Открываем config и открываем через текстовик файл Farmila_Settings.ini
0 = нет, 1 = да
pass=Farmila_Passw0rd - пароль
avtosmenanicka=1 - авто смена ника при заходе
ubegatsospawna=1 - убегать со спавна при заходе

tokenbot=tokebottg - токен бота телеграм
chatid=chatid - чат айди телеграм
admsobesuveda=1 - уведолмение при телепортации админом на собеседование
admspawnuveda=1 - уведомление при спавне админом
admtpuveda=1 - уведолмение при телепорте админом
admcoordtpuveda=1 - уведомление при тп на координаты админом
jailuveda=1 - уведомление при сажании в деморган (ник админа + причина)
joinuveda=0 - уведомление при заходе на сервер
loginuveda=1 - уведолмение при логине на аккаунт
reguveda=1 - уведомление при регистрации аккаунта
noipbanuveda=1 - уведомление при бане (ник админа + причина + сколько прожил аккаунт)
ipbanuveda=1 - уведомление при айпи бане (ник админа + причина + сколько прожил аккаунт)
kickuveda=1 - уведомление при кике (ник админа + причина)
ssakkuveda=1 - уведолмение при загрузке аккаунта на самп стор
levelupuveda=1 - уведомление при повышении лвла

vilagivat=1 - вылаживать ли аккаунт на самп стор
sampstoretoken=SAMP_STORE_TOKEN - токен самп стора (апи)
price=10 - цена аккаунта
infopokupo=sps - описание после покупки аккаунта
infoakk=6 ЛВЛ | 1кк | AZ-Coinы | Подходит для всех целей - описание аккаунта
Аккаунт на самп стор автоматически вылаживается с рег ипом
Настроили, сохранили. Запускаем AutoServers_WINDOWS.py (НУЖЕН PYTHON 3.9) и боты автоматически заходят на 24 сервера аризоны, удачи!
Авторы: Haymiritch, Chocomami1488
Вылаживать только под нашими именами!

Слапфикс, анимфикс: Dimiano
Роут плеер: ulong | shamanije

https://www.blast.hk/threads/164838/
https://www.blast.hk/threads/164838/
https://www.blast.hk/threads/164838/
