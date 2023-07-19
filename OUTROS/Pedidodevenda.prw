#include "TOTVS.CH"
#include "fileio.ch"




#Define SALTO CHR(13) + CHR(10)

User Function RFONI01()

	// Local aParam	:= {}
	Local aPergs	:= {}
	Local aRet		:= {}
	Local cArquivo := Space(100)

	aAdd(aPergs,{6,"Selecione o arquivo",cArquivo,"","","",90,.F.,"Arquivo CSV (*.csv) |*.csv"})

	If ParamBox(aPergs,"Caminho",@aRet,,,,,,,"",.T.,.T.)

		If MessageBox("Deseja realizar a importação do Pedido de Compras?","TOTVS",4) ==  6

			Processa({||ImportPC(aRet[1])}, "Importando dados")

		EndIf

	EndIf

Return

Static Function ImportPC(cFile)

	// Local cCaminho := cFile
	Local nPedido := 0
	Local cLinha := ""
	Local aLinha := {}
	Local aItens := {}
	Local aDados := {}
	Local lPrim := .T.
	Local lCabec := .T.
	Local aCabec := {}
	Local aCabecT := {}
	Local nHandle := ""
	Local aLog := {}
	// Local cDoc := ""
	Local cNota := ""
	// Local nHandle := 0
	Local cNomeArq := dtos(dDataBase) + strtran(time(),":", "") + ".TXT"
	Local cArqErro		:= "ERRO_AUTO.TXT"
	Local nX := 0
	Local ny := 0
	Local i  := 0
	Private lMsErroAuto := .F.

	nHandle := FCREATE('C:\TEMP\' + cNomeArq, FC_NORMAL)
	FWrite(nHandle,"LOG DE IMPORTAÇÃO"+SALTO)//Salva no arquivo os nomes dos campos na primeira linha

	If !File(cFile)
		MsgStop("O arquivo " + cFile + " não foi encontrado. A importação será abortada!","[AEST901] - ATENCAO")
		Return
	EndIf

	FT_FUSE(cFile)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	aLinhas:= {}
	While !FT_FEOF()

		IncProc("Lendo arquivo texto...")
		aDados := {}
		cLinha := FT_FREADLN()

		If lPrim
			aHeader := Separa(cLinha,";",.T.)
			lPrim := .F.
			FT_FSKIP()
			Loop
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
			AADD(aLinhas,Separa(cLinha,";",.T.))
			If empty(npedido)

				npedido := VAL(aDados[1][aScan(aHeader,{|x| x =="C7_YNUM" })])

			EndIf
		EndIf

		For nX := 1 to len(aDados)

			//Verifica se o pedido é diferente
			If npedido != VAL(aDados[nX][aScan(aHeader,{|x| x =="C7_YNUM" })])

				cQuery := ""
				cQuery := " SELECT * "
				cQuery += "   FROM " + RETSQLNAME("SC7") + " SC7 "
				cQuery += "  WHERE SC7.D_E_L_E_T_ = ' ' "
				cQuery += "    AND SC7.C7_YNUM = " + cValToChar(nPedido) + " "

				dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "XSC7", .F., .T.)

				If XSC7->(!EOF())

					aCabecT := aClone(aCabec)

					aadd(aCabect,{"C7_NUM" ,XSC7->C7_NUM,Nil})

					MATA120(1,aCabect,aItens,5)

					aCabect := {}

				EndIf

				XSC7->(DBCLOSEAREA())

				MATA120(1,aCabec,aItens,3)

				If lMsErroAuto

					MostraErro( GetSrvProfString("Startpath","") , cArqErro )

					aAdd(Alog, MemoRead(  GetSrvProfString("Startpath","") + '\' + cArqErro ))

				Else

					AADD(aLog,"Pedido:  " + SC7->C7_NUM + " gerado com sucesso. Código sistema legado: " + cValToChar(nPedido))

				EndIf

				aCabec := {}
				aItens := {}
				lCabec := .T.
				lMsErroAuto := .F.
				aLinha := {}
				npedido := VAL(aDados[nX][aScan(aHeader,{|x| x =="C7_YNUM" })])

			EndIf

			If lCabec

				aadd(aCabec,{"C7_EMISSAO" ,dDataBase})
				aadd(aCabec,{"C7_FORNECE" ,aDados[nX][aScan(aHeader,{|x| x == "C7_FORNECE" })]})
				aadd(aCabec,{"C7_LOJA" ,aDados[nX][aScan(aHeader,{|x| x == "C7_LOJA" })]})
				aadd(aCabec,{"C7_COND" ,aDados[nX][aScan(aHeader,{|x| x == "C7_COND" })]})

				aadd(aCabec,{"C7_CONTATO" ,"AUTO"})
				aadd(aCabec,{"C7_FILENT" ,cFilAnt})

				aadd(aLinha,{"C7_PRODUTO" ,aDados[nX][aScan(aHeader,{|x| x =="C7_PRODUTO" })],Nil})
				aadd(aLinha,{"C7_QUANT" ,val(aDados[nX][aScan(aHeader,{|x| x =="C7_QUANT" })]),Nil})
				aadd(aLinha,{"C7_PRECO" ,val(aDados[nX][aScan(aHeader,{|x| x =="C7_PRECO" })]),Nil})
				aadd(aLinha,{"C7_TOTAL" ,val(aDados[nX][aScan(aHeader,{|x| x =="C7_TOTAL" })]),Nil})
				aadd(aLinha,{"C7_TES" ,aDados[nX][aScan(aHeader,{|x| x =="C7_TES" })],Nil})
				aadd(aLinha,{"C7_YNUM" ,VAL(aDados[nX][aScan(aHeader,{|x| x == "C7_YNUM" })]),NIL})
				aadd(aLinha,{"C7_YALIQII" ,VAL(aDados[nX][aScan(aHeader,{|x| x == "C7_YALIQII" })]),NIL})
				aadd(aLinha,{"C7_YVALII" ,VAL(aDados[nX][aScan(aHeader,{|x| x == "C7_YVALII" })]),NIL})

				npedido := VAL(aDados[nX][aScan(aHeader,{|x| x =="C7_YNUM" })])
				cNota := aDados[nX][aScan(aHeader,{|x| x =="CD5_DOC" })]

				aadd(aItens,aLinha)

				lCabec := .F.

			Else

				aadd(aLinha,{"C7_PRODUTO" ,aDados[nX][aScan(aHeader,{|x| x =="C7_PRODUTO" })],Nil})
				aadd(aLinha,{"C7_QUANT" ,val(aDados[nX][aScan(aHeader,{|x| x =="C7_QUANT" })]),Nil})
				aadd(aLinha,{"C7_PRECO" ,val(aDados[nX][aScan(aHeader,{|x| x =="C7_PRECO" })]),Nil})
				aadd(aLinha,{"C7_TOTAL" ,val(aDados[nX][aScan(aHeader,{|x| x =="C7_TOTAL" })]),Nil})
				aadd(aLinha,{"C7_TES" ,aDados[nX][aScan(aHeader,{|x| x =="C7_TES" })],Nil})
				aadd(aLinha,{"C7_YNUM" ,VAL(aDados[nX][aScan(aHeader,{|x| x == "C7_YNUM" })]),NIL})
				aadd(aLinha,{"C7_YALIQII" ,VAL(aDados[nX][aScan(aHeader,{|x| x == "C7_YALIQII" })]),NIL})
				aadd(aLinha,{"C7_YVALII" ,VAL(aDados[nX][aScan(aHeader,{|x| x == "C7_YVALII" })]),NIL})

				aadd(aItens,aLinha)

			EndIf

			aLinha := {}

		next nX

		FT_FSKIP()

	End

	fClose()

	cQuery := ""
	cQuery := " SELECT * "
	cQuery += "   FROM " + RETSQLNAME("SC7") + " SC7 "
	cQuery += "  WHERE SC7.D_E_L_E_T_ = ' ' "
	cQuery += "    AND SC7.C7_YNUM = " + cValToChar(nPedido) + " "

	dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "XSC7", .F., .T.)

	If XSC7->(!EOF())
		aCabecT := aClone(aCabec)
		aadd(aCabect,{"C7_NUM", XSC7->C7_NUM,Nil})
		MATA120(1,aCabect,aItens,5)

		aCabect := {}

		cQuery := " UPDATE " + RetSqlName("CD5")
		cQuery += "    SET D_E_L_E_T_ = '*' "
		cQuery += "  WHERE CD5_FILIAL = '" + XFILIAL("CD5",XSC7->C7_FILIAL) + "' "
		cQuery += "    AND CD5_DOC  = '" + cNota + "' "
		cQuery += "    AND D_E_L_E_T_ <> '*' "

		TCSQLExec(cQuery)

	EndIf

	XSC7->(DBCLOSEAREA())

	MATA120(1,aCabec,aItens,3)

	If lMsErroAuto
		MostraErro( GetSrvProfString("Startpath","") , cArqErro )
		aAdd(Alog, MemoRead(  GetSrvProfString("Startpath","") + '\' + cArqErro ))

	Else
		AADD(aLog,"Pedido:  " + SC7->C7_NUM + " gerado com sucesso. Código sistema legado: " + cValToChar(nPedido))
	EndIf

	for nX := 1 to len(alog)
		FWrite(nHandle,aLog[nX])
	next

	fclose(nHandle)

	For i := 1 To Len(aLinhas)
		DbSelectArea(("CD5"))
		RecLock("CD5",.T.)
		For ny := 1 to len(aHeader)
			If "CD5" $  aHeader[ny]
				If AllTrim(GETSX3CACHE(aHeader[ny],"X3_TIPO")) == 'N'
					&("CD5->"+aHeader[ny]) := val(aLinhas[i][ny])
				ElseIf AllTrim(GETSX3CACHE(aHeader[ny],"X3_TIPO")) == 'D'
					&("CD5->"+aHeader[ny]) := ctod(aLinhas[i][ny]) // Dtos(ctod(aLinhas[i][ny]))
				Else
					&("CD5->"+aHeader[ny]) := aLinhas[i][ny]
				EndIf
			Endif
		Next
		CD5->(MsUnlock())
	Next

	MessageBox("Arquivo " + cNomeArq + " gerado em C:\TEMP\" ,"TOTVS",64)

Return
