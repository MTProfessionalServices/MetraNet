using System;
using System.CodeDom;
using System.CodeDom.Compiler;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using Microsoft.CSharp;

namespace MetraTech.BusinessEntity.DataAccess.Common
{
  public static class CodeGeneratorUtil
  {
    internal static string GetFileContent(CodeCompileUnit codeCompileUnit)
    {
      CodeDomProvider codeProvider = new CSharpCodeProvider();

      // The CodeGeneratorOptions object allows us to specify
      // various formatting settings that will be used 
      // by the generator.
      var codeGeneratorOptions = new CodeGeneratorOptions();

      // Here we specify that the curley braces should start 
      // on the line following the opening of the block
      codeGeneratorOptions.BracingStyle = "C";

      // Here we specify that each block should be indented by 2 spaces
      codeGeneratorOptions.IndentString = "  ";

      var stringWriter = new StringWriter();
      codeProvider.GenerateCodeFromCompileUnit(codeCompileUnit, new IndentedTextWriter(stringWriter), codeGeneratorOptions);

      return stringWriter.ToString();
    }
  }
}
