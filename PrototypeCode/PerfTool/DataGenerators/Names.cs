using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace DataGenerators
{
    public class Name
    {
        public string n;
        public string gender;
    }

    public class Names
    {
        public List<Name> FirstNames = new List<Name>();
        public List<Name> LastNames = new List<Name>();

        public Names()
        {
            ReadFirstNames();
            ReadLastNames();
        }

        public void ReadFirstNames()
        {
            string line;
            // Read the file and display it line by line.
            StreamReader file = new StreamReader(@"Assets\Names\FirstNames.csv");
            while ((line = file.ReadLine()) != null)
            {
                string[] tokens = line.Split(',');
                Name name = new Name();
                name.n = tokens[0];
                name.gender = tokens[1];
                FirstNames.Add(name);
            }
            file.Close();
       }

        public void ReadLastNames()
        {
            string line;
            // Read the file and display it line by line.
            StreamReader file = new StreamReader(@"Assets\Names\LastNames.csv");
            while ((line = file.ReadLine()) != null)
            {
                string[] tokens = line.Split(',');
                Name name = new Name();
                name.n = tokens[0];
                LastNames.Add(name);
            }
            file.Close();
        }

        public string pick(List<Name> list)
        {
            int ix = DataGenerator.random.Next(list.Count);
            return list[ix].n;
        }

        public string pickFirst()
        {
            return pick(FirstNames);
        }

        public string pickLast()
        {
            return pick(LastNames);
        }

    }
}
