package com.metratech.pipeline;

/**
 * COM Interface 'IMTNameID'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTNameID Interface</B>'
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
public interface IMTNameID {
  /**
   * getNameID. method GetNameID
   *
   * @param     name The name (in)
   * @return    return value.  The id
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getNameID  (
              String name) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getName. method GetName
   *
   * @param     id The id (in)
   * @return    return value.  The name
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getName  (
              int id) throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IID49a30e80_3eaf_11d2_a1c5_006008c0e24a = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTNameIDProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "49a30e80-3eaf-11d2-a1c5-006008c0e24a";
  String DISPID_1_NAME = "getNameID";
  String DISPID_2_NAME = "getName";
}
