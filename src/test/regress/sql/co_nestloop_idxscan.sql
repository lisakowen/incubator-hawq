--
-- Nested loop join with index scan on CO table, test for MPP-17658
--


create schema co_nestloop_idxscan;
create table co_nestloop_idxscan.foo (id bigint, data text) with (appendonly=true, orientation=column)
distributed by (id);
create table co_nestloop_idxscan.bar (id bigint) distributed by (id);

-- Changing the text to be smaller doesn't repro the issue
insert into co_nestloop_idxscan.foo select 1, repeat('xxxxxxxxxx', 100000);
insert into co_nestloop_idxscan.bar values (1);

create index foo_id_idx on co_nestloop_idxscan.foo(id);

-- test with hash join
explain select f.id from co_nestloop_idxscan.foo f, co_nestloop_idxscan.bar b where f.id = b.id;
select f.id from co_nestloop_idxscan.foo f, co_nestloop_idxscan.bar b where f.id = b.id;

-- test with nested loop join
set enable_hashjoin=off;
explain select f.id from co_nestloop_idxscan.foo f, co_nestloop_idxscan.bar b where f.id = b.id;
select f.id from co_nestloop_idxscan.foo f, co_nestloop_idxscan.bar b where f.id = b.id;

-- test with nested loop join and index scan
set enable_seqscan = off;
explain select f.id from co_nestloop_idxscan.foo f, co_nestloop_idxscan.bar b where f.id = b.id;
select f.id from co_nestloop_idxscan.foo f, co_nestloop_idxscan.bar b where f.id = b.id;

drop schema co_nestloop_idxscan cascade;
