using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace BaselineGUI
{
    public class ExtensionFileSystem
    {
        public string rootPath;

        public ExtensionFileSystem()
        {
            rootPath = @"c:\MetraTech\RMP\extensions\GSM";
        }


        public static void copy(string dstPath, string srcPath)
        {
            DirectoryInfo dstDir = new DirectoryInfo(dstPath);
            DirectoryInfo srcDir = new DirectoryInfo(srcPath);

            // Copy subdirectories
            DirectoryInfo[] srcSubdirs = srcDir.GetDirectories();
            foreach (DirectoryInfo sDir in srcSubdirs)
            {
                if (sDir.FullName.EndsWith(".git"))
                    continue;
                if (sDir.FullName.EndsWith("_svn"))
                    continue;

                string name = sDir.Name;
                DirectoryInfo dDir;
                DirectoryInfo[] dDirs = dstDir.GetDirectories(name, SearchOption.TopDirectoryOnly);
                if (dDirs.Length == 0)
                {
                    dDir = dstDir.CreateSubdirectory(name);
                }
                else
                {
                    dDir = dDirs[0];
                }

                copy(dDir.FullName, sDir.FullName);
            }

            FileInfo[] files = srcDir.GetFiles();
            foreach (FileInfo f in files)
            {
                bool copyIt = false;
                if (f.Extension.ToLower().EndsWith("xml"))
                    copyIt = true;
                if (f.Extension.ToLower().EndsWith("msixdef"))
                    copyIt = true;

                if (copyIt)
                {
                    string s = File.ReadAllText(f.FullName);
                    File.WriteAllText(dstDir.FullName + @"\" + f.Name, s);
                }
            }

        }


        public void load()
        {
            List<FileInfo> allFiles = new List<FileInfo>();
            Queue<DirectoryInfo> dirs = new Queue<DirectoryInfo>();


            DirectoryInfo dirInfo = new DirectoryInfo(rootPath);
            dirs.Enqueue(dirInfo);

            List<DirectoryInfo> allDirs = new List<DirectoryInfo>();

            while (dirs.Count > 0)
            {
                dirInfo = dirs.Dequeue();
                Console.WriteLine("{0}", dirInfo.FullName);

                FileInfo[] files = dirInfo.GetFiles();
                foreach (FileInfo f in files)
                {
                    allFiles.Add(f);
                }
                DirectoryInfo[] da = dirInfo.GetDirectories();
                foreach (DirectoryInfo d in da)
                {
                    if (d.FullName.EndsWith(".git"))
                        continue;
                    if (d.FullName.EndsWith("_svn"))
                        continue;

                    dirs.Enqueue(d);
                    allDirs.Add(d);
                }

            }

        }

    }
}
