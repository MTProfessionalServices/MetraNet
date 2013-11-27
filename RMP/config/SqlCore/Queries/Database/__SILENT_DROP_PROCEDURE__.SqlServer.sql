
IF EXISTS (SELECT name FROM sysobjects 
      WHERE name = '%%PROC_NAME%%' AND type = 'P')
   DROP PROCEDURE %%PROC_NAME%%
