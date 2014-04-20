module irrlicht.cpp;

import std.traits;

version(Posix)
    alias wchar_t = dchar;
version(Windows)    
    alias wchar_t = wchar;
    
/// TODO: need to anchor generated strings to not be collected
wchar_t* toCppWString(T)(T str)
    if(isSomeString!T)
{
    wchar_t* innerTransform(T str)
    {
        auto arr = new wchar_t[str.length+1];
        foreach(i, ch; str)
        {
            arr[i] = cast(wchar_t) ch;
        }
        arr[$-1] = '\0';
        return arr.ptr;
    }
    
    static if(is(T == wstring))
    {
        version(Windows)
        {
            return str.ptr;
        } else
        {
            return innerTransform(str);
        }
    }
    else static if(is(T == dstring))
    {
        version(Posix)
        {
            return str.ptr;
        } else
        {
            return innerTransform(str);
        }
    } else
    {
        return innerTransform(str);
    }
}
