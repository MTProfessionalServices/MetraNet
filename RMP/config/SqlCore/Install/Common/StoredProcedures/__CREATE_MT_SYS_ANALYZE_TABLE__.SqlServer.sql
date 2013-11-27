
        -- =============================================
-- Author:		<Author,,Name>: tmistry
-- Create date: <Create Date,,>: 9/20/2010
-- Description:	<Description,,>: For ESR-3553 & ESR-3707
-- =============================================

CREATE  PROCEDURE mt_sys_analyze_table
(
  @p_table_name VARCHAR(128),
  @p_sampling_ratio   int,
  @p_status int output
)
AS
  
BEGIN
  
   declare @SQLStmt as nvarchar(4000)
   declare @SQLStmtError int
   declare @p_ratio  int
   declare @p_default_ratio int
   set  @p_default_ratio = 20 
   set @p_status=0
   
	IF @p_sampling_ratio > 0  
	begin
	set @p_ratio = @p_sampling_ratio
    end
    
    Else 
    
    begin
    set @p_ratio =  @p_default_ratio
    end        
 
 
 BEGIN
   SET @SQLStmt = 'UPDATE STATISTICS '+  cast(@p_table_name as varchar(128)) + ' '+ 'with sample ' + cast(@p_ratio as varchar(30)) +' ' + 'Percent' 
    EXECUTE (@SQLStmt)
 END

  SELECT @SQLStmtError = @@ERROR
  IF @SQLStmtError <> 0
       BEGIN				
			set @p_status = -1
       END		
END
     
    