using System;
using Microsoft.CSharp;
using System.CodeDom.Compiler;
using System.IO;
using System.Reflection;
using System.Xml;
using System.Threading;

#pragma warning disable 0618    // Disable warning System.Reflection.Assembly.LoadWithPartialName(string)' is obsolete:

namespace CSharpScript
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
  class MTCSharpScript {
    /// <summary>
    /// The main entry point for the application.
    /// </summary>
    public Assembly AssemblyResolver(Object sender, ResolveEventArgs args) 
    {
      System.Console.WriteLine("Attempt To resolve assembly");
      throw new Exception("not implemented");

    }

    // Loads the content of a file to a byte array. 
    static byte[] loadFile(string filename) {
      FileStream fs = new FileStream(filename, FileMode.Open,System.IO.FileAccess.Read);
      byte[] buffer = new byte[(int) fs.Length];
      fs.Read(buffer, 0, buffer.Length);
      fs.Close();
   
      return buffer;
    }   



  [STAThread] // when using COM interop, perform as a single threaded apartment. the alternative is a MTA apartment
  static void Main(string[] args)
		{
      try {

        // load up the assembly resolver delegate
        AppDomain threadDomain = Thread.GetDomain();
        //threadDomain.


        MTCSharpScript script = new MTCSharpScript();

       // threadDomain.AssemblyResolve += new ResolveEventHandler(script.AssemblyResolver);


        if(args.Length == 0) {
          System.Console.WriteLine("CSharpScript Input file required.");
          return;
        }
        System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
        doc.Load(args[0]);

        // build the parameters
        CompilerParameters comp_params = new CompilerParameters();

        

        foreach (System.Xml.XmlAttribute attr in doc.SelectSingleNode("/csharpscript").Attributes) {
          if(attr.Name.CompareTo("assembly") == 0)  {
            comp_params.CompilerOptions += "/r:" + attr.Value + " ";
            comp_params.ReferencedAssemblies.Add(attr.Value);
          }
        }
        AppDomainSetup domSetup = new AppDomainSetup();
        domSetup.ApplicationBase = "O:\\";
        domSetup.ApplicationName = "MetraNet";
        domSetup.DynamicBase = "debug\\TempAssemblies";

     //   AppDomain currentDomain = System.AppDomain.CreateDomain("CSharpScript",
     //     new System.Security.Policy.Evidence(Thread.GetDomain().Evidence),
     //     "O:\\","debug\\bin",false);

        AppDomain currentDomain = System.AppDomain.CreateDomain("CSharpScript",
          new System.Security.Policy.Evidence(Thread.GetDomain().Evidence),domSetup);
        currentDomain.AppendPrivatePath("debug\\bin");
        currentDomain.AppendPrivatePath("debug\\TempAssemblies");

        string tempAssemblyName = "O:\\debug\\TempAssemblies\\foo.dll";
        comp_params.OutputAssembly = tempAssemblyName;


        // check if we need to to add pick up any reference path's from the command line
        foreach (string testval in args) {
          if(testval.StartsWith("/lib:")) {
            string tempstr = testval.Substring(5);
            comp_params.CompilerOptions += " " + testval;
          }
        }
        
        // create instance of CSharp Compiler
        CSharpCodeProvider myCodeProvider = new CSharpCodeProvider();
        // get ICompiler interface
        ICodeCompiler csharpCompiler = myCodeProvider.CreateCompiler();

        CompilerResults results = csharpCompiler.CompileAssemblyFromSource(comp_params,
          doc.SelectSingleNode("/csharpscript").InnerText);

  				
        if(results.Errors.HasErrors == true) {
          string error = "";
          foreach (CompilerError temp in results.Errors) {
            error += temp.ErrorText;
            error += "\n";
          }
          throw new Exception(error);
        }

      string basedir = currentDomain.BaseDirectory;
      string privatepath = currentDomain.RelativeSearchPath;

      

       currentDomain.Load(loadFile(tempAssemblyName));

     //   AssemblyName myName = AssemblyName.GetAssemblyName("E:\\temp\\foo.dll");    
        //currentDomain.Load(myName);
      //  Thread.GetDomain().Load(results.CompiledAssembly.FullName);

       // currentDomain.Load("E:\\temp\\foo");
  			
        System.Type[] typelist = results.CompiledAssembly.GetTypes();

        foreach(Type currentType in typelist) {
          //Object myobjects = currentDomain.CreateInstance(results.CompiledAssembly.FullName,currentType.FullName);
         Object myobjects = results.CompiledAssembly.CreateInstance(currentType.FullName);
          object[] mainparams = new object[1];
          mainparams[0] = args;
          myobjects.GetType().GetMethod("Main").Invoke(myobjects,mainparams);
        }
        System.Console.Write("done!");
      }
      catch(System.Exception e) {
        System.Console.WriteLine("Caught exception:\n {0}",e);
      }
      finally {
        // I don't think we have any resources to clean up... everything
        // should go out of scope and be cleaned up correctly.
      }
		}
	}
}
