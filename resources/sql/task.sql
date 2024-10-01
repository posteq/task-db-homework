-- 1 Вывести к каждому самолету класс обслуживания и количество мест этого класса

select model ->> 'ru' as model,fare_conditions,count(seat_no) as number_seats
from seats join  aircrafts_data ad using(aircraft_code)
GROUP BY model,fare_conditions
order by model,fare_conditions;

-- 2 Найти 3 самых вместительных самолета (модель + кол-во мест)

select model ->> 'ru' as model, count(seat_no) as number_seats
from seats join aircrafts_data ad using(aircraft_code)
group by model
order by number_seats desc
limit 3;


-- 3 Найти все рейсы, которые задерживались более 2 часов

select *
from flights
where extract(epoch from(actual_departure-scheduled_departure))/3600 >2
order by 1,2;


-- 4 Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'), с указанием имени пассажира и контактных данных

select book_date,passenger_name,contact_data
from ticket_flights tf  join tickets t using(ticket_no)
						 join bookings b using(book_ref)
where fare_conditions like('Business')
order by book_date desc
limit 10;

-- 5 Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business')

select flight_id
from flights f
where flight_id not in (
	select flight_id
	from ticket_flights tf
	where fare_conditions like('Business')
	group by flight_id
	)
order by flight_id;

-- 6 Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой по вылету

select airport_name ->>'ru' as airport_name,city ->>'ru' as city
from airports_data ad join flights f on departure_airport = airport_code
where status = 'Delayed'
group by airport_name,city
order by city;

-- 7 Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта, отсортированный по убыванию количества рейсов

select airport_name ->>'ru' as airport_name,count(*) as amount
from flights fv join airports_data ad
	on departure_airport = airport_code
group by airport_name
order by amount desc;

-- 8 Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным

select *
from flights f
where scheduled_arrival <> actual_arrival ;

--9. Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200" с сортировкой по местам

SELECT aircraft_code,
		model -> 'ru' AS model ,seat_no,fare_conditions
FROM aircrafts_data ad
JOIN seats s using(aircraft_code)
WHERE fare_conditions NOT like('Economy')
		AND model ->> 'ru' = 'Аэробус A321-200'
ORDER BY  seat_no;

--10. Вывести города, в которых больше 1 аэропорта (код аэропорта,аэропорт, город)

SELECT airport_code,
		 airport_name->'ru' AS airport_name, city ->'ru' AS city
FROM airports_data ad
JOIN
	(SELECT city,
		 count(city) AS amount
	FROM airports_data ad2
	GROUP BY  city) a2_city using(city)
WHERE a2_city.amount > 1;

--11. Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований

select *
from tickets t join
			(select book_ref
			from bookings b
			where total_amount > (select avg(total_amount)
									from bookings b)) b
			using(book_ref);


--12. Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация

select *
from flights f
where departure_airport in (select airport_code
								from airports_data
								where city ->> 'ru'= ('Екатеринбург')
								group by airport_code)
	and arrival_airport in(select airport_code
								from airports_data
								where city ->> 'ru'= ('Москва')
								group by airport_code)
	and status like('Scheduled')
order by scheduled_departure
limit 1;

--13. Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)

 (select *
  from bookings
  order by total_amount
  limit 1)
 union
 (select *
  from bookings
  order by total_amount DESC
  limit 1);

-- 14 Написать DDL таблицы Customers, должны быть поля id, firstName, LastName, email, phone. Добавить ограничения на поля (constraints)

create table Customers(
  id serial primary key,
  firstName varchar(50) not null,
  LastName varchar(50) not null,
  email varchar(50) unique,
  phone varchar(50) not null unique,
  check(
    email like('%@%.%')
  )
);

-- 15 Написать DDL таблицы Orders, должен быть id, customerId, quantity. Должен быть внешний ключ на таблицу customers + constraints

create table Orders(
  id serial primary key,
  customerId int not null,
  quantity int default 0,
  foreign key(customerId) references Customers(id) on delete restrict
);

-- 16 Написать 5 insert в эти таблицы

insert into Customers(firstName, LastName, email, phone)
values
  ('Ivan', 'Petrov', 'an@.com', '578636'),
  ('Vlad', 'Prilepin', 'vPril@m.ru', '+375253657826'),
  ('666', '666', '666@666.com', '666');
insert into Orders(customerId, quantity)
values
  (1, 30),
 (2, 23);

-- 17 Удалить таблицы

drop table Orders;
drop table Customers;
