using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using MetraTech.ExpressionEngine.Validations;

//http://social.msdn.microsoft.com/Forums/en-US/csharpgeneral/thread/791963c8-9e20-4e9e-b184-f0e592b943b0
  
namespace MetraTech.ExpressionEngine.Spelling
{
    public static class SpellingEngine
    {
        private const string BlackList = "'{0} is on the Black List";
        #region Properties
        public static CustomDictionary CustomEnglishDictionary = new CustomDictionary("en-us");
        #endregion

        #region Constructor
        static SpellingEngine()
        {
            CustomEnglishDictionary.AddWhiteList("MetraTech");
            CustomEnglishDictionary.AddBlackList("MDM");
        }
        #endregion

        #region Methods

        //static string[] GetWords(string input)
        //{
        //    MatchCollection matches = Regex.Matches(input, @"\b[\w']*\b");
        //    foreach (var match in matches.)
        //    var words = from m in matches.Cast<Match>()
        //                where !string.IsNullOrEmpty(m.Value)
        //                select TrimSuffix(m.Value);

        //    return words.ToArray();
        //}

        public static void CheckString(string value, string languageCode, ValidationMessageCollection messages)
        {
        }

        public static void CheckWords(List<string> words, string languageCode, ValidationMessageCollection messages)
        {
            //Hardcode to english for now
            var dictionary = CustomEnglishDictionary;
            foreach (var word in words)
            {
                CheckWord(word, languageCode, messages);
            }
        }

        public static bool CheckWord(string word, string languageCode, ValidationMessageCollection messages)
        {
            //Hardcode to english for now
            var dictionary = CustomEnglishDictionary;
            CustomDictionaryResult result = dictionary.Lookup(word);
            switch (result)
            {
                case CustomDictionaryResult.WhiteList:
                    return true;
                case CustomDictionaryResult.BalckList:
                    messages.Warn(string.Format(BlackList, word));
                    return false;
                case CustomDictionaryResult.NotFound:
                    //Lookup in real dictionary
                    return true;
            }
            throw new Exception("unhandled result");
        }


        public static List<string> SplitPascalOrCamelString(string stringToSplit)
        {
            var words = new List<string>();

            var lastChar = char.MinValue;
            int currentIndex = 0;
            int lastIndex = 0;;
            foreach (char currentChar in stringToSplit)
            {
                if (char.IsLower(lastChar) && char.IsUpper(currentChar))
                {
                    var word = stringToSplit.Substring(lastIndex, currentIndex - lastIndex);
                    words.Add(word);
                    lastIndex = currentIndex;
                }
                lastChar = currentChar;
                currentIndex++; 
            }

            var lastWord = stringToSplit.Substring(lastIndex);
            words.Add(lastWord);

            var finalWords = new List<string>();
            for (int wordIndex=0; wordIndex < words.Count; wordIndex++)
            {
                var word = words[wordIndex];

                //If it's camel case, let it pass
                if (char.IsLower(word[0]))
                {
                    finalWords.Add(word);
                    continue;
                }
                if (char.IsUpper(word[word.Length-1]))
                {
                    finalWords.Add(word);
                    continue;
                }

                for (int charIndex = 0; charIndex < word.Length; charIndex++)
                {
                    if (char.IsLower(word[charIndex]))
                    {
                        if (charIndex <= 1 || charIndex == word.Length-1)
                        {
                            finalWords.Add(word);
                            break;
                        }
                        else
                        {
                            finalWords.Add(word.Substring(0, charIndex-1));
                            finalWords.Add(word.Substring(charIndex - 1));
                            break;
                        }
                    }
                }
            }
            return finalWords;
        } 
        #endregion
    }
}
