-- uninstall_cnpj.sql

SET client_min_messages = warning;

DROP DOMAIN IF EXISTS cnpj;
DROP OPERATOR IF EXISTS ##("numeric", NONE);
DROP OPERATOR IF EXISTS ##?("numeric", NONE);

DROP FUNCTION IF EXISTS formata_cnpj(NUMERIC);
DROP FUNCTION IF EXISTS formata_cnpj(BIGINT);

DROP FUNCTION IF EXISTS valida_cnpj(NUMERIC);
DROP FUNCTION IF EXISTS valida_cnpj(BIGINT);
DROP FUNCTION IF EXISTS valida_cnpj(text);
