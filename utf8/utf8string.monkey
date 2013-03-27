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
			
	'Muteable methods
	Method Append:UTF8String(str:String)
		Local start:Int = Self.chars.Length() 'Insertion point for new chars
		Self.chars = Self.chars.Resize(Self.chars.Length + str.Length)

		For Local i:Int = 0 Until str.Length
			Self.chars[start + i] = str[i]
		Next
		Return Self
	End Method
	Method Append:UTF8String(chars:Int[])
		Local start:Int = Self.chars.Length() 'Insertion point for new chars
		Self.chars = Self.chars.Resize(Self.chars.Length + chars.Length)

		For Local i:Int = 0 Until chars.Length
			Self.chars[start + i] = chars[i]
		Next
		Return Self
	End Method
	Method Append:UTF8String(str:UTF8String)
		Append(str.chars)
	End Method

	'TODO:  String operation methods:  Concat, Substr, Find/FindLast, Split, Format....
End Class