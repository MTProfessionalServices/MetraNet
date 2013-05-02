dim rs
SET rs = CreateObject("MTSQLRowset.MTSQLRowset")
rs.Init "Queries\\Adjustments"
rs.SetQueryTag "__GET_ADJUSTMENT_RECORDS_BY_PI__"
rs.AddParam "%%AJ_COLUMN%%", "sss", true
rs.AddParam "%%AJ_ID%%", 123, true
wscript.echo rs.GetQueryString

function dumprs(rowset)
	dim i,str,j,tempvar
	for i = 0 to rowset.recordcount -1
		str = ""
		for j = 0 to rowset.count -1
			tempvar = rowset.value(j)
				tempvar = rowset.value(j)
				if not IsObject(tempvar) then
					if not IsNull(tempvar) then
						str = str & CStr(rowset.value(j)) & " "
					end if
				end if
		next
		wscript.echo str
		rowset.MoveNext
	next
end function