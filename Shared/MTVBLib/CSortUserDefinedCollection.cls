VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CSortUserDefinedCollection"
Attribute VB_GlobalNameSpace = True
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' selection sort for collection based on property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub sortUserDefinedCollection(col As Collection, prop As String)
   Dim i, j, temp As Variant, temp2 As Variant
   Dim placeHolder As String
   
   For i = 1 To col.Count
      For j = i + 1 To col.Count 'Look at all elements after a(i)
         If CallByName(col.Item(j), prop, VbGet) < CallByName(col.Item(i), prop, VbGet) Then
            'If we found something smaller, exchange the values
            
            ' save the items we want to swap
            Set temp = col.Item(j)
            Set temp2 = col.Item(i)
    
            ' Setup place holders so we can swap ID's without having duplicates
            col.Remove i
            col.Add placeHolder, "TEMP_PLACE_HOLDER_1", i
             
            col.Remove j
            If j > col.Count Then
              col.Add placeHolder, "TEMP_PLACE_HOLDER_2", , j - 1
            Else
              col.Add placeHolder, "TEMP_PLACE_HOLDER_2", j
            End If
            
            ' do the swap and remove the place holders
            col.Remove i
            col.Add temp, temp.id, i
            
            col.Remove j
            If j > col.Count Then
              col.Add temp2, temp2.id, , j - 1
            Else
              col.Add temp2, temp2.id, j
            End If
            
         End If
      Next j
   Next i
End Sub

