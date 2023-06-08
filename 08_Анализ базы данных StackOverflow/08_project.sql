--Проект: Анализ базы данных StackOverflow--

/*Источник данных: реляционная БД, которая хранит информацию о постах пользователей StackOverflow за 2008 год.*/

/*В проекте 20 заданий - запросы к БД(PostgreSQL)*/

/*Задание 1:
Найдите количество вопросов, 
которые набрали больше 300 очков или как минимум 100 раз были добавлены в «Закладки».*/

SELECT COUNT(*)
FROM stackoverflow.posts
WHERE post_type_id=1 AND (score>300 OR favorites_count>=100)

/*Задание 2:
Сколько в среднем в день задавали вопросов с 1 по 18 ноября 2008 включительно? 
Результат округлите до целого числа.*/

WITH
d1 AS (SELECT DATE_TRUNC('DAY', creation_date)::date,
       COUNT(id)
FROM stackoverflow.posts
WHERE post_type_id=1 AND (DATE_TRUNC('DAY', creation_date)::date BETWEEN '2008-11-01' AND '2008-11-18')
GROUP BY 1)

SELECT ROUND(AVG(count))
FROM d1

/*Задание 3:

Сколько пользователей получили значки сразу в день регистрации? 
Выведите количество уникальных пользователей.*/

SELECT COUNT(DISTINCT d1.id)
FROM stackoverflow.users AS d1
JOIN stackoverflow.badges AS d2 ON d1.id = d2.user_id AND DATE_TRUNC('day', d1.creation_date)::date = DATE_TRUNC('day', d2.creation_date)::date

/*Задание 4:
Сколько уникальных постов пользователя с именем Joel Coehoorn получили хотя бы один голос?*/

SELECT COUNT(*)
FROM stackoverflow.posts AS d1
LEFT JOIN stackoverflow.users AS d2 ON d1.user_id=d2.id
JOIN (SELECT DISTINCT post_id FROM stackoverflow.votes) AS d3 ON d1.id=d3.post_id
WHERE d2.display_name = 'Joel Coehoorn'

/*Задание 5:
Выгрузите все поля таблицы vote_types. 
Добавьте к таблице поле rank, в которое войдут номера записей в обратном порядке. 
Таблица должна быть отсортирована по полю id.*/

SELECT *,
       RANK() OVER (ORDER BY id DESC) AS rn
FROM stackoverflow.vote_types
ORDER BY id

/*Задание 6:
Отберите 10 пользователей, которые поставили больше всего голосов типа Close. 
Отобразите таблицу из двух полей: идентификатором пользователя и количеством голосов. 
Отсортируйте данные сначала по убыванию количества голосов, 
потом по убыванию значения идентификатора пользователя.*/

SELECT d1.user_id,
       COUNT(d1.post_id)
FROM stackoverflow.votes AS d1
LEFT JOIN stackoverflow.vote_types AS d2 ON d1.vote_type_id = d2.id
WHERE d2.name = 'Close'
GROUP BY 1
ORDER BY 2 DESC, 1 DESC
LIMIT 10

/*Задание 7:
Отберите 10 пользователей по количеству значков, 
полученных в период с 15 ноября по 15 декабря 2008 года включительно.
Отобразите несколько полей:
- идентификатор пользователя;
- число значков;
- место в рейтинге — чем больше значков, тем выше рейтинг.
Пользователям, которые набрали одинаковое количество значков, 
присвойте одно и то же место в рейтинге.
Отсортируйте записи по количеству значков по убыванию, 
а затем по возрастанию значения идентификатора пользователя.*/

SELECT user_id,
       COUNT(id),
       DENSE_RANK() OVER (ORDER BY COUNT(id) DESC)
FROM stackoverflow.badges
WHERE DATE_TRUNC('day', creation_date)::date BETWEEN '2008-11-15' AND '2008-12-15'
GROUP BY 1
ORDER BY 2 DESC, 1
LIMIT 10

/*Задание 8:
Сколько в среднем очков получает пост каждого пользователя?
Сформируйте таблицу из следующих полей:
- заголовок поста;
- идентификатор пользователя;
- число очков поста;
- среднее число очков пользователя за пост, округлённое до целого числа.
Не учитывайте посты без заголовка, а также те, что набрали ноль очков.*/

SELECT title,
       user_id,
       score,
       ROUND(AVG(score) OVER (PARTITION BY user_id)) AS avg_score
FROM stackoverflow.posts
WHERE title IS NOT NULL AND score<>0;

/*Задание 9:
Отобразите заголовки постов, которые были написаны пользователями, получившими более 1000 значков. 
Посты без заголовков не должны попасть в список.*/

SELECT title
FROM stackoverflow.posts
WHERE title IS NOT NULL AND user_id IN (SELECT user_id
FROM stackoverflow.badges
GROUP BY 1
HAVING COUNT(id)>1000)

/*Задание 10:
Напишите запрос, который выгрузит данные о пользователях из США (англ. United States). 
Разделите пользователей на три группы в зависимости от количества просмотров их профилей:
- пользователям с числом просмотров больше либо равным 350 присвойте группу 1;
- пользователям с числом просмотров меньше 350, но больше либо равно 100 — группу 2;
- пользователям с числом просмотров меньше 100 — группу 3.
Отобразите в итоговой таблице идентификатор пользователя, 
количество просмотров профиля и группу. 
Пользователи с нулевым количеством просмотров не должны войти в итоговую таблицу.*/

SELECT id,
       views,
       CASE
           WHEN views>=350 THEN 1
           WHEN views>=100 THEN 2
           ELSE 3
       END AS gr
FROM stackoverflow.users
WHERE location LIKE '%United States%' AND views<>0;

/*Задание 11:
Дополните предыдущий запрос.
Отобразите лидеров каждой группы — пользователей, 
которые набрали максимальное число просмотров в своей группе. 
Выведите поля с идентификатором пользователя, 
группой и количеством просмотров. 
Отсортируйте таблицу по убыванию просмотров, а затем по возрастанию значения идентификатора.*/

WITH

d1 AS (SELECT id,
       views,
       CASE
           WHEN views>=350 THEN 1
           WHEN views>=100 THEN 2
           ELSE 3
       END AS gr
FROM stackoverflow.users
WHERE location LIKE '%United States%' AND views<>0),

d2 AS (SELECT *,
       MAX(views) OVER (PARTITION BY gr)
FROM d1)

SELECT id,
       views,
       gr
FROM d2
WHERE views = max
ORDER BY 2 DESC, 1


/*Задание 12:
Посчитайте ежедневный прирост новых пользователей в ноябре 2008 года. Сформируйте таблицу с полями:
- номер дня;
- число пользователей, зарегистрированных в этот день;
- сумму пользователей с накоплением.*/

WITH
d1 AS (SELECT DATE_TRUNC('day', creation_date)::date AS dt,
       COUNT(id)
FROM stackoverflow.users
WHERE DATE_TRUNC('day', creation_date)::date BETWEEN '2008-11-01' AND '2008-11-30'
GROUP BY 1
ORDER BY 1)

SELECT ROW_NUMBER() OVER (),
       count,
       SUM(count) OVER (ORDER BY dt) AS total_count
FROM d1

/*Задание 13:
Для каждого пользователя, который написал хотя бы один пост, 
найдите интервал между регистрацией и временем создания первого поста.
Отобразите:
- идентификатор пользователя;
- разницу во времени между регистрацией и первым постом.*/

WITH
d1 AS (SELECT user_id,
       creation_date,
       ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY creation_date) AS rn
FROM stackoverflow.posts),

d2 AS (SELECT user_id,
       creation_date
FROM d1
WHERE rn=1)

SELECT d.id,
       d2.creation_date - d.creation_date AS delta
FROM stackoverflow.users AS d
JOIN d2 ON d.id = d2.user_id

/*Задание 14:
Выведите общую сумму просмотров постов за каждый месяц 2008 года. 
Если данных за какой-либо месяц в базе нет, такой месяц можно пропустить. 
Результат отсортируйте по убыванию общего количества просмотров.*/

SELECT DATE_TRUNC('month', creation_date)::date,
       SUM(views_count)
FROM stackoverflow.posts
WHERE EXTRACT(YEAR FROM DATE_TRUNC('month', creation_date)::date) = '2008'
GROUP BY 1
ORDER BY 2 DESC

/*Задание 15:
Выведите имена самых активных пользователей, 
которые в первый месяц после регистрации (включая день регистрации) дали больше 100 ответов. 
Вопросы, которые задавали пользователи, не учитывайте. 
Для каждого имени пользователя выведите количество уникальных значений user_id. 
Отсортируйте результат по полю с именами в лексикографическом порядке.*/

SELECT d2.display_name,
       COUNT(DISTINCT d1.user_id)
FROM stackoverflow.posts AS d1
LEFT JOIN stackoverflow.users AS d2 ON d1.user_id = d2.id
WHERE DATE_TRUNC('day', d1.creation_date)::date<=DATE_TRUNC('day', d2.creation_date)::date + INTERVAL '1 month' AND d1.post_type_id=2
GROUP BY 1
HAVING COUNT(d1.user_id)>100
ORDER BY 1

/*Задание 16:
Выведите количество постов за 2008 год по месяцам. 
Отберите посты от пользователей, 
которые зарегистрировались в сентябре 2008 года и сделали хотя бы один пост в декабре того же года. 
Отсортируйте таблицу по значению месяца по убыванию.*/

SELECT DATE_TRUNC('month', creation_date)::date,
       COUNT(id)
FROM stackoverflow.posts 
WHERE DATE_TRUNC('year', creation_date)::date = '2008-01-01' AND user_id IN (SELECT DISTINCT d1.user_id
FROM stackoverflow.posts AS d1
JOIN stackoverflow.users AS d2 ON d1.user_id=d2.id
WHERE DATE_TRUNC('month', d1.creation_date)::date = '2008-12-01' AND DATE_TRUNC('month', d2.creation_date)::date = '2008-09-01'
)
GROUP BY 1
ORDER BY 1 DESC

/*Задание 17:
Используя данные о постах, выведите несколько полей:
идентификатор пользователя, который написал пост;
дата создания поста;
количество просмотров у текущего поста;
сумму просмотров постов автора с накоплением.
Данные в таблице должны быть отсортированы по возрастанию идентификаторов пользователей, 
а данные об одном и том же пользователе — по возрастанию даты создания поста.*/

SELECT user_id,
       creation_date,
       views_count,
       SUM(views_count) OVER (PARTITION BY user_id ORDER BY creation_date)
FROM stackoverflow.posts
ORDER BY 1,2

/*Задание 18:
Сколько в среднем дней в период с 1 по 7 декабря 2008 года включительно пользователи взаимодействовали с платформой? 
Для каждого пользователя отберите дни, в которые он или она опубликовали хотя бы один пост. 
Нужно получить одно целое число — не забудьте округлить результат.*/

WITH
d1 AS (SELECT user_id,
       COUNT(DISTINCT DATE_TRUNC('day', creation_date)::date) AS active_day
FROM stackoverflow.posts
WHERE DATE_TRUNC('day', creation_date)::date BETWEEN '2008-12-01' AND '2008-12-07'
GROUP BY 1)

SELECT ROUND(AVG(active_day))
FROM d1

/*Задание 19:
На сколько процентов менялось количество постов ежемесячно с 1 сентября по 31 декабря 2008 года? 
Отобразите таблицу со следующими полями:
номер месяца;
количество постов за месяц;
процент, который показывает, 
насколько изменилось количество постов в текущем месяце по сравнению с предыдущим.
Если постов стало меньше, значение процента должно быть отрицательным, 
если больше — положительным. 
Округлите значение процента до двух знаков после запятой.
Напомним, что при делении одного целого числа на другое в PostgreSQL 
в результате получится целое число, округлённое до ближайшего целого вниз. 
Чтобы этого избежать, переведите делимое в тип numeric.*/

WITH
d1 AS (SELECT EXTRACT(MONTH FROM creation_date::date) AS month_corrent,
       COUNT(DISTINCT id) AS count_post
FROM stackoverflow.posts
WHERE DATE_TRUNC('day', creation_date)::date BETWEEN '2008-09-01' AND '2008-12-31'
GROUP BY 1)

SELECT *,
       ROUND((count_post::numeric/(LAG(count_post) OVER (ORDER BY month_corrent))-1)*100, 2) AS delta
FROM d1

/*Задание 20:
Выгрузите данные активности пользователя, 
который опубликовал больше всего постов за всё время. 
Выведите данные за октябрь 2008 года в таком виде:
номер недели;
дата и время последнего поста, опубликованного на этой неделе.*/

WITH

d AS (SELECT user_id,
       COUNT(id) AS count_posts
FROM stackoverflow.posts
GROUP BY 1),

d1 AS (SELECT user_id
FROM d
WHERE count_posts = (SELECT MAX(count_posts) FROM d))

SELECT DISTINCT EXTRACT(week FROM creation_date::date),
       MAX(creation_date) OVER (PARTITION BY EXTRACT(week FROM creation_date::date))
FROM stackoverflow.posts AS p
JOIN d1 ON p.user_id=d1.user_id
WHERE DATE_TRUNC('month', p.creation_date)::date = '2008-10-01'