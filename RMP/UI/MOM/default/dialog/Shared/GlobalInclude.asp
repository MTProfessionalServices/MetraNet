<%
'---------------------------------------------------------------------------------------'
' Constants                                                                             '
'---------------------------------------------------------------------------------------'

'Used for all edit tables
Const  g_str_OPEN_TABLE_TAG_PARAMS =  "border=""0"" cellspacing=""1"" cellpadding=""1"" bgcolor=""#999999"""



'---------------------------------------------------------------------------------------'
' Function GetValidSessionObject(strObject, strProgID) As Object                        '
'                                                                                       '
' Description: Get a valid session object if it exists.  If it doesn't, create it.      '
'                                                                                       '
' Inputs:      strObject -- name of the session variable to use.                        '
'              strProgID -- prog ID to use if the object needs to be created.           '
'                                                                                       '                                                                               '
' Outputs:     The object                                                               '
'---------------------------------------------------------------------------------------'
Function GetValidSessionObject(strObject, strProgID)
  Dim objObject
    
  'See if a valid object already exists.  If so, return it.
  if isobject(session(strObject)) then
    if not session(strObject) is nothing then
      Set GetValidSessionObject = session(strObject)
      exit function
    end if
  end if

  'If the valid object doesn't exist, create it and return it.
  Set objObject = CreateObject(strProgID)
   
  if not objObject is nothing then
    Set session(strObject) = objObject
  end if

  Set GetValidSessionObject = session(strObject)

 End Function
 '--------------------------------------------------------------------------------------'
' Function ArrayCat(arrOne, arrTwo) As array                                            '
'                                                                                       '
' Description: Concatenate to arrays.  arrTwo is added to the end of arrOne             '
'                                                                                       '
' Inputs:      arrOne -- first array                                                    '
'              arrTwo -- second array                                                   '
'                                                                                       '                                                                               '
' Outputs:     The resulting array.                                                     '
'---------------------------------------------------------------------------------------'
Function ArrayCat(arrOne, arrTwo)
  Dim arrOut()
  Dim intBound
  Dim i
  
  'Is array one initialized?
  if not isempty(arrOne) then
    redim preserve arrOut(UBound(arrOne))
    
    'Copy the values to the concatenation array
    for i = 0 to UBound(arrOut)
      arrOut(i) = arrOne(i)
    next

  end if
  
  'Is array two intialized
  if not isempty(arrTwo) then
    
    'if arrOUt is empty, that means array one was empty
    'the concatenation will just be array two
    if not isempty(arrOut) then
      intBound = i
      redim preserve arrOut(intBound + UBound(arrTwo))
    else
      ArrayCat = arrTwo
      exit function
    end if
    
    'Copy the values into the concatenation array
    for i = 0 to UBound(arrTwo)
      arrOut(i + intBound) = arrTwo(i)
    next
  end if
  
  
  ArrayCat = arrOut

End Function


%>