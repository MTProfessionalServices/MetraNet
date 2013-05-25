          
You can call the MTPipeline::ExamineSession call:

dim myMsix = "<msix><......"
dim session
set session = mtPipeline.ExamineSession myMsix

' get the children
dim child
for each child in session.Children
	...
next

' get the properties from the session:
dim prop
for each prop in session
	dim name, nameID, type
	name = prop.Name
	type = prop.Type
	nameID = prop.NameID
next


// ----------------------------------------------------------------
// Description:   Parse a session out of its XML representation.
//                Return the session as a session object.
// Arguments:     xml - the XML representation of the session
// Return Value:  full MSIX message
// Errors Raised: PIPE_ERR_INVALID_SESSION, if session ID cannot be found.
// ----------------------------------------------------------------
STDMETHODIMP CMTPipeline::ExamineSession(BSTR xml,
																				 /*[out, retval]*/ IMTSession * * session)



