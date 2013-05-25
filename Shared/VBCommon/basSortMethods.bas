Attribute VB_Name = "basSortMethods"

'----------------------------------------------------------------------------
' Copyright 1998, 1999, 2000 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'
' $Workfile$
' $Date$
' $Author$
' $Revision$
'
'
'----------------------------------------------------------------------------


'----------------------------------------------------------------------------
'*****
'***** DESCRIPTION: This class provides basic sorting sorting routines for
'                   variable data types.  BubbleSort, SelectSort and QuickSort
'                   are currently supported.
'*****
'***** ASSUMPTIONS:
'*****
'***** CALLS (REQUIRES): Propset
'*****
'----------------------------------------------------------------------------
Option Explicit



'----------------------------------------------------------------------------
' CONSTANTS
'----------------------------------------------------------------------------
'none


'----------------------------------------------------------------------------
' VARIABLES
'----------------------------------------------------------------------------
'none


'----------------------------------------------------------------------------
' METHODS
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: BubbleSortString
'   Description:  Standard BubbleSort algorithm.  NOT GENERALLY RECOMENDED
'               BECAUSE IT IS VERY SLOW.  Provided here for completeness.
'               BubbleSort - go through the list.  Take an element and compare
'                           it to the adjacent one.  If it is less, then "bubble"
'                           it up to the top and continue.
'   Parameters: oArray - The array to sort
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub BubbleSortString(ByRef oArray() As String, Optional ByVal icbolIgnoreCase As Boolean = True)

    Dim lngLoopCount1   As Long
    Dim lngLoopCount2   As Long
    Dim lngLowerBound   As Long
    
    
    lngLowerBound = LBound(oArray)
    
    '-------------------------------------------------------
    ' Loop through the array, starting at the bottom and
    ' Working up through the list
    '-------------------------------------------------------
    For lngLoopCount1 = UBound(oArray) To lngLowerBound Step -1
      
        
        '-------------------------------------------------------
        ' Now loop through the remaining elements and "bubble" the
        ' bigger elements up through the list
        '-------------------------------------------------------
        For lngLoopCount2 = lngLowerBound + 1 To lngLoopCount1
        
            
            '-------------------------------------------------------
            ' If the elements need to be switched, switch them
            '-------------------------------------------------------
            If icbolIgnoreCase Then
                If UCase$(oArray(lngLoopCount2 - 1)) > UCase$(oArray(lngLoopCount2)) Then
                    Call SwapElements(oArray, lngLoopCount2 - 1, lngLoopCount2)
                End If
            Else
                If oArray(lngLoopCount2 - 1) > oArray(lngLoopCount2) Then
                    Call SwapElements(oArray, lngLoopCount2 - 1, lngLoopCount2)
                End If
            End If
            
                      
        Next ' end inner loop
        
    Next ' end outer loop
  
End Sub




'----------------------------------------------------------------------------
'   Name: BubbleSortLong
'   Description:  Standard BubbleSort algorithm.  NOT GENERALLY RECOMENDED
'               BECAUSE IT IS VERY SLOW.  Provided here for completeness.
'               BubbleSort - go through the list.  Take an element and compare
'                           it to the adjacent one.  If it is less, then "bubble"
'                           it up to the top and continue.
'   Parameters: oArray - The array to sort
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub BubbleSortLong(ByRef oArray() As Long)

    Dim lngLoopCount1   As Long
    Dim lngLoopCount2   As Long
    Dim lngLowerBound   As Long
    
    
    lngLowerBound = LBound(oArray)
    
    '-------------------------------------------------------
    ' Loop through the array, starting at the bottom and
    ' Working up through the list
    '-------------------------------------------------------
    For lngLoopCount1 = UBound(oArray) To lngLowerBound Step -1
      
        
        '-------------------------------------------------------
        ' Now loop through the remaining elements and "bubble" the
        ' bigger elements up through the list
        '-------------------------------------------------------
        For lngLoopCount2 = lngLowerBound + 1 To lngLoopCount1
        
            
            '-------------------------------------------------------
            ' If the elements need to be switched, switch them
            '-------------------------------------------------------
            If oArray(lngLoopCount2 - 1) > oArray(lngLoopCount2) Then
                Call SwapElements(oArray, lngLoopCount2 - 1, lngLoopCount2)
            End If
                      
        Next ' end inner loop
        
    Next ' end outer loop
  
End Sub


'----------------------------------------------------------------------------
'   Name: BubbleSortDouble
'   Description:  Standard BubbleSort algorithm.  NOT GENERALLY RECOMENDED
'               BECAUSE IT IS VERY SLOW.  Provided here for completeness.
'               BubbleSort - go through the list.  Take an element and compare
'                           it to the adjacent one.  If it is less, then "bubble"
'                           it up to the top and continue.
'   Parameters: oArray - The array to sort
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub BubbleSortDouble(ByRef oArray() As Double)

    Dim lngLoopCount1   As Long
    Dim lngLoopCount2   As Long
    Dim lngLowerBound   As Long
    
    lngLowerBound = LBound(oArray)
    
    '-------------------------------------------------------
    ' Loop through the array, starting at the bottom and
    ' Working up through the list
    '-------------------------------------------------------
    For lngLoopCount1 = UBound(oArray) To lngLowerBound Step -1
      
        
        '-------------------------------------------------------
        ' Now loop through the remaining elements and "bubble" the
        ' bigger elements up through the list
        '-------------------------------------------------------
        For lngLoopCount2 = lngLowerBound + 1 To lngLoopCount1
        
            
            '-------------------------------------------------------
            ' If the elements need to be switched, switch them
            '-------------------------------------------------------
            If oArray(lngLoopCount2 - 1) > oArray(lngLoopCount2) Then
                Call SwapElements(oArray, lngLoopCount2 - 1, lngLoopCount2)
            End If
                      
        Next ' end inner loop
        
    Next ' end outer loop
  
End Sub



'----------------------------------------------------------------------------
'   Name: BubbleSortVariant
'   Description:  Standard BubbleSort algorithm.  NOT GENERALLY RECOMENDED
'               BECAUSE IT IS VERY SLOW.  Provided here for completeness.
'               BubbleSort - go through the list.  Take an element and compare
'                           it to the adjacent one.  If it is less, then "bubble"
'                           it up to the top and continue.
'   Parameters: oArray - The array to sort
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub BubbleSortVariant(ByRef oArray As Variant)

    Dim lngLoopCount1   As Long
    Dim lngLoopCount2   As Long
    Dim lngLowerBound   As Long
    
    lngLowerBound = LBound(oArray)
    
    '-------------------------------------------------------
    ' Loop through the array, starting at the bottom and
    ' Working up through the list
    '-------------------------------------------------------
    For lngLoopCount1 = UBound(oArray) To lngLowerBound Step -1
      
        
        '-------------------------------------------------------
        ' Now loop through the remaining elements and "bubble" the
        ' bigger elements up through the list
        '-------------------------------------------------------
        For lngLoopCount2 = lngLowerBound + 1 To lngLoopCount1
        
            
            '-------------------------------------------------------
            ' If the elements need to be switched, switch them
            '-------------------------------------------------------
            If oArray(lngLoopCount2 - 1) > oArray(lngLoopCount2) Then
                Call SwapElements(oArray, lngLoopCount2 - 1, lngLoopCount2)
            End If
                      
        Next ' end inner loop
        
    Next ' end outer loop
  
End Sub



'----------------------------------------------------------------------------
'   Name: SelectionSortString
'   Description:  Standard SelectSort algorithm.  NOT GENERALLY RECOMENDED
'               BECAUSE IT IS VERY SLOW.  Provided here for completeness.
'               Select - go through the list finding the largest element and
'                       placing it at the end.  Then the next largest element, etc..
'   Parameters: oArray - The array to sort
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub SelectSortString(ByRef oArray() As String, Optional ByVal icbolIgnoreCase As Boolean = True)
  
    Dim lngLoopCount1   As Long
    Dim lngLoopCount2   As Long
    
    Dim lngUpperBound   As Long
    Dim lngMinIndex     As Long
                        
    
    lngUpperBound = UBound(oArray)
    
    
    '-------------------------------------------------------
    ' Loop through the list.  Start at the bottom and loop
    ' through to find the lowest element in the list.  Once
    ' the lowest element is found, swap it into the first place.
    ' Then move the second place and find the second lowest
    ' element, etc....
    '-------------------------------------------------------
    For lngLoopCount1 = LBound(oArray) To lngUpperBound - 1
    
        lngMinIndex = lngLoopCount1
        
        For lngLoopCount2 = lngLoopCount1 + 1 To lngUpperBound
            
            If icbolIgnoreCase Then
                If UCase$(oArray(lngLoopCount2)) < UCase$(oArray(lngMinIndex)) Then
                    lngMinIndex = lngLoopCount2
                End If
            Else
                If oArray(lngLoopCount2) < oArray(lngMinIndex) Then
                    lngMinIndex = lngLoopCount2
                End If
            End If ' end test on case sensitivity
         
        Next ' end inner loop
        
        Call SwapElements(oArray, lngLoopCount1, lngMinIndex)
      
    Next ' end outer loop
  
End Sub


'----------------------------------------------------------------------------
'   Name: SelectSortLong
'   Description:  Standard SelectSort algorithm.  NOT GENERALLY RECOMENDED
'               BECAUSE IT IS VERY SLOW.  Provided here for completeness.
'               Select - go through the list finding the largest element and
'                       placing it at the end.  Then the next largest element, etc..
'   Parameters: oArray - The array to sort
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub SelectSortLong(ByRef oArray() As Long)
  
    Dim lngLoopCount1   As Long
    Dim lngLoopCount2   As Long
    
    Dim lngUpperBound   As Long
    Dim lngMinIndex     As Long
                        
    
    lngUpperBound = UBound(oArray)
    
    
    '-------------------------------------------------------
    ' Loop through the list.  Start at the bottom and loop
    ' through to find the lowest element in the list.  Once
    ' the lowest element is found, swap it into the first place.
    ' Then move the second place and find the second lowest
    ' element, etc....
    '-------------------------------------------------------
    For lngLoopCount1 = LBound(oArray) To lngUpperBound - 1
    
        lngMinIndex = lngLoopCount1
        
        For lngLoopCount2 = lngLoopCount1 + 1 To lngUpperBound
            
            If oArray(lngLoopCount2) < oArray(lngMinIndex) Then
                lngMinIndex = lngLoopCount2
            End If
            
        Next ' end inner loop
        
        Call SwapElements(oArray, lngLoopCount1, lngMinIndex)
      
    Next ' end outer loop
  
End Sub


'----------------------------------------------------------------------------
'   Name: SelectSortDouble
'   Description:  Standard SelectSort algorithm.  NOT GENERALLY RECOMENDED
'               BECAUSE IT IS VERY SLOW.  Provided here for completeness.
'               Select - go through the list finding the largest element and
'                       placing it at the end.  Then the next largest element, etc..
'   Parameters: oArray - The array to sort
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub SelectSortDouble(ByRef oArray() As Double)
  
    Dim lngLoopCount1   As Long
    Dim lngLoopCount2   As Long
    
    Dim lngUpperBound   As Long
    Dim lngMinIndex     As Long
                        
    
    lngUpperBound = UBound(oArray)
    
    
    '-------------------------------------------------------
    ' Loop through the list.  Start at the bottom and loop
    ' through to find the lowest element in the list.  Once
    ' the lowest element is found, swap it into the first place.
    ' Then move the second place and find the second lowest
    ' element, etc....
    '-------------------------------------------------------
    For lngLoopCount1 = LBound(oArray) To lngUpperBound - 1
    
        lngMinIndex = lngLoopCount1
        
        For lngLoopCount2 = lngLoopCount1 + 1 To lngUpperBound
            
            If oArray(lngLoopCount2) < oArray(lngMinIndex) Then
                lngMinIndex = lngLoopCount2
            End If
            
        Next ' end inner loop
        
        Call SwapElements(oArray, lngLoopCount1, lngMinIndex)
      
    Next ' end outer loop
  
End Sub


'----------------------------------------------------------------------------
'   Name: SelectSortVariant
'   Description:  Standard SelectSort algorithm.  NOT GENERALLY RECOMENDED
'               BECAUSE IT IS VERY SLOW.  Provided here for completeness.
'               Select - go through the list finding the largest element and
'                       placing it at the end.  Then the next largest element, etc..
'   Parameters: oArray - The array to sort
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub SelectSortVariant(ByRef oArray As Variant)
  
    Dim lngLoopCount1   As Long
    Dim lngLoopCount2   As Long
    
    Dim lngUpperBound   As Long
    Dim lngMinIndex     As Long
                        
    
    lngUpperBound = UBound(oArray)
    
    
    '-------------------------------------------------------
    ' Loop through the list.  Start at the bottom and loop
    ' through to find the lowest element in the list.  Once
    ' the lowest element is found, swap it into the first place.
    ' Then move the second place and find the second lowest
    ' element, etc....
    '-------------------------------------------------------
    For lngLoopCount1 = LBound(oArray) To lngUpperBound - 1
    
        lngMinIndex = lngLoopCount1
        
        For lngLoopCount2 = lngLoopCount1 + 1 To lngUpperBound
            
            If oArray(lngLoopCount2) < oArray(lngMinIndex) Then
                lngMinIndex = lngLoopCount2
            End If
            
        Next ' end inner loop
        
        Call SwapElements(oArray, lngLoopCount1, lngMinIndex)
      
    Next ' end outer loop
  
End Sub



'----------------------------------------------------------------------------
'   Name: QuicksortString
'   Description:  Calls the internal QuickSort method.  This just hides the
'                   first and last params from the calling user
'   Parameters: oArray - The array to sort
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub QuickSortString(ByRef oArray() As String, Optional ByVal icbolIgnoreCase As Boolean = True)
    Call QuickSortStringInternal(oArray, LBound(oArray), UBound(oArray), icbolIgnoreCase)
End Sub


'----------------------------------------------------------------------------
'   Name: QuickSortLong
'   Description:  Calls the internal QuickSort method.  This just hides the
'                   first and last params from the calling user
'   Parameters: oArray - The array to sort
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub QuickSortLong(ByRef oArray() As Long)
    Call QuickSortLongInternal(oArray, LBound(oArray), UBound(oArray))
End Sub


'----------------------------------------------------------------------------
'   Name: QuickSortDouble
'   Description:  Calls the internal QuickSort method.  This just hides the
'                   first and last params from the calling user
'   Parameters: oArray - The array to sort
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub QuickSortDouble(ByRef oArray() As Double)
    Call QuickSortDoubleInternal(oArray, LBound(oArray), UBound(oArray))
End Sub


'----------------------------------------------------------------------------
'   Name: QuickSortVariant
'   Description:  Calls the internal QuickSort method.  This just hides the
'                   first and last params from the calling user
'   Parameters: oArray - The array to sort
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub QuickSortVariant(ByRef oArray As Variant)
    Call QuickSortVariantInternal(oArray, LBound(oArray), UBound(oArray))
End Sub




'----------------------------------------------------------------------------
'   Name: QuicksortString
'   Description:  Standard QuickSort algorithm.  RECOMENDED - VERY FAST.
'               QuickSort - recursive algorithm whose performance hinges on
'                           the partition algorithm.  Basically, find a partition
'                           element (ideally, the element where exactly half the
'                           list is greater than, half less than).  Determining the
'                           best possible partition would slow the algorithm, so you
'                           compromise and just pick the middle element - and hope
'                           for the best.  This usually works well.  Then, split
'                           the list around the partition and call quicksort on the
'                           the two halves.
'   Parameters: oArray - The array to sort
'               iclngFirst - the first element to work with in the list
'               iclngLast - the last element to work with in the list
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub QuickSortStringInternal(ByRef oArray() As String, ByVal iclngFirst As Long, ByVal iclngLast As Long, Optional ByVal icbolIgnoreCase As Boolean = True)

    Dim lngLoopCount1   As Long
    Dim lngLoopCount2   As Long
    
    Dim varPartitionElem    As String ' This variable type will change depending on
                                        ' the sort (string, long, etc...)
    
    
    
    lngLoopCount1 = iclngFirst
    lngLoopCount2 = iclngLast
    
    '-------------------------------------------------------
    ' Get the partition element
    '-------------------------------------------------------
    varPartitionElem = oArray((iclngFirst + iclngLast) / 2)
    If icbolIgnoreCase Then
        varPartitionElem = UCase$(varPartitionElem)
    End If


    '-------------------------------------------------------
    ' Maintain two counters.  One counter starts on the left,
    ' one on the right.  The increment and decrement until they
    ' find elements that are on the wrong side of the partition.
    ' Once they both find elements on the wrong side, swap the
    ' elements and keep going.  Goo until they cross sides.
    ' At this point, everything to the left of the partition is
    ' less than the partition, everything to the right is greater
    ' than - but neither side is sorted.  Now call sorts on both
    ' sides of the partition
    '-------------------------------------------------------
    While (lngLoopCount1 <= lngLoopCount2)
        
        '-------------------------------------------------------
        ' Find the first element that is on the wrong side of the
        ' partition - make a note of it
        '-------------------------------------------------------
        If icbolIgnoreCase Then
            While (UCase$(oArray(lngLoopCount1)) < varPartitionElem) And (lngLoopCount1 < iclngLast)
                lngLoopCount1 = lngLoopCount1 + 1
            Wend
        Else
            While (oArray(lngLoopCount1) < varPartitionElem) And (lngLoopCount1 < iclngLast)
                lngLoopCount1 = lngLoopCount1 + 1
            Wend
        End If

        '-------------------------------------------------------
        ' Find the first element that is on the wrong side of the
        ' partition - make a note of it
        '-------------------------------------------------------
        If icbolIgnoreCase Then
            While (varPartitionElem < UCase$(oArray(lngLoopCount2))) And (lngLoopCount2 > iclngFirst)
                lngLoopCount2 = lngLoopCount2 - 1
            Wend
        Else
            While (varPartitionElem < oArray(lngLoopCount2)) And (lngLoopCount2 > iclngFirst)
                lngLoopCount2 = lngLoopCount2 - 1
            Wend
        End If

        
        '-------------------------------------------------------
        ' Swap the elements that are on the wrong side
        '-------------------------------------------------------
        If (lngLoopCount1 <= lngLoopCount2) Then
            Call SwapElements(oArray, lngLoopCount1, lngLoopCount2)
            
            lngLoopCount1 = lngLoopCount1 + 1
            lngLoopCount2 = lngLoopCount2 - 1
        End If

    Wend

    If (iclngFirst < lngLoopCount2) Then
        Call QuickSortStringInternal(oArray, iclngFirst, lngLoopCount2, icbolIgnoreCase)
    End If
    
    If (lngLoopCount1 < iclngLast) Then
        Call QuickSortStringInternal(oArray, lngLoopCount1, iclngLast, icbolIgnoreCase)
    End If

End Sub



'----------------------------------------------------------------------------
'   Name: QuicksortLong
'   Description:  Standard QuickSort algorithm.  RECOMENDED - VERY FAST.
'               QuickSort - recursive algorithm whose performance hinges on
'                           the partition algorithm.  Basically, find a partition
'                           element (ideally, the element where exactly half the
'                           list is greater than, half less than).  Determining the
'                           best possible partition would slow the algorithm, so you
'                           compromise and just pick the middle element - and hope
'                           for the best.  This usually works well.  Then, split
'                           the list around the partition and call quicksort on the
'                           the two halves.
'   Parameters: oArray - The array to sort
'               iclngFirst - the first element to work with in the list
'               iclngLast - the last element to work with in the list
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub QuickSortLongInternal(ByRef oArray() As Long, ByVal iclngFirst As Long, ByVal iclngLast As Long)

    Dim lngLoopCount1   As Long
    Dim lngLoopCount2   As Long
    
    Dim varPartitionElem    As Long ' This variable type will change depending on
                                        ' the sort (string, long, etc...)
    
    
    
    lngLoopCount1 = iclngFirst
    lngLoopCount2 = iclngLast
    
    '-------------------------------------------------------
    ' Get the partition element
    '-------------------------------------------------------
    varPartitionElem = oArray((iclngFirst + iclngLast) / 2)


    '-------------------------------------------------------
    ' Maintain two counters.  One counter starts on the left,
    ' one on the right.  The increment and decrement until they
    ' find elements that are on the wrong side of the partition.
    ' Once they both find elements on the wrong side, swap the
    ' elements and keep going.  Goo until they cross sides.
    ' At this point, everything to the left of the partition is
    ' less than the partition, everything to the right is greater
    ' than - but neither side is sorted.  Now call sorts on both
    ' sides of the partition
    '-------------------------------------------------------
    While (lngLoopCount1 <= lngLoopCount2)
        
        '-------------------------------------------------------
        ' Find the first element that is on the wrong side of the
        ' partition - make a note of it
        '-------------------------------------------------------
        While (oArray(lngLoopCount1) < varPartitionElem) And (lngLoopCount1 < iclngLast)
            lngLoopCount1 = lngLoopCount1 + 1
        Wend

        '-------------------------------------------------------
        ' Find the first element that is on the wrong side of the
        ' partition - make a note of it
        '-------------------------------------------------------
        While (varPartitionElem < oArray(lngLoopCount2)) And (lngLoopCount2 > iclngFirst)
            lngLoopCount2 = lngLoopCount2 - 1
        Wend

        
        '-------------------------------------------------------
        ' Swap the elements that are on the wrong side
        '-------------------------------------------------------
        If (lngLoopCount1 <= lngLoopCount2) Then
            Call SwapElements(oArray, lngLoopCount1, lngLoopCount2)
            
            lngLoopCount1 = lngLoopCount1 + 1
            lngLoopCount2 = lngLoopCount2 - 1
        End If

    Wend

    If (iclngFirst < lngLoopCount2) Then
        Call QuickSortLongInternal(oArray, iclngFirst, lngLoopCount2)
    End If
    
    If (lngLoopCount1 < iclngLast) Then
        Call QuickSortLongInternal(oArray, lngLoopCount1, iclngLast)
    End If

End Sub




'----------------------------------------------------------------------------
'   Name: QuicksortDouble
'   Description:  Standard QuickSort algorithm.  RECOMENDED - VERY FAST.
'               QuickSort - recursive algorithm whose performance hinges on
'                           the partition algorithm.  Basically, find a partition
'                           element (ideally, the element where exactly half the
'                           list is greater than, half less than).  Determining the
'                           best possible partition would slow the algorithm, so you
'                           compromise and just pick the middle element - and hope
'                           for the best.  This usually works well.  Then, split
'                           the list around the partition and call quicksort on the
'                           the two halves.
'   Parameters: oArray - The array to sort
'               iclngFirst - the first element to work with in the list
'               iclngLast - the last element to work with in the list
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub QuickSortDoubleInternal(ByRef oArray() As Double, ByVal iclngFirst As Long, ByVal iclngLast As Long)

    Dim lngLoopCount1   As Long
    Dim lngLoopCount2   As Long
    
    Dim varPartitionElem    As Double ' This variable type will change depending on
                                        ' the sort (string, long, etc...)
    
    
    
    lngLoopCount1 = iclngFirst
    lngLoopCount2 = iclngLast
    
    '-------------------------------------------------------
    ' Get the partition element
    '-------------------------------------------------------
    varPartitionElem = oArray((iclngFirst + iclngLast) / 2)


    '-------------------------------------------------------
    ' Maintain two counters.  One counter starts on the left,
    ' one on the right.  The increment and decrement until they
    ' find elements that are on the wrong side of the partition.
    ' Once they both find elements on the wrong side, swap the
    ' elements and keep going.  Goo until they cross sides.
    ' At this point, everything to the left of the partition is
    ' less than the partition, everything to the right is greater
    ' than - but neither side is sorted.  Now call sorts on both
    ' sides of the partition
    '-------------------------------------------------------
    While (lngLoopCount1 <= lngLoopCount2)
        
        '-------------------------------------------------------
        ' Find the first element that is on the wrong side of the
        ' partition - make a note of it
        '-------------------------------------------------------
        While (oArray(lngLoopCount1) < varPartitionElem) And (lngLoopCount1 < iclngLast)
            lngLoopCount1 = lngLoopCount1 + 1
        Wend

        '-------------------------------------------------------
        ' Find the first element that is on the wrong side of the
        ' partition - make a note of it
        '-------------------------------------------------------
        While (varPartitionElem < oArray(lngLoopCount2)) And (lngLoopCount2 > iclngFirst)
            lngLoopCount2 = lngLoopCount2 - 1
        Wend

        
        '-------------------------------------------------------
        ' Swap the elements that are on the wrong side
        '-------------------------------------------------------
        If (lngLoopCount1 <= lngLoopCount2) Then
            Call SwapElements(oArray, lngLoopCount1, lngLoopCount2)
            
            lngLoopCount1 = lngLoopCount1 + 1
            lngLoopCount2 = lngLoopCount2 - 1
        End If

    Wend

    If (iclngFirst < lngLoopCount2) Then
        Call QuickSortDoubleInternal(oArray, iclngFirst, lngLoopCount2)
    End If
    
    If (lngLoopCount1 < iclngLast) Then
        Call QuickSortDoubleInternal(oArray, lngLoopCount1, iclngLast)
    End If

End Sub


'----------------------------------------------------------------------------
'   Name: QuicksortVariant
'   Description:  Standard QuickSort algorithm.  RECOMENDED - VERY FAST.
'               QuickSort - recursive algorithm whose performance hinges on
'                           the partition algorithm.  Basically, find a partition
'                           element (ideally, the element where exactly half the
'                           list is greater than, half less than).  Determining the
'                           best possible partition would slow the algorithm, so you
'                           compromise and just pick the middle element - and hope
'                           for the best.  This usually works well.  Then, split
'                           the list around the partition and call quicksort on the
'                           the two halves.
'   Parameters: oArray - The array to sort
'               iclngFirst - the first element to work with in the list
'               iclngLast - the last element to work with in the list
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub QuickSortVariantInternal(ByRef oArray As Variant, ByVal iclngFirst As Long, ByVal iclngLast As Long)

    Dim lngLoopCount1   As Long
    Dim lngLoopCount2   As Long
    
    Dim varPartitionElem    As Variant ' This variable type will change depending on
                                        ' the sort (string, long, etc...)
    
    
    
    lngLoopCount1 = iclngFirst
    lngLoopCount2 = iclngLast
    
    '-------------------------------------------------------
    ' Get the partition element
    '-------------------------------------------------------
    varPartitionElem = oArray((iclngFirst + iclngLast) / 2)


    '-------------------------------------------------------
    ' Maintain two counters.  One counter starts on the left,
    ' one on the right.  The increment and decrement until they
    ' find elements that are on the wrong side of the partition.
    ' Once they both find elements on the wrong side, swap the
    ' elements and keep going.  Goo until they cross sides.
    ' At this point, everything to the left of the partition is
    ' less than the partition, everything to the right is greater
    ' than - but neither side is sorted.  Now call sorts on both
    ' sides of the partition
    '-------------------------------------------------------
    While (lngLoopCount1 <= lngLoopCount2)
        
        '-------------------------------------------------------
        ' Find the first element that is on the wrong side of the
        ' partition - make a note of it
        '-------------------------------------------------------
        While (oArray(lngLoopCount1) < varPartitionElem) And (lngLoopCount1 < iclngLast)
            lngLoopCount1 = lngLoopCount1 + 1
        Wend

        '-------------------------------------------------------
        ' Find the first element that is on the wrong side of the
        ' partition - make a note of it
        '-------------------------------------------------------
        While (varPartitionElem < oArray(lngLoopCount2)) And (lngLoopCount2 > iclngFirst)
            lngLoopCount2 = lngLoopCount2 - 1
        Wend

        
        '-------------------------------------------------------
        ' Swap the elements that are on the wrong side
        '-------------------------------------------------------
        If (lngLoopCount1 <= lngLoopCount2) Then
            Call SwapElements(oArray, lngLoopCount1, lngLoopCount2)
            
            lngLoopCount1 = lngLoopCount1 + 1
            lngLoopCount2 = lngLoopCount2 - 1
        End If

    Wend

    If (iclngFirst < lngLoopCount2) Then
        Call QuickSortVariantInternal(oArray, iclngFirst, lngLoopCount2)
    End If
    
    If (lngLoopCount1 < iclngLast) Then
        Call QuickSortVariantInternal(oArray, lngLoopCount1, iclngLast)
    End If

End Sub



'----------------------------------------------------------------------------
'   Name: SwapElements
'   Description:  Swaps to elements in an array.  Called by the various sorting
'                   functions
'   Parameters: oArray - The array to containing the items
'               iclngIndex1 - the first element to swap
'               iclngIndex2 - the second element to swap
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub SwapElements(ByRef oArray As Variant, ByVal iclngIndex1, ByVal iclngIndex2)
    Dim varTemp     As Variant
    
    varTemp = oArray(iclngIndex1)
    oArray(iclngIndex1) = oArray(iclngIndex2)
    oArray(iclngIndex2) = varTemp
End Sub
