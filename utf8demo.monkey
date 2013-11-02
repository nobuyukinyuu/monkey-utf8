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
	
	Field useUTF:Int = 1
	
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

		'Test functions of utf8string
		Local n:= New UTF8String("Oh Noes")
		Print n.FindLast("Oh No", 9999) 'Should print 0
	End Method
	
	Method OnUpdate()
		If KeyHit(KEY_ESCAPE) Then Error("")
		If KeyHit(KEY_SPACE) Then useUTF = 1 - useUTF
	End Method
	
	Method OnRender()
		Cls
		'af.DrawText(str.ToString, 8, 8)

		AngelFont.current = af  'Set current font
		If useUTF > 0 Then
			SimpleTextBox.Draw(str.chars, DeviceWidth() / 2, 16, DeviceWidth(), AngelFont.ALIGN_CENTER)
		Else 'Use regular, non-utf
			SimpleTextBox.Draw(str.ToString, DeviceWidth() / 2, 16, DeviceWidth(), AngelFont.ALIGN_CENTER)
		End If
				
	End Method
End Class