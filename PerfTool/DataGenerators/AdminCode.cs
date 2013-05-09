using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;


namespace DataGenerators
{
    public class AdminCode
    {
        public string key;
        public string name;
        public string n2;
        public string geonameid;
    }

    public class AllAdminCodes
    {
        static Dictionary<string, AdminCode> allCodes = new Dictionary<string, AdminCode>();

        public AllAdminCodes()
        {
            string line;
            // Read the file and display it line by line.
            StreamReader file = new StreamReader(@"Assets\Places\admin1CodesASCII.txt");
            if (file == null)
            {
                throw new Exception("Failed to open file");
            }

            while ((line = file.ReadLine()) != null)
            {
                string[] tabTokens = line.Split('\t');

                AdminCode a = new AdminCode();
                a.key = tabTokens[0];
                a.name = tabTokens[1];
                a.n2 = tabTokens[2];
                a.geonameid = tabTokens[3];

                allCodes.Add(a.key, a);
            }

            file.Close();

        }

        public static string getName(string cc, string admin1)
        {
            return allCodes[cc + "." + admin1].name;
        }


    }

}
