# Microsoft Developer Studio Generated NMAKE File, Based on SimplePlugin.dsp
!IF "$(CFG)" == ""
CFG=SimplePlugin - Win32 Debug
!MESSAGE No configuration specified. Defaulting to SimplePlugin - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "SimplePlugin - Win32 Release" && "$(CFG)" != "SimplePlugin - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "SimplePlugin.mak" CFG="SimplePlugin - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "SimplePlugin - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "SimplePlugin - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "SimplePlugin - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(MTOUTDIR)\SimplePlugin.dll" "$(MTOUTDIR)\MTConfig.tlb" "$(MTOUTDIR)\MTConfigProp.tlb" "$(MTOUTDIR)\MTConfigPropSet.tlb" "$(MTOUTDIR)\MTPipelinePlugIn.tlb" "$(MTOUTDIR)\MTSession.tlb" "$(MTOUTDIR)\MTSessionProp.tlb" "$(MTOUTDIR)\MTSessionPropType.tlb" "$(MTOUTDIR)\MTSessionSet.tlb" "$(MTOUTDIR)\PropValType.tlb"


CLEAN :
	-@erase "$(INTDIR)\MTConfig.tlb"
	-@erase "$(INTDIR)\MTConfigProp.tlb"
	-@erase "$(INTDIR)\MTConfigPropSet.tlb"
	-@erase "$(INTDIR)\MTPipelinePlugIn.tlb"
	-@erase "$(INTDIR)\MTSession.tlb"
	-@erase "$(INTDIR)\MTSessionProp.tlb"
	-@erase "$(INTDIR)\MTSessionPropType.tlb"
	-@erase "$(INTDIR)\MTSessionSet.tlb"
	-@erase "$(INTDIR)\PropValType.tlb"
	-@erase "$(INTDIR)\SimplePlugin.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(MTOUTDIR)\SimplePlugin.dll"
	-@erase "$(MTOUTDIR)\SimplePlugin.exp"
	-@erase "$(MTOUTDIR)\SimplePlugin.lib"

"$(MTOUTDIR)" :
    if not exist "$(MTOUTDIR)/$(NULL)" mkdir "$(MTOUTDIR)"

CPP_PROJ=/nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "SimplePlugin_EXPORTS" /Fp"$(INTDIR)\SimplePlugin.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
MTL_PROJ=/nologo /D "NDEBUG" /mktyplib203 /win32 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(MTOUTDIR)\SimplePlugin.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /incremental:no /pdb:"$(MTOUTDIR)\SimplePlugin.pdb" /machine:I386 /def:".\SimplePlugin.def" /out:"$(MTOUTDIR)\SimplePlugin.dll" /implib:"$(MTOUTDIR)\SimplePlugin.lib" 
DEF_FILE= \
	".\SimplePlugin.def"
LINK32_OBJS= \
	"$(INTDIR)\SimplePlugin.obj" \
	".\Staticlibs\release\error.lib" \
	".\Staticlibs\release\mtcomerr.lib" \
	".\Staticlibs\release\skeleton.lib" \
	".\Staticlibs\release\tls4d.lib"

"$(MTOUTDIR)\SimplePlugin.dll" : "$(MTOUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "SimplePlugin - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

ALL : "$(MTOUTDIR)\SimplePlugin.dll" "$(MTOUTDIR)\MTConfig.tlb" "$(MTOUTDIR)\MTConfigProp.tlb" "$(MTOUTDIR)\MTConfigPropSet.tlb" "$(MTOUTDIR)\MTPipelinePlugIn.tlb" "$(MTOUTDIR)\MTSession.tlb" "$(MTOUTDIR)\MTSessionProp.tlb" "$(MTOUTDIR)\MTSessionPropType.tlb" "$(MTOUTDIR)\MTSessionSet.tlb" "$(MTOUTDIR)\PropValType.tlb" "$(MTOUTDIR)\SimplePlugin.bsc"


CLEAN :
	-@erase "$(INTDIR)\MTConfig.tlb"
	-@erase "$(INTDIR)\MTConfigProp.tlb"
	-@erase "$(INTDIR)\MTConfigPropSet.tlb"
	-@erase "$(INTDIR)\MTPipelinePlugIn.tlb"
	-@erase "$(INTDIR)\MTSession.tlb"
	-@erase "$(INTDIR)\MTSessionProp.tlb"
	-@erase "$(INTDIR)\MTSessionPropType.tlb"
	-@erase "$(INTDIR)\MTSessionSet.tlb"
	-@erase "$(INTDIR)\PropValType.tlb"
	-@erase "$(INTDIR)\SimplePlugin.obj"
	-@erase "$(INTDIR)\SimplePlugin.sbr"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(MTOUTDIR)\SimplePlugin.bsc"
	-@erase "$(MTOUTDIR)\SimplePlugin.dll"
	-@erase "$(MTOUTDIR)\SimplePlugin.exp"
	-@erase "$(MTOUTDIR)\SimplePlugin.ilk"
	-@erase "$(MTOUTDIR)\SimplePlugin.lib"
	-@erase "$(MTOUTDIR)\SimplePlugin.pdb"

"$(MTOUTDIR)" :
    if not exist "$(MTOUTDIR)/$(NULL)" mkdir "$(MTOUTDIR)"

CPP_PROJ=/nologo /MDd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "SimplePlugin_EXPORTS" /FR"$(INTDIR)\\" /Fp"$(INTDIR)\SimplePlugin.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 
MTL_PROJ=/nologo /D "_DEBUG" /win32 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(MTOUTDIR)\SimplePlugin.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\SimplePlugin.sbr"

"$(MTOUTDIR)\SimplePlugin.bsc" : "$(MTOUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /incremental:yes /pdb:"$(MTOUTDIR)\SimplePlugin.pdb" /debug /machine:I386 /def:".\SimplePlugin.def" /out:"$(MTOUTDIR)\SimplePlugin.dll" /implib:"$(MTOUTDIR)\SimplePlugin.lib" /libpath:"StaticLibs\debug" 
DEF_FILE= \
	".\SimplePlugin.def"
LINK32_OBJS= \
	"$(INTDIR)\SimplePlugin.obj" \
	".\Staticlibs\debug\tls7d.lib" \
	".\Staticlibs\debug\mtcomerr.lib" \
	".\Staticlibs\debug\error.lib" \
	".\Staticlibs\debug\skeleton.lib"

"$(MTOUTDIR)\SimplePlugin.dll" : "$(MTOUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("SimplePlugin.dep")
!INCLUDE "SimplePlugin.dep"
!ELSE 
!MESSAGE Warning: cannot find "SimplePlugin.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "SimplePlugin - Win32 Release" || "$(CFG)" == "SimplePlugin - Win32 Debug"
SOURCE=SimplePlugin.cpp

!IF  "$(CFG)" == "SimplePlugin - Win32 Release"


"$(INTDIR)\SimplePlugin.obj" : $(SOURCE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "SimplePlugin - Win32 Debug"


"$(INTDIR)\SimplePlugin.obj"	"$(INTDIR)\SimplePlugin.sbr" : $(SOURCE) "$(INTDIR)"


!ENDIF 

SOURCE=.\MTConfig.idl

!IF  "$(CFG)" == "SimplePlugin - Win32 Release"

MTL_SWITCHES=/nologo /D "NDEBUG" /tlb "$(MTOUTDIR)\MTConfig.tlb" /mktyplib203 /win32 

"$(INTDIR)\MTConfig.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "SimplePlugin - Win32 Debug"

MTL_SWITCHES=/nologo /D "_DEBUG" /tlb "$(MTOUTDIR)\MTConfig.tlb" /win32 

"$(INTDIR)\MTConfig.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ENDIF 

SOURCE=.\MTConfigProp.idl

!IF  "$(CFG)" == "SimplePlugin - Win32 Release"

MTL_SWITCHES=/nologo /D "NDEBUG" /tlb "$(MTOUTDIR)\MTConfigProp.tlb" /mktyplib203 /win32 

"$(INTDIR)\MTConfigProp.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "SimplePlugin - Win32 Debug"

MTL_SWITCHES=/nologo /D "_DEBUG" /tlb "$(MTOUTDIR)\MTConfigProp.tlb" /win32 

"$(INTDIR)\MTConfigProp.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ENDIF 

SOURCE=.\MTConfigPropSet.idl

!IF  "$(CFG)" == "SimplePlugin - Win32 Release"

MTL_SWITCHES=/nologo /D "NDEBUG" /tlb "$(MTOUTDIR)\MTConfigPropSet.tlb" /mktyplib203 /win32 

"$(INTDIR)\MTConfigPropSet.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "SimplePlugin - Win32 Debug"

MTL_SWITCHES=/nologo /D "_DEBUG" /tlb "$(MTOUTDIR)\MTConfigPropSet.tlb" /win32 

"$(INTDIR)\MTConfigPropSet.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ENDIF 

SOURCE=.\MTPipelinePlugIn.idl

!IF  "$(CFG)" == "SimplePlugin - Win32 Release"

MTL_SWITCHES=/nologo /D "NDEBUG" /tlb "$(MTOUTDIR)\MTPipelinePlugIn.tlb" /mktyplib203 /win32 

"$(INTDIR)\MTPipelinePlugIn.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "SimplePlugin - Win32 Debug"

MTL_SWITCHES=/nologo /D "_DEBUG" /tlb "$(MTOUTDIR)\MTPipelinePlugIn.tlb" /win32 

"$(INTDIR)\MTPipelinePlugIn.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ENDIF 

SOURCE=.\MTSession.idl

!IF  "$(CFG)" == "SimplePlugin - Win32 Release"

MTL_SWITCHES=/nologo /D "NDEBUG" /tlb "$(MTOUTDIR)\MTSession.tlb" /mktyplib203 /win32 

"$(INTDIR)\MTSession.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "SimplePlugin - Win32 Debug"

MTL_SWITCHES=/nologo /D "_DEBUG" /tlb "$(MTOUTDIR)\MTSession.tlb" /win32 

"$(INTDIR)\MTSession.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ENDIF 

SOURCE=.\MTSessionProp.idl

!IF  "$(CFG)" == "SimplePlugin - Win32 Release"

MTL_SWITCHES=/nologo /D "NDEBUG" /tlb "$(MTOUTDIR)\MTSessionProp.tlb" /mktyplib203 /win32 

"$(INTDIR)\MTSessionProp.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "SimplePlugin - Win32 Debug"

MTL_SWITCHES=/nologo /D "_DEBUG" /tlb "$(MTOUTDIR)\MTSessionProp.tlb" /win32 

"$(INTDIR)\MTSessionProp.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ENDIF 

SOURCE=.\MTSessionPropType.idl

!IF  "$(CFG)" == "SimplePlugin - Win32 Release"

MTL_SWITCHES=/nologo /D "NDEBUG" /tlb "$(MTOUTDIR)\MTSessionPropType.tlb" /mktyplib203 /win32 

"$(INTDIR)\MTSessionPropType.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "SimplePlugin - Win32 Debug"

MTL_SWITCHES=/nologo /D "_DEBUG" /tlb "$(MTOUTDIR)\MTSessionPropType.tlb" /win32 

"$(INTDIR)\MTSessionPropType.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ENDIF 

SOURCE=.\MTSessionSet.idl

!IF  "$(CFG)" == "SimplePlugin - Win32 Release"

MTL_SWITCHES=/nologo /D "NDEBUG" /tlb "$(MTOUTDIR)\MTSessionSet.tlb" /mktyplib203 /win32 

"$(INTDIR)\MTSessionSet.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "SimplePlugin - Win32 Debug"

MTL_SWITCHES=/nologo /D "_DEBUG" /tlb "$(MTOUTDIR)\MTSessionSet.tlb" /win32 

"$(INTDIR)\MTSessionSet.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ENDIF 

SOURCE=.\PropValType.idl

!IF  "$(CFG)" == "SimplePlugin - Win32 Release"

MTL_SWITCHES=/nologo /D "NDEBUG" /tlb "$(MTOUTDIR)\PropValType.tlb" /mktyplib203 /win32 

"$(INTDIR)\PropValType.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "SimplePlugin - Win32 Debug"

MTL_SWITCHES=/nologo /D "_DEBUG" /tlb "$(MTOUTDIR)\PropValType.tlb" /win32 

"$(INTDIR)\PropValType.tlb" : $(SOURCE) "$(INTDIR)"
	$(MTL) @<<
  $(MTL_SWITCHES) $(SOURCE)
<<


!ENDIF 


!ENDIF 

