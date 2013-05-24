#ifndef __OPERATOR_ARG_H__
#define __OPERATOR_ARG_H__

#include "LogAdapter.h"

typedef enum 
{ 
  OPERATOR_ARG_TYPE_STRING,
  OPERATOR_ARG_TYPE_BOOLEAN,
  OPERATOR_ARG_TYPE_INTEGER,
  OPERATOR_ARG_TYPE_SUBLIST,
  OPERATOR_ARG_TYPE_VARIABLE
} OperatorArgType;

/**
 * Contains an operator argument that specified in a MetraFlow script.  
 * This class is used in these ways:
 * (1) to pass a specified operator argument from data_generate.g
 *     to an instatiated operator defined in the main script, 
 * (2) for operators inside composites, to hold specified
 *     arguments,
 * (3) for DesignTimeComposites (composite placeholder) to hold 
 *     specified composite arguments
 */
class OperatorArg 
{
private:

  /** The argument name. */
  std::wstring mName;

  /** The argument type. */
  OperatorArgType mType;

  /** Value of the argument, if the type is OPERATOR_ARG_TYPE_STRING. */
  std::wstring mStringValue;

  /** Value of the argument, if the type is OPERATOR_ARG_TYPE_BOOLEAN. */
  bool mBoolValue;

  /** Value of the argument, if the type is OPERATOR_ARG_TYPE_INT. */
  int mIntValue;

  /** 
   * Value of the argument, if the type is OPERATOR_ARG_TYPE_SUBLIST
   * A vector of sub-arguments.
   */
  std::vector<OperatorArg> mSubList;

  /**
   * The type of the referenced arg, 
   * if the this is a OPERATOR_ARG_TYPE_VARIABLE.
   */
  OperatorArgType mCompositeArgType;

  /** Line where the value of the argument was specified in the script. */
  int mValueLine;

  /** Column where the value of the argument was specified in the script. */
  int mValueColumn;

  /** Line where the name of the argument was specified in the script. */
  int mNameLine;

  /** Column where the name of the argument was specified in the script. */
  int mNameColumn;

  /** 
   * Name of the script that was the origin of the argument. Used for
   * error reporting.  Empty string if not known.
   */
  std::wstring mFilename;

  /**
   * A vector of references to composite arguments embedded in the
   * string (only applies to OPERATOR_ARG_TYPE_STRING).
   */
  std::vector<std::wstring> mEmbeddedArgs;

public:
  /** 
   * Constructor - constructs an OPERATOR_ARG_TYPE_STRING
   */
  OperatorArg(const std::wstring& name,
              const std::wstring& value,
              int nameLine,
              int nameColumn,
              int valueLine,
              int valueColumn,
              const std::wstring &filename);
  /** 
   * Constructor - constructs an OPERATOR_ARG_TYPE_BOOLEAN
   */
  OperatorArg(const std::wstring& name,
              bool value,
              int nameLine,
              int nameColumn,
              int valueLine,
              int valueColumn,
              const std::wstring &filename);
  /** 
   * Constructor - constructs an OPERATOR_ARG_TYPE_INTEGER
   */
  OperatorArg(const std::wstring& name,
              int value,
              int nameLine,
              int nameColumn,
              int valueLine,
              int valueColumn,
              const std::wstring &filename);

  /** 
   * Constructor - constructs an OPERATOR_ARG_TYPE_VARIABLE
   *
   * @param value Name of the composite argument
   */
  OperatorArg(OperatorArgType type,
              const std::wstring& name,
              const std::wstring& value,
              OperatorArgType argType,
              int nameLine,
              int nameColumn,
              int valueLine,
              int valueColumn,
              const std::wstring &filename);
  /** 
   * Constructor - constructs an OPERATOR_ARG_TYPE_SUBLIST
   */
  OperatorArg(OperatorArgType type);

  /** Copy constructor */
  OperatorArg(const OperatorArg&);

  /** Equal operator */
  OperatorArg& operator = (const OperatorArg&);

  /** Destructor */
  ~OperatorArg();

  /**
   * Get the embedded arguments (if any) in the string value.
   * If the string contained, $(a) $(b), returns a, b.
   * Applies to OPERATOR_ARG_TYPE_STRING
   */
  const std::vector<std::wstring> & getEmbeddedArgs() const;

  /** 
   * Add the given argument to the sublist.  
   * Applies to OPERATOR_ARG_TYPE_SUBLIST.
   */
  void addSubListArg(const OperatorArg& arg);

  /** 
   * Get the name 
   * Applies to all operator types.
   */
  std::wstring getName() const;

  /** 
   * Get argument type 
   * Applies to all operator types.
   */
  OperatorArgType getType() const;

  /** 
   * Get the string value.
   * Applies to OPERATOR_ARG_TYPE_STRING and OPERATOR_ARG_TYPE_COMPOSITE_STRING
   */
  std::wstring getStringValue() const;

  /** 
   * Get the string value without the beginning and ending quotes. 
   * Applies to OPERATOR_ARG_TYPE_STRING
   */
  std::wstring getNormalizedString() const;

  /** 
   * Get the bool value 
   * Applies to OPERATOR_ARG_TYPE_BOOL
   */
  bool getBoolValue() const;

  /** 
   * Get the int value 
   * Applies to OPERATOR_ARG_TYPE_INT
   */
  int getIntValue() const;

  /** 
   * Get the type of the variable.
   * Applies to OPERATOR_ARG_TYPE_VARIABLE
   */
  OperatorArgType getVarType() const;

  /**
   * Regardless of the type of the operator, return a string
   * version of the value.  Example use of this is 
   * when an operator argument is used
   * as something embedded in a string. (E.g. "select where id=$(myId)")
   */
  std::wstring getValueAsString() const;

  /** Get the line where value was defined. */
  int getValueLine() const;

  /** Get the sublist of arguments. */
  const std::vector<OperatorArg> & getSubList() const;

  /** Get the column where value was defined. */
  int getValueColumn() const;

  /** Get the line where name was defined. */
  int getNameLine() const;

  /** Get the column where name was defined. */
  int getNameColumn() const;

  /** Get the name of the file where the argument as defined. */
  std::wstring getFilename() const;
  
  /** 
   * Returns true if the name of the argument matches (case insensitive)
   * the given name and if the type matches.
   * If the name matches, but the type doesn't, will throw an
   * DataflowInvalidArgumentValueException.
   *
   * @param matchThis    expected argument name
   * @param expectedType expected argument type
   * @param opName       name of operator, used for error reporting.
   */
  bool is(const std::wstring &matchThis,
          OperatorArgType expectedType,
          const std::wstring &opName) const;
  /**
   * Does the argument contain a reference to a composite
   * argument variable.  This only applies to OPERATOR_ARG_TYPE_COMPOSITE_STRING
   */
  bool isThereAnEmbeddedArg() const;

  /**
   * Returns true if the string value associated with the argument
   * matches the given string.  Should only be used for string arguments.
   * 
   * @param matchThis  string to match. This string should not be
   *                   surrounded by quotes -- we are matching to the
   *                   normalized string.
   */
  bool isValue(const std::wstring &matchThis) const;

  /**
   * Replace the given embedded argument with the given value.
   * The embedded argument is expected to appear in the string value.
   * This only applies to OPERATOR_ARG_TYPE_COMPOSITE_STRING.
   */
  void replaceEmbeddedArg(const std::wstring &embeddedArg,
                          const std::wstring &replacementValue);
  /**
   * Set the name of the argument. This is used in the
   * case of a sublist where the argument name is not known
   * when constructed (see ::OperatorArg(OperatorArgType) constructor.
   */
  void setName(const std::wstring &name,
               int line, int column);
  /**
   * Set the name of the argument. This is used when we are tailoring
   * an argument for use in cloning an operator.
   */
  void setName(const std::wstring &name);

  /**
   * Replace \\n with \n.  When a parameter value contains a new
   * line (\n), it is read as \\n.  This method restores the new
   * line back to \n.
   */
  static void repairNewLines(std::wstring &s);

private:
  /** Disallowed */
  OperatorArg();

  /** Find embedded args */
  void findEmbeddedArgs();
};

#endif
