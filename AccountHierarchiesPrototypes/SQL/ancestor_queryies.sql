select * from account_ancestor where num_generations > 0 order by ancestor_id, num_generations, descendent_id 
delete from account_ancestor
select * from account_ancestor where ancestor_id ='1410613883.1.0'
select count(*) from account
select count(*) from account_ancestor

select distinct ancestor_id from account_ancestor where num_generations = 7;

select * from account_ancestor inner join account on account_id=descendent_id  where ancestor_id='766572053.0' and account_name like '%.0.0%'
select * from account

select * from account_ancestor inner join account on account_id=descendent_id where ancestor_id='*****' and num_generations=1

select * from account_ancestor where descendent_id='1410613883.1.0'

select count(*) from account_ancestor a1, account_ancestor a2, account_ancestor a3 where
a3.ancestor_id='1907107968.8.4'   and
a3.descendent_id=a2.descendent_id and
a1.descendent_id='1907107968.8.4'and a1.num_generations > 0  and
a1.ancestor_id=a2.ancestor_id

delete a2 from account_ancestor a1, account_ancestor a2, account_ancestor a3 where
a3.ancestor_id='1984751967.6' and
a3.descendent_id=a2.descendent_id and
a1.descendent_id='1984751967.6'and a1.num_generations > 0  and
a1.ancestor_id=a2.ancestor_id

insert into account_ancestor(ancestor_id, descendent_id, num_generations) 
select a.ancestor_id, d.descendent_id, a.num_generations+d.num_generations+1 as num_generations 
from account_ancestor d cross join account_ancestor a where a.descendent_id = '*****' and d.ancestor_id = '1984751967.6'

-- Select all roots of the ancestor tree (might be a good idea to make a synthetic root to make this easier)
select count(*) from account where account_id not in (select descendent_id from account_ancestor where num_generations>0)

-- How does one select all of the leaves of the ancestor tree???

select * from account_ancestor where descendent_id='1984751967.6' and num_generations=1


select * from account_ancestor

--delete from t_account_ancestor
--delete from t_account_test

--drop index t_account_ancestor.t_account_ancestor_level
create index t_account_ancestor_level on t_account_ancestor(id_descendent,num_generations)

-- Move 33412 between -1 and [36745,37745]
begin transaction
delete a2 from t_account_ancestor a1, t_account_ancestor a2, t_account_ancestor a3 
where a3.id_ancestor=73154 
and a3.id_descendent=a2.id_descendent 
and a1.id_descendent=73154 and a1.num_generations > 0  
and a1.id_ancestor=a2.id_ancestor
commit transaction

insert into t_account_ancestor(id_ancestor, id_descendent, num_generations) 
select a.id_ancestor, d.id_descendent, a.num_generations+d.num_generations+1 as num_generations 
from t_account_ancestor d cross join t_account_ancestor a 
where a.id_descendent = 73150 and d.id_ancestor = 73154

select * from t_account_ancestor where id_descendent=73154
select * from t_account_ancestor where id_ancestor=73154


select * from t_account_ancestor where num_generations > 6

begin transaction
delete a2 from t_account_ancestor a3
inner loop join t_account_ancestor a2 on a3.id_descendent=a2.id_descendent
inner loop join t_account_ancestor a1 on a1.id_ancestor=a2.id_ancestor
where 
a3.id_ancestor=73154 
and a1.id_descendent=73154 and a1.num_generations > 0  


exec mtsp_move_account 73154, 73152

GO

-- This stored procedure move the entire subtree rooted
-- at @id_root under the new parent @id_parent.
create procedure mtsp_move_account @id_root integer, @id_parent integer
as
delete a2 from t_account_ancestor a1, t_account_ancestor a2, t_account_ancestor a3 
where a3.id_ancestor=@id_root 
and a3.id_descendent=a2.id_descendent 
and a1.id_descendent=@id_root and a1.num_generations > 0  
and a1.id_ancestor=a2.id_ancestor

insert into t_account_ancestor(id_ancestor, id_descendent, num_generations) 
select a.id_ancestor, d.id_descendent, a.num_generations+d.num_generations+1 as num_generations 
from t_account_ancestor d cross join t_account_ancestor a 
where a.id_descendent = @id_parent and d.id_ancestor = @id_root

GO

-- This stored procedure creates account hierarchy information for an account.
-- It assumes that both the account and its parent are already added to t_account
create procedure mtsp_add_account @id_acc integer, @id_parent integer
as
insert into t_account_ancestor(id_ancestor, id_descendent, num_generations) values (@id_acc, @id_acc, 0)
insert into t_account_ancestor(id_ancestor, id_descendent, num_generations) 
select a.id_ancestor, d.id_descendent, a.num_generations+d.num_generations+1 as num_generations 
from t_account_ancestor d cross join t_account_ancestor a 
where a.id_descendent = @id_parent and d.id_ancestor = @id_acc

GO

create procedure mtsp_get_payer @id_acc integer, @id_billable integer output 
as
select @id_billable = aa2.id_ancestor
from
t_account_ancestor aa2 
where
aa2.num_generations =
(
select min(aa.num_generations) 
from
t_account_ancestor aa
inner join t_av_payer billable on billable.id_acc = aa.id_ancestor
where 
billable.b_billable = 'Y'
and
aa.id_descendant=aa2.id_descendant
group by
aa.id_descendant
)
and
   aa2.id_descendant = @id_acc


GO
commit transaction

--create table t_account_billable (id_acc integer, b_billable char(1));
insert into t_account_billable values (-1, 'Y')
--insert into t_account_billable values (62407, 'Y')

select aa2.id_ancestor, aa2.id_descendent, 1 as num_generations
from
t_account_ancestor aa2 
where
aa2.num_generations =
(
select min(aa.num_generations) 
from
t_account_ancestor aa
inner join t_account_billable billable on billable.id_acc = aa.id_ancestor
where 
billable.b_billable = 'Y'
and
aa.id_descendent=aa2.id_descendent
group by
aa.id_descendent
)
and
aa2.id_descendent = 62511

 