
			 SELECT ('alter table ' + b.name + ' drop constraint ' + f.name) statement
			 from sysconstraints a, sysobjects b, sysobjects f where a.id = b.id
			 and a.constid = f.id and f.type in ('F','K') order by f.type desc
			 