module irrlicht.io.IXMLWriter;

/// Interface providing methods for making it easier to write XML files.
/**
* This XML Writer writes xml files using in the platform dependent 
* wchar_t format and sets the xml-encoding correspondingly. 
*/
interface IXMLWriter 
{
	/// Writes an xml 1.0 header.
	/**
	* Looks like &lt;?xml version="1.0"?&gt;. This should always
	* be called before writing anything other, because also the text
	* file header for unicode texts is written out with this method. 
	*/
	void writeXMLHeader();

	/// Writes an xml element with maximal 5 attributes like "<foo />" or
	/// &lt;foo optAttr="value" /&gt;.
	/**
	* The element can be empty or not.
	* Params:
	* 	name=  Name of the element
	* 	empty=  Specifies if the element should be empty. Like
	* "<foo />". If You set this to false, something like this is
	* written instead: "<foo>".
	* 	attr1Name=  1st attributes name
	* 	attr1Value=  1st attributes value
	* 	attr2Name=  2nd attributes name
	* 	attr2Value=  2nd attributes value
	* 	attr3Name=  3rd attributes name
	* 	attr3Value=  3rd attributes value
	* 	attr4Name=  4th attributes name
	* 	attr4Value=  4th attributes value
	* 	attr5Name=  5th attributes name
	* 	attr5Value=  5th attributes value 
	*/
	void writeElement(wstring name, bool empty=false,
		wstring attr1Name = "", wstring attr1Value = "",
		wstring attr2Name = "", wstring attr2Value = "",
		wstring attr3Name = "", wstring attr3Value = "",
		wstring attr4Name = "", wstring attr4Value = "",
		wstring attr5Name = "", wstring attr5Value = "");

	/// Writes an xml element with any number of attributes
	void writeElement(wstring name, bool empty,
			const(wstring[]) names, const(wstring[]) values)
	in 
	{
		assert(names.length == values.length);
	}

	/// Writes a comment into the xml file
	void writeComment(wstring comment);

	/// Writes the closing tag for an element. Like "</foo>"
	void writeClosingTag(wstring name);

	/// Writes a text into the file.
	/**
	* All occurrences of special characters such as
	* & (&amp;), < (&lt;), > (&gt;), and " (&quot;) are automaticly
	* replaced. 
	*/
	void writeText(wstring text);

	/// Writes a line break
	void writeLineBreak();
}