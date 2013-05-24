package com.metratech.pipeline;

/**
 * COM Interface 'IEnumConfig'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IEnumConfig Interface</B>'
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
public interface IEnumConfig {
  /**
   * initialize. method Initialize
   *
   * @param     config_path A Variant (in, optional, pass null if not required)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void initialize  (
              Object config_path) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEnumWithValue. method GetEnumWithValue
   *
   * @param     enum_space The enum_space (in)
   * @param     enum_name The enum_name (in)
   * @param     enum_value The enum_value (in)
   * @return    return value.  The name
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getEnumWithValue  (
              String enum_space,
              String enum_name,
              String enum_value) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEnumSpace. method GetEnumSpace
   *
   * @param     __MIDL_0023 The __MIDL_0023 (in)
   * @return    return value.  An reference to a IMTEnumSpace
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTEnumSpace getEnumSpace  (
              String __MIDL_0023) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * writeNewEnumSpaceWithFileName. method WriteNewEnumSpaceWithFileName
   *
   * @param     file The file (in)
   * @param     enum_space An reference to a IMTEnumSpace (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void writeNewEnumSpaceWithFileName  (
              String file,
              IMTEnumSpace enum_space) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getFQN. method GetFQN
   *
   * @param     enum_space The enum_space (in)
   * @param     enum_name The enum_name (in)
   * @param     enum_value The enum_value (in)
   * @return    return value.  The name
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getFQN  (
              String enum_space,
              String enum_name,
              String enum_value) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * updateEnumSpace. method UpdateEnumSpace
   *
   * @param     enum_space An reference to a IMTEnumSpace (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void updateEnumSpace  (
              IMTEnumSpace enum_space) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEnumSpaces. method GetEnumSpaces
   *
   * @return    return value.  An reference to a IMTEnumSpaceCollection
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTEnumSpaceCollection getEnumSpaces  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * writeNewEnumSpace. method WriteNewEnumSpace
   *
   * @param     enum_space An reference to a IMTEnumSpace (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void writeNewEnumSpace  (
              IMTEnumSpace enum_space) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * validEnumSpace. method ValidEnumSpace
   *
   * @param     name The name (in)
   * @return    return value.  The ret
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int validEnumSpace  (
              String name) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * validEnumType. method ValidEnumType
   *
   * @param     __MIDL_0025 The __MIDL_0025 (in)
   * @param     __MIDL_0026 The __MIDL_0026 (in)
   * @return    return value.  The ret
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int validEnumType  (
              String __MIDL_0025,
              String __MIDL_0026) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEnumType. method GetEnumType
   *
   * @param     enum_space The enum_space (in)
   * @param     enum_type The enum_type (in)
   * @return    return value.  An reference to a IMTEnumType
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTEnumType getEnumType  (
              String enum_space,
              String enum_type) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEnumerators. method GetEnumerators
   *
   * @param     enum_space The enum_space (in)
   * @param     enum_type The enum_type (in)
   * @return    return value.  An reference to a IMTEnumeratorCollection
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTEnumeratorCollection getEnumerators  (
              String enum_space,
              String enum_type) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * initializeFromHost. method InitializeFromHost
   *
   * @param     host The host (in)
   * @param     relative_path The relative_path (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void initializeFromHost  (
              String host,
              String relative_path) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * read. method Read
   *
   * @param     file The file (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void read  (
              String file) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * loadEnumeration. method LoadEnumeration
   *
   * @param     from_file_path The from_file_path (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void loadEnumeration  (
              String from_file_path) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * initializeWithFileName. method InitializeWithFileName
   *
   * @param     master_file_full_path The master_file_full_path (in)
   * @param     host_name A Variant (in, optional, pass null if not required)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void initializeWithFileName  (
              String master_file_full_path,
              Object host_name) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * enumerateFQN. method EnumerateFQN
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void enumerateFQN  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * nextFQN. method NextFQN
   *
   * @return    return value.  The fQN
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String nextFQN  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * fQNCollectionEnd. method FQNCollectionEnd
   *
   * @return    return value.  The ret
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int fQNCollectionEnd  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * fQNCount. method FQNCount
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int fQNCount  () throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IID3ada858d_01c6_11d4_95a0_00b0d025b121 = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IEnumConfigProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "3ada858d-01c6-11d4-95a0-00b0d025b121";
  String DISPID_1_NAME = "initialize";
  String DISPID_2_NAME = "getEnumWithValue";
  String DISPID_3_NAME = "getEnumSpace";
  String DISPID_4_NAME = "writeNewEnumSpaceWithFileName";
  String DISPID_5_NAME = "getFQN";
  String DISPID_6_NAME = "updateEnumSpace";
  String DISPID_7_NAME = "getEnumSpaces";
  String DISPID_8_NAME = "writeNewEnumSpace";
  String DISPID_9_NAME = "validEnumSpace";
  String DISPID_10_NAME = "validEnumType";
  String DISPID_11_NAME = "getEnumType";
  String DISPID_12_NAME = "getEnumerators";
  String DISPID_13_NAME = "initializeFromHost";
  String DISPID_14_NAME = "read";
  String DISPID_15_NAME = "loadEnumeration";
  String DISPID_16_NAME = "initializeWithFileName";
  String DISPID_17_NAME = "enumerateFQN";
  String DISPID_18_NAME = "nextFQN";
  String DISPID_19_NAME = "fQNCollectionEnd";
  String DISPID_20_NAME = "fQNCount";
}
