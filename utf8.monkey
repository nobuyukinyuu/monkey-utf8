'utf8.monkey  -- 2013 Nobuyuki et. al.  (nobu@subsoap.com).
'No warranties expressed or implied. Please see homepage for more details:  
' https://github.com/nobuyukinyuu/monkey-utf8

Import brl.filestream

Class UTF8
	'Mask values for bit pattern of first byte in multi-byte UTF-8 sequences: 
	'  128 - 10xxxxxx - Multibyte Character continuation
	'  192 - 110xxxxx - Latin Characters;    for U+0080 to U+07FF.      2 bytes
	'  224 - 1110xxxx - Most of Plane 0;     for U+0800 to U+FFFF.      3 bytes
	'  240 - 11110xxx - SMP (emoji, etc.);   for U+010000 to U+1FFFFF.  4 bytes
    Global mask:Int[] =[128, 192, 224, 240]
	Const StripContinuingChar:Int = 63  '00111111.  bitwise AND this against a byte to use...
	
	Function LoadString:UTF8String(path:String, crlfToLF:Bool = False)
		Local file:FileStream = New FileStream("monkey://data/" + path, "r")
		Local chars:Int[]
		chars = chars.Resize(file.Length)

		Local i:Int = 0  'Iterator
		While file.Eof = 0
			Local b:Int = file.ReadByte()  'Get the first byte, let's take a look.
			Local bytesNeeded:Int          'How many more bytes are needed to get the codepoint?
			
			If (b & mask[1]) = mask[1] Then bytesNeeded += 1
			If (b & mask[2]) = mask[2] Then bytesNeeded += 1
			If (b & mask[3]) = mask[3] Then bytesNeeded += 1

			'Print "byte 1: " + b + ". bytesNeeded " + bytesNeeded
			

			If bytesNeeded > 0  'We've got a multi-byte character we need to process.
	
				'Create a mask to chop off the leading bits of this first byte. EG: 000xxxxx for 2byte
				Local FirstByteMask:Int = 127 shr bytesNeeded '01111111 >> bytesNeeded
				b = b & FirstByteMask  'We now have a clean number.

				For Local j:Int = 0 Until bytesNeeded
					Local b2:Int = file.ReadByte()
					'Print "byte " + (j + 2) + ": " + b2
					b2 = b2 & StripContinuingChar 'Clean the leading 2 bits.
					b = b Shl 6  'Make room for the next bit sequence.
					b = b | b2   'Insert the next 6 bits
				Next
				
			End If

			If crlfToLF And b = 13  'Convert line feeds so that there's only one char for it.
				'The byte is a cr.  Let's peek one byte ahead to see if it's an lf.
				Local pos:Int = file.Position
				Local lfMaybe:Int = file.ReadByte()
				If lfMaybe = 10 Then b = lfMaybe Else file.Seek(pos)
			End If

			
			If b <> $FEFF  'Ignore Byte Order Mark
				chars[i] = b
				i += 1
			End If			
			
		Wend
				
		file.Close()
		chars = chars.Resize(i)  'Clip the char array to the actual length based on our read-in.		
		Return New UTF8String(chars)
	End Function
	
	Function LoadRaw:UTF8String(path:String)
		Local file:FileStream = New FileStream("monkey://data/" + path, "r")
		Local chars:Int[]
		chars = chars.Resize(file.Length)

		For Local i:Int = 0 Until chars.Length
			chars[i] = file.ReadByte()
		Next
		
		file.Close()
		Return New UTF8String(chars)
	End Function
End Class

Class UTF8String
	Field chars:Int[]
	
	Method New()
		'chars =[0]
	End Method
	
	'Summary:  Creates a new UTF8String from a monkey-compatible String.
	Method New(str:String)
		chars = chars.Resize(str.Length)
		For Local i:Int = 0 Until str.Length
			chars[i] = str[i]
		Next
	End Method

	'Summary:  Creates a new UTF8String from an array of chars.	
	Method New(chars:Int[])
		Self.chars = chars
	End Method
	
	Method ToString:String()  'Returns a Monkey-compatible string. Astral plane chars are substituted.
		If chars.Length = 0 Then Return ""
		Local output:String
		For Local i:Int = 0 Until chars.Length
			If chars[i] > $FFFD Then 'invalid char or char's on a different plane
				output += String.FromChar($FFFD)  'Substitution char �
				
			Else
				output += String.FromChar(chars[i])
			End If
		Next
		
		Return output
	End Method
		
	'TODO:  String operation methods:  Concat, Substr, Find/FindLast, Split, Format....
End Class
