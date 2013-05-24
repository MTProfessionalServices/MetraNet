Attribute VB_Name = "modClassIDGenerator"
Attribute VB_Ext_KEY = "RVB_UniqueId" ,"39AD60E4004B"
'##ModelId=39AD60E400B7
Function GetNextClassDebugID() As Long
    'class ID generator
    Static lClassDebugID As Long
    lClassDebugID = lClassDebugID + 1
    GetNextClassDebugID = lClassDebugID
End Function

