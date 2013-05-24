VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CByteSyntaxAnalyser"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
' ****************************************************************************************************************************************************
'
'  Written (W) by Frederic Torres 2001-2002
'  ARR.
'
'
'  CLASS        : CByteSyntaxAnalyser
'  AUTHOR       : Frederic Torres
'  DATE         : july/xx/99-09/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
' PRIVIOUS HISTORY
' ****************************************************************************************************************************************************
'
'                                       CByteSyntaxeAnalyser
'
'                                   TORRES Frederic xx/july/99
'
' Je redeveloppe la classe CLi.cls mais je n'utilise pas de string mais un byte array... Apres certain test fait en C++
' J'ai obtenu des meilleurs performance en C++ par rapport a VB! Apres reflexion l'idee mais vene que les chaines VB
' sont des chaines UNICODE ce qui ralenti VB compare au C++! Donc je re ecris le tout! de plus la class CLi est devenu un
' foutoire de premiere... Les performances avec un byte array sont comparable a class C++. # fois plus vites.
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' HISTORIQUE:
'
'  Fom Turbo pascal
'  From VbLib3 for Visual basic 3
'  From OoVbLib4 For Visual Basic 16b/32b
'
'
' ******************************************************************************************************
'
'                       Parseur d'expression Numerique et chaine
'
'                          (C) Frederic TORRES 1993,...
'
' xx Nov 91 - Melrose - Pour le compte de PDD j'ecris la premiere version PDDLA.
' Qui est juste l'hypertext je crois. Par la meme occasion j'ecris mon premier
' parseur d'expression numeric a partir de la description BNF du pascal.
' La classe s'appelle DIe_LI.pas. Donc fait partie de DOS INTERFACE.
' Et ca marche. En decembre a partir de cette evaluateur j'ecrirais le PDDLA.
'
' 19/10/93 - Aix en provence - Pey blanc.
' Porte d'une version PASCAL en Visual Basic. Voir l'unite DIe_LI.PAS de
' DOS INTERFACE le 19/10/93 en une heure (pas mal). Je n'ai pas encore
' tester la rapidite du parser en VB. Ca peut etre interressant car VB
' utilise assez bien le coprocesseur. De plus cette version n'a pas ete
' optimise et il y du boulot.
'
' L'objectif inavoue est d'ecrire encore un langage dont l'interpreteur
' est ecrit en VB, ce qui permettrait d'ecrire un PDDLA sous WINDOWS.
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' 05/10/98 - Sophia Antipolis.
'
' J'integre la classe cLi et les modules ParseN.bas et ParseS.bas dans la classe cLi.cls Pour VB5.
' Je n'ai jamais ecrit d'interpreteur en vb, bien que j'en eut realiser 2 en Turbo Pascal voir PDDLA
' et RunTime. L'objectif inavouve est d'ecrire un interpreteur d'un langage oriente objet...
' Une fois l'integration faite j'ajouterai a cette unite la gestion des variables, qui seront prise en
' compte par les parser...Je compte aussi faire une machine a pile,  qui n'utilisera cette
' classe pour ecrire l'interpreteur/compilateur...
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' xx/05/98 - Sophia Antipolis.
'
' J'ai bosse sur la machine a pile...Mais en fin de compte ca na pas donne un resultat interressant
' je ne sais meme plus pourquoi...Le source est dans l'arbre de OoVblib5
'
' 07/07/98 - Sophia Antipolis.
'
' Je modifie la class cCsv qui n'utilisait pas cLi. Cela ma parut meilleur!
' Je rajoute mode KillSpaceOnly qui fait que killSpace ne kill que les space et pas les 13,10,9, mode
' par defaut
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' 27/11/98 Boston - Que de chemin parcourue...Je remet un peu d'ordre dans la OoVblib6. Pour la passer
' en activeX Dll. Je vais peut etre le faire cet interpreteur vb...
'
' 01/12/98 Je le fais cette interpreteur...
' Remarque :  Tout les interpreteurs que j'ai developpe depuis le debut :
'               #1 - Melrose Turbo Pascal avec utilisation des pointeurs de function...(On devrait pouvoir utiliser la meme technique en vb6)
'               #2 - Le PDDLA...
'               #3 - Le RunTime...
'               #4 - Le fVb Engine...
'
' sont fondes sur plusieurs criteres :
'           1 - Analyse recursive descendante
'           2 - Utilisation de la pile du langage de developpement comme la pile de la machine!
'
' En fait je n'ai pas une vrai machine a pile! D'ailleurs je n'ai meme pas de pile! J'utilise celle de TP ou VB!
' En fait ce n'est pas une bonne idee! Il vaudrait mieux utiliser une pile a part! Car a cause de cela
' Je ne peux pas implementer les instructions Exit Sub, Function, Do, Loop...Car je ne peux sortir que d'un seul
' block a la fois! Je ne peux pas depiler ma pile a mon gre...En fait il serait tout a fait possible de garder
' la meme structure, d'ajouter un pile et de plus faire d'appel recursif mais un simple boucle dans la procedure
' RunBlock...
'
' Avec le PDDLA, J'y allais fort, on avais utilise setjump longjump pour faire quelque chose mais je ne me
' souviens plus koi!!! Cela pourrait resoudre le probleme du exit...
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
' Durant l'hiver 99 j'ai ecrit un compilateur/evaluatuer d'expression fondee sur les expression polack renversee...
' et a partir de la developpee une vrai stack machine enfin plus un sql interpreter juste le select tres simple...
' plus un vbscript non terminer...
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' Feb-1-2000, Durant Janvier 2000, je change de boite de LongViewGroup je passe a MetraTech. Enfin je crois.
' Je commence le 9 mars. MetraTech est a fond dans XML. Du coup j'ai ecrit un interpreter de SQL Select qui
' s'applique a un fichier XML! Le tout fonder sur mon premier interpreteur SQL en memoire.
' J'ai re-utiliser le compilateur polack et re-ecrit une stack machine. J'ai ajouter des instruction
' specific pour evaluer des hierarchie. Sa marche bien.
' Je l'appel XQL le nom existe deja pour une syntax bidon qui ne ressemble pas a SQL!
' Je sais pas si ca va me servir, mais ca marche plutot bien. Du coup je voudrai
' avoir des Commentaires /* */. En les integrant dans cette classe dans la function GetCChar() ca va etre tres
' facil a implemente!
' A+!
'
' ******************************************************************************************************

Option Explicit

Public Enum FUNCTION_RETURN_CODE
    rSUCCEED = 0
    rFAILED = -1
    rVBERROR = -2
    rTRUE = rSUCCEED
    rFALSE = rFAILED
End Enum

Private m_Bytes()           As Byte
Private m_string            As String
Private m_stack             As New CVariantStack
Private m_lngMaxBytesIndex  As Long
Private m_Length            As Long

Public lngBytesIndex        As Long
Public booKillSpaceOnly     As Boolean
Public booAcceptPointInId   As Boolean
Public booAccept2PointInId  As Boolean
Public booAcceptMinusInId   As Boolean
Public lngCurrentLine       As Long
Public lngIdSize            As Long
Public lngStringSize        As Long
Public strDateSeparator     As String

Const stringCote = """"



Public Function Init(strS As String) As FUNCTION_RETURN_CODE

    On Error GoTo errmgr
    
    Str2BytesArray strS
    
    m_string = strS
    lngBytesIndex = 0
    m_lngMaxBytesIndex = 0
    lngCurrentLine = 1
    Init = rSUCCEED
    Exit Function
errmgr:
    Init = rVBERROR
End Function


Public Function done() As FUNCTION_RETURN_CODE

    On Error GoTo errmgr
    
    Erase m_Bytes()
    done = rSUCCEED
    Exit Function
errmgr:
    done = rVBERROR
End Function

Public Function GetIdentifier(strID As String, Optional booUpCase As Boolean = True) As FUNCTION_RETURN_CODE

    On Error GoTo errmgr
    
    If (KillSpace() = rVBERROR) Then
    
        GetIdentifier = rVBERROR
        Exit Function
    End If
    
    ' Pre alloc the string so we do not lose time
    Dim strS        As String: strS = Space(lngIdSize)
    Dim strSIndex   As Long
    
    Do While ((IsCharID() = rTRUE) And (EOS() = rFALSE))
        Mid(strS, strSIndex + 1, 1) = Chr(m_Bytes(lngBytesIndex))
        NextChar
        strSIndex = strSIndex + 1
        If (EOS() = rTRUE) Then Exit Do
    Loop
    If (booUpCase) Then
        strID = UCase(Mid(strS, 1, strSIndex))
    Else
        strID = Mid(strS, 1, strSIndex)
    End If
    GetIdentifier = IIf(Len(strID), rSUCCEED, rFAILED)
    Exit Function
errmgr:
    GetIdentifier = rVBERROR
End Function

Public Function GetInteger(lngI As Long, Optional booAcceptMinusAndPlus As Boolean = True) As FUNCTION_RETURN_CODE
    On Error GoTo errmgr
    
    If (KillSpace() = rVBERROR) Then
    
        GetInteger = rVBERROR
        Exit Function
    End If
    
    ' Pre alloc the string so we do not lose time
    Dim strS        As String: strS = Space(lngIdSize)
    Dim strSIndex   As Long
    
    If (booAcceptMinusAndPlus) Then
        Do While (((IsCharInteger()) = rTRUE) And (EOS() = rFALSE))
            Mid(strS, strSIndex + 1, 1) = Chr(m_Bytes(lngBytesIndex))
            NextChar
            strSIndex = strSIndex + 1
        Loop
    Else
    
        Do While (((IsCharNumeric()) = rTRUE) And (EOS() = rFALSE))
            Mid(strS, strSIndex + 1, 1) = Chr(m_Bytes(lngBytesIndex))
            NextChar
            strSIndex = strSIndex + 1
        Loop
    End If
    strS = Mid(strS, 1, strSIndex)
    lngI = CLng(strS)
    GetInteger = rSUCCEED
    
    Exit Function
errmgr:
    GetInteger = rVBERROR
End Function

Public Function GetString(strString As String, Optional strCote As String = """") As FUNCTION_RETURN_CODE
    On Error GoTo errmgr
    
    Dim eRetCode As FUNCTION_RETURN_CODE
    Dim lngCote  As Byte: lngCote = Asc(Mid(strCote, 1, 1))
    
    eRetCode = GetChar(strCote)
    If (eRetCode <> rTRUE) Then
        GetString = eRetCode
        Exit Function
    End If
        
    ' Pre alloc the string so we do not lose time
    Dim strS        As String: strS = Space(lngStringSize)
    Dim strSIndex   As Long
    
    Do While (True)
        If (EOS() = rTRUE) Then Exit Do
        
        If (m_Bytes(lngBytesIndex) = lngCote) Then
            If (EOS() = rFALSE) Then
                If (lngBytesIndex + 1 < m_Length) Then
                    If (m_Bytes(lngBytesIndex + 1) = lngCote) Then
                        ' End of string char doubled
                        NextChar ' Skip the first char separator and continue like nothing happend
                    Else
                        Exit Do ' we found the end of the string
                    End If
                Else
                    Exit Do
                End If
            End If
        End If
        
        Mid(strS, strSIndex + 1, 1) = Chr(m_Bytes(lngBytesIndex))
        NextChar
        strSIndex = strSIndex + 1
    Loop
    If ((m_Bytes(lngBytesIndex) = lngCote) And (EOS() = rFALSE)) Then
        strString = Mid(strS, 1, strSIndex)
        GetString = rSUCCEED
        NextChar
    Else
        GetString = rFAILED
    End If
    Exit Function
errmgr:
    GetString = rVBERROR
End Function

Public Function GetUpToChar(theChar As String, strS As String, Optional lngStringSize As Long = 1024) As FUNCTION_RETURN_CODE
    On Error GoTo errmgr
    
    If (KillSpace() = rVBERROR) Then
    
        GetUpToChar = rVBERROR
        Exit Function
    End If
    
    Dim bytTheChar As Byte
    bytTheChar = Asc(Mid(theChar, 1, 1))
    
    ' Pre alloc the string so we do not lose time
    strS = Space(lngStringSize)
    Dim strSIndex   As Long
    
    Do While (GetCByteChar() <> bytTheChar) And (EOS() = rFALSE)
        Mid(strS, strSIndex + 1, 1) = Chr(m_Bytes(lngBytesIndex))
        NextChar
        strSIndex = strSIndex + 1
        If (EOS() = rSUCCEED) Then Exit Do
    Loop
    strS = Mid(strS, 1, strSIndex)
    
    GetUpToChar = rSUCCEED
    Exit Function
errmgr:
    GetUpToChar = rVBERROR
End Function


Public Function GetNextLine() As FUNCTION_RETURN_CODE

    On Error GoTo errmgr
    
    Do While (EOS() = rFALSE)
    
        If (m_Bytes(lngBytesIndex) = Asc(vbCr)) Then
            NextChar
            If (EOS() = rFALSE) Then
                If (m_Bytes(lngBytesIndex) = Asc(vbLf)) Then
                    NextChar
                End If
                GetNextLine = rSUCCEED
                Exit Function
            End If
        End If
        NextChar
    Loop
    GetNextLine = rFALSE
    Exit Function
errmgr:
    GetNextLine = rVBERROR
End Function

Public Function GetChar(C As String) As FUNCTION_RETURN_CODE

    On Error GoTo errmgr
      
    Dim bytChar As Byte: bytChar = Asc(Mid(C, 1, 1))
    
    If (KillSpace() = rVBERROR) Then
    
        GetChar = rVBERROR
        Exit Function
    End If
        
    If (Me.EOS() = rSUCCEED) Then
        GetChar = rFALSE
        Exit Function
    End If
        
    If (m_Bytes(lngBytesIndex) = bytChar) Then
    
        NextChar
        GetChar = rTRUE
        Exit Function
    End If
    GetChar = rFALSE
    Exit Function
errmgr:
    GetChar = rVBERROR
End Function

Public Function KillSpace() As FUNCTION_RETURN_CODE

    On Error GoTo errmgr
    Do While ((IsCharSpace() = rTRUE) And (EOS() = rFALSE))
        NextChar
        If (EOS() = rTRUE) Then Exit Do
    Loop
    KillSpace = rSUCCEED
Exit Function
errmgr:
    KillSpace = rVBERROR
End Function

Public Function getDouble(dblD As Double) As FUNCTION_RETURN_CODE
    On Error GoTo errmgr
    
    If (KillSpace() = rVBERROR) Then
    
        getDouble = rVBERROR
        Exit Function
    End If
    
    ' Pre alloc the string so we do not lose time
    Dim strS        As String: strS = Space(lngIdSize)
    Dim strSIndex   As Long
    
    Do While (((IsCharDouble()) = rTRUE) And (EOS() = rFALSE))
        Mid(strS, strSIndex + 1, 1) = Chr(m_Bytes(lngBytesIndex))
        NextChar
        strSIndex = strSIndex + 1
    Loop
    strS = Mid(strS, 1, strSIndex)
    dblD = CDbl(strS)
    getDouble = rSUCCEED
    
    Exit Function
errmgr:
    getDouble = rVBERROR
End Function

Public Function EOS() As FUNCTION_RETURN_CODE

    If (lngBytesIndex < m_Length) Then
        EOS = rFALSE
    Else
        EOS = rTRUE
    End If
'    On Error GoTo ErrMgr
'    If (lngBytesIndex < m_Length) Then
'        EOS = rFALSE
'    Else
'        EOS = rTRUE
'    End If
'    Exit Function
'ErrMgr:
'    EOS = rVBERROR
End Function
Private Sub Class_Initialize()
    On Error GoTo errmgr
    booKillSpaceOnly = False
    booAcceptPointInId = True
    booAccept2PointInId = False
    lngIdSize = 256
    lngStringSize = 256
    strDateSeparator = "/"
    m_stack.Initialize 64
    Exit Sub
errmgr:
    Debug.Print Err.Description
    Err.Clear
End Sub

Public Function NextLine() As FUNCTION_RETURN_CODE
    On Error GoTo errmgr
    
    Do While (IsCRLF() = rFAILED)
        NextChar
        If (EOS() = rTRUE) Then Exit Do
    Loop
    Do While (IsCRLF() = rSUCCEED)
        NextChar
        If (EOS() = rTRUE) Then Exit Do
    Loop
    
    NextLine = rSUCCEED
    Exit Function
errmgr:
    NextLine = rVBERROR
End Function

Public Function see(Optional pp As Long) As String
    On Error GoTo errmgr
    
    Exit Function
errmgr:
    see = rVBERROR
End Function

Public Function Percent() As Long
    On Error GoTo errmgr
    Percent = CLng((lngBytesIndex / m_Length) * 100)
    Exit Function
errmgr:
    Percent = rVBERROR
End Function

Public Function Length() As Long
    On Error GoTo errmgr
    Length = m_Length
    Exit Function
errmgr:
    Length = 0
    Err.Clear
End Function

Public Function Str2BytesArray(strS As String) As FUNCTION_RETURN_CODE
    On Error GoTo errmgr
    
    Dim i As Long
    
    ' MTVBLIB 1.3
    'ReDim m_Bytes(Len(strS) - 1)
    'For i = 1 To Len(strS)
    '
    '    m_Bytes(i - 1) = Asc(Mid(strS, i, 1))
    'Next
    'Str2BytesArray = rSUCCEED
    
    m_Bytes = StrConv(strS, vbFromUnicode)
    
    m_Length = UBound(m_Bytes()) + 1
    Exit Function
errmgr:
    Str2BytesArray = rFAILED
End Function

Private Function IsCharSpace() As FUNCTION_RETURN_CODE

    On Error GoTo errmgr
    
    If (CBool(m_Bytes(lngBytesIndex) = vbKeySpace)) Then
        IsCharSpace = rTRUE
        Exit Function
    End If
    If (booKillSpaceOnly) Then
        IsCharSpace = rFALSE
        Exit Function
    End If
    If (CBool(m_Bytes(lngBytesIndex) = vbKeyTab)) Then
        IsCharSpace = rTRUE
        Exit Function
    End If
    If (CBool(m_Bytes(lngBytesIndex) = 13)) Then
        IsCharSpace = rTRUE
        Exit Function
    End If
    If (CBool(m_Bytes(lngBytesIndex) = 10)) Then
        IsCharSpace = rTRUE
        Exit Function
    End If
    IsCharSpace = rFALSE
Exit Function
errmgr:
    IsCharSpace = rVBERROR
End Function

Public Function IsCharAlpha() As FUNCTION_RETURN_CODE

    On Error GoTo errmgr
    
    If ((m_Bytes(lngBytesIndex) >= Asc("A")) And (m_Bytes(lngBytesIndex) <= Asc("Z"))) Or _
       ((m_Bytes(lngBytesIndex) >= Asc("a")) And (m_Bytes(lngBytesIndex) <= Asc("z"))) Or _
       (m_Bytes(lngBytesIndex) = Asc("_")) Then
       
        IsCharAlpha = rTRUE
    Else
        IsCharAlpha = rFALSE
    End If
Exit Function
errmgr:
    IsCharAlpha = rVBERROR
End Function

Public Function IsCharNumeric() As FUNCTION_RETURN_CODE

    On Error GoTo errmgr
    
    If ((m_Bytes(lngBytesIndex) >= Asc("0")) And (m_Bytes(lngBytesIndex) <= Asc("9"))) Then
        IsCharNumeric = rTRUE
    Else
        IsCharNumeric = rFALSE
    End If
Exit Function
errmgr:
    IsCharNumeric = rVBERROR
End Function


Public Function IsCharID() As FUNCTION_RETURN_CODE
    On Error GoTo errmgr
    If (IsCharNumeric() = rTRUE) Then
        IsCharID = rTRUE
        Exit Function
    End If
    If (IsCharAlpha() = rTRUE) Then
        IsCharID = rTRUE
        Exit Function
    End If
    If (booAcceptPointInId) Then
        If (m_Bytes(lngBytesIndex) = Asc(".")) Then
            IsCharID = rTRUE
            Exit Function
        End If
    End If
    If (booAccept2PointInId) Then
        If (m_Bytes(lngBytesIndex) = Asc(":")) Then
            IsCharID = rTRUE
            Exit Function
        End If
    End If
    If (booAcceptMinusInId) Then
        If (m_Bytes(lngBytesIndex) = Asc("-")) Then
            IsCharID = rTRUE
            Exit Function
        End If
    End If
    IsCharID = rFALSE
    
    Exit Function
errmgr:
    IsCharID = rVBERROR
End Function

Public Function IsCharAlphaNumeric() As FUNCTION_RETURN_CODE
    On Error GoTo errmgr
    If (IsCharNumeric() = rTRUE) Then
        IsCharAlphaNumeric = rTRUE
        Exit Function
    End If
    If (IsCharAlpha() = rTRUE) Then
        IsCharAlphaNumeric = rTRUE
        Exit Function
    End If
    IsCharAlphaNumeric = rFALSE
    Exit Function
errmgr:
    IsCharAlphaNumeric = rVBERROR
End Function

Public Function IsCharInteger() As FUNCTION_RETURN_CODE
    On Error GoTo errmgr
    If (IsCharNumeric() = rTRUE) Then
        IsCharInteger = rTRUE
        Exit Function
    End If
    If (m_Bytes(lngBytesIndex) = Asc("+")) Then
        IsCharInteger = rTRUE
        Exit Function
    End If
    If (m_Bytes(lngBytesIndex) = Asc("-")) Then
        IsCharInteger = rTRUE
        Exit Function
    End If
    IsCharInteger = rFALSE
    Exit Function
errmgr:
    IsCharInteger = rVBERROR
End Function

Public Function IsCharDouble() As FUNCTION_RETURN_CODE
    On Error GoTo errmgr
    If (IsCharInteger() = rTRUE) Then
        IsCharDouble = rTRUE
        Exit Function
    End If
    If (m_Bytes(lngBytesIndex) = Asc(".")) Then
        IsCharDouble = rTRUE
        Exit Function
    End If
    IsCharDouble = rFALSE
    Exit Function
errmgr:
    IsCharDouble = rVBERROR
End Function

Public Function IsCharDate() As FUNCTION_RETURN_CODE
    On Error GoTo errmgr
    If (IsCharNumeric() = rTRUE) Then
        IsCharDate = rTRUE
        Exit Function
    End If
    If (m_Bytes(lngBytesIndex) = Asc(strDateSeparator)) Then
        IsCharDate = rTRUE
        Exit Function
    End If
    IsCharDate = rFALSE
    Exit Function
errmgr:
    IsCharDate = rVBERROR
End Function


Public Function Bench() As FUNCTION_RETURN_CODE

    Dim i           As Long
    Dim d           As Double
    Dim r           As Long
    Dim b           As Long
    Dim s           As String
    Dim vbLex       As New CByteSyntaxAnalyser
    
        
    Const strTest = vbCrLf & "Toto(1245,123.456)" & vbCrLf
    Dim tim As Long
    
    tim = GetTickCount()
    For b = 1 To 5000
            vbLex.Init strTest
            vbLex.GetNextLine
            vbLex.GetIdentifier s
            vbLex.GetChar "("
            vbLex.GetInteger i
            vbLex.GetChar ","
            vbLex.getDouble d
            vbLex.GetChar ")"
            vbLex.GetNextLine
    Next
    MsgBox GetTickCount() - tim
    
    Bench = rSUCCEED
    
End Function

Public Function DataString(Optional lngIndex As Long = -1) As String
    If (lngIndex = -1) Then
        DataString = m_string
    Else
        Dim i As Long
        Dim s As String
        For i = lngIndex To m_Length - 1
            s = s & Me.GetCChar(i)
        
        Next
        DataString = s
    End If
End Function


Public Function GetCByteChar(Optional lngIndex As Long = -1) As Byte

    If (lngIndex = -1) Then lngIndex = lngBytesIndex
    If (m_Length = 0) Then Exit Function
    
    GetCByteChar = (m_Bytes(lngIndex))
End Function

Public Function GetCChar(Optional lngIndex As Long = -1) As String

    If (lngIndex = -1) Then lngIndex = lngBytesIndex
    
    If (m_Length = 0) Then Exit Function
    
    GetCChar = Chr(m_Bytes(lngIndex))

    
End Function

Public Function PopBytesIndex(Optional booRestorIndex As Boolean = True) As Long
    If (booRestorIndex) Then
        lngBytesIndex = CLng(m_stack.Pop())
        PopBytesIndex = lngBytesIndex
    Else
        PopBytesIndex = CLng(m_stack.Pop())
    End If
End Function
Public Function PushBytesIndex() As Long
    m_stack.Push lngBytesIndex
    PushBytesIndex = lngBytesIndex
End Function
Private Sub Class_Terminate()
    m_stack.done
End Sub


Private Function IsCRLF() As FUNCTION_RETURN_CODE

    On Error GoTo errmgr
    

    If (CBool(m_Bytes(lngBytesIndex) = 13)) Then
        IsCRLF = rTRUE
        Exit Function
    End If
    If (CBool(m_Bytes(lngBytesIndex) = 10)) Then
        IsCRLF = rTRUE
        Exit Function
    End If
    IsCRLF = rFALSE
Exit Function
errmgr:
    IsCRLF = rVBERROR
End Function

Public Function NextChar(Optional lngStep As Long = 1) As Boolean

    On Error GoTo errmgr
    
    lngBytesIndex = lngBytesIndex + lngStep
        
    If (lngBytesIndex > m_lngMaxBytesIndex) Then m_lngMaxBytesIndex = lngBytesIndex
    
    NextChar = True
    Exit Function
errmgr:
End Function

Public Property Get MaxBytesIndex() As Long
    MaxBytesIndex = m_lngMaxBytesIndex
End Property


Public Function IsID(strID As String) As FUNCTION_RETURN_CODE

    On Error GoTo errmgr
    
    Dim i As Long
    
    Dim clsTmpParser As New CByteSyntaxAnalyser
    
    clsTmpParser.Init strID
    
    IsID = rFAILED
    
    For i = 1 To Len(strID)
    
        If (clsTmpParser.IsCharID() = rFAILED) Then Exit Function
    Next
    IsID = rSUCCEED
    Exit Function
errmgr:
End Function

Public Function IsLong(strLong As String) As Boolean
    If (IsNumeric(strLong)) Then
        IsLong = InStr(strLong, ".") = 0
    End If
End Function

Public Function IsBool(strStr As String) As Boolean
        IsBool = UCase(strStr = "TRUE") Or UCase(strStr = "FALSE")
End Function
