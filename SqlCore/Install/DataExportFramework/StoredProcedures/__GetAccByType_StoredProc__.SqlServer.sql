IF OBJECT_ID('GetAccByType') IS NOT NULL 
DROP PROCEDURE GetAccByType
GO

CREATE PROCEDURE GetAccByType				        
	@acc_type NVARCHAR(100)
AS			
BEGIN
SELECT map.NM_LOGIN as Loggin, 
       map.NM_SPACE as Mn_Space, 
       tp.name as Acc_Type 
FROM T_ACCOUNT_MAPPER map 
INNER JOIN T_ACCOUNT acc 
ON acc.id_acc= map.id_acc 
INNER JOIN T_ACCOUNT_TYPE tp 
ON acc.id_type= tp.id_type 
WHERE tp.name = @acc_type
END

GO