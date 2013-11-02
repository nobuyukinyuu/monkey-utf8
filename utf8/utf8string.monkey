'utf8.monkey  -- 2013 Nobuyuki et. al.  (nobu@subsoap.com).
'No warranties expressed or implied. Please see homepage for more details:  
' https://github.com/nobuyukinyuu/monkey-utf8

Import utf8

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
	
	'Summary: Returns a Monkey-compatible string. Astral plane chars are substituted by default.
	Method ToString:String(substitute:Bool = True)
		If Self.chars.Length = 0 Then Return ""
		Local output:String
		For Local i:Int = 0 Until Self.chars.Length
			If substitute
				If Self.chars[i] > $FFFD Then 'invalid char or char's on a different plane
					output += String.FromChar($FFFD)  'Substitution char �
				Else
					output += String.FromChar(chars[i])
				End If
			Else
				output += UTF8.EncodeSurrogatePair(chars[i])
			End If
		Next
				
		 Return output		
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
			
	'Muteable methods.  These change the instance content.
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
	
	'Static methods

	'Note:  Substrings are provided for convenience.  Monkey-style slicing -does- work on arrays.
	Function Substr:UTF8String(chars:Int[], start:Int, len:Int)
		Return New UTF8String(chars[start .. Min(chars.Length(), start + len)])
	End Function
	Function Substr:UTF8String(str:UTF8String)
		Return Substr(str.chars)
	End Function

		
	'TODO:  String operation methods:  f Join, f Split, m Format, f Normalize (Case folding)....
	'TODO:  String comparison methods: m StartsWith, m EndsWith,  Equals (case-in/sensitive)
End Class