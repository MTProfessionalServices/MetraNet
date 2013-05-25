Attribute VB_Name = "MTMSIX_READ_ME_TEXT"
' -------------------------------------------------------------------------------
' CLASS         : MTMSIX_READ_ME_TEXT
' FILE          : MSMSIX.ReadMe.Txt
' AUTHOR        : F.Torres
' CREATION DATE : 09/03/2000
' DESCRIPTION   : THIS FILE CONTAINS ONLY TEXT NOTES ABOUT THE COM OBJECT
' -------------------------------------------------------------------------------
'
' NOTE          :   Parent/Children relation side effect.
' DESCRIPTION   :   Because of the Parent/Children relation in the all object model!
'                   If the parent does not make sure the child.parent is not set to nothing
'                   the MSIX Instance is never unallocated!
'                   This function cannot be called from the Destructor Class_Terminate(),
'                   because the destructor is only called when nothing reference the object.
'
'                   All the class that have a parent Property have friend method call delete.
'                   This function that must be called before the ref is set to nothing.
'                   This function reset the parent property to nothing.
'
'                   Since the parent property is very usefull i decided to keep it, but to make
'                   the all COM object safer I decided that the object MSIXProperties will
'                   not have a parent property. So Now I am shure that when the last MSIXHandler
'                   ref is set to nothing the instance is deleted!
'
'                   A GOOD USAGE of this componant suppose does not create yourself a MSXI..... object
'                   yourself except the class MSIXHandler and MSIXProperties call.
'                   This 2 classes does not have an parent property
'                   All the rest class MSXI..... are PublicNotCreateAble so nobody can use them directly!
' AUTHOR        :   F.Torres
' CREATION DATE :   09/03/2000
'
'
' NOTE          :   TRACE_DESTRUCTOR Compilation condition
' DESCRIPTION   :   If the define TRACE_DESTRUCTOR is set all the destructor log a message in the log.
'                   This mode allow to check that all the instance are release!
'                   Not set for the real build.
'
' NOTE          :   What is stored in the cache
' DESCRIPTION   :
'
'                   Objects : MTEnumConfig object, RCD Object are stored in the cache. And so used/shared
'                   by the all application. MTEnumConfig and RCD cache themself information and because they
'                   are COM singleton the information is shared across session/user.
'
'                   Unicode2Big5Translater : For chinese user only store the object and the XML tranlation table.
'
'                   Product view localization : Every product view has a localization string associated with
'                   every property. This is not a COM singleton, plus in the case of chinese release we have
'                   to translate the DB unicode string into big5. The big5 is stored in the cache so the translation
'                   is done once per session. This cannot be shared across session/user for now!
'



