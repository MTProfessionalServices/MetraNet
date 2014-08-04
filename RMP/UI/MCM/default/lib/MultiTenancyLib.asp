<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : SaveTenantIdForPriceList                                        '
' Description : Workaround to populate t_ep_pricelist with TenantId             '
' Inputs      :                                                                 '
' Outputs     :                                                                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function SaveTenantIdForPriceList(pricelistId, tenantId)
    Dim objSqlRowset
    Set objSqlRowset = Server.CreateObject("MTSQLRowset.MTSQLRowset.1")

    Call objSqlRowset.Init("..\Extensions\Partitions\config\queries")
    ' Call objSqlRowset.SetQueryTag("____")

    Call objSqlRowset.InitializeForStoredProc("ExtendedUpsert")
    Call objSqlRowset.AddInputParameterToStoredProc("table_name",  MTTYPE_VARCHAR, INPUT_PARAM, "t_ep_pricelist")
    Call objSqlRowset.AddInputParameterToStoredProc("update_list", MTTYPE_VARCHAR, INPUT_PARAM, "t_ep_pricelist.c_TenantId = " & tenantId)
    Call objSqlRowset.AddInputParameterToStoredProc("insert_list", MTTYPE_VARCHAR, INPUT_PARAM, CStr(tenantId))
    Call objSqlRowset.AddInputParameterToStoredProc("clist",       MTTYPE_VARCHAR, INPUT_PARAM, "c_TenantId")
    Call objSqlRowset.AddInputParameterToStoredProc("id_prop",     MTTYPE_INTEGER, INPUT_PARAM, pricelistId)
    Call objSqlRowset.AddOutputParameterToStoredProc("status",     MTTYPE_INTEGER, OUTPUT_PARAM)
    Call objSqlRowset.ExecuteStoredProc()

    Dim status ' As Long
    status = objSqlRowset.GetParameterFromStoredProc("status")
    Set objSqlRowset = nothing

    If status = 0 Then
        SaveTenantIdForPriceList = True
    Else
        SaveTenantIdForPriceList = False
    End If
End Function


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