module main;

import std.stdio;
import std.regex;
import std.array;
import std.string;
import std.file;
import std.container;

void main(string[] args)
{
//	foreach (string name; dirEntries(".","*.d", SpanMode.depth)) 
//	{ 
//		if (isDir(name))
//		{
//			continue;
//		}
//
//		//formatToDDOC(name);
//		writef("File:%s...",name);
//		formatToDoc(name);
//		writeln("Done");
//	}
		string name = "in.d";
		writef("File:%s...",name);
		formatToDoc(name);
		writeln("Done");

	readln();

}

void formatToDoc(string filename)
{
	auto file = File(filename, "r");

	try
	{
		std.file.remove("out.d");
	}
	catch(Exception ex)
	{
	}

	auto temp = File("out.d","w");
	
//	auto strs = Array!string();
//
//	int i = 0;
//	
//	foreach(line; file.byLine)
//	{
//		strs~= line.idup;
//	}

//	string[] strs = [
//	                 "\t\t//! Sets a new GUI Skin",
//	                 "\t\t/** You can use this to change the appearance of the whole GUI",
//	                 "\t\tEnvironment. You can set one of the built-in skins or implement your",
//	                 "\t\town class derived from IGUISkin and enable it using this method.",
//	                 "\t\t*To set for example the built-in Windows classic skin, use the following",
//	                 "\t\tcode:",
//	                 "\t\t\\code",
//	                 "\t\tgui::IGUISkin* newskin = environment->createSkin(gui::EGST_WINDOWS_CLASSIC);",
//	                 "\t\tenvironment->setSkin(newskin);",
//	                 "\t\tnewskin->drop();",
//	                 "\t\t\\endcode",
//	                 //"\t\t/**Comment",
//	                 "\t\t/**\\param skin New skin to use.*/"
//	                 //"\t\t*/"
//	                 ];

	struct Key
	{
		private string _value = "";

		string value() @property
		{
			return _value;
		}

		void value(string val) @property
		{
			_value=val;
		}

		bool empty() @property
		{
			return _value == "" ? true : false;
		}
	}

	int params = 0;
	bool flag = false;
	//for(int i = 0; i < strs.length; i++)

	foreach(line; file.byLine)
	{
		string str = line.idup;

		str = replace(str, r"//!", "///"); 

		Key tabs = Key(bmatch(str, r"^(\t*)\s*").captures()[1]);

		Key beginKey = Key(bmatch(str, r"\/\*\*").captures()[0]);

		Key endKey = Key(bmatch(str, r"\*\/$").captures()[0]);

		Key starKey = Key(bmatch(str, r"^\s*\t*\s*(\*(?!\/)){0,1}(\/\*\*){0,1}").captures()[1]);

		Key strBody = Key(bmatch(str, r"^\s*\t*\s*(\*(?!\/)){0,1}(\/\*\*){0,1}(.*(?!\*\/))(\*\/){0,1}$").captures()[3]);

		//Key strBody = Key(match(str, r"^\s*\t*\s*\*{0,1}\/*\**\**(.*(?!\*\/))(\*\/){0,1}$").captures[1]);

		if (!endKey.empty && !strBody.empty)
		{
			strBody.value = strBody.value[0..$-2];
		}

		//writefln("[%s][%s][%s][%s][%s]", tabs.value, beginKey.value, starKey.value, strBody.value, endKey.value);

		if(!beginKey.empty)
		{
			flag = true;

			params = 0;

			//writefln("Begin %d",i);
		}

		if (!flag)
		{
			temp.writeln(str);
			continue;
		}

		void parseBody(string str)
		{
			if (!strBody.empty)
			{
				auto m = match(strBody.value, r"\s*(\\param:*){0,1}\s*(\\return:*){0,1}\s*(See\b){0,1}\s*(\\code\b){0,1}\s*(\\endcode\b){0,1}(\\deprecated\b){0,1}(\\note\b){0,1}(.*)");

				auto c = m.captures();

				Key paramKey = Key(c[1]);

				Key returnKey = Key(c[2]);

				Key seeKey = Key(c[3]);

				Key codeKey = Key(c[4]);

				Key endcodeKey = Key(c[5]);

				Key deprKey = Key(c[6]);

				Key noteKey = Key(c[7]);

				Key inBody = Key(c[8]);

				if (!paramKey.empty)
				{
					auto m2 = bmatch(inBody.value, r"(\w+\b){1,1}(:){0,1}(.*)");
					
					auto c2 = m2.captures;
					//c2[0]==hit
					//c2[1]==x,y,z...
					//c3[2]==":"
					//c4[3]=="description"

					params++;

					if (params == 1)
					{
						//strs.insertAfter(tabs.value ~ "* Params:");
						//strs.insertBefore(strs[i..$], tabs.value ~ "* Params:");
						temp.writeln(tabs.value ~ "* Params:");
						//i++;
					}
					
					//str = format("%s* \t%s= %s",tabs.value,c2[1],c2[3]);

					temp.writeln(format("%s* \t%s= %s",tabs.value,c2[1],c2[3]));

//					if (!endKey.empty)
//					{
//						strs.insertInPlace(i + 1, tabs.value ~ "*/");
//						i++;
//					}

					return;
				}
				else if(!returnKey.empty)
				{
					//strs[i]= format("%s* Returns: %s", tabs.value, inBody.value);
					temp.writeln(format("%s* Returns: %s", tabs.value, inBody.value));

//					if (!endKey.empty)
//					{
//						strs.insertInPlace(i + 1, c[1] ~ "*/");
//						i++;
//					}
					return;
				}
				else if(!deprKey.empty)
				{
					temp.writeln(format("%s* Deprecated: %s", tabs.value, inBody.value));
					return;
				}
				else if(!noteKey.empty)
				{
					temp.writeln(format("%s* Note: %s", tabs.value, inBody.value));
					return;
				}
				else if (!seeKey.empty)
				{
					//strs.insertBefore(strs[i..$], tabs.value ~ "* See_Also:");
					temp.writeln(tabs.value ~ "* See_Also:");
					
					//strs[i + 1] = format("%s* \t%s", tabs.value, inBody.value);
					temp.writeln(format("%s* \t%s", tabs.value, inBody.value));
					
//					if (!endKey.empty)
//					{
//						strs.insertInPlace(i + 2, tabs.value ~ "*/");
//						i++;
//					}
					//i++;
					return;
				}
				else if (!codeKey.empty)
				{
					//strs[i] = format("%s* Examples:", tabs.value);
					temp.writeln(format("%s* Examples:", tabs.value));
					
					//strs.insertBefore(strs[i+1..$], format("%s* ------", tabs.value));
					temp.writeln(format("%s* ------", tabs.value));
					
					//i++;
					
					return;
				}
				
				else if (!endcodeKey.empty)
				{
					//strs[i] = format("%s* ------", tabs.value);
					temp.writeln(format("%s* ------", tabs.value));
					
//					if (!endKey.empty)
//					{
//						strs.insertInPlace(i + 1, c[1] ~ "*/");
//						i++;
//					}
					return;
				}

				else if (starKey.empty)
				{
					//strs[i] = format("%s* %s", tabs.value, inBody.value);
					temp.writeln(format("%s* %s", tabs.value, inBody.value));

					return;
				}
				else
				{
					temp.writeln(str);
				}
			}
		}

		if (!beginKey.empty && strBody.empty && endKey.empty)
		{
			temp.writeln(str);
			continue;
		}

		if (!beginKey.empty && !strBody.empty)
		{
			//strs[i] = format("%s/**", tabs.value);
			temp.writeln(format("%s/**", tabs.value));

			//strs.insertBefore(strs[i+1..$], tabs.value ~ strBody.value ~ endKey.value);
			//temp.writeln(tabs.value ~ strBody.value ~ endKey.value);
			parseBody(tabs.value ~ strBody.value ~ endKey.value);

			if (!endKey.empty)
			{
				temp.writefln("%s*/", tabs.value);

				flag = false;
				
				params = 0;
			}
			continue;
		}
		else
		{
			parseBody(str);
		}

		if (!endKey.empty && strBody.empty)
		{
			flag = false;

			params = 0;

			temp.writeln(str);

			//writefln("End %d", i);
		}

		else if (!endKey.empty && !strBody.empty)
		{
			flag = false;
			
			params = 0;

			//strs.insertBefore(strs[i+1..$], tabs.value ~ "*/");

			temp.writeln(tabs.value ~ "*/");

			//i++;

			//writefln("End %d", i);
		}

	}

//	foreach(str; strs)
//	{
//		writeln(str);
//	}

	file.close();

	temp.close();

//	rename(filename, filename~"old");
//
//	file = File(filename, "w");
//
//	foreach(str; strs)
//	{
//		file.writeln(str);
//	}
//
//	file.close();
}

