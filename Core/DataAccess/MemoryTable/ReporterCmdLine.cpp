#include "ReporterCmdLine.h"
#include <iostream>

ReporterCmdLine::ReporterCmdLine()
{
}

ReporterCmdLine::~ReporterCmdLine()
{
}

void ReporterCmdLine::reportException(antlr::ANTLRException& e)
{
  mWasErrorReported = true;
  // Assume ANTLR exception is in default locale.
  ::ASCIIToWide(mErrMessage, e.toString());
  mLineNumber = 0;
  mColumnNumber = 0;
  std::cout << e.toString().c_str() << std::endl;
}

void ReporterCmdLine::reportException(DataflowException& e)
{
  mWasErrorReported = true;
  mErrMessage = e.getMessage();
  mLineNumber = e.getLineNumber();
  mColumnNumber = e.getColumnNumber();
  std::string localeMsg;
  ::WideStringToMultiByte(e.getMessage(), localeMsg, CP_ACP);
  std::cout << localeMsg.c_str() << std::endl;
}

void ReporterCmdLine::reportException(std::exception& e)
{
  mWasErrorReported = true;
  // Assume STL exception is in default locale.
  ::ASCIIToWide(mErrMessage, e.what());
  mLineNumber = 0;
  mColumnNumber = 0;
  std::cout << e.what() << std::endl;
}

void ReporterCmdLine::reportException(const std::wstring& phase)
{
  mWasErrorReported = true;
  mErrMessage = L"Unknown error occurred during " + phase;
  mLineNumber = 0;
  mColumnNumber = 0;
  std::string localePhase;
  ::WideStringToMultiByte(phase, localePhase, CP_ACP);
  std::cout << "Unknown error occurred during " + localePhase
            << std::endl;
}

void ReporterCmdLine::reportError(const std::wstring& errMessage)
{
  mWasErrorReported = true;
  mErrMessage = errMessage;
  mLineNumber = 0;
  mColumnNumber = 0;
  std::string localeMessage;
  ::WideStringToMultiByte(errMessage, localeMessage, CP_ACP);  
  std::cout << localeMessage.c_str() << std::endl;
}
