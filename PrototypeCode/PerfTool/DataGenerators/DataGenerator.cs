using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace DataGenerators
{
    public class DataGenerator
    {
        private static DataGenerator myInstance;
        public static DataGenerator instance
        {
            get
            {
                if( myInstance == null)
                myInstance = new DataGenerator();
                return myInstance;
            }
            set
            {
            }
        }

        public static Random random = new Random();

        private AllAdminCodes allAdminCodes;
        private AllCities allCities;
        private Names allNames;

        private DataGenerator()
        {
            Console.WriteLine("#1");
            allAdminCodes = new AllAdminCodes();
            Console.WriteLine("#2");
            allCities = new AllCities();
            Console.WriteLine("#3");
            allNames = new Names();
            Console.WriteLine("#4");
        }

        public string pickFirst()
        {
            return allNames.pickFirst();
        }

        public string pickLast()
        {
            return allNames.pickLast();
        }

        public City pickCity()
        {
            return allCities.pick();
        }

        public int NextNumber(int limit)
        {
            return random.Next(limit);
        }


        public string pickIMSI()
        {
            string s = "USATT";
            for( int ix=0; ix<10; ix++) 
            {
                int digit = random.Next(10);
                s += string.Format("{0}", digit);
            }
            return s;

        }

    }
}
