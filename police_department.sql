CREATE SCHEMA IF NOT EXISTS police_department
    AUTHORIZATION postgres;
set search_path to police_department, public;

DROP TABLE IF EXISTS cases CASCADE;
DROP TABLE IF EXISTS category CASCADE;
DROP TABLE IF EXISTS client CASCADE;
DROP TABLE IF EXISTS clue CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP TABLE IF EXISTS document CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS salary CASCADE;
DROP TABLE IF EXISTS title CASCADE;

--таблица сотрудников участка   
CREATE SEQUENCE id_emp start 1001;
CREATE TABLE IF NOT EXISTS employee (
  	id bigint DEFAULT nextval('id_emp'),
  	first_name character varying(14) NOT NULL,
    last_name character varying(16) NOT NULL,
  	hire_date date DEFAULT current_date,
	num_of_ac_cases numeric,
  	PRIMARY KEY (id)
);
ALTER SEQUENCE id_emp OWNED BY employee.id;

--таблица отделов участка
CREATE TABLE IF NOT EXISTS department(
	emp_id bigint NOT NULL,
	dep_name text NOT NULL,
	from_date date DEFAULT current_date,
	to_date date,
	PRIMARY KEY (emp_id, dep_name),
	FOREIGN KEY (emp_id)
		REFERENCES employee(id) MATCH SIMPLE
		ON UPDATE RESTRICT
		ON DELETE CASCADE
);

--таблица зарплат сотрудников
CREATE TABLE IF NOT EXISTS salary(
	emp_id bigint NOT NULL,
	amount numeric NOT NULL,
	from_date date DEFAULT current_date,
	to_date date,
	PRIMARY KEY (emp_id, from_date),
    FOREIGN KEY (emp_id)
        REFERENCES employee (id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);

--таблица должностей сотрудников
CREATE TABLE IF NOT EXISTS title
(
    emp_id bigint NOT NULL,
    title character varying(50) NOT NULL,
    from_date date DEFAULT current_date,
    to_date date,
    PRIMARY KEY (emp_id, title, from_date),
    FOREIGN KEY (emp_id)
        REFERENCES employee (id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);

--тип данных статус дела
--CREATE TYPE case_status AS ENUM
--    ('A', 'C', 'U'); --active/closed/unsolved

--таблица дел
CREATE SEQUENCE id_case start 1001;
CREATE TABLE IF NOT EXISTS cases
(
	id bigint DEFAULT nextval('id_case'),
	status case_status NOT NULL,
	from_date date DEFAULT current_date,
    to_date date,
	investigator_id bigint,
	PRIMARY KEY (id),
    FOREIGN KEY (investigator_id)
        REFERENCES employee (id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);
ALTER SEQUENCE id_case OWNED BY cases.id;

--таблица улик
CREATE SEQUENCE id_clue start 1001;
CREATE TABLE IF NOT EXISTS clue
(
	id bigint DEFAULT nextval('id_clue'),
	description text not null,
	case_id bigint not null,
	PRIMARY KEY (id),
    FOREIGN KEY (case_id)
        REFERENCES cases (id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);
ALTER SEQUENCE id_clue OWNED BY clue.id;

--таблица клиентов(свидетелей, жертв и подозреваемых)
CREATE SEQUENCE id_client;
CREATE TABLE IF NOT EXISTS client (
  	id bigint DEFAULT nextval('id_client'),
  	first_name character varying(14),
    last_name character varying(16),
  	phone_number bigint,
	birth_date date,
	address text,
  	PRIMARY KEY (id)
);
ALTER SEQUENCE id_client OWNED BY client.id;

--тип данных категория клиента
--CREATE TYPE client_category AS ENUM
--    ('W', 'V', 'S'); --witness/victim/suspect
	
--таблица категорий клиентов
CREATE TABLE IF NOT EXISTS category(
	client_id bigint NOT NULL,
	case_id bigint NOT NULL,
	who client_category not null,
	PRIMARY KEY (client_id, case_id),
	FOREIGN KEY (client_id)
		REFERENCES client(id) MATCH SIMPLE
		ON UPDATE RESTRICT
		ON DELETE CASCADE,
	FOREIGN KEY (case_id)
		REFERENCES cases(id) MATCH SIMPLE
		ON UPDATE RESTRICT
		ON DELETE CASCADE
);

--тип документа(заявление, объяснительная, рапорт)
--CREATE TYPE document_type AS ENUM
--    ('S', 'E', 'R'); --statement/explanation/report
	
--таблица документов
CREATE SEQUENCE id_document start 1001;
CREATE TABLE IF NOT EXISTS document
(
	id bigint DEFAULT nextval('id_document'),
	type document_type not null,
	case_id bigint not null,
	document_date date DEFAULT current_date,
	PRIMARY KEY (id),
    FOREIGN KEY (case_id)
        REFERENCES cases (id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE CASCADE
);
ALTER SEQUENCE id_document OWNED BY document.id;

-- заполнение таблиц

insert into employee (first_name, last_name)
			values ('Fred','Lewis');
insert into employee (first_name, last_name, hire_date)
			values ('William','Garcia', '2022-11-03');
insert into employee (first_name, last_name, hire_date)
			values ('Alex','Lee', '2015-07-23');
insert into employee (first_name, last_name, hire_date)
			values ('Josh','Martin', '2017-05-17');

insert into department (emp_id, dep_name) 
			values ('1001', 'criminal');
insert into department (emp_id, dep_name, from_date, to_date) 
			values ('1002', 'administrative', '2022-11-03', '2023-11-04');
insert into department (emp_id, dep_name, from_date, to_date) 
			values ('1003', 'traffic', '2015-07-23', '2017-05-26');
insert into department (emp_id, dep_name, from_date, to_date) 
			values ('1003', 'administrative', '2017-05-26', '2019-10-01');
insert into department (emp_id, dep_name, from_date) 
			values ('1003', 'criminal', '2019-10-01');
insert into department (emp_id, dep_name, from_date, to_date) 
			values ('1004', 'criminal', '2017-05-17', '2021-12-12');
insert into department (emp_id, dep_name, from_date) 
			values ('1004', 'administrative', '2021-12-12');
			
insert into title (emp_id, title) 
			values ('1001', 'medical_examiner');
insert into title (emp_id, title, from_date, to_date) 
			values ('1002', 'officer', '2022-11-03', '2023-11-04');
insert into title (emp_id, title, from_date, to_date) 
			values ('1003', 'traffic_policeman', '2015-07-23', '2017-05-26');
insert into title (emp_id, title, from_date, to_date) 
			values ('1003', 'officer', '2017-05-26', '2019-10-01');
insert into title (emp_id, title, from_date) 
			values ('1003', 'investigator', '2019-10-01');
insert into title (emp_id, title, from_date, to_date) 
			values ('1004', 'investigator', '2017-05-17', '2021-12-12');
insert into title (emp_id, title, from_date) 
			values ('1004', 'officer', '2021-12-12');

insert into salary (emp_id, amount) 
			values ('1001', '87000');
insert into salary (emp_id, amount, from_date, to_date) 
			values ('1002', '75300', '2022-11-03', '2023-11-04');
insert into salary (emp_id, amount, from_date, to_date) 
			values ('1003', '49600', '2015-07-23', '2017-05-26');
insert into salary (emp_id, amount, from_date, to_date) 
			values ('1003', '66800', '2017-05-26', '2019-10-01');
insert into salary (emp_id, amount, from_date, to_date) 
			values ('1003', '74400', '2019-10-01', '2022-01-17');
insert into salary (emp_id, amount, from_date) 
			values ('1003', '96000', '2022-01-17');
insert into salary (emp_id, amount, from_date, to_date) 
			values ('1004', '70470', '2017-05-17', '2021-12-12');
insert into salary (emp_id, amount, from_date, to_date) 
			values ('1004', '72500', '2021-12-12', '2023-03-02');
insert into salary (emp_id, amount, from_date) 
			values ('1004', '78500', '2023-03-02');

insert into cases (status, from_date, investigator_id) 
			values ('A', '2023-12-20', '1003');
insert into cases (status, from_date, investigator_id) 
			values ('U', '2018-11-19', '1004');
insert into cases (status, from_date, to_date, investigator_id) 
			values ('C', '2020-04-21', '2020-05-30', '1004');
insert into cases (status, from_date, to_date, investigator_id) 
			values ('C', '2021-06-08', '2021-09-05', '1003');
			
insert into clue (description, case_id) values ('a fingerprint', '1003');
insert into clue (description, case_id) values ('a telephone', '1003');
insert into clue (description, case_id) values ('a piece of paint', '1002');
insert into clue (description, case_id) values ('a piece of cloth', '1001');
insert into clue (description, case_id) values ('a cigarette butt', '1004');

insert into client (first_name, last_name, phone_number, address)
			values ('Jack', 'Fisher', '89156059438', '1337 Nice Avenue 13B');
insert into client (first_name, last_name, phone_number)
			values ('Robert', 'Hardin', '89738594038');
insert into client (first_name, last_name, phone_number)
			values ('Theodore', 'Irwin', '89654839582');
insert into client (first_name, last_name, phone_number)
			values ('Dakota', 'Lynn', '89029584730');
insert into client (first_name, last_name, phone_number)
			values ('Kylo', 'O’Connor', '89953057749');

insert into category (client_id, case_id, who)
			values ('1', '1001', 'W');
insert into category (client_id, case_id, who)
			values ('2', '1003', 'V');
insert into category (client_id, case_id, who)
			values ('3', '1004', 'S');

insert into document (type, case_id, document_date)
			values ('S', '1001', '2023-12-21');
insert into document (type, case_id, document_date)
			values ('E', '1002', '2019-11-19');
insert into document (type, case_id, document_date)
			values ('R', '1003', '2020-05-09');
						
--select * from cases;
--select * from category;
--select * from client;
--select * from clue;
--select * from department;
--select * from document;
--select * from employee;
--select * from salary;
--select * from title;

-- Процедура
-- 1) добавление нового клиента, если его не существует
--set search_path to police_department, public;
create or replace procedure add_client(
    ask_first_name text,
	ask_last_name text,
    ask_phone_number numeric,
	ask_birth_date date,
	ask_address text
)
as $$
begin
	if exists (select 1 from client cl
		where cl.first_name = ask_first_name and cl.last_name = ask_last_name
			   and cl.phone_number = ask_phone_number) then
	else
		insert into client (first_name, last_name, phone_number,
							birth_date, address)
			values (ask_first_name, ask_last_name, ask_phone_number,
							ask_birth_date, ask_address);
	end if;
end;
$$ language plpgsql;

--call add_client('Zayn', 'Pollard', '89475638504', '1995-09-27', '394 Bayshore Rd');
--select * from client;

--2) подсчёт активных дел у следователя
set search_path to police_department, public;
create or replace procedure counter_of_active_cases( emp_id bigint )
as $$
	declare counter int;
begin
	counter = (select count(*) from cases where status = 'A' and investigator_id = emp_id);
	if exists (select 1 from employee where id = emp_id) then
		update employee set num_of_ac_cases = counter
			where id = emp_id;
	else
		insert into employee (id, first_name, last_name, num_of_ac_cases)
					values (emp_id, 'Delo', 'Delov', counter);
	end if;
end;
$$ language plpgsql;
CALL counter_of_active_cases(1001);
CALL counter_of_active_cases(1002);
CALL counter_of_active_cases(1003);
CALL counter_of_active_cases(1004);
--select * from employee;

-- триггер
-- 3) пересчёт активных дел после открытия нового
create or replace function recount_cases() returns trigger as $$
	begin
		call counter_of_active_cases(CAST(new.investigator_id as bigint));
		return new;
	end;
$$ LANGUAGE plpgsql;

create or replace trigger recount_cases after INSERT on cases
    for each row execute procedure recount_cases();

--Проверка триггера
--insert into cases (status, investigator_id) values ('A', '1003');
--select * from employee;

-- view
-- 4) выводит список зарплат по отделам в настоящее время(сортирует по назанию отдела)
create view salaries_in_the_department as
	select dep_name, first_name, last_name, amount
		from department d join employee e
			on d.emp_id = e.id
		join salary s
			on d.emp_id = s.emp_id
		where current_date >= s.from_date and (current_date <= s.to_date or s.to_date is null)
		and current_date >= d.from_date and (current_date <= d.to_date or d.to_date is null)
	order by dep_name;

--select * from salaries_in_the_department;
--drop view salaries_in_the_department;