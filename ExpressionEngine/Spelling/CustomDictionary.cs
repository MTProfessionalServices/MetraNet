
using System.Collections.Generic;

namespace MetraTech.ExpressionEngine.Spelling
{
    public class CustomDictionary
    {
        #region Properties
        public string LanguageCode { get; set; }
        public Dictionary<string, CustomDictionaryResult> CustomWords = new Dictionary<string, CustomDictionaryResult>();
        #endregion

        #region Constructor
        public CustomDictionary(string languageCode)
        {
            LanguageCode = languageCode;
        }
        #endregion

        #region Methods
        public void AddWhiteList(string word)
        {
            CustomWords.Add(word, CustomDictionaryResult.WhiteList);
        }
        public void AddBlackList(string word)
        {
            CustomWords.Add(word, CustomDictionaryResult.BalckList);
        }
        public CustomDictionaryResult Lookup(string word)
        {
            CustomDictionaryResult result;
            if (CustomWords.TryGetValue(word, out result))
                return result;
            return CustomDictionaryResult.NotFound;
        }
        #endregion
    }
}
