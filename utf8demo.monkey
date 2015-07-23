#GLFW_WINDOW_TITLE="Monkey UTF-8 Test"

Import utf8

Import mojo
Import AngelFont.angelfont
Import AngelFont.simpletextbox

Function Main:Int()
	New TestApp()
End Function

Class TestApp Extends App
	Field str:UTF8String
	Field af:AngelFont
	
	Field useUTF:Bool
	
	Method OnCreate()
		SetUpdateRate 60

		str = UTF8.LoadString("test.txt", True)

		#If TARGET="html5"
			Print str.ToString(False)
		#Else
			Print str.ToDebugString()
		#End		
		
		af = New AngelFont()
		af.LoadFontXml("yza")

		'Test functions of utf8string.  Change n to String to compare output!
		Local n:= New UTF8String("Oh Noes|Delimiter2|Part3| Part 4!| ||Part7|")
		Print n.FindLast("Oh No", 9999) 'Should print 0
		
		Local parts:= n.Split("|")
		For Local o:= EachIn parts
			Print o
		Next
		Print "Split string parts: " + parts.Length()
		
		n = New UTF8String(" ~n~n  x Trim x  ~n~n ")
		Print n.Trim
		
		'Case folding..
		n = New UTF8String("Let's try case folding!")
		Print n.ToLower()
		Print n.ToUpper()
		Print n.ToTitle()
		
	End Method
	
	Method OnUpdate()
		If KeyHit(KEY_ESCAPE) Then Error("")
		If KeyHit(KEY_SPACE) Then useUTF = Not useUTF
	End Method
	
	Method OnRender()
		Cls
		'af.DrawText(str.ToString, 8, 8)

		AngelFont.current = af  'Set current font
		If useUTF
			SimpleTextBox.Draw(str.chars, DeviceWidth() / 2, 16, DeviceWidth(), AngelFont.ALIGN_CENTER)
		Else 'Use regular, non-utf
			SimpleTextBox.Draw(str.ToString, DeviceWidth() / 2, 16, DeviceWidth(), AngelFont.ALIGN_CENTER)
		End If
				
	End Method
End Class