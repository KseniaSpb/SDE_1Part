CREATE TABLE results(
    id INT,
    response TEXT
);

-- 1 Вывести максимальное количество человек в одном бронировании

INSERT INTO results (id, response)

SELECT 1 AS id, count_pass AS response
FROM
(
SELECT count(passenger_id) as count_pass
FROM tickets
GROUP BY book_ref
ORDER BY count(passenger_id) DESC
LIMIT 1) as t_1;

-- 2 Вывести количество бронирований с количеством людей больше среднего значения людей на одно бронирование

INSERT INTO results (id, response)

SELECT 2 AS id, count(book_ref) AS response
FROM
(
SELECT book_ref, count(passenger_id) as count_pass
FROM tickets
GROUP BY book_ref
HAVING count(passenger_id) > (SELECT sum(cnt)/count(book_ref)
FROM
(SELECT book_ref, count(passenger_id) as cnt
FROM tickets
GROUP BY book_ref
) as t_2_1)) as t_2_2;

-- 3 Вывести количество бронирований, у которых состав пассажиров повторялся два и более раза,
--   среди бронирований с максимальным количеством людей (п.1)?

INSERT INTO results (id, response)

SELECT 3 AS id, count_pass_3 AS response
FROM
(
SELECT count(cnt_2) as count_pass_3
FROM
(
SELECT pass_in_br, count(book_ref) as cnt_2
FROM
(SELECT book_ref, string_agg(passenger_id, ',') as pass_in_br
FROM
(SELECT book_ref, passenger_id
FROM tickets
WHERE book_ref IN
(
SELECT book_ref
FROM tickets
GROUP BY book_ref
HAVING count(passenger_id) = (SELECT max(cnt)
FROM
(SELECT count(passenger_id) as cnt
FROM tickets
GROUP BY book_ref
) as t_3_1))
ORDER BY book_ref, passenger_id) as t_3_2
GROUP BY book_ref) as t_3_4
GROUP BY pass_in_br
HAVING count(book_ref) >= 2) as t_3_5) as t_3_6;

-- 4 Вывести номера брони и контактную информацию по пассажирам в брони (passenger_id, passenger_name, contact_data)
--   с количеством людей в брони = 3

INSERT INTO results (id, response)

SELECT 4 AS id, CONCAT(book_ref, '|', passenger_id, '|', passenger_name, '|', contact_data) AS response
FROM
(
SELECT book_ref, passenger_id, passenger_name, contact_data
FROM
(
SELECT book_ref, passenger_id, passenger_name, contact_data
FROM tickets
WHERE book_ref IN (SELECT DISTINCT book_ref
FROM tickets
GROUP BY book_ref
HAVING count(passenger_id) = 3)) as t_4_1
ORDER BY 1, 2) as t_4_2;

-- 5 Вывести максимальное количество перелётов на бронь

INSERT INTO results (id, response)

SELECT 5 AS id, cnt_5 AS response
FROM
(
SELECT count(concat(tf.ticket_no, flight_id)) as cnt_5
FROM ticket_flights tf
JOIN tickets t ON tf.ticket_no = t.ticket_no
GROUP BY book_ref
ORDER BY cnt_5 DESC
LIMIT 1
) as t_5;

-- 6 Вывести максимальное количество перелётов на пассажира в одной брони

INSERT INTO results (id, response)

SELECT 6 AS id, cnt_6 AS response
FROM
(
SELECT book_ref, passenger_id, count(concat(tf.ticket_no, flight_id)) as cnt_6
FROM ticket_flights tf
JOIN tickets t ON tf.ticket_no = t.ticket_no
GROUP BY book_ref, passenger_id
ORDER BY cnt_6 DESC
LIMIT 1) as t_6;

-- 7 Вывести максимальное количество перелётов на пассажира

INSERT INTO results (id, response)

SELECT 7 AS id, cnt_7 AS response
FROM
(
SELECT passenger_id, count(concat(tf.ticket_no, flight_id)) as cnt_7
FROM ticket_flights tf
JOIN tickets t ON tf.ticket_no = t.ticket_no
GROUP BY passenger_id
ORDER BY cnt_7 DESC
LIMIT 1) as t_7;

-- 8 Вывести контактную информацию по пассажиру(ам) (passenger_id, passenger_name, contact_data) и общие траты на билеты,
--   для пассажира потратившему минимальное количество денег на перелеты

INSERT INTO results (id, response)

SELECT 8 AS id, CONCAT(pass_id, '|', pass_n, '|', cont_d, '|', sum_8_3) AS response
FROM
(
SELECT t2.passenger_id as pass_id, t2.passenger_name as pass_n, t2.contact_data as cont_d, sum_8_2 as sum_8_3
FROM
(SELECT passenger_id, sum(amount) as sum_8_2
FROM ticket_flights tf
JOIN tickets t ON tf.ticket_no = t.ticket_no
JOIN flights ON flights.flight_id = tf.flight_id
WHERE flights.status != 'Cancelled'
GROUP BY passenger_id
HAVING sum(amount) = (SELECT min(sum_8_1)
FROM
(SELECT passenger_id, sum(amount) as sum_8_1
FROM ticket_flights tf
JOIN tickets t ON tf.ticket_no = t.ticket_no
JOIN flights ON flights.flight_id = tf.flight_id
WHERE flights.status != 'Cancelled'
GROUP BY passenger_id) as t_8_1)) as t_8_2
JOIN tickets t2 ON t_8_2.passenger_id = t2.passenger_id
ORDER BY t2.passenger_id
) as t_8;

-- 9 Вывести контактную информацию по пассажиру(ам) (passenger_id, passenger_name, contact_data) и общее время в полётах, для пассажира, который провёл
--   максимальное время в полётах

INSERT INTO results (id, response)

SELECT 9 AS id, CONCAT(pass_id_9, '|', pass_n_9, '|', cd_9, '|', sum_9) AS response
FROM
(
SELECT pass_id_9, t9.passenger_name as pass_n_9, t9.contact_data as cd_9, sum_9
FROM
(
SELECT pass_id_9, sum_9
FROM
(SELECT tickets.passenger_id as pass_id_9, sum(t_9_1.actual_duration) as sum_9
FROM
(
SELECT ticket_flights.ticket_no, COALESCE(actual_duration, INTERVAL '0') as actual_duration
FROM ticket_flights
JOIN flights_v ON ticket_flights.flight_id = flights_v.flight_id
WHERE flights_v.status = 'Arrived') as t_9_1
JOIN tickets ON t_9_1.ticket_no = tickets.ticket_no
GROUP BY tickets.passenger_id
ORDER BY sum(t_9_1.actual_duration) DESC) as t_9_2
WHERE sum_9 =
(
SELECT max(sum_9_2)
FROM
(
SELECT tickets.passenger_id, sum(t_9_2.actual_duration) as sum_9_2
FROM
(
SELECT ticket_flights.ticket_no, COALESCE(actual_duration, INTERVAL '0') as actual_duration
FROM ticket_flights
JOIN flights_v ON ticket_flights.flight_id = flights_v.flight_id
WHERE flights_v.status = 'Arrived') as t_9_2
JOIN tickets ON t_9_2.ticket_no = tickets.ticket_no
GROUP BY tickets.passenger_id
) as t_9_3)) as t_9_4
JOIN tickets t9 ON t9.passenger_id = t_9_4.pass_id_9
ORDER BY pass_id_9, t9.passenger_name, t9.contact_data, sum_9) as t_9_5;

-- 10 Вывести город(а) с количеством аэропортов больше одного

INSERT INTO results (id, response)

SELECT 10 AS id, city AS response
FROM
(
SELECT city, count(airport_code)
FROM airports
GROUP BY city
HAVING count(airport_code) > 1
ORDER BY city) as t_10;

-- 11 Вывести город(а), у которого самое меньшее количество городов прямого сообщения

INSERT INTO results (id, response)

SELECT 11 AS id, dc AS response
FROM
(
SELECT departure_city as dc, count(DISTINCT arrival_city) as cnt_11_1
FROM routes
GROUP BY departure_city
HAVING count(DISTINCT arrival_city) = (

SELECT min(cnt_11_2)
FROM
(SELECT count(DISTINCT arrival_city) as cnt_11_2
FROM routes
GROUP BY departure_city
) as t_11_1)
ORDER BY departure_city) as t_11_2;

-- 13 Вывести города, до которых нельзя добраться без пересадок из Москвы?

INSERT INTO results (id, response)

SELECT 13 AS id, arrival_city AS response
FROM
(
SELECT DISTINCT arrival_city
FROM routes
EXCEPT
SELECT DISTINCT arrival_city
FROM routes
WHERE departure_city = 'Москва'
EXCEPT
SELECT DISTINCT arrival_city
FROM routes
WHERE arrival_city = 'Москва'
ORDER BY arrival_city) as t_13;

-- 14 Вывести модель самолета, который выполнил больше всего рейсов

INSERT INTO results (id, response)

SELECT 14 AS id, a_mod AS response
FROM
(
SELECT a.model as a_mod FROM flights f
JOIN aircrafts a ON f.aircraft_code = a.aircraft_code
WHERE status = 'Arrived'
GROUP BY a.model
ORDER BY count(flight_id) DESC
LIMIT 1) as t_14;

-- 15 Вывести модель самолета, который перевез больше всего пассажиров

INSERT INTO results (id, response)

SELECT 15 AS id, a_mod AS response
FROM
(
SELECT a.model as a_mod
FROM ticket_flights tf
JOIN flights f ON tf.flight_id = f.flight_id
JOIN aircrafts a ON f.aircraft_code = a.aircraft_code
JOIN tickets t ON tf.ticket_no = t.ticket_no
WHERE status = 'Arrived'
GROUP BY a.model
ORDER BY count(t.passenger_id) DESC
LIMIT 1) as t_15;

-- 16 Вывести отклонение в минутах суммы запланированного времени перелета от фактического по всем перелётам

INSERT INTO results (id, response)

SELECT 16 AS id, abs_16 AS response
FROM
(
SELECT abs(EXTRACT(EPOCH from sum(scheduled_duration) - sum(actual_duration))/60) as abs_16
FROM flights_v
WHERE status = 'Arrived'
) as t_16;

-- 17 Вывести города, в которые осуществлялся перелёт из Санкт-Петербурга 2016-09-13

INSERT INTO results (id, response)

SELECT 17 AS id, a_c AS response
FROM
(
SELECT DISTINCT arrival_city as a_c, departure_city, status, date(actual_departure)
FROM flights_v
WHERE (status = 'Arrived' or status = 'Departed') and departure_city = 'Санкт-Петербург' and date(actual_departure) = '2016-09-13'
ORDER BY arrival_city) as t_17;

-- 18 Вывести перелёт(ы) с максимальной стоимостью всех билетов

INSERT INTO results (id, response)

SELECT 18 AS id, fl_id AS response
FROM
(
SELECT f.flight_id as fl_id, sum(amount)
FROM ticket_flights tf
JOIN flights f ON tf.flight_id = f.flight_id
WHERE status != 'Cancelled'
GROUP BY f.flight_id
HAVING sum(amount) =
(SELECT max(sum_18)
FROM
(
SELECT f.flight_id, sum(amount) as sum_18
FROM ticket_flights tf
JOIN flights f ON tf.flight_id = f.flight_id
WHERE status != 'Cancelled'
GROUP BY f.flight_id) as t_18_1)
ORDER BY f.flight_id) as t_18_2;

-- 19 Выбрать дни в которых было осуществлено минимальное количество перелётов

INSERT INTO results (id, response)

SELECT 19 AS id, ac_dp AS response
FROM
(
SELECT date(actual_departure) as ac_dp, count(flight_id)
FROM flights
WHERE status != 'Cancelled' and actual_departure is not null
GROUP BY date(actual_departure)
HAVING count(flight_id) =
(SELECT min(min_19)
FROM
(
SELECT date(actual_departure), count(flight_id) as min_19
FROM flights f
WHERE status != 'Cancelled' and actual_departure is not null
GROUP BY date(actual_departure)) as t_19_1)
ORDER BY date(actual_departure)) as t_19_2;

--20 Вывести среднее количество вылетов в день из Москвы за 09 месяц 2016 года

INSERT INTO results (id, response)

SELECT 20 AS id, cnt_20 AS response
FROM
(
SELECT count(flight_id)/30 as cnt_20
FROM
(
SELECT flight_id, arrival_city as a_c, departure_city, status, date(actual_departure) as dt, actual_departure
FROM flights_v
WHERE (status = 'Arrived' or status = 'Departed') and departure_city = 'Москва') as t_20_1
WHERE extract(month from dt) = 9 and extract(year from dt) = 2016) as t_20_2;

-- 21 Вывести топ 5 городов у которых среднее время перелета до пункта назначения больше 3 часов

INSERT INTO results (id, response)

SELECT 21 AS id, dep_c AS response
FROM
(
SELECT departure_city as dep_c, avg(actual_duration)
FROM flights_v
GROUP BY departure_city
HAVING EXTRACT(HOUR from avg(actual_duration)) > 3
ORDER BY avg(actual_duration) DESC
LIMIT 5) as t_21
ORDER BY response;