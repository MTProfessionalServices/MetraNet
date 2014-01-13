
/* ===========================================================
Create a temporary table to hold the accounts which will be used by
billing rerun to backout and resubmit the usage associated with those accounts.
===========================================================*/
CREATE TABLE %%TABLENAME%%
(
   id_acc INT NOT NULL         
   PRIMARY KEY (id_acc)
)
      