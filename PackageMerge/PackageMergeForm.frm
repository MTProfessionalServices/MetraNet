VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form PackageMergeForm 
   Caption         =   "Package Merge Tool"
   ClientHeight    =   5190
   ClientLeft      =   165
   ClientTop       =   450
   ClientWidth     =   6900
   FillColor       =   &H00FF0000&
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MousePointer    =   1  'Arrow
   Picture         =   "PackageMergeForm.frx":0000
   ScaleHeight     =   5190
   ScaleWidth      =   6900
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox txtConfigDir 
      Height          =   285
      Left            =   240
      TabIndex        =   9
      Top             =   4440
      Width           =   4455
   End
   Begin VB.TextBox txtPackageDir 
      Height          =   285
      Left            =   240
      TabIndex        =   8
      Top             =   3480
      Width           =   4455
   End
   Begin VB.CommandButton ButtonChangeTargetDir 
      Caption         =   "Browse..."
      Height          =   375
      Left            =   5160
      TabIndex        =   7
      Top             =   4395
      Width           =   1335
   End
   Begin VB.CommandButton ButtonChangePackageDir 
      Caption         =   "Browse..."
      Height          =   375
      Left            =   5160
      TabIndex        =   6
      Top             =   3435
      Width           =   1335
   End
   Begin VB.CommandButton UnMerge 
      Caption         =   "Un-Merge!"
      Height          =   495
      Left            =   3960
      TabIndex        =   4
      Top             =   1440
      Width           =   2055
   End
   Begin MSComctlLib.ImageList PackageImageList 
      Left            =   240
      Top             =   5400
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   1
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "PackageMergeForm.frx":74ED2
            Key             =   ""
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.TreeView PackageTView 
      Height          =   2535
      Left            =   240
      TabIndex        =   2
      Top             =   240
      Width           =   2175
      _ExtentX        =   3836
      _ExtentY        =   4471
      _Version        =   393217
      Style           =   3
      Checkboxes      =   -1  'True
      ImageList       =   "PackageImageList"
      Appearance      =   1
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Merge!"
      Height          =   495
      Left            =   3960
      TabIndex        =   1
      Top             =   840
      Width           =   2055
   End
   Begin VB.Label PackagesDirectory 
      BackStyle       =   0  'Transparent
      Caption         =   "Packages directory:"
      ForeColor       =   &H00FFFFFF&
      Height          =   255
      Left            =   240
      TabIndex        =   5
      Top             =   3240
      Width           =   2295
   End
   Begin VB.Label StaticTargetDir 
      BackStyle       =   0  'Transparent
      Caption         =   "Target Configuration directory:"
      ForeColor       =   &H00FFFFFF&
      Height          =   255
      Left            =   240
      TabIndex        =   3
      Top             =   4200
      Width           =   2295
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "Select the platform extensions you wish to merge into your target configuration tree."
      ForeColor       =   &H00FFFFFF&
      Height          =   495
      Left            =   3360
      TabIndex        =   0
      Top             =   240
      Width           =   3375
   End
   Begin VB.Menu mnuAbout 
      Caption         =   "About"
   End
End
Attribute VB_Name = "PackageMergeForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private WshFileSystem As New FileSystemObject
Private PackageDir As String
Private mConfigDirectory As String
Private mConfig As New MTConfig
Private mProgress As New PackageProgressBar


Private Function RemoveOwnerFiles(aOwnerModule As MTModule, _
                                OwnerType As MTOwnerType, _
                                Name As String, _
                                ConfigDir As String, _
                                ByRef Progress As PackageProgressBar) As Boolean

Dim aOwnerList As New MTConfigSetOwnerList
Dim aCurrentFile, aFile, aTempString As String
Dim aCount, aListCount As Integer
Dim aFileList As Variant
Dim aDirectory As String



' step 1: initialize the owner list
Call aOwnerList.Init(aOwnerModule, OwnerType)

For aCount = 0 To aOwnerList.Count - 1
  aFile = aOwnerList.Item(aCount)
  
  aFileList = Split(aFile, "\")
  For aListCount = 0 To UBound(aFileList)
    If aFileList(aListCount) = Name Then
      ' account for the package name + config
      aListCount = aListCount + 2
      Exit For
    End If
  Next
  
  aDirectory = ConfigDir
  For aListCount = aListCount To UBound(aFileList) - 1
    aDirectory = aDirectory & PackageTView.PathSeparator & aFileList(aListCount)
  Next
  aTempString = aDirectory & PackageTView.PathSeparator & aFileList(UBound(aFileList))
  
  
  If WshFileSystem.FileExists(aTempString) Then
    Call WshFileSystem.DeleteFile(aTempString)
  End If
  Progress.Update
Next

End Function

'----------------------------------------------------------------------------
'   Name: CopyOwnerFiles
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------

Private Function CopyOwnerFiles(aOwnerModule As MTModule, _
                                OwnerType As MTOwnerType, _
                                Name As String, _
                                ConfigDir As String, _
                                 ByRef Progress As PackageProgressBar) As Boolean
                                
Dim aOwnerList As New MTConfigSetOwnerList
Dim aCurrentFile, aFile, aTempString As String
Dim aCount, aListCount As Integer
Dim aFileList As Variant
Dim aDirectory As String



' step 1: initialize the owner list
Call aOwnerList.Init(aOwnerModule, OwnerType)

For aCount = 0 To aOwnerList.Count - 1
  aFile = aOwnerList.Item(aCount)
  
  aFileList = Split(aFile, "\")
  For aListCount = 0 To UBound(aFileList)
    If aFileList(aListCount) = Name Then
      ' account for the package name + config
      aListCount = aListCount + 2
      Exit For
    End If
  Next
  
  aDirectory = ConfigDir
  For aListCount = aListCount To UBound(aFileList) - 1
    aDirectory = aDirectory & PackageTView.PathSeparator & aFileList(aListCount)
  Next
  aTempString = aDirectory & PackageTView.PathSeparator & aFileList(UBound(aFileList))
  
  If Not WshFileSystem.FolderExists(aDirectory) Then
    WshFileSystem.CreateFolder (aDirectory)
  End If
  
  Call WshFileSystem.CopyFile(aFile, aTempString)
  Progress.Update
  
  
Next



End Function

Private Function FolderCount(aFolder As Object) As Long
Dim aSub As Folder
Dim aCount As Long
aCount = 0

If TypeOf aFolder Is Folder Then
  FolderCount = aFolder.Files.Count + FolderCount(aFolder.SubFolders)
Else

  For Each aSub In aFolder
    aCount = aCount + FolderCount(aSub)
  Next
  FolderCount = aCount
End If


End Function

'----------------------------------------------------------------------------
'   Name: GetRegValue
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------

Private Function ProcessAllConfigSets(Name As String, Optional bUnmerge As Boolean = False)

  Dim aFileCount As Long
  Dim aPackageConfigDir As String
  
  Call mProgress.Show
  mProgress.MousePointer = vbHourglass
  DoEvents
  
  aPackageConfigDir = PackageDir & PackageTView.PathSeparator & Name & PackageTView.PathSeparator & "config"
  
  aFileCount = FolderCount(WshFileSystem.GetFolder(aPackageConfigDir))
  
  mProgress.SetNumItems (aFileCount)
  
  
  Call MergePackage(Name, OWNER_TYPE_SHARED, mConfigDirectory, bUnmerge)
  Call MergePackage(Name, OWNER_TYPE_PLATFORMEXTENSION, aPackageConfigDir, bUnmerge)
  Call MergePackage(Name, OWNER_TYPE_USER, aPackageConfigDir, bUnmerge)
  
  mProgress.Hide
  mProgress.MousePointer = vbNormal
  ProcessAllConfigSets = True

End Function

'----------------------------------------------------------------------------
'   Name: MergePackage
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------


Private Function MergePackage(Name As String, _
                              aConfigOwner As MTOwnerType, _
                              aConfigDir As String, _
                              Optional bUnmerge As Boolean = False) As Boolean
Dim aConfigSetOwner As New MTConfigSetOwnerList
Dim aModule As New MTModule
Dim aCount As Integer
Dim aFile As String
Dim aFullPackageFile As String
Dim aOldFile As String
Dim aDiffTool As New XmlDiff
Dim NumDirs As Integer
Dim ConfigDirList As Variant
Dim FileList As Variant
Dim Index As Integer
Dim aRelativeDir, aDirectory As String
            
  ConfigDirList = Split(aConfigDir, "\")
  NumDirs = UBound(ConfigDirList) - 1
  
  
  aModule.AbsolutePath = True
  aModule.ModuleDataFileName = aConfigDir & "\_config.xml"
  Call aModule.Read
  
  Call aConfigSetOwner.Init(aModule, aConfigOwner)
  
  For aCount = 0 To aConfigSetOwner.Count - 1
    aFile = aConfigSetOwner.Item(aCount)
    
    aFullPackageFile = ""
    aRelativeDir = ""
    
    FileList = Split(aFile, "\")
    For Index = NumDirs + 2 To UBound(FileList) - 1
      aRelativeDir = aRelativeDir & PackageTView.PathSeparator & FileList(Index)
    Next
      aFullPackageFile = aRelativeDir & PackageTView.PathSeparator & FileList(UBound(FileList))
    
    
    aFile = mConfigDirectory & aFullPackageFile
    
    aFullPackageFile = PackageDir & PackageTView.PathSeparator & _
      Name & "\config" & aFullPackageFile
    
    If WshFileSystem.FileExists(aFullPackageFile) Then
      If WshFileSystem.FileExists(aFile) And _
         aDiffTool.CanFilesMerge(aFile) Then
        ' ok... this file has merge capabilities
        If bUnmerge Then
          If aConfigOwner = OWNER_TYPE_SHARED Then
            mProgress.lblFile.Caption = aFile
            Call aDiffTool.UnMergeByOwner(aFile, aFile, Name)
          Else
             If WshFileSystem.FileExists(aFile) Then
              Call WshFileSystem.DeleteFile(aFile)
             End If
          End If
        Else
          mProgress.lblFile.Caption = aFullPackageFile
          Call aDiffTool.MergeXML(aFile, aFullPackageFile, aFile, Name, "")
        End If
      Else
        aDirectory = mConfigDirectory & aRelativeDir
        ' ok... we can't merge.
        If bUnmerge Then
          If WshFileSystem.FileExists(aFile) Then
            Call WshFileSystem.DeleteFile(aFile)
          End If
        Else
          If Not WshFileSystem.FolderExists(aDirectory) Then
              WshFileSystem.CreateFolder (aDirectory)
            End If
            Call WshFileSystem.CopyFile(aFullPackageFile, aFile)
        End If
      End If
    
    Call mProgress.Update
    End If
    
  Next
  
  MergePackage = True
  
  Set aConfigSetOwner = Nothing
  Set aModule = Nothing


End Function

Private Sub ButtonChangePackageDir_Click()
  PackageDir = getBrowseDirectory(0, "Platform extension directory")
  If Not Len(PackageDir) = 0 Then
    txtPackageDir = PackageDir
  End If
End Sub

Private Sub ButtonChangeTargetDir_Click()
  mConfigDirectory = getBrowseDirectory(0, "Target configuration directory")
  If Not Len(mConfigDirectory) = 0 Then
    txtConfigDir = mConfigDirectory
  End If
  Call PopulateSelectedItems
End Sub

'----------------------------------------------------------------------------
'   Name: Command1_Click
'   Description: merge the platform extensions
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------

Private Sub Command1_Click()
Dim aNode As Node
Dim Item As Variant
Dim aPropType As PropValType
Dim fso As New FileSystemObject

txtPackageDir = PackageDir
mConfigDirectory = txtConfigDir

If mConfigDirectory = "" Or Not fso.FolderExists(mConfigDirectory) Then
  MsgBox ("You must specify a valid target configuration directory")
  Exit Sub
End If

PackageMergeForm.MousePointer = vbHourglass

Dim aMergeSuccessfullList As New Collection


' step 1: find all the selected platform extensions
For Each aNode In PackageTView.Nodes
  If (aNode.Checked) Then
    If ProcessAllConfigSets(aNode.FullPath) Then
      Call aMergeSuccessfullList.Add(aNode.FullPath)
    End If
  End If

Next

Call WriteXmlWithCol(aMergeSuccessfullList)

PackageMergeForm.MousePointer = vbDefault

End Sub
'----------------------------------------------------------------------------
'   Name: Form_Load
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------
Private Sub Form_Load()
  Dim ExtensionsDir As Folder
  Dim CurrentFolder As Folder
 

'   iterate through all the directories
'    Set ExtensionsDir = WshFileSystem.GetFolder(RootDir & "\packages")
'
'   Enumerate through all the platform extensions
'  For Each Folder In ExtensionsDir.SubFolders
'     generate the package
'    wscript.echo "Starting processing of " & Folder.Path & "\manifest.xml"
'    Call GeneratePackage(Folder.Path & "\manifest.xml")
'     Modify the IPR file & build package
'    Call ModifyIPRAndBuildPackage(Folder.Path & "\manifest.xml")
'    wscript.echo "Finished processing " & Folder.Path & "\manifest.xml"
'
'  Next


'PackageDir = getBrowseDirectory(0, "Platform extension directory")
 'mConfigDirectory = CStr(GetRegValue(HKEY_LOCAL_MACHINE, _
 '           "Software\Metratech\Netmeter", "ConfigDir", _
 '           ""))
 
 mConfigDirectory = Environ("ROOTDIR") & "\config"
 PackageDir = Environ("ROOTDIR") & "\packages"
 mProgress.Hide

txtConfigDir = mConfigDirectory
txtPackageDir = PackageDir

' default to rootdir ^ packages


  Set ExtensionsDir = WshFileSystem.GetFolder(PackageDir)
  For Each CurrentFolder In ExtensionsDir.SubFolders
    Call PackageTView.Nodes.Add(, , CurrentFolder.Name, CurrentFolder.Name, 1, 1)
  Next
            
 Me.Show
 DoEvents
 Call PopulateSelectedItems
 
            

End Sub
'----------------------------------------------------------------------------
'   Name: PopulateSelectedItems
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------

Private Function PopulateSelectedItems()
Dim aPropSet As MTConfigPropSet
Dim acol As New Collection
Dim aName As String
Dim aNode As Node

aName = ""

On Error Resume Next
Set aPropSet = mConfig.ReadConfiguration(mConfigDirectory & "\MergedPackages.xml", False)
If aPropSet Is Nothing Then
  Exit Function
End If

Do
  aName = ""
  aName = aPropSet.NextStringWithName("MergedPackage")
  If aName <> "" Then
    For Each aNode In PackageTView.Nodes
      If aNode.FullPath = aName Then
        aNode.Checked = True
        Exit For
      End If
    Next
  End If
Loop Until aName = ""
On Error GoTo 0



End Function



'----------------------------------------------------------------------------
'   Name: getBrowseDirectory
'   Description: Get the packages directory from the shell browseforfolder API method
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------

Private Function getBrowseDirectory(hwnd As Long, Optional msg As String) As String

  Dim bi          As BROWSEINFO
  Dim IDL         As ITEMIDLIST
  Dim r           As Long
  Dim pidl        As Long
  Dim tmpPath     As String
  Dim pos         As Integer
    
   bi.hOwner = hwnd
   bi.pidlRoot = 0&
   bi.lpszTitle = IIf(msg <> "", msg, "Select the search directory")
   bi.ulFlags = BIF_RETURNONLYFSDIRS
   
  'get the folder
   pidl = SHBrowseForFolder(bi)
   
   tmpPath = Space$(512)
   r = SHGetPathFromIDList(ByVal pidl, ByVal tmpPath)
     
   If r Then
       pos = InStr(tmpPath, Chr$(0))
       tmpPath = Left(tmpPath, pos - 1)
       getBrowseDirectory = tmpPath
   Else
       getBrowseDirectory = ""
   End If
   
End Function


'----------------------------------------------------------------------------
'   Name: UnMergePackage
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------

Private Function UnMergePackage(aPackage As String) As Boolean
  
  PackageMergeForm.MousePointer = vbHourglass
  
  Call ProcessAllConfigSets(aPackage, True)
  UnMergePackage = True
PackageMergeForm.MousePointer = vbDefault
End Function
'----------------------------------------------------------------------------
'   Name: UnMerge_Click
'   Description:
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------


Private Sub Form_Terminate()
'MsgBox ("Bye!")
End Sub

Private Sub Form_Unload(Cancel As Integer)
Unload mProgress
End Sub

Private Sub mnuAbout_Click()
Dim aAbout As New frmAbout
Call aAbout.Show(vbModal)
End Sub

Private Sub UnMerge_Click()
Dim aNode As Node
Dim aMergedCollection As New Collection
Dim fso As New FileSystemObject

txtPackageDir = PackageDir
mConfigDirectory = txtConfigDir

If mConfigDirectory = "" Or Not fso.FolderExists(mConfigDirectory) Then
  MsgBox ("You must specify a valid target configuration directory")
  Exit Sub
End If


' step 1: iterate through the list of selected extensions.
For Each aNode In PackageTView.Nodes
  If aNode.Checked Then
    If (UnMergePackage(aNode.FullPath)) Then
      aNode.Checked = False
    End If
  End If
Next

For Each aNode In PackageTView.Nodes
  If aNode.Checked Then
    aMergedCollection.Add (aNode.FullPath)
  End If
Next

Call WriteXmlWithCol(aMergedCollection)


End Sub


Private Function WriteXmlWithCol(ByRef acol As Collection)
Dim Item As Variant
Dim aPropType As PropValType
Dim aPropSet As MTConfigPropSet
Dim aFile As String

aFile = mConfigDirectory & PackageTView.PathSeparator & "MergedPackages.xml"
If acol.Count = 0 And WshFileSystem.FileExists(aFile) Then
  WshFileSystem.DeleteFile (aFile)
  Exit Function
End If


Set aPropSet = mConfig.NewConfiguration("xmlconfig")

For Each Item In acol
  aPropType = PROP_TYPE_STRING
  Call aPropSet.InsertProp("MergedPackage", aPropType, Item)
Next

Call aPropSet.Write(aFile)

End Function
