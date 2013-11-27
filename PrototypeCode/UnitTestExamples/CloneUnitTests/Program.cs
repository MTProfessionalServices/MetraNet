using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;

namespace CloneUnitTests
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Count() != 2)
                throw new ArgumentException("Program takes 2 int argument:\n1.Solution directory;\n2.Ammount of copies.");

            string solutionDirectory = args[0];
            int ammountOfClones = Convert.ToInt32(args[1]);
            int numberOfExecution = 1;

            while (numberOfExecution <= ammountOfClones)
            {
                CloneAllTestMethods(solutionDirectory, numberOfExecution);
                numberOfExecution++;
            }
        }

        private static void CloneAllTestMethods(string solutionDirectory, int numberOfExecution)
        {
            const string fItClassFileName = "DataExportReportManagementServiceFakeItEasyTest.cs";
            const string fItProjFileName = "Metratech.Core.Services.FakeItEasy_Unit_Test.csproj";
            var fItFolderPath = Path.Combine(solutionDirectory, "Metratech.Core.Services.FakeItEasy_Unit_Test");

            const string justMockClassFileName = "DataExportReportManagementServiceJustMock.cs";
            const string justMockProjFileName = "Metratech.Core.Services.JustMock_Unit_Test.csproj";
            string justMockFolderPath = Path.Combine(solutionDirectory, "Metratech.Core.Services.JustMock_Unit_Test");

            const string moqClassFileName = "DataExportReportManagementServiceMoqTest.cs";
            const string moqProjFileName = "Metratech.Core.Services.Moq_Unit_Test.csproj";
            string moqFolderPath = Path.Combine(solutionDirectory, "Metratech.Core.Services.Moq_Unit_Test");

            // Clone FakeItEasy
            CloneTestMethodsOfProject(
                fItFolderPath,
                fItClassFileName,
                fItProjFileName,
                numberOfExecution);

            // Clone JustMock
            CloneTestMethodsOfProject(
                justMockFolderPath,
                justMockClassFileName,
                justMockProjFileName,
                numberOfExecution);

            // Clone Moq
            CloneTestMethodsOfProject(
                moqFolderPath,
                moqClassFileName,
                moqProjFileName,
                numberOfExecution);
        }

        private static void CloneTestMethodsOfProject(string pathToFolder, string classFileName, string projFileName, int cloneNumber)
        {
            var pathToClass = Path.Combine(pathToFolder, classFileName);
            var newClassFileName = classFileName.Insert(classFileName.LastIndexOf('.'), String.Format("_{0}", cloneNumber));
            var newPathToClass = Path.Combine(pathToFolder, newClassFileName);
            var pathToProj = Path.Combine(pathToFolder, projFileName);
            var projFileXml = new XmlDocument();

            // Correcting code & saving new .cs file
            var codeReader = new StreamReader(pathToClass);
            string classCode = codeReader.ReadToEnd();
            codeReader.Close();

            string className = classFileName.Substring(0, classFileName.LastIndexOf('.'));
            int classNameEnd = classCode.IndexOf(className) + className.Length;
            classCode = classCode.Insert(classNameEnd, String.Format("_{0}", cloneNumber));
            int construnctorNameEnd = classCode.LastIndexOf(className) + className.Length;
            classCode = classCode.Insert(construnctorNameEnd, String.Format("_{0}", cloneNumber));

            string methodName = "AddNewReportDefinition_SuccessfulExecution_ReaderExecutedWithAllParameters";
            int methodNameEnd = classCode.IndexOf(methodName) + methodName.Length;
            classCode = classCode.Insert(methodNameEnd, String.Format("_{0}", cloneNumber));

            methodName = "AddNewReportDefinition_MASBasicExceptionOccures_MASBaseExceptionThrown";
            methodNameEnd = classCode.IndexOf(methodName) + methodName.Length;
            classCode = classCode.Insert(methodNameEnd, String.Format("_{0}", cloneNumber));

            methodName = "AddNewReportDefinition_ExceptionOccures_MASBaseExceptionThrown";
            methodNameEnd = classCode.IndexOf(methodName) + methodName.Length;
            classCode = classCode.Insert(methodNameEnd, String.Format("_{0}", cloneNumber));

            using (var fsWriter = File.Create(newPathToClass))
            {
                Byte[] code = new UTF8Encoding(true).GetBytes(classCode);
                fsWriter.Write(code, 0, code.Length);
            }

            projFileXml.Load(pathToProj);
            XmlNamespaceManager nsmgr = new XmlNamespaceManager(projFileXml.NameTable);
            nsmgr.AddNamespace("x", "http://schemas.microsoft.com/developer/msbuild/2003");

            var firstCompileFileNode = (XmlElement)projFileXml.SelectSingleNode("/x:Project/x:ItemGroup/x:Compile", nsmgr);
            XmlNode compileFilesContainerNode = firstCompileFileNode.ParentNode;
            XmlNode newCompileFileNode = projFileXml.CreateElement("Compile", projFileXml.DocumentElement.NamespaceURI);
            var includeAttr = projFileXml.CreateAttribute("Include");
            includeAttr.Value = newClassFileName;

            newCompileFileNode.Attributes.Append(includeAttr);
            compileFilesContainerNode.AppendChild(newCompileFileNode);

            projFileXml.Save(pathToProj);
        }
    }
}
