#ifndef __ARG_ENVIRONMENT_H__
#define __ARG_ENVIRONMENT_H__

#include "LogAdapter.h"
#include "OperatorArg.h"
#include <map>

class OperatorArg;

/**
 * This class is used to manage name/value pairs specified
 * for composite arguments.  These arguments can be specified on the command
 * line (using --arg) or through environmental variables.
 *
 * This class also holds a singleton instance of the active
 * argument environment.  This is the environment that applies
 * to the entire running script.  The typical use of this class
 * is to call getActiveEnvironment() to get the environment and
 * make subsequent calls. Only in rare instances (MetraflowHistorian)
 * should the default constructor be used.
 *
 * Usage Notes: setCommandLineArg() should be called for each --arg
 *          encountered on the command line.
 *
 * CAUTION: although this class is a singleton, there is no locking
 *          in the instance creation.  This means you must guarantee
 *          getInstance() is called first by a single thread with
 *          no other thread interference.
 */
class ArgEnvironment
{
  private:
    /** Holds singleton instance. */
    static ArgEnvironment *mInstance;

    /** 
     * Map of name value pairs specified either on the command line
     * or through environmental variables.  This map is constructed
     * so that if the argument was defined by the command line, then
     * the environmental setting for argument (if it exists) is not
     * included in the map.
     */
    std::map<std::wstring, std::wstring> mArgs;

    /** 
     * Map of name value pairs of intrinsics.  These are variables
     * that are built-in, such as, number of partitions numPartitions.
     */
    std::map<std::wstring, std::wstring> mIntrinsics;

  private:
    /** 
     * Given a name, return the stored value
     * or an empty string if not found.
     */
    std::wstring getArg(const std::wstring &name);

    /** 
     * Given a name, return the intrinsic value
     * or an empty string if does not exist. Returns empty
     * string if name not found.
     */
    std::wstring getIntrinsic(const std::wstring &name);

  public:
    /** 
     * Constructor.  Use cautiously.  Typically getActiveEnvironment()
     * should be used instead.
     */
    ArgEnvironment();

    /** Destructor */
    ~ArgEnvironment();

    /** Equal operator */
    ArgEnvironment& operator=(const ArgEnvironment &rhs);

    /** Get ArgEnvironment */
    static ArgEnvironment* getActiveEnvironment();

    /**
     * Given the name of an argument, find the value
     * to use for the argument.  Precedence is: 
     * (1) the intrinsic value (example numPartitions),
     * (2) the value specified by the MetraFlow command line
     * (3) the environmental setting for the argument
     * If not found, return an empty string.
     */
     std::wstring getValue(const std::wstring &argName);

    /**
     * Given the name of an argument, find the value
     * to use for the argument.  Precedence is: 
     * (1) the value in the given vector of arguments, 
     * (2) the intrinsic value (example numPartitions),
     * (3) the value specified by the MetraFlow command line
     * (4) the environmental setting for the argument
     *
     * If not found, return an empty string.
     */
     std::wstring getValue(const std::wstring &argName,
                          const std::vector<OperatorArg *>&opArgList);

     /**
      * Given the name of an argument, find the value
      * to use for the argument.  Precedence is: 
      * (1) the value in the given vector of arguments, 
      * (2) the intrinsic value (example numPartitions),
      * (3) the value specified by the MetraFlow command line
      *
      * Once found, construct an operator arg matching
      * the requested type.  It is the responsibility of the caller of this
      * method to delete the argument.  If not found, returns NULL.
      */
     OperatorArg* getValueAsOperatorArg(
                          const std::wstring &argName,
                          OperatorArgType desiredType);

    /** Get all the non-intrinsic argument settings */
    const std::map<std::wstring, std::wstring>& getNonIntrinsicArgs() const;

    /** Get all the intrinsic argument settings */
    const std::map<std::wstring, std::wstring>& getIntrinsicArgs() const;

    /** 
     * Return a string representing the serialized version of 
     * the argument environment.
     */
    std::string serialize() const;

    /** 
     * Set argument environment by de-serializing the given string.
     * All previously stored argument settings are discarded.
     */
    void deserialize(const std::string& serialized);

    /**
     * Store the name/value pair specified for the argument
     * on the command line.
     *
     * @param nameValue  expected format <name>=<value>
     * @return false if improperly formatted nameValue.
     */
    bool storeArg(const std::wstring &nameValue);

    /**
     * Store the name/value pair specified for the non-intrinsic arg.
     *
     * @param name   name of argument
     * @param value  value of argument
     */
    void storeArg(const std::wstring &name,
                  const std::wstring &value);

    /**
     * If the given name is not already defined by a 
     * stored command line argument, then check if the name
     * is defined by an environmental variable.  If so, store
     * the environmental variable.  If not, nothing is saved.
     *
     * @param name  Name of the argument.
     */
    void storeEnvironmentalSettingForArg(const std::wstring &name);

    /**
     * Store the name/value pair specified for the intrinsic.
     *
     * @param name   name of argument
     * @param value  value of argument
     */
    void storeIntrinsicArg(const std::wstring &name,
                           const std::wstring &value);

    void storeIntrinsicArg(const std::wstring &name,
                           int value);
};

#endif
