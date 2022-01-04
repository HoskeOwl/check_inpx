# Описание

Скрипт предназначен для проверки целостности индекса оффлайн-библиотеки.
В программу загружается inpx-файл. Все файлы, начинающиеся с f./d./fb открываются и проверяются на количество колонок (должно быть 15)

# установка
## windows
* Скачиваем последнюю версию питона [python.org](https://www.python.org/downloads/)
* Скачиваем cам скрипт [github.com](https://github.com/HoskeOwl/check_inpx/archive/refs/heads/master.zip)
* распаковываем архив и заходим в папку check_inpx
* двойным кликом запускаем main.pyx

## linux
* ставим актуальную версию питона (смотрим инструкцию по своему дистрибутиву)
* качаем скрипт либо по ссылке [github.com](https://github.com/HoskeOwl/check_inpx/archive/refs/heads/master.zip) либо через `git clone https://github.com/HoskeOwl/check_inpx.git`
* делаем файл `main.pyx` исполнеяемым и запускаем как приложение