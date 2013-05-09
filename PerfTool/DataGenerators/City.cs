using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;


namespace DataGenerators
{
    public class City
    {
        public string geonameid;

        public string Name;
        public string County;
        public string State;
        public string Country;
    }


    public class AllCities
    {
        public List<City> cities = new List<City>();

        public AllCities()
        {
            string line;
            int counter = 0;

            int fieldCountryCode = 8;
            int fieldAdmin1Code = 10;
            int fieldAdmin2Code = 11;
            int fieldAdmin3Code = 12;
            int fieldAdmin4Code = 13;

            // Read the file and display it line by line.
            StreamReader file = new StreamReader(@"Assets\Places\cities1000.txt");
            while ((line = file.ReadLine()) != null)
            {
                string[] tabTokens = line.Split('\t');

                string countryCode = tabTokens[fieldCountryCode];
                string admin1Code = tabTokens[fieldAdmin1Code];
                string admin2Code = tabTokens[fieldAdmin2Code];
                string admin3Code = tabTokens[fieldAdmin3Code];
                string admin4Code = tabTokens[fieldAdmin4Code];


                if (countryCode == "US")
                {
                    string state = AllAdminCodes.getName(countryCode, admin1Code);
                    //if (false)
                    //{
                    //    Console.WriteLine("{0} {1} {2} || {3} {4} {5} {6}", tabTokens[0], tabTokens[1], countryCode,
                    //            state, admin2Code, admin3Code, admin4Code);
                    //}
                    counter++;

                    City city = new City();
                    city.geonameid = tabTokens[0];
                    city.Country = countryCode;
                    city.Name = tabTokens[1];
                    city.County = "";
                    city.State = state;

                    cities.Add(city);
                }

            }

            file.Close();
            Console.WriteLine("Found {0} US cities", counter);
        }

        public City pick()
        {
            int ix = DataGenerator.random.Next(cities.Count);
            return cities[ix];
        }

 
    }

}
