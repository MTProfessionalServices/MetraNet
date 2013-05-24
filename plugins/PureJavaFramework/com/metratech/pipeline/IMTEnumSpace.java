package com.metratech.pipeline;

/**
 * COM Interface 'IMTEnumSpace'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTEnumSpace Interface</B>'
 *
 * Generator Options:
 * PromptForTypeLibraries = True
 * AttemptNonDual = True
 * ClashPrefix = zz_
 * LowerCaseMemberNames = True
 * IDispatchOnly = False
 * RetryOnReject = True
 * GenerateDeprecatedConstructors = True
 * ArraysAsObjects = False
 * DontGenerateDisp = False
 * DontRenameSameMethods = False
 * IgnoreConflictingInterfaces = True
 */
public interface IMTEnumSpace {
  /**
   * getEnumTypes. method GetEnumTypes
   *
   * @return    return value.  An reference to a IMTEnumTypeCollection
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTEnumTypeCollection getEnumTypes  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEnumType. method GetEnumType
   *
   * @param     __MIDL_0020 The __MIDL_0020 (in)
   * @return    return value.  An reference to a IMTEnumType
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTEnumType getEnumType  (
              String __MIDL_0020) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * add. method Add
   *
   * @param     enum_type An reference to a IMTEnumType (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void add  (
              IMTEnumType enum_type) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getName. property Name
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getName  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setName. property Name
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setName  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getDescription. property Description
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getDescription  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setDescription. property Description
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setDescription  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getLocation. property Location
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getLocation  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setLocation. property Location
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setLocation  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * writeSet. method WriteSet
   *
   * @param     __MIDL_0022 An reference to a IMTConfigPropSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void writeSet  (
              IMTConfigPropSet __MIDL_0022) throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IIDbc3e00f8_0665_11d4_95a1_00b0d025b121 = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTEnumSpaceProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "bc3e00f8-0665-11d4-95a1-00b0d025b121";
  String DISPID_1_NAME = "getEnumTypes";
  String DISPID_2_NAME = "getEnumType";
  String DISPID_3_NAME = "add";
  String DISPID_4_GET_NAME = "getName";
  String DISPID_4_PUT_NAME = "setName";
  String DISPID_5_GET_NAME = "getDescription";
  String DISPID_5_PUT_NAME = "setDescription";
  String DISPID_8_GET_NAME = "getLocation";
  String DISPID_8_PUT_NAME = "setLocation";
  String DISPID_9_NAME = "writeSet";
}
