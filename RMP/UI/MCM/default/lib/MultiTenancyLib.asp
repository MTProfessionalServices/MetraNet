<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : GetPriceListListOfValues                                        '
' Description : Workaround to populate list of pricelists available for mappings'
' Inputs      :                                                                 '
' Outputs     :                                                                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function GetPriceListListOfValues(curr, language)
    Dim objSqlRowset
    Set objSqlRowset = Server.CreateObject("MTSQLRowset.MTSQLRowset.1")

    Call objSqlRowset.Init("\Queries\ProductCatalog")
    Call objSqlRowset.SetQueryTag("__GET_PRICELISTS__")

    Call objSqlRowset.AddParam("%%RS_WHERE%%", "")
    Call objSqlRowset.AddParam("%%ID_LANG%%",  language)
    
    Dim filter
    filter = "n_type = 1"
    If curr <> "" Then
        filter = filter & vbNewLine & "  and nm_currency_code = '" & curr & "'"
    End If
    If Session("isPartitionUser") Then
        filter = filter & vbNewLine & "  and c_PLPartitionId = " & Session("topLevelAccountId")
    End If

    Call objSqlRowset.AddParam("%%FILTER%%", filter, True)
    
    Call objSqlRowset.Execute()
    
    Set GetPriceListListOfValues = objSqlRowset
End Function

%>