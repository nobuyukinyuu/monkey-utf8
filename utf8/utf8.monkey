'utf8.monkey  -- 2013 Nobuyuki et. al.  (nobu@subsoap.com).
'No warranties expressed or implied. Please see homepage for more details:  
' https://github.com/nobuyukinyuu/monkey-utf8

Import utf8string

Import brl.databuffer

Class UTF8
  Protected
	'Mask values for bit pattern of first byte in multi-byte UTF-8 sequences: 
	'  128 - 10xxxxxx - Multibyte Character continuation
	'  192 - 110xxxxx - Latin Characters;    for U+0080 to U+07FF.      2 bytes
	'  224 - 1110xxxx - Most of Plane 0;     for U+0800 to U+FFFF.      3 bytes
	'  240 - 11110xxx - SMP (emoji, etc.);   for U+010000 to U+1FFFFF.  4 bytes
    Global mask:Int[] =[128, 192, 224, 240]
	Const StripContinuingChar:Int = 63  '00111111.  bitwise AND this against a byte to use...

  Public
	'Summary:  Loads a string from a local resource. Optionally converts line feeds.
	Function LoadString:UTF8String(path:String, crlfToLF:Bool = True)
 		Return DecodeString(LoadRaw("monkey://data/" + path), crlfToLF, True)
	End Function

	'Summary: Loads a stream of chars hot and steaming from the computer.  (For experts only)
	Function LoadRaw:Int[] (path:String)
		Local file:DataBuffer = DataBuffer.Load(path)
			Return file.PeekBytes(0)  'Note: brl.DataBuffer says this is Depreciated, but not until PeekString stops using it (!)
	End Function
	
	'Summary:  Takes a raw string of chars and attempts to turn it into a UTF8String.
	Function DecodeString:UTF8String(chars:Int[], crlfToLF:Bool = False, ignoreBOM:Bool = True)
		Local i:Int = 0  'Iterator for utf8 chars
		Local j:Int = 0  'Step iterator / read cursor
		Local output:Int[]    'Output chars
		output = output.Resize(chars.Length)
		
		While j < chars.Length
			Local b:Int = chars[j]  'Get the first byte, let's take a look.
			j += 1 'Move the read cursor ahead
			Local bytesNeeded:Int          'How many more bytes are needed to get the codepoint?
			
			If (b & mask[1]) = mask[1] Then bytesNeeded += 1
			If (b & mask[2]) = mask[2] Then bytesNeeded += 1
			If (b & mask[3]) = mask[3] Then bytesNeeded += 1			

			If bytesNeeded > 0  'We've got a multi-byte character we need to process.
	
				'Create a mask to chop off the leading bits of this first byte. EG: 000xxxxx for 2byte
				'Because shr is arithmetic in Monkey, we should make the MSB zero.
				Local FirstByteMask:Int = 127 shr bytesNeeded '01111111 >> bytesNeeded
				b = b & FirstByteMask  'We now have a clean number.

				For Local k:Int = 0 Until bytesNeeded
					Local b2:Int = chars[j] 'Read in next byte
					 j += 1

					b2 = b2 & StripContinuingChar 'Clean the leading 2 bits.
					b = b Shl 6  'Make room for the next bit sequence.
					b = b | b2   'Insert the next 6 bits
				Next
				
			End If

			If crlfToLF And b = 13  'Convert line feeds so that there's only one char for it.
				'The byte is a cr.  Let's peek one byte ahead to see if it's an lf.
				Local lfMaybe:Int
 				'Don't peek ahead if we're at the end.
 				If j < chars.Length Then lfMaybe = chars[j] Else lfMaybe = 10

				If lfMaybe = 10 Then 'Next char's LF.
					b = lfMaybe 'Set this char to LF
					j += 1  'Move ahead one, to skip the LF in chars[].
				End If
			End If

			'Ignore Byte Order Mark
			If (ignoreBOM And b <> $FEFF) or ( Not ignoreBOM)
				output[i] = b
				i += 1
			End If
		Wend
				
		output = output.Resize(i)  'Clip the char array to the actual length based on our read-in.		
		Return New UTF8String(output)
	End Function
	
	'Summary:  Converts a string of chars containing UTF-16 surrogate pairs into a string of proper codepoints.
	Function DecodeSurrogatePairs:Int[] (chars:Int[])
	'       This function's useful when you're dealing with UTF-16 / UCS-2, like for printing to old terminals.
	'Note:  This code may or may not have endian-ness issues. I don't know. If you run into one, file a bug.
	
		Local j:Int 'output length iterator
		Local output:Int[]
		output = output.Resize(chars.Length)
		
		For Local i:Int = 0 Until chars.Length
			If chars[i] > $D800 And chars[i] < $DBFF  'We found the lead bit for a surrogate pair.
				'Check to make sure the next character is legit.
				If i < chars.Length - 1 Then
					If chars[i + 1] > $DC00 And chars[i + 1] < $DFFF 'We found the tail bit.  Encode.
						Local HighBit:Int = (chars[i] - $D800) shl 10
						Local LowBit:Int = chars[i + 1] - $DC00
						output[j] = (HighBit | LowBit) + $10000
						j += 1
						i += 1  'Skip the next char to check, since it was the tail bit.
					Else; output[i] = $FFFD  'Substitution character.  Next char's not a valid tail.
					End If
				Else; output[i] = $FFFD  'Substitution character. We're at end of string with no matching pair.	
				End If
			Else  'Char's normal.  Let it be.
				output[j] = chars[i]
				j += 1
			End If
		Next
		output = output.Resize(j)  'Trim to the new length.
		Print j + " / " + chars.Length 
		Return output
	End Function
	
	'Summary:  Returns a UTF-16 compatible surrogate pair for the given codepoint. Codepoint MUST exceed $FFFF.
	Function EncodeSurrogatePair:String(codepoint:Int)
		If codepoint > $FFFF
			' 1. 0 x10000 is subtracted from the code point, leaving a 20 bit number in the range 0 .. 0 xFFFFF.
			codepoint -= $10000
  			' 2. The top ten bits (a number in the range 0..0x3FF) are added to 0xD800 to give the first
  			'    code unit or lead surrogate, which will be in the range 0xD800..0xDBFF
			Local leadSurrogate:Int = (codepoint shr 10) + $D800
  			' 3. The low ten bits (also in the range 0..0x3FF) are added to 0xDC00 to give the second code
  			'    unit or trail surrogate, which will be in the range 0xDC00..0xDFFF
  			Local trailSurrogate:Int = (codepoint & $3FF) + $DC00
			
			Return String.FromChar(leadSurrogate) + String.FromChar(trailSurrogate)
					
		Else; Return String.FromChar(codepoint)
		End If
	End Function
End Class


