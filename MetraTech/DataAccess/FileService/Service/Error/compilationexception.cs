using System;
using System.Collections.Generic;
using System.Text;
using System.CodeDom;
using System.CodeDom.Compiler;

namespace MetraTech.FileService
{
  /// <summary>
  /// Exception that is thrown when an application encounters errors compiling code.
  /// </summary>
  public class CompilationException : Exception
  {
    /// <summary>
    /// Default constructor.
    /// </summary>
    public CompilationException()
      : base()
    {
    }

    /// <summary>
    /// Constructor allowing the user to pass in a collection of CompilerError objects that we 
    /// then assemble into a string for the exception message.
    /// </summary>
    /// <param name="errors">
    /// Collection of CompilerError objects that we are to parse together.
    /// </param>
    public CompilationException(CompilerErrorCollection errors)
      : base(AssembleExceptionMessage(errors))
    {
    }

    /// <summary>
    /// Constructor allowing the user to pass in a root exception and a collection of 
    /// CompilerError objects that we then assemble into a string for the exception message.
    /// </summary>
    /// <param name="errors">
    /// Collection of CompilerError objects that we are to parse together.
    /// </param>
    /// <param name="innerException">
    /// Exception that caused this exception.
    /// </param>
    public CompilationException(CompilerErrorCollection errors, Exception innerException)
      : base(AssembleExceptionMessage(errors), innerException)
    {
    }

    /// <summary>
    /// Parses together a collection of CompilerError objects in the form of a string whose 
    /// contents mimic the output of the Visual Studio build process.
    /// </summary>
    /// <param name="errors">
    /// Collection of CompilerError objects that we are to parse together.
    /// </param>
    /// <returns>
    /// A Visual Studio-like string of compilation errors.
    /// </returns>
    protected static string AssembleExceptionMessage(CompilerErrorCollection errors)
    {
      StringBuilder exceptionMessage = new StringBuilder("Errors occurred during compilation:\n");

      // Add each error to the string in Visual Studio-like format
      foreach (CompilerError error in errors)
      {
        if (error.FileName != "")
          exceptionMessage.AppendFormat("{0}({1},{2}): ", error.FileName, error.Line, error.Column);

        exceptionMessage.AppendFormat("{0} {1}: {2}\n", (error.IsWarning ? "warning" : "error"), error.ErrorNumber, error.ErrorText);
      }

      return exceptionMessage.ToString();
    }
  }
}
