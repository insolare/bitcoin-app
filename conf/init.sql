create schema if not exists bitcoin;

create table if not exists bitcoin.configuration
(
    name text primary key,
    value text not null
);

create table if not exists bitcoin.currencies
(
    name text primary key,
    proj_id text[] not null
);

commit;