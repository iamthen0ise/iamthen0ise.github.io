#!/usr/bin/env fish
# Ждёт, пока зеркало на Yandex CDN начнёт отдавать 200.
# Использование: scripts/wait-mirror.fish [url] [интервал_сек]

set -l url https://ru.euvarov.me
set -l interval 20
test (count $argv) -ge 1; and set url $argv[1]
test (count $argv) -ge 2; and set interval $argv[2]

while true
    set -l code (curl -sI -o /dev/null -m 15 -w '%{http_code}' $url 2>/dev/null)
    test -z "$code"; or test "$code" = 000; and set code 'нет ответа'
    printf '%s  %s  %s\n' (date +%H:%M:%S) $url $code
    test "$code" = 200; and break
    sleep $interval
end

echo "Готово: $url отвечает 200"
