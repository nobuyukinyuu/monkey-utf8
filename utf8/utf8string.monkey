'utf8.monkey  -- 2013 Nobuyuki et. al.  (nobu@subsoap.com).
'No warranties expressed or implied. Please see homepage for more details:  
' https://github.com/nobuyukinyuu/monkey-utf8

Import utf8
Import mappings

Class UTF8String
	Field chars:Int[]
	
	Method New()
		'chars =[0]
	End Method
	
	'Summary:  Creates a new UTF8String from a monkey-compatible String.
	Method New(str:String)
		Self.chars = Self.chars.Resize(str.Length)
		For Local i:Int = 0 Until str.Length
			Self.chars[i] = str[i]
		Next
	End Method

	'Summary:  Creates a new UTF8String from an array of chars.	
	Method New(chars:Int[])
		Self.chars = chars
	End Method
	
	Method Length:Int()
		Return chars.Length()
	End Method

				
	'Summary:  Muteable method.  This changes the instance content by appending a string to Self.
	Method Append:Void(str:String)
		Local start:Int = Self.chars.Length() 'Insertion point for new chars
		Self.chars = Self.chars.Resize(Self.chars.Length + str.Length)

		For Local i:Int = 0 Until str.Length
			Self.chars[start + i] = str[i]
		Next
	End Method
	Method Append:Void(chars:Int[])
		Local start:Int = Self.chars.Length() 'Insertion point for new chars
		Self.chars = Self.chars.Resize(Self.chars.Length + chars.Length)

		For Local i:Int = 0 Until chars.Length
			Self.chars[start + i] = chars[i]
		Next
	End Method
	Method Append:Void(str:UTF8String)
		Append(str.chars)
	End Method

	'Summary: Returns the index of the first occurance of subString within the current string. -1 if not found.
	Method Find:Int(str:String, startpos:Int = 0)
		If str.Length() = 0 Then Return 0
		If Self.chars.Length() < str.Length() Or startpos > chars.Length() -str.Length() Then Return - 1

		For Local i:Int = startpos To Self.chars.Length() -str.Length()
		
			If str[0] = chars[i] 'we found a match for the first character.  Let's check for a whole string match.
				Local Match:Bool = True
				If str.Length() < 2 Then Return i '1-length chars are good to go

				For Local j:Int = 1 Until str.Length() 'Starts at 1 because we found the first char already.

					If str[j] <> chars[i + j] Then
						Match = False
						Exit 'Early, a char didn't match. Start loop i again.
					End If
				Next
				
				If Match Then Return i  'Found.
			End If
		Next
		
		Return -1  'Not found.
	End Method
	Method Find:Int(str:Int[], startpos:Int = 0)
		If str.Length() = 0 Then Return 0
		If Self.chars.Length() < str.Length() Or startpos > chars.Length() -str.Length() Then Return - 1

		For Local i:Int = startpos To Self.chars.Length() -str.Length()
		
			If str[0] = chars[i] 'we found a match for the first character.  Let's check for a whole string match.
				Local Match:Bool = True
				If str.Length() = 1 Then Return i '1-length chars are good to go

				For Local j:Int = 1 Until str.Length() 'Starts at 1 because we found the first char already.
					If str[j] <> chars[i + j] Then
						Match = False
						Exit 'Early, a char didn't match. Start loop i again.
					End If
				Next
				
				If Match Then Return i  'Found.
			End If
		Next
		
		Return -1  'Not found.	
	End Method
	Method Find:Int(str:UTF8String, startpos:Int = 0)
		Return Find(str.chars, startpos)
	End Method

	'Summary: Returns the index of the last occurance of subString within the current string. -1 if not found.	
	Method FindLast:Int(str:String, startpos:Int = $1fffffff)
		If str.Length() = 0 Then Return chars.Length()
		If startpos >= chars.Length() Then startpos = chars.Length() -1  'Monkey seems to clamp to this
		If Self.chars.Length() < str.Length() Or startpos < str.Length() -1 Then Return - 1
		
		For Local i:Int = Min(startpos, chars.Length - str.Length() -1) To 0 Step - 1
		
			If str[0] = chars[i] 'we found a match for the last character.  Let's check for a whole string match.
				Local Match:Bool = True
				If str.Length() = 1 Then Return i '1-length chars are good to go

				For Local j:Int = 1 Until str.Length()  'Starts at 1 because we found the first char already

					If str[j] <> chars[i + j] Then
						Match = False
						Exit 'Early, a char didn't match. Start loop i again.
					End If
				Next
				
				If Match Then Return i  'Found.
			End If
		Next
		
		Return -1  'Not found.
	End Method
	Method FindLast:Int(str:Int[], startpos:Int = $1fffffff)
		If str.Length() = 0 Then Return chars.Length()
		If startpos >= chars.Length() Then startpos = chars.Length() -1  'Monkey seems to clamp to this
		If Self.chars.Length() < str.Length() Or startpos < str.Length() -1 Then Return - 1
		
		For Local i:Int = Min(startpos, chars.Length - str.Length() -1) To 0 Step - 1
		
			If str[0] = chars[i] 'we found a match for the last character.  Let's check for a whole string match.
				Local Match:Bool = True
				If str.Length() = 1 Then Return i '1-length chars are good to go

				For Local j:Int = 1 Until str.Length()  'Starts at 1 because we found the first char already

					If str[j] <> chars[i + j] Then
						Match = False
						Exit 'Early, a char didn't match. Start loop i again.
					End If
				Next
				
				If Match Then Return i  'Found.
			End If
		Next
		
		Return -1  'Not found.
	
	End Method
	Method FindLast:Int(str:UTF8String, startpos:Int = $1fffffff)
		Return FindLast(str.chars, startpos)
	End Method

	'Summary: Returns true if the current string contains subString.
	Method Contains:Bool(str:UTF8String)
		Local found:Int = Find(str)
		If found >= 0 Then Return True Else Return False
	End Method
	Method Contains:Bool(str:Int[])
		Local found:Int = Find(str)
		If found >= 0 Then Return True Else Return False
	End Method
	Method Contains:Bool(str:String)
		Local found:Int = Find(str)
		If found >= 0 Then Return True Else Return False
	End Method
	
	'Summary:  Replaces all instances of findStr with replaceStr, if found.
	Method Replace:Void(findStr:String, replaceStr:String)
		Local s:= New Stack<Int>
		
		For Local i:Int = 0 To chars.Length() -findStr.Length()
			If replaceStr[0] = chars[i] Then 'first char found.

				For Local j:Int = 1 Until findStr.Length()  'Starts at 1 because we found the first char already
					If str[j] <> chars[i + j] Then
						Match = False
						Exit 'Early, a char didn't match. Start loop i again.
					End If
				Next
				
				If Match Then  'Found.  Push the replace string.

					For Local k:Int = 0 Until replaceStr.Length()
						s.Push(replaceStr[k])
					Next

				Else  'Not found.  Push the original char.
					s.Push(chars[i])				
				End If
				
			Else  'First char not found.  Push the original char.
				s.Push(chars[i])
			End If
		Next
		
		chars = s
	End Method
	Method Replace:Void(findStr:Int[], replaceStr:Int[])
		Local s:= New Stack<Int>
		
		For Local i:Int = 0 To chars.Length() -findStr.Length()
			If replaceStr[0] = chars[i] Then 'first char found.

				For Local j:Int = 1 Until findStr.Length()  'Starts at 1 because we found the first char already
					If str[j] <> chars[i + j] Then
						Match = False
						Exit 'Early, a char didn't match. Start loop i again.
					End If
				Next
				
				If Match Then  'Found.  Push the replace string.

					For Local k:Int = 0 Until replaceStr.Length()
						s.Push(replaceStr[k])
					Next

				Else  'Not found.  Push the original char.
					s.Push(chars[i])				
				End If
				
			Else  'First char not found.  Push the original char.
				s.Push(chars[i])
			End If
		Next
		
		chars = s		
	End Method
	Method Replace:Void(findStr:UTF8String, replaceStr:UTF8String)
		Replace(findStr.chars, replaceStr.chars)
	End Method
					
	'Returns an array of UTF8Strings containing the substrings in the current string separated by delimeter.
	Method Split:UTF8String[] (delimeter:String, ignoreZeroLengthStrings:Bool = False)
		If delimeter.Length = 0  'Split EVERYTHING. (Worst idea! Carryover from Monkey.String.Split())
			Local bits:UTF8String[chars.Length]
			For Local i:Int = 0 Until chars.Length
				bits[i] = New UTF8String([chars[i]])
			Next
			Return bits
		Else
		    Local result:= New Stack<UTF8String>
		    Local start:Int = 0
		    Local pos:Int = Find(delimeter)
			
			'Loop through the string until we can't find the delimeter anymore.
		    While pos >= start
		        If pos > start Or ignoreZeroLengthStrings = False
		            result.Push(New UTF8String(chars[start .. pos]))
		        End If
		        start = pos + delimeter.Length()
		        'result.Push(delimeter)
		        pos = Find(delimeter, start)
		    Wend
		    If start < chars.Length() Or ignoreZeroLengthStrings = False
		        result.Push(New UTF8String(chars[start ..]))
		    End If
		    Return result.ToArray()	
		End If
	End Method
	Method Split:UTF8String[] (delimeter:Int[], ignoreZeroLengthStrings:Bool = False)
		If delimeter.Length = 0  'Split EVERYTHING. (Worst idea! Carryover from Monkey.String.Split())
			Local bits:UTF8String[chars.Length]
			For Local i:Int = 0 Until chars.Length
				bits[i] = New UTF8String([chars[i]])
			Next
			Return bits
		Else
		    Local result:= New Stack<UTF8String>
		    Local start:Int = 0
		    Local pos:Int = Find(delimeter)
			
			'Loop through the string until we can't find the delimeter anymore.
		    While pos >= start
		        If pos > start Or ignoreZeroLengthStrings = False
		            result.Push(New UTF8String(chars[start .. pos]))
		        End If
		        start = pos + delimeter.Length()
		        'result.Push(delimeter)
		        pos = Find(delimeter, start)
		    Wend
		    If start < chars.Length() Or ignoreZeroLengthStrings = False
		        result.Push(New UTF8String(chars[start ..]))
		    End If
		    Return result.ToArray()	
		End If		
	End Method
	Method Split:UTF8String[] (delimeter:UTF8String, ignoreZeroLengthStrings:Bool = False)
		Return Split(delimeter.chars, ignoreZeroLengthStrings)
	End Method

	'Summary:  Returns a folded copy of the string using standard lowercase mapping.
	Method ToLower:UTF8String()
		If Not UTF8CharMappings.initialized Then UTF8CharMappings.Init()

		Local result:Int[chars.Length]
		For Local i:Int = 0 Until chars.Length
			Local swap:Int = UTF8CharMappings.lowercase.Get(chars[i])
			If swap > 0 Then result[i] = swap Else result[i] = chars[i]
		Next
		Return New UTF8String(result)
	End Method
	'Summary:  Returns a folded copy of the string using standard uppercase mapping.
	Method ToUpper:UTF8String()
		If Not UTF8CharMappings.initialized Then UTF8CharMappings.Init()
	
		Local result:Int[chars.Length]
		For Local i:Int = 0 Until chars.Length
			Local swap:Int = UTF8CharMappings.uppercase.Get(chars[i])
			If swap > 0 Then result[i] = swap Else result[i] = chars[i]			
		Next
		Return New UTF8String(result)
	End Method
	'Summary:  Returns a folded copy of the string using title ("Proper") mapping.	
	Method ToTitle:UTF8String()
		If Not UTF8CharMappings.initialized Then UTF8CharMappings.Init()
	
		Local result:Int[chars.Length]
		Local capThis = True
		For Local i:Int = 0 Until chars.Length
			Local swap:Int
			If capThis Then
				swap = UTF8CharMappings.uppercase.Get(chars[i])
				capThis = False
			Else
				swap = UTF8CharMappings.lowercase.Get(chars[i])
			End If
			If swap > 0 Then result[i] = swap Else result[i] = chars[i]
			
			If chars[i] <= 32 Then capThis = True
		Next
		Return New UTF8String(result)
				
	End Method
	
	'Summary: Returns a Monkey-compatible string. Astral plane chars are substituted by default.
	Method ToString:String(substitute:Bool)
		If Self.chars.Length = 0 Then Return ""
		Local output:String
		For Local i:Int = 0 Until Self.chars.Length
			If substitute
				If Self.chars[i] > $FFFD Then 'invalid char or char's on a different plane
					output += String.FromChar(SUBSTITUTE)  'Substitution char �
				Else
					output += String.FromChar(chars[i])
				End If
			Else
				output += UTF8.EncodeSurrogatePair(chars[i])
			End If
		Next
				
		 Return output		
	End Method
	Method ToString:String()  'Autobox method
		Return ToString(True)
	End Method

	'Summary: Returns a string with astrals replaced by codepoints.
	Method ToDebugString:String()
		If Self.chars.Length = 0 Then Return ""
		Local output:String
		For Local i:Int = 0 Until Self.chars.Length
			If Self.chars[i] > $FFFD Then 'invalid char or char's on a different plane
				output += "(" + chars[i] + ")"
			Else
				output += String.FromChar(chars[i])
			End If
		Next
		
		Return output
	End Method
		
	
	'Summary:  Strips control codes from a UTF8String and returns a copy.
	Method Trim:UTF8String()
		Local i:int = 0, i2:int = chars.Length
		While i < i2 And chars[i] <= 32
			i += 1
		Wend
		While i2 > i And chars[i2 - 1] <= 32
			i2 -= 1
		Wend
		Return New UTF8String(chars[i .. i2])
	End Method
				
	'Static methods =====================================
	
	'Note:  Substrings are provided for convenience.  Monkey-style slicing -does- work on arrays.
	Function Substr:UTF8String(str:UTF8String, start:Int, len:Int)
		Return New UTF8String(str.chars[start .. Min(str.chars.Length(), start + len)])
	End Function
	
	'Summary:  Joins multiple UTF8strings together.
	Function Join:UTF8String(bits:UTF8String[])
		'TODO
		Local newLen:Int
		For Local i:Int = 0 Until bits.Length
			newLen += bits[i].chars.Length
		Next
		
		Local newChars:Int[newLen]
		
		Local pos:Int
		For Local i:Int = 0 Until bits.Length
			For Local j:Int = 0 Until bits[i].chars.Length
				newChars[pos] = bits[i].chars[j]
			Next
		Next
		Return New UTF8String(newChars)
	End Function
			
	Const CR = 13
	Const LF = 10
	Const SUBSTITUTE = $FFFD    'Substitution character �
	
	'TODO:  String operation methods:  m Format, f Normalize (Case folding)....
	'TODO:  String comparison methods: m StartsWith, m EndsWith,  Equals (case-in/sensitive)
End Class