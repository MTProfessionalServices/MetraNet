<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2002 by MetraTech Corporation
'  All rights reserved.
' 
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' 
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
'
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' NAME          : CBatchError.Asp - MetratTech Batch Error Resolution Class
' VERSION       : 1.0
' CREATION_DATE : 05/05/2002
' AUTHOR        : Kevin A. Boucher
' DESCRIPTION   :
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Class CErrorNode
  Dim id_acc
  Dim accountname
  Dim description
End Class

Dim BatchError
Set BatchError = New CBatchError   ' Allocate the BatchError instance
    
CLASS CBatchError ' -- The BatchError Class --

      Private m_colErrorNodes
      
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : GetBatchErrorRS
	    ' PARAMETERS  : 
	    ' DESCRIPTION : Returns the BatchErrorRS
	    ' RETURNS     :      
      PUBLIC FUNCTION GetBatchErrorRS()
        Const adVarChar = 200
        Dim rs, node
        Set rs = server.CreateObject(MTSQLRowset) 

        rs.InitDisconnected
        rs.AddColumnDefinition "id_acc", "int32", 4
        rs.AddColumnDefinitionByType "accountname", adVarChar, 256
        rs.AddColumnDefinitionByType "description", adVarChar, 256
        rs.OpenDisconnected

        for each node in m_colErrorNodes
          rs.AddRow
          rs.AddColumnData "id_acc", node.id_acc  
          rs.AddColumnData "accountname", node.accountname 
          rs.AddColumnData "description", node.description 
          rs.MoveNext
        next

        if m_colErrorNodes.Count > 0 then
          rs.MoveFirst
        end if
          
        Set GetBatchErrorRS = rs        
        
      END FUNCTION
        
      ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Add
	    ' PARAMETERS  : account id, error description
	    ' DESCRIPTION : 
	    ' RETURNS     :
	    PUBLIC FUNCTION Add(lngAccountID, strAccountName, strErrorDescription) ' As Boolean
        Dim newError
        Set newError = New CErrorNode
        
        newError.id_acc = lngAccountID
        newError.accountname = strAccountName
        newError.description  = strErrorDescription
        
        Call m_colErrorNodes.add(newError)
        
        err.clear
        
	      Add = TRUE
	    END FUNCTION         
        
            
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Default Initialize
	    ' PARAMETERS  :
	    ' DESCRIPTION :
	    ' RETURNS     :
	    PRIVATE SUB Class_Initialize() ' As Boolean
        set m_colErrorNodes = Server.CreateObject(MT_COLLECTION_PROG_ID)

	    END SUB
      
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    :
	    ' PARAMETERS  :
	    ' DESCRIPTION :
	    ' RETURNS     :
	    PRIVATE SUB Class_Terminate() ' As Boolean
        set m_colErrorNodes = Nothing
	    END SUB		  
	
END CLASS    	

  
%>