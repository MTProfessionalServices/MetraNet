using System;
using System.IO;
using MetraTech.ExpressionEngine.MetraNet.MtProperty;

namespace MetraTech.ExpressionEngine.MetraNet
{
    public static class Loader
    {
        public static void LoadDirectory(string dirPath)
        {
            var dirInfo = new DirectoryInfo(dirPath);
            if (dirInfo.Exists)
                throw new ArgumentException("Directory doesn't exist " + dirPath);

            foreach (var fileInfo in dirInfo.GetFiles("*.xml"))
            {
                //switch (dirInfo.Name.ToLower())
                //{
                //    //case "accountviews":
                //    //    AccountViewEntity.CreateProductView()
                //    case "productviews":
                //        var pv = EntityFactory.CreateProductViewEntity()
                //    //case "servicedefinitions":
                //    //case "enumerations":
                //}
                
            }

            //Recurse on the sub directories
            foreach (var subDirInfo in dirInfo.GetDirectories())
            {
                LoadDirectory(subDirInfo.FullName);
            }
        }
    }
}
