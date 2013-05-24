#include "ScriptInterpreter.h"
#include "ReporterCmdLine.h"

#include <windows.h>
#include <iostream>

#include <boost/program_options.hpp>

int main(int argc, char * argv[])
{
  ::CoInitializeEx(NULL, COINIT_MULTITHREADED);

  ReporterCmdLine reporter;

  try
  {
    DataflowScriptInterpreter interpreter(&reporter);
    return interpreter.Run(argc, argv);
  }
  // ESR-5619: MetraFlowShell Error Message for invalid arguments needs clarity
  // Ideally, functionality would exist to handle all exceptions in a common manner.
  catch(const boost::program_options::multiple_occurrences & e)
  {
    std::cerr << "Exception: " << e.what() << ", Hint: " << e.get_option_name() << std::endl;
    return 1;
  }
  catch(std::exception & e)
  {
    std::cerr << "Exception: " << e.what() << std::endl;
    return 1;
  }
  catch(...)
  {
    std::cerr << "Unknown exception: " << std::endl;
    return 1;
  }
}
