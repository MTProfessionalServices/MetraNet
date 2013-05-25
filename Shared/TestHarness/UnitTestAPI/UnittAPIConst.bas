Attribute VB_Name = "UnitAPIConst"
Option Explicit


' this enum is duplicated in  class TestAPI
Public Enum LOG_RESULT_MODE

    LOG_RESULT_MODE_START = 1
    LOG_RESULT_MODE_END = 2
    
    LOG_RESULT_MODE_TEST = 4
    LOG_RESULT_MODE_SESSION = 8
    LOG_RESULT_MODE_SUPER_SESSION = 16
    
    LOG_RESULT_MODE_CHECKPOINT = 32 '
    
    LOG_RESULT_MODE_COMPAREDEF = 64
    
End Enum

