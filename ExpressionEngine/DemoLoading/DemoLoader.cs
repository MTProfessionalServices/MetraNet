using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using CsvHelper;
using CsvHelper.Configuration;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Expressions;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.Placeholders;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;


namespace MetraTech.ExpressionEngine
{
    //this is a total mess that loads data into the GlobalContext.... needs to replaced with clean data loading
    public static class DemoLoader
    {
        #region Properties
        public const string DirPath = @"C:\ExpressionEngine";
        public static string TopLevelDataDir = Path.Combine(DirPath, "Data");
        private static string DataPath;
        public static Context GlobalContext { get; private set; }
        #endregion

        #region General
        public static void LoadGlobalContext(ProductType product, string subDir)
        {
            GlobalContext = new Context(product);
            DataPath = Path.Combine(TopLevelDataDir, subDir);

            if (Context.ProductType == ProductType.MetraNet)
            {
                GlobalContext = Context.LoadExtensions(Path.Combine(DataPath, "Extensions"));
;
                LoadXqg(GlobalContext, ExpressionType.Aqg, Path.Combine(DataPath, "AqgExpressions.csv"));
                LoadXqg(GlobalContext, ExpressionType.Uqg, Path.Combine(DataPath, "UqgExpressions.csv"));
            }
            else
            {
                GlobalContext = Context.LoadMetanga(DataPath);
            }

            LoadFunctions();
            LoadExpressions();
            LoadEmailTemplates(GlobalContext, Path.Combine(DataPath, "EmailTemplates"));
            LoadEmailInstances(GlobalContext, Path.Combine(DataPath, "EmailInstances"));
        }

        #endregion

        #region Expressions
        public static void LoadExpressions()
        {
            var dirInfo = new DirectoryInfo(Path.Combine(DataPath, "Expressions"));
            if (!dirInfo.Exists)
                return;

            foreach (var fileInfo in dirInfo.GetFiles("*.xml"))
            {
                var exp = Expression.CreateFromFile(fileInfo.FullName);
                GlobalContext.Expressions.Add(exp.Name, exp);
            }
        }
        #endregion

        #region XQGs

        public static void LoadXqg(Context context, ExpressionType type, string filePath)
        {
            if (context == null)
                throw new ArgumentException("context");

            if (!File.Exists(filePath))
                return;

            var lines = File.ReadAllLines(filePath);
            for (int index = 1; index < lines.Length; index++)
            {
                var cols = lines[index].Split(',');
                var name = cols[0];
                var expression = cols[1];
                var description = string.Empty;
                switch (type)
                {
                    case ExpressionType.Aqg:
                        var aqg = new Aqg(name, description, expression);
                        context.Aqgs.Add(aqg.Name, aqg);
                        break;
                    case ExpressionType.Uqg:
                        var uqg = new Uqg(name, description, expression);
                        context.Uqgs.Add(uqg.Name, uqg);
                        break;
                    default:
                        throw new NotImplementedException();
                }
            }
        }
        #endregion

        #region Emails
        public static void LoadEmailInstances(Context context, string dirPath)
        {
            if (context == null)
                throw new ArgumentException("context");

            var dirInfo = new DirectoryInfo(dirPath);
            if (!dirInfo.Exists)
                return;
            foreach (var file in dirInfo.GetFiles("*.xml"))
            {
                var emailInstance = EmailInstance.CreateFromFile(file.FullName);
                context.EmailInstances.Add(emailInstance.Name, emailInstance);
            }
        }
        public static void LoadEmailTemplates(Context context, string dirPath)
        {
            if (context == null)
                throw new ArgumentNullException("context");

            var dirInfo = new DirectoryInfo(dirPath);
            if (!dirInfo.Exists)
                return;
            foreach (var file in dirInfo.GetFiles("*.xml"))
            {
                var emailTemplate = EmailTemplate.CreateFromFile(file.FullName);
                context.EmailTemplates.Add(emailTemplate.Name, emailTemplate);
            }
        }
        #endregion

        #region Functions
        public static void LoadFunctions()
        {
            DemoLoader.GlobalContext.Functions.Clear();
            var dirInfo = new DirectoryInfo(Path.Combine(DirPath, @"Reference\Functions"));
            foreach (var file in dirInfo.GetFiles("*.xml"))
            {
                var func = Function.CreateFromFile(file.FullName);
                GlobalContext.Functions.Add(func.Name, func);
            }
        }
        #endregion
    }
}
