# Проект: А/В тестирование

## Цель проекта
оценка изменений, связанных с внедрением улучшенной рекомендательной системы.

## Источник данных
- календарь маркетинговых событий на 2020 год.
- список пользователей, зарегистрировавшихся с 7 до 21 декабря 2020 года.
- список действий новых пользователей в период с 7 декабря 2020 по 4 января 2021 года.
- таблица участников тестов.

## Этапы выполнения проекта
* постановка цели;
* анализ исходных данных;
* оценка корректности проведения теста;
* иследовательский анализ данных;
* оценка результатов А/В теста;
* формулировка выводов.

## Навыки и инструменты
* Python 
* Pandas
* NumPy
* datetime
* Matplotlib
* plotly
* scipy
* Seaborn
* exploratory data analysis (EDA)
* анализ бизнес показателей 

## Вывод
* гипотеза_1 была отвергнута: доля уникальных пользователей группы А, побывавших на этапе воронки product_page, не равна доле уникальных пользователей группы В, побывавших на этапе воронки product_page;
* не получилось отвергнуть гипотезу_2: нет статистически значимой разницы между долями уникальных пользователей группы А и группы В, побывавших на этапе product_cart воронки;
* не получилось отвергнуть гипотезу_3: нет статистически значимой разницы между долями уникальных пользователей группы А и группы В, побывавших на этапе purchase воронки.
Как исследовательский анализ, так и анализ результатов А/В тест не подтвердили наличия ожидаемого в ТЗ эффекта от внедрения новой рекомендательной системы.
