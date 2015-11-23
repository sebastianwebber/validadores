\set ECHO none
BEGIN;
\i sql/cnpj.sql
\set ECHO all

SELECT valida_cnpj(53870617000124);

SELECT 53870617000124 ##? AS cnpj_valido;
SELECT 35705388000100 ##? AS cnpj_valido;
SELECT NOT 00000000000191 ##? AS cnpj_valido;
SELECT NOT 51255388000100 ##? AS cnpj_valido;

CREATE TABLE empresa (
    numero_doc cnpj
);

INSERT INTO empresa VALUES(35705388000100);
INSERT INTO empresa VALUES(53870617000124);

SAVEPOINT cnpj_invalido1;
INSERT INTO empresa VALUES(00000000000191);
ROLLBACK TO cnpj_invalido1;


SAVEPOINT cnpj_invalido2;
INSERT INTO empresa VALUES(51255388000100);
ROLLBACK TO cnpj_invalido2;

SAVEPOINT valida_formata_cnpj;
SELECT formata_cnpj(53870617000124);
SELECT formata_cnpj(12345);

ROLLBACK TO valida_formata_cnpj;

SAVEPOINT valida_operadores;
SELECT 53870617000124 ##;
SELECT 53870617000124 ##?;
SELECT 5124 ##; -- vai passar assim mesmo
SELECT 53870617000121 ##?; -- vai falhar no digito

ROLLBACK TO valida_operadores;

ROLLBACK;