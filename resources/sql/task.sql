-- 1 Вывести к каждому самолету класс обслуживания и количество мест этого класса

select model,fare_conditions,count(seat_no) as number_seats
from seats inner join aircrafts ad using(aircraft_code)
GROUP BY model,fare_conditions
order by model,fare_conditions;

-- 2 Найти 3 самых вместительных самолета (модель + кол-во мест)

select model , count(seat_no) as number_seats
from seats inner join aircrafts ad using(aircraft_code)
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
from ticket_flights tf left join tickets t using(ticket_no)
						left join bookings b using(book_ref)
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
--select airport_name,city
--from airports_data ad join (select departure_airport
--from flights
--where extract(epoch from(actual_departure-scheduled_departure))=0
--group by departure_airport) aiport_delay
--using(departure_airport)
--where airport_code not in departure_airport

select airport_name,city
from airports_data ad join flights f on departure_airport = airport_code
where status = 'Delayed';




-- 7 Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта, отсортированный по убыванию количества рейсов

select airport_name,count(*) as amount
from flights_v fv join airports_data ad on departure_airport = airport_code
group by airport_name
order by amount desc;

-- 8 Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным

select count(*)
from flights f
where scheduled_arrival <> actual_arrival ;