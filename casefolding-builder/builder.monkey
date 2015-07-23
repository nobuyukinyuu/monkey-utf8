'The CaseFolding mappings builder creates a source file which generates the table of all current
'Unicode case mappings.  By replacing the CaseFolding.txt file with the latest version 
'from unicode.org and rebuilding this project, an updated mappings.monkey file is generated.
'You may then copy the mappings.monkey file to your utf8 folder.
'												-Nobuyuki (nobu@subsoap.com), 22 July 2015

'NOTE:   Be sure to build using C++_Tool !
Import brl.filestream

Import "CaseFolding.txt"
Import "template.txt"

Const OUTPUT_PATH:String = "../../mappings.monkey"  'NASTY hack. C++_Tool targe needs to copy included files somehow!
Const CASEFOLDING_PATH:String = "../../CaseFolding.txt"
Const TEMPLATE_PATH:String = "../../template.txt"

Function Main:Int()
	Print("Generating mappings....")
	Local folding_file:FileStream = FileStream.Open(CASEFOLDING_PATH, "r")
	Local chars:= New Stack<FoldingEquivalents>

	'Get version info.
	Local versionInfo:String[2]
	versionInfo[0] = folding_file.ReadLine()
	versionInfo[1] = folding_file.ReadLine()
	
	
	'Get the mappings.
	While folding_file.Eof = 0
		Local line:String = folding_file.ReadLine()
		'Skip comments.
		If line.StartsWith("#") Then Continue
		
		'Get the mapping for this character.
		Local bits:String[] = line.Trim.Split(";")

		If bits.Length < 4 Then Continue  'Skip blank and malformed lines.
				
		'Our script currently does simple case folding only.  Feel free to submit a patch...
		If Not (bits[1].Trim() = "C" Or bits[1].Trim() = "S") Then Continue
		


		Local p:= New FoldingEquivalents()   'Object prototype
		p.code = HexBEToDec(bits[0].Trim())
		p.status = bits[1].Trim()
		p.mapping = HexBEToDec(bits[2].Trim())   'Change me to split by space delimeters if using full case folding...
		p.name = bits[3].Replace(" # ", "").Trim()
			
		chars.Push(p)
	Wend
	folding_file.Close()

	
	'Now, let's open up the template monkey file and inject the pairs.	
	Local template:FileStream = FileStream.Open(TEMPLATE_PATH, "r")
	Local output:FileStream = FileStream.Open(OUTPUT_PATH, "w")
	If output = Null Then Error("Error saving to " + OUTPUT_PATH)	
			
	While template.Eof = 0
		Local line:String = template.ReadLine()
		
		If line.StartsWith("{MAPPINGS}") 'Write the mapping here!
			For Local o:FoldingEquivalents = EachIn chars
				output.WriteLine("~t~tlowercase.Add(" + o.code + ", " + o.mapping + ")" + "~t'" + o.name)
				output.WriteLine("~t~tuppercase.Add(" + o.mapping + ", " + o.code + ")")
			Next
		ElseIf line.StartsWith("{INFO}")
			output.WriteLine("'" + versionInfo[0])
			output.WriteLine("'" + versionInfo[1])
		Else 'Write from the template.
			output.WriteLine(line)
		End If
	Wend
	
	
	Print("Mappings built.")
	Return 0
End Function


'Summary:  Provides data for a folding equivalent.
Class FoldingEquivalents
	Field name:String   'Proper name
	Field code:Int      'Codepoint for original character
	Field mapping:Int   'Mapping for the codepoint
	Field status:String 'Char determining the status type of the mapping.  See CaseFolding.txt for details.
End Class



'HexToDec code ripped from Goodlookinguy.  More information:
'http://www.nrgs.org/2030/the-fastestquickest-hex-to-dec-and-dec-to-hex/
'http://www.monkey-x.com/Community/posts.php?topic=8247&post=83171
Function HexBEToDec:Int(hex:String)
	Local a1, a2, b1, b2, c1, c2, d1, d2, len, off
	len = hex.Length ' assuming 8 is the max without having to clamp
	off = 8 - len
	
	If len < 1 Then a1 = 0 Else a1 = hex[7 - off] - 48
	If len < 2 Then a2 = 0 Else a2 = hex[6 - off] - 48
	If len < 3 Then b1 = 0 Else b1 = hex[5 - off] - 48
	If len < 4 Then b2 = 0 Else b2 = hex[4 - off] - 48
	If len < 5 Then c1 = 0 Else c1 = hex[3 - off] - 48
	If len < 6 Then c2 = 0 Else c2 = hex[2 - off] - 48
	If len < 7 Then d1 = 0 Else d1 = hex[1 - off] - 48
	If len < 8 Then d2 = 0 Else d2 = hex[0] - 48
	
	If a1 > 9 Then a1 = a1 - 7 - (a1 / 48 * 32)
	If a2 > 9 Then a2 = a2 - 7 - (a2 / 48 * 32)
	If b1 > 9 Then b1 = b1 - 7 - (b1 / 48 * 32)
	If b2 > 9 Then b2 = b2 - 7 - (b2 / 48 * 32)
	If c1 > 9 Then c1 = c1 - 7 - (c1 / 48 * 32)
	If c2 > 9 Then c2 = c2 - 7 - (c2 / 48 * 32)
	If d1 > 9 Then d1 = d1 - 7 - (d1 / 48 * 32)
	If d2 > 9 Then d2 = d2 - 7 - (d2 / 48 * 32)
	
	Return a1 | (a2 Shl 4) | (b1 Shl 8) | (b2 Shl 12) | (c1 Shl 16) | (c2 Shl 20) | (d1 Shl 24) | (d2 Shl 28)
End