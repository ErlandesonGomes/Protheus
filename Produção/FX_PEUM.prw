#Include 'Protheus.ch'

/***********************************************************************************
|----------------------------------------------------------------------------------|
|* Programa   | FX_PEUM                                         Data | 28/06/19 | *|
|----------------------------------------------------------------------------------|   
|* Autor      | 4Fx Soluções em Tecnologia                                        *|
|----------------------------------------------------------------------------------|
|* Utilização | GuardiãoXML                                                       *|
|----------------------------------------------------------------------------------|
|* Descricao  | Ponto de Entrada para tratamento das unidades de medida.          *|
|*            |                                                                   *|
|----------------------------------------------------------------------------------|
***********************************************************************************/

User Function FX_PEUM()

	Local cUmPrd    := Alltrim(PARAMIXB[1])
	Local cSegUmPrd := Alltrim(PARAMIXB[2])
	Local cUmXml    := Alltrim(PARAMIXB[3])

	Local cUmRet := ""

	If UPPER(cUmXml) == "M"

		If cUmPrd == "MT"
			cUmRet := "1"
		ElseIf cSegUmPrd == "MT"
			cUmRet := "2"
		Endif

	ElseIf UPPER(cUmXml) == "PCS"

		If cUmPrd == "UN"
			cUmRet := "1"
		ElseIf cSegUmPrd == "UN"
			cUmRet := "2"
		Endif
		
	ElseIf UPPER(cUmXml) == "TON"

		If cUmPrd == "T"
			cUmRet := "1"
		ElseIf cSegUmPrd == "T"
			cUmRet := "2"
		Endif
		
	ElseIf UPPER(cUmXml) == "TN"

		If cUmPrd == "T"
			cUmRet := "1"
		ElseIf cSegUmPrd == "T"
			cUmRet := "2"
		Endif					
		
	ElseIf UPPER(cUmXml) == "M3V"

		If cUmPrd == "M3"
			cUmRet := "1"
		ElseIf cSegUmPrd == "M3"
			cUmRet := "2"
		Endif					

	ElseIf UPPER(cUmXml) == "UN1"

		If cUmPrd == "UN"
			cUmRet := "1"
		ElseIf cSegUmPrd == "UN"
			cUmRet := "2"
		Endif					

	ElseIf UPPER(cUmXml) == "PC"

		If cUmPrd == "UN"
			cUmRet := "1"
		ElseIf cSegUmPrd == "UN"
			cUmRet := "2"
		Endif		

	ElseIf UPPER(cUmXml) == "UZ"

		If cUmPrd == "UN"
			cUmRet := "1"
		ElseIf cSegUmPrd == "UN"
			cUmRet := "2"
		Endif							

	ElseIf UPPER(cUmXml) == "LT"

		If cUmPrd == "L"
			cUmRet := "1"
		ElseIf cSegUmPrd == "L"
			cUmRet := "2"
		Endif	

	ElseIf UPPER(cUmXml) == "UN"

		If cUmPrd == "PC"
			cUmRet := "1"
		ElseIf cSegUmPrd == "PC"
			cUmRet := "2"
		Endif	

	ElseIf UPPER(cUmXml) == "RL"

		If cUmPrd == "UN"
			cUmRet := "1"
		ElseIf cSegUmPrd == "UN"
			cUmRet := "2"
		Endif			

	Endif	


Return cUmRet

