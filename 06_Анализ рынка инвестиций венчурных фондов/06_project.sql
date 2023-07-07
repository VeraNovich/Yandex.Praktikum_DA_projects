--Проект: Анализ рынок инвестиций венчурных фондах--
/*В проекте 23 задания - запросы к БД (PostgreSQL)*/
/*БД основана на датасете Startup Investments, опубликованном на платформе Kaggle*/

/*Задание 1: 
Посчитать, сколько компаний закрылось.*/

SELECT COUNT(id)
FROM company
WHERE status = 'closed';

/*Задание 2: 
Отобразить количество привлечённых средств для новостных компаний США. 
Использовать данные из таблицы company. 
Отсортировать таблицу по убыванию значений в поле */

SELECT funding_total
FROM company
WHERE category_code LIKE 'news'
      AND country_code LIKE 'USA'
ORDER BY 1 DESC;

/*Задание 3:
Найти общую сумму сделок по покупке одних компаний другими в долларах. 
Отобрать сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.*/

SELECT SUM(price_amount)
FROM acquisition
WHERE EXTRACT(YEAR FROM acquired_at::date) BETWEEN 2011 AND 2013
      AND term_code LIKE 'cash'
      
/*Задание 4:
Отобразить имя, фамилию и названия аккаунтов людей в твиттере, 
у которых названия аккаунтов начинаются на 'Silver'.*/

SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';

/*Задание 5:
Вывести на экран всю информацию о людях, 
у которых названия аккаунтов в твиттере содержат подстроку 'money', 
а фамилия начинается на 'K'.*/

SELECT *
FROM people
WHERE twitter_username LIKE '%money%'
      AND last_name LIKE 'K%';
      
/*Задание 6:
Для каждой страны отобразить общую сумму привлечённых инвестиций, 
которые получили компании, зарегистрированные в этой стране. 
Страну, в которой зарегистрирована компания, можно определить по коду страны. 
Отсортировать данные по убыванию суммы.*/

SELECT country_code,
       SUM(funding_total)
FROM company
GROUP BY 1
ORDER BY 2 DESC;


/*Задание 7:
Составить таблицу, в которую войдёт дата проведения раунда, 
а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
Оставить в итоговой таблице только те записи, 
в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.*/

SELECT funded_at,
       MIN(raised_amount),
       MAX(raised_amount)
FROM funding_round
GROUP BY 1
HAVING MIN(raised_amount)>0
       AND MIN(raised_amount) <> MAX(raised_amount);
       
/*Задание 8:
Создать поле с категориями:
- Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
- Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
- Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
Отобразить все поля таблицы fund и новое поле с категориями.*/

SELECT *,
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END
FROM fund;

/*Задание 9:
Для каждой из категорий, 
назначенных в предыдущем задании, 
посчитать округлённое до ближайшего целого числа среднее количество инвестиционных раундов, 
в которых фонд принимал участие. 
Вывести на экран категории и среднее число инвестиционных раундов. 
Отсортировать таблицу по возрастанию среднего.*/

SELECT activity,
       ROUND(AVG(investment_rounds))
FROM (SELECT *,
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity
FROM fund) AS d
GROUP BY 1
ORDER BY 2;

/*Задание 10:
Проанализировать, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
Для каждой страны посчитать минимальное, максимальное и среднее число компаний, 
в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно. 
Исключить страны с фондами, у которых минимальное число компаний, 
получивших инвестиции, равно нулю.
Выгрузить десять самых активных стран-инвесторов: 
отсортировать таблицу по среднему количеству компаний от большего к меньшему. 
Затем добавить сортировку по коду страны в лексикографическом порядке.*/

SELECT country_code,
       MIN(invested_companies),
       MAX(invested_companies),
       AVG(invested_companies)
FROM fund
WHERE EXTRACT(YEAR FROM founded_at::date) BETWEEN 2010 AND 2012
GROUP BY 1
HAVING MIN(invested_companies)>0
ORDER BY 4 DESC, 1
LIMIT 10;

/*Задание 11:
Отобразить имя и фамилию всех сотрудников стартапов. 
Добавить поле с названием учебного заведения, которое окончил сотрудник, 
если эта информация известна.*/

SELECT d2.first_name,
       d2.last_name,
       d1.instituition
FROM education AS d1
RIGHT JOIN people AS d2 ON d1.person_id=d2.id

/*Задание 12:
Для каждой компании найти количество учебных заведений, 
которые окончили её сотрудники. 
Вывести название компании и число уникальных названий учебных заведений. 
Составить топ-5 компаний по количеству университетов.*/

SELECT d1.name,
       COUNT(DISTINCT d3.instituition)
FROM company AS d1
JOIN people AS d2 ON d1.id = d2.company_id
JOIN education AS d3 ON d2.id = d3.person_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

/*Задание 13:

Составить список с уникальными названиями закрытых компаний, 
для которых первый раунд финансирования оказался последним.*/

SELECT d1.name 
FROM company AS d1
INNER JOIN funding_round AS d2 ON d1.id=d2.company_id
WHERE status = 'closed'
      AND is_first_round = 1
      AND is_last_round = 1
GROUP BY 1;

/*Задание: 14
Составить список уникальных номеров сотрудников, 
которые работают в компаниях, отобранных в предыдущем задании.*/

SELECT id
FROM people
WHERE company_id IN (SELECT d1.id 
FROM company AS d1 
INNER JOIN funding_round AS d2 ON d1.id=d2.company_id
WHERE status = 'closed'
AND is_first_round = 1
AND is_last_round = 1
GROUP BY 1)
GROUP BY 1;

/*Задание 15:

Составить таблицу, 
куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, 
которое окончил сотрудник.*/

SELECT a1.id,
       a2.instituition
FROM people AS a1
INNER JOIN education AS a2 ON a1.id=a2.person_id
WHERE company_id IN (SELECT d1.id 
FROM company AS d1 
INNER JOIN funding_round AS d2 ON d1.id=d2.company_id
WHERE status = 'closed'
AND is_first_round = 1
AND is_last_round = 1
GROUP BY 1)
GROUP BY 1, 2;

/*Задание 16:

Посчитать количество учебных заведений для каждого сотрудника из предыдущего задания. 
При подсчёте учесть, что некоторые сотрудники могли окончить одно и то же заведение дважды.*/

SELECT a1.id,
       COUNT(a2.instituition)
FROM people AS a1
INNER JOIN education AS a2 ON a1.id=a2.person_id
WHERE company_id IN (SELECT d1.id 
FROM company AS d1 
INNER JOIN funding_round AS d2 ON d1.id=d2.company_id
WHERE status = 'closed'
AND is_first_round = 1
AND is_last_round = 1
GROUP BY 1)
GROUP BY 1;

/*Задание 17:
Дополнить предыдущий запрос и вывести среднее число учебных заведений (всех, не только уникальных), 
которые окончили сотрудники разных компаний. 
Нужно вывести только одну запись, группировка здесь не понадобится.*/

WITH
d0 AS (SELECT a1.id,
       COUNT(a2.instituition)
FROM people AS a1
INNER JOIN education AS a2 ON a1.id=a2.person_id
WHERE company_id IN (SELECT d1.id 
FROM company AS d1 
INNER JOIN funding_round AS d2 ON d1.id=d2.company_id
WHERE status = 'closed'
AND is_first_round = 1
AND is_last_round = 1
GROUP BY 1)
GROUP BY 1)

/*Задание 18:
Написать похожий запрос: вывести среднее число учебных заведений (всех, не только уникальных), 
которые окончили сотрудники Facebook*.*/

WITH
d0 AS (SELECT a1.id,
       COUNT(a2.instituition)
FROM people AS a1
INNER JOIN education AS a2 ON a1.id=a2.person_id
WHERE company_id IN (SELECT id 
FROM company 
WHERE name = 'Facebook')
GROUP BY 1)

SELECT AVG(COUNT)
FROM d0

/*Задание 19:
Составить таблицу из полей:
- name_of_fund — название фонда;
- name_of_company — название компании;
- amount — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, 
а раунды финансирования проходили с 2012 по 2013 год включительно.*/

SELECT d2.name AS name_of_fund,
       d1.name AS name_of_company,
       d3.raised_amount
FROM investment AS d0
INNER JOIN company AS d1 ON d0.company_id=d1.id
INNER JOIN fund AS d2 ON d0.fund_id=d2.id
INNER JOIN funding_round AS d3 ON d0.funding_round_id=d3.id
WHERE d1.milestones>6
      AND EXTRACT(YEAR FROM funded_at::date) BETWEEN 2012 AND 2013
      
/*Задание 20:
Выгрузить таблицу, в которой будут такие поля:
- название компании-покупателя;
- сумма сделки;
- название компании, которую купили;
- сумма инвестиций, вложенных в купленную компанию;
- доля, которая отображает, 
во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, 
округлённая до ближайшего целого числа.
Не учитывать те сделки, в которых сумма покупки равна нулю. 
Если сумма инвестиций в компанию равна нулю, исключить такую компанию из таблицы. 
Отсортировать таблицу по сумме сделки от большей к меньшей, 
а затем по названию купленной компании в лексикографическом порядке. 
Ограничить таблицу первыми десятью записями.*/

SELECT d2.name,
       d1.price_amount,
       d3.name,
       d3.funding_total,
       ROUND(d1.price_amount/d3.funding_total)
FROM acquisition AS d1
INNER JOIN company AS d2 ON d2.id=d1.acquiring_company_id
INNER JOIN company AS d3 ON d3.id=d1.acquired_company_id 
WHERE d1.price_amount<>0
      AND d3.funding_total<>0
ORDER BY 2 DESC, 3
LIMIT 10

/*Заданиее 21:
Выгрузить таблицу, в которую войдут названия компаний из категории social, 
получившие финансирование с 2010 по 2013 год включительно. 
Проверить, что сумма инвестиций не равна нулю. 
Вывести также номер месяца, в котором проходил раунд финансирования.*/

SELECT d1.name,
       EXTRACT(MONTH FROM d2.funded_at::date)
FROM company AS d1
INNER JOIN funding_round AS d2 ON d1.id=d2.company_id
WHERE EXTRACT(YEAR FROM d2.funded_at::date) BETWEEN 2010 AND 2013
      AND d2.raised_amount<>0
      AND d1.category_code LIKE 'social'
      
/*Задание 22:
Отобрать данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. 
Сгруппировать данные по номеру месяца и получите таблицу, в которой будут поля:
- номер месяца, в котором проходили раунды;
- количество уникальных названий фондов из США, которые инвестировали в этом месяце;
- количество компаний, купленных за этот месяц;
- общая сумма сделок по покупкам в этом месяце.*/

WITH
from_fund  AS (SELECT EXTRACT(MONTH FROM d1.funded_at::date) AS month,
       COUNT(DISTINCT d3.name) AS fund_count
FROM funding_round AS d1
JOIN investment AS d2 ON d1.id=d2.funding_round_id
JOIN fund AS d3 ON d2.fund_id=d3.id
WHERE EXTRACT(YEAR FROM d1.funded_at::date) BETWEEN 2010 AND 2013
      AND d3.country_code LIKE 'USA'
GROUP BY 1),

from_acquisition AS (SELECT EXTRACT(MONTH FROM acquired_at ::date) AS month,
       COUNT(acquired_company_id) AS company_count,
       SUM(price_amount ) AS amount
FROM acquisition 
WHERE EXTRACT(YEAR FROM acquired_at ::date) BETWEEN 2010 AND 2013
GROUP BY 1)

SELECT a1.month,
       a1.fund_count,
       a2.company_count,
       a2.amount
FROM from_fund AS a1 
INNER JOIN from_acquisition AS a2 ON a1.month=a2.month

/*Задание 23:
Составить сводную таблицу и выведите среднюю сумму инвестиций для стран, 
в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. 
Данные за каждый год должны быть в отдельном поле. 
Отсортировать таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.*/

WITH
a1 AS (SELECT country_code 
FROM company
GROUP BY 1
ORDER BY 1),

a2 AS (SELECT country_code,
       AVG(funding_total) AS total_2011
FROM company
WHERE EXTRACT(YEAR FROM founded_at::date) = 2011
GROUP BY 1
ORDER BY 1),

a3 AS (SELECT country_code,
       AVG(funding_total) AS total_2012
FROM company
WHERE EXTRACT(YEAR FROM founded_at::date) = 2012
GROUP BY 1
ORDER BY 1),

a4 AS (SELECT country_code,
       AVG(funding_total) AS total_2013
FROM company
WHERE EXTRACT(YEAR FROM founded_at::date) = 2013
GROUP BY 1
ORDER BY 1)

SELECT a1.country_code,
       a2.total_2011,
       a3.total_2012,
       a4.total_2013
FROM a1
JOIN a2 USING(country_code)
JOIN a3 USING(country_code)
JOIN a4 USING(country_code)
ORDER BY 2 DESC