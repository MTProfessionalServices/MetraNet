
			 SELECT ('drop table ' + name) statement from sysobjects where
			 name like 't_%' and type ='U'
			 