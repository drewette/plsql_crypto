set define off;

--build tables
@tables\BLOCKCHAIN.sql;
@tables\BLOCKCHAIN_PK.sql;
@tables\BLOCKCHAIN_CONSTRAINT.sql;

--build packages
@packages\blockchain.pks;
@packages\blockchain.pkb;
@packages\sha256.pks;
@packages\sha256.pkb;


