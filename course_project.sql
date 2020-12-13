/* Курсовой проект
Создадим базу данных онлайн кинотеатра ivi.ru
Используемые таблицы: фильмы, тв-канналы, категории фильмов, категории тв-канналов, актеры, режиссеры,
языки, качество фильмов, отзывы, трейлеры, пользователи, фильмы(которые посмотрели пользователи), отложенные фильмы (фильмы, которые 
пользователи отметили флажком "посмотреть позже"), настройки пользователя, серии(для сериалов), подборки.
Напишем триггеры проверки пароля на количество символов (нельзя менее 6 символов), проверки наличия номера телефона или email у пользователя
напишем функцию проверки наличия подписки у пользователя и функцию проверки активности пользователя
Сделаем представления: фильмы 2019 года и топ 10 фильмов по версии ivi
А так же напишем универсальный запрос для просмотра данных о фильме
Скрипт наполнения БД в отдельном файле.

*/


drop database if exists ivi_DB;
create database ivi_DB;
-- +
drop table if exists films;
create table films(
id serial primary key,
name varchar(255) not null,
production_year DATE,
country varchar(255),
director_id bigint unsigned,
duration smallint unsigned comment 'Продолжительность',
description text,
rating float,
age_category tinyint,
is_series bool default 0 comment 'Сериал или нет',
is_cartoon bool default 0 comment 'Мультфильм или нет',
subscription bool not null comment 'Нужна ли подписка для просмотра',
main_trailer_id bigint comment 'Основной трейлер',
title_picture varchar(55) comment 'Обложка фильма',
price float unsigned comment '0 если бесплатный или по подписке',
foreign key (director_id) references directors(id)
);
alter table films change production_year production_year year;
alter table films change name name varchar(255) unique;
-- +
drop table if exists tv_channels;
create table tv_channels(
id smallint unsigned not null auto_increment unique primary key,
name varchar(255) not null,
description text,
subscription bool not null comment 'Нужна ли подписка для просмотра'
);

-- Создадим таблицу для категорий тв-канналов +
drop table if exists tv_categories;
create table tv_categories(
id tinyint unsigned not null auto_increment unique primary key,
name varchar(255) not null
);

-- Создадим таблицу для создания связи тв-канналов и их категорий +
drop table if exists tv_channels_categories;
create table tv_channels_categories(
channel_id smallint unsigned not null,
category_id tinyint unsigned not null,
primary key (channel_id, category_id),
index (channel_id),
index (category_id),
foreign key (channel_id) references tv_channels(id),
foreign key (category_id) references tv_categories(id)
);
-- +
drop table of exists actors;
create table actors(
id serial primary key,
name varchar(255),
annotation text comment 'Краткое описание',
biography mediumtext
);
alter table actors change name name varchar(255) unique;

-- Создадим таблицу для связи фильмов и актеров (многое ко многим) +
drop table if exists films_actors;
create table films_actors(
film_id bigint unsigned not null,
actor_id bigint unsigned not null,
primary key (film_id, actor_id),
foreign key (film_id) references films(id),
foreign key (actor_id) references actors(id)
);

-- Таблица для категории фильмов +
drop table if exists categories; 
create table categories(
id serial primary key,
name varchar(255)
);
alter table categories change name name varchar(255) unique;

-- Таблица для связи фильмов и каттегорий (Один фильм может относится к нескольким категориям) +
drop table if exists films_categories;
create table films_categories(
film_id bigint unsigned not null,
category_id bigint unsigned not null,
primary key (film_id, category_id),
foreign key (film_id) references films(id),
foreign key (category_id) references categories(id)
);

-- ++
drop table if exists directors;
create table directors(
id serial primary key,
name varchar(255)
);
alter table directors change name name varchar(255) unique;
-- Создадим таблицу для хранения доступных на сервисе языков ++
drop table if exists languages;
create table languages(
id tinyint unsigned not null auto_increment unique,
name varchar(255)
);

-- Таблица для связи фильмов и доступных для просмотра языков фильма +
drop table if exists films_languages;
create table films_languages(
film_id bigint unsigned not null,
language_id tinyint unsigned not null,
primary key (film_id, language_id),
foreign key (film_id) references films(id),
foreign key (language_id) references languages(id)
);

-- Таблица для хранения доступных качеств видео (например HD 720) + +
drop table if exists quality;
create table quality(
id tinyint unsigned not null auto_increment unique,
name varchar(55)
);

-- Таблица для связи фильмов и доступных качеств просмотра +
drop table if exists films_quality;
create table films_quality(
film_id bigint unsigned not null,
quality_id tinyint unsigned not null,
primary key (film_id, quality_id),
foreign key (film_id) references films(id),
foreign key (quality_id) references quality(id)
);

-- Отзывы к фильмам (один ко многим) +
drop table if exists films_reviews;
create table films_reviews(
id serial primary key,
user_id bigint unsigned not null,
film_id bigint unsigned not null,
review text,
created_at datetime default current_timestamp,
updated_at datetime default current_timestamp on update current_timestamp,
foreign key (user_id) references users(id),
foreign key (film_id) references films(id)
);

-- В одном фильме может быть несколько трейлеров (один ко многим) +
drop table if exists trailers;
create table trailers(
id serial primary key,
name varchar(255),
duration time,
film_id bigint unsigned not null,
foreign key (film_id) references films(id)
);

-- Добавим таблицу с информацией о пользователях, в том числе информацией о платной подписке пользователей +
drop table if exists users;
create table users(
id serial primary key,
name varchar(255),
photo_file_name varchar(55),
phone varchar(20),
email varchar(55),
have_subscription bool default 0,
start_subscription date,
finish_subscription date,
pass char(30)
);

-- Таблица, в которую помещаем фильмы, просмотренные пользователем +
drop table if exists watched_films;
create table watched_films(
user_id bigint unsigned not null,
film_id bigint unsigned not null,
watched_date datetime default current_timestamp,
primary key (user_id, film_id),
foreign key (user_id) references users(id),
foreign key (film_id) references films(id)
);

-- Таблица, в которую помещаем фильмы, которые пользователи отметили флажко "Смотреть позже" +
drop table if exists watch_later;
create table watch_later(
user_id bigint unsigned not null,
film_id bigint unsigned not null,
primary key (user_id, film_id),
foreign key (user_id) references users(id),
foreign key (film_id) references films(id)
);

-- Таблица, в которой храним настройки пользователей +
drop table if exists users_settings;
create table users_settings(
user_id serial primary key,
default_quality enum('Full HD 1080', 'HD 720', 'SD 480', 'SD 320', 'SD 240') default 'HD 720' comment 'Качество видео пользователя по умолчанию',
content_18_plus bool default 1 comment 'Отображается ли контент 18+',
interface_animation bool default 1 comment 'Включена ли анимация в меню',
show_profile_before_start bool default 1 comment 'Отображать ли профиль в списке профилей перед включением',
premier_announcement bool default 1 comment 'СМС оповещение о новинках',
special_orders_announcement bool default 1 comment 'СМС оповещение о специальных предложениях',
unwatched_reminders_announcement bool default 1 comment 'СМС оповещение о незаконченных фильмах',
foreign key (user_id) references users(id)
);

-- Создадим отдельную таблицу для серий и сезонов сериалов +
drop table if exists series;
create table series(
id serial primary key,
film_id bigint unsigned not null,
season_number tinyint not null comment 'Номер сезона',
series_number smallint not null comment 'Номер серии в сезоне',
series_name varchar(255) comment 'Название серии',
series_discription text comment 'Описание серии',
foreign key (film_id) references films(id)
);

-- Подборки фильмов +
drop table if exists collections;
create table collections(
id smallint unsigned not null auto_increment unique primary key,
name varchar(255) not null
);

-- Фильмы в подбоках +
drop table if exists films_collections;
create table films_collections(
film_id bigint unsigned not null,
collection_id smallint unsigned not null,
primary key(collection_id, film_id),
foreign key (film_id) references films(id),
foreign key (collection_id) references collections(id)
);

-- Создадим триггеры, хранимые процедуры, представления, характерные выборки

-- Триггер. Если пароль пользователя менее 6 символов, то сгенерируем ошибку
drop trigger if exists check_pass;
delimiter //
create trigger check_pass before insert on users
for each row
begin 
	if (length(new.pass) < 6) then 
		signal sqlstate '45000' set message_text = 'Пароль должен быть более 6 символов';
	end if;
end//
delimiter ;

-- Триггер. У пользователя должен быть или телефон или email
drop trigger if exists check_email_phone;
delimiter //
create trigger check_email_phone before insert on users
for each row
begin 
	if (isnull(new.email) and isnull(new.phone)) then 
		signal sqlstate '45000' set message_text = 'Введите телефон или email';
	end if;
end //
delimiter ;

-- Функция для проверки, есть ли подписка у пользователя

drop function if exists check_subscription;
delimiter //
create function check_subscription(us_id int)
returns boolean reads sql data
begin
	if (us_id in (select id from users where have_subscription = 1)) then
		return true;
	else
		return false;
	end if;
end //
delimiter ;

-- Функция для проверки активности пользователя по формуле 
-- Активность = (5 если есть подписка, 0 если нет) + Количество просмотренных фильмов + Количество оставленных отзывов* 3

drop function if exists user_activity;
delimiter //
create function user_activity(us_id int)
returns int reads sql data
begin
	declare activity_subscription int;
	if (us_id in (select id from users where have_subscription = 1)) then
		set activity_subscription = 5;
	else set activity_subscription = 0;
	end if;
	return activity_subscription + (select count(*) from watched_films where user_id = us_id) + (select count(*) from films_reviews where user_id = us_id);
end//
delimiter ;

-- Сделаем представление фильмов 2019 года с жанрами и описанием
drop view if exists films_2019;
create view films_2019 as 
select 
f.name as "Название фильма",
f.country as 'Страна',
d.name as 'Режиссер',
group_concat(c.name separator ', ') as 'Жанр',
f.description as 'Описание' 
from
films f
join
films_categories fc  
on f.id = fc.film_id
join categories c
on c.id = fc.category_id
join directors d 
on f.director_id = d.id
where f.production_year = 2019
group by f.name;

-- Сделаем представление топ 10 фильмов по версии ivi

drop view if exists top_10;
create or replace view top_10 as
select
f.name as 'Название фильма',
f.country as 'Страна',
round(f.rating, 1) as 'Рейтинг',
f.age_category as 'Возрастная категория', 
d.name as 'Режиссер',
group_concat(c.name separator ', ') as 'Жанр',
f.description as 'Описание' 
from
films f
join 
directors d on d.id = f.director_id 
join
films_categories fc  
on f.id = fc.film_id
join categories c on c.id = fc.category_id 
group by f.name
order by f.rating desc limit 10; 

select * from top_10;

-- Выведем информацию о фильме с id 1 (работает с любым фильмом)
select 
f.name as 'Название',
f.country as 'Страна',
concat(f.age_category, '+') as 'Категория',
group_concat(distinct(c.name) separator ', ') as 'Жанр',
f.duration as 'Продолжительность',
d2.name as 'Режиссер',
group_concat(distinct(a.name) separator ', ') as 'Актеры',
f.main_trailer_id as 'Трейлер',
group_concat(distinct(l2.name) separator ', ') as 'Языки',
group_concat(distinct(q2.name) separator ', ') as 'Доступное качество',
f.description as 'Описание'
from films f
join films_categories fc  
on f.id = fc.film_id
join categories c on c.id = fc.category_id  
join films_actors fa on fa.film_id = f.id
join actors a on a.id = fa.actor_id
join films_languages fl on fl.film_id = f.id
join languages l2 on l2.id = fl.language_id 
join directors d2 on f.director_id = d2.id
join films_quality fq on fq.film_id = f.id
join quality q2 on q2.id = fq.quality_id 
where f.id = 1 group by f.name;
