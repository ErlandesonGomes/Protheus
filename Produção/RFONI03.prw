#Include 'Protheus.ch'
#include "TOTVS.CH"
#include "fileio.ch"
#include 'rwmake.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

#Define SALTO CHR(13) + CHR(10)

/*/{Protheus.doc} User Function RFONI03
	Importacao de Pedidos de venda. Sistema importa via MSEXECAUTO.
	Caso ja importado anteriormente, sistema exclui e reimporta.
	@type  Function
	@author Compila.com.br
	@history Andre Froes MConsult, 20201214, Encontramos este fonte no FTP no dia de hoje, para analisarmos problemas de importacao em producao.
 Entretando, existem varias situações que indicam que este nao é o fonte atual me produção.
 	@history Andre Froes MConsult, 20201218, incluido apresentacao de mensagem de falha, quando nao for importado. Adicionei FWMsgRun, para apresentacao de processamento.
	/*/
User Function RFONI03()

	// Local aParam	:= {}
	Local aPergs	:= {}
	Local aRet		:= {}
	Local cArquivo := Space(100)
	Private cNomeArq := dtos(dDataBase) + strtran(time(),":", "") + ".TXT"

	aAdd(aPergs,{6,"Selecione o arquivo",cArquivo,"","","",90,.F.,"Arquivo CSV (*.csv) |*.csv"})

	If ParamBox(aPergs,"Caminho",@aRet,,,,,,,"",.T.,.T.)

		If MessageBox("Deseja realizar a importação do Pedido de Vendas?","TOTVS",4) ==  6

			FWMsgRun(,{|| ImportPC2(aRet[1])}, "Aguarde...", "Processando Registros...",.F.)
			
			MessageBox("Arquivo " + cNomeArq + " gerado em C:\." ,"TOTVS",64)

		EndIf

	EndIf

Return

Static Function ImportPC2(cFile)

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
	Local aLog := {}
	// Local cDoc := ""
	Local nHandle := 0
	Local cArqErro		:= "ERRO_AUTO.TXT"
	Local cErro

	Local nX := 1
	//Local cDoc := ""

	Private lMsErroAuto := .F.

	//cDoc := GetSxeNum("SC5","C5_NUM")
	//RollBAckSx8()

	If !File(cFile)
		MsgStop("O arquivo " + cFile + " não foi encontrado. A importação será abortada!","[AEST901] - ATENCAO")
		Return
	EndIf

	FT_FUSE(cFile)
	FT_FGOTOP()

	nHandle := FCREATE('C:\TEMP\' + cNomeArq, FC_NORMAL)
	//Seek(nHandle, 0, FS_END) // Posiciona no fim do arquivo
	FWrite(nHandle,"LOG DE IMPORTAÇÃO"+SALTO)//Salva no arquivo os nomes dos campos na primeira linha

	aDados := {}

	//Ler arquivo e preencher aDados.
	While !FT_FEOF()

		IncProc("Lendo arquivo texto...")
		cLinha := FT_FREADLN()

		If lPrim
			aHeader := Separa(cLinha,";",.T.)
			lPrim := .F.
			FT_FSKIP()
			Loop
		Else
			AADD(aDados,Separa(cLinha,";",.T.))

			If empty(nPedido)

				nPedido := val(aDados[1][aScan(aHeader,{|x| x =="C5_YNUM" })])

			EndIf
		EndIf

		FT_FSKIP()

	End

	fClose()

	//De-Para de aDados para EXECAUTO de Pedido de venda.
	//Se ja existe, exclui para depois reimportar
	For nX := 1 to len(aDados)
		

		If nPedido != val(aDados[nX][aScan(aHeader,{|x| x =="C5_YNUM" })])

			cQuery := ""
			cQuery := " SELECT * "
			cQuery += "   FROM " + RETSQLNAME("SC5") + " SC5 "
			cQuery += "  WHERE SC5.D_E_L_E_T_ = ' ' "
			cQuery += "    AND SC5.C5_YNUM = " + cValToChar(nPedido) + " "

			dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "XSC5", .F., .T.)

			If XSC5->(!EOF())

				aCabecT := aClone(aCabec)

				aadd(aCabect,{"C5_NUM" ,XSC5->C5_NUM,Nil})
				// MATA410(aCabect,aItens,5)
				MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 5)

				aCabect := {}

			EndIf

			XSC5->(DBCLOSEAREA())


			// MATA410(aCabec,aItens,3)
			MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 3)

			If lMsErroAuto

				MostraErro( GetSrvProfString("Startpath","") , cArqErro )

				aAdd(Alog, MemoRead(  GetSrvProfString("Startpath","") + '\' + cArqErro ))

				//MOSTRAERRO()

			Else

				AADD(aLog,"Pedido:  " + SC5->C5_NUM + " gerado com sucesso. Código sistema legado: " + cValToChar(nPedido))

			EndIf

			aCabec := {}
			aItem := {}
			lCabec := .T.
			lMsErroAuto := .F.
			nX:=1

			nPedido := val(aDados[nX][aScan(aHeader,{|x| x =="C5_YNUM" })])

		EndIf

		If lCabec

				/*aadd(aCabec,{"C5_FILIAL",aDados[nX][aScan(aHeader,{|x| x == "C5_FILIAL" })],NIL})
				//aadd(aCabec,{"C5_NUM" ,aDados[nX][aScan(aHeader,{|x| x[1]=="C5_NUM" })],NIL})
				aadd(aCabec,{"C5_NUM" ,soma1(cDoc)})
				aadd(aCabec,{"C5_YNUMP" ,aDados[nX][aScan(aHeader,{|x| x == "C5_YNUMP" })],NIL})
				aadd(aCabec,{"C5_EMISSAO" ,aDados[nX][aScan(aHeader,{|x| x == "C5_EMISSAO" })],NIL})
				aadd(aCabec,{"C5_FORNECE" ,aDados[nX][aScan(aHeader,{|x| x == "C5_FORNECE" })],NIL})
				aadd(aCabec,{"C5_LOJA" ,aDados[nX][aScan(aHeader,{|x| x == "C5_LOJA" })],NIL})
				aadd(aCabec,{"C5_COND" ,aDados[nX][aScan(aHeader,{|x| x == "C5_COND" })],NIL})
				aadd(aCabec,{"C5_CONTATO" ,"AUTO",NIL})
			//aadd(aCabec,{"C5_FILENT" ,aDados[nX][aScan(aHeader,{|x| x[1]=="C5_FILIAL" })],NIL})*/
			
				/*aadd(aCabec,{"C5_FILIAL",aDados[nX][aScan(aHeader,{|x| x == "C5_FILIAL" })],NIL})
				aadd(aCabec,{"C5_EMISSAO" ,dDataBase,NIL})
				aadd(aCabec,{"C5_CLIENTE" ,aDados[nX][aScan(aHeader,{|x| x == "C5_CLIENTE" })],NIL})
				aadd(aCabec,{"C5_LOJACLI" ,aDados[nX][aScan(aHeader,{|x| x == "C5_LOJACLI" })],NIL})
				aadd(aCabec,{"C5_CONDPAG" ,aDados[nX][aScan(aHeader,{|x| x == "C5_CONDPAG" })],NIL})
				aadd(aCabec,{"C5_YNUMP" ,aDados[nX][aScan(aHeader,{|x| x == "C5_YNUMP" })],NIL})
				aadd(aCabec,{"C5_VEND1" ,aDados[nX][aScan(aHeader,{|x| x == "C5_VEND1" })],NIL})
				aadd(aCabec,{"C5_TIPO" ,"N",NIL})
				aadd(aCabec,{"C5_MENNOTA" ,aDados[nX][aScan(aHeader,{|x| x == "C5_MENNOTA" })],NIL})*/
				
				//aadd(aCabec,{"C5_NUM"   ,cDoc,Nil})
				aadd(aCabec,{"C5_FILIAL",aDados[nX][aScan(aHeader,{|x| x == "C5_FILIAL" })],NIL})
				aadd(aCabec,{"C5_TIPO" ,"N",Nil})
				aadd(aCabec,{"C5_EMISSAO" ,dDataBase,NIL})
				aadd(aCabec,{"C5_CLIENTE" ,aDados[nX][aScan(aHeader,{|x| x == "C5_CLIENTE" })],NIL})
				aadd(aCabec,{"C5_LOJACLI" ,aDados[nX][aScan(aHeader,{|x| x == "C5_LOJACLI" })],NIL})
				aadd(aCabec,{"C5_LOJAENT" ,aDados[nX][aScan(aHeader,{|x| x == "C5_LOJACLI" })],NIL})
				aadd(aCabec,{"C5_NATCLI","000001",Nil})
				aadd(aCabec,{"C5_VEND1"   ,aDados[nX][aScan(aHeader,{|x| x == "C5_VEND1" })],NIL})
				aadd(aCabec,{"C5_CONDPAG" ,aDados[nX][aScan(aHeader,{|x| x == "C5_CONDPAG" })],NIL})
				aadd(aCabec,{"C5_MENNOTA" ,aDados[nX][aScan(aHeader,{|x| x == "C5_MENNOTA" })],NIL})
				//aadd(aCabec,{"C5_FRETE" ,aDados[nX][aScan(aHeader,{|x| x == "C5_FRETE" })],NIL})
				aadd(aCabec,{"C5_YNUM" ,val(aDados[nX][aScan(aHeader,{|x| x == "C5_YNUM" })]),NIL})
				aadd(aCabec,{"C5_YPEDCLI" ,aDados[nX][aScan(aHeader,{|x| x == "C5_YPEDCLI" })],NIL})
				aadd(aCabec,{"C5_EMAIL" ,aDados[nX][aScan(aHeader,{|x| x == "C5_EMAIL" })],NIL})
				aadd(aCabec,{"C5_TRANSP" ,aDados[nX][aScan(aHeader,{|x| x == "C5_TRANSP" })],NIL})
				//-----------------------ERLANDESON---------------------------------------------------//
				aadd(aCabec,{"C5_MENPAD" ,aDados[nX][aScan(aHeader,{|x| x == "C5_MENPAD" })],NIL})
				aadd(aCabec,{"C5_TPFRETE" ,aDados[nX][aScan(aHeader,{|x| x == "C5_TPFRETE" })],NIL})
				aadd(aCabec,{"C5_PESOL" ,val(aDados[nX][aScan(aHeader,{|x| x == "C5_PESOL" })]),NIL})
				aadd(aCabec,{"C5_PBRUTO" ,val(aDados[nX][aScan(aHeader,{|x| x == "C5_PBRUTO" })]),NIL})
				aadd(aCabec,{"C5_VOLUME1" ,val(aDados[nX][aScan(aHeader,{|x| x == "C5_VOLUME1" })]),NIL})
				aadd(aCabec,{"C5_ESPECI1" ,aDados[nX][aScan(aHeader,{|x| x == "C5_ESPECI1" })],NIL})
				//--------------------------------------------------------------------------//	
					
				//TODO Pedro, descomenta quando voce tiver no arquivo o codigo da transportadora
				// aadd(aCabec,{"C5_TRANSP" ,aDados[nX][aScan(aHeader,{|x| x == "C5_TRANSP" })],NIL})				
				
				/*
				aadd(aLinha,{"C6_ITEM",StrZero(nX,2),Nil})			
				aadd(aLinha,{"C6_PRODUTO",SB1->B1_COD,Nil})			
				aadd(aLinha,{"C6_QTDVEN",1,Nil})			
				aadd(aLinha,{"C6_PRCVEN",100,Nil})			
				aadd(aLinha,{"C6_PRUNIT",100,Nil})			
				aadd(aLinha,{"C6_VALOR",100,Nil})		
				aadd(aLinha,{"C6_QTDLIB",1,Nil})		
				aadd(aLinha,{"C6_TES","501",Nil})	
				*/

			aadd(aLinha,{"C6_ITEM",StrZero(nX,2),Nil})
			aadd(aLinha,{"C6_PRODUTO" ,aDados[nX][aScan(aHeader,{|x| x =="C6_PRODUTO" })],Nil})
			aadd(aLinha,{"C6_QTDVEN" ,val(aDados[nX][aScan(aHeader,{|x| x =="C6_QTDVEN" })]),Nil})
			aadd(aLinha,{"C6_PRCVEN" ,val(aDados[nX][aScan(aHeader,{|x| x =="C6_PRCVEN" })]),Nil})
			aadd(aLinha,{"C6_PRUNIT" ,val(aDados[nX][aScan(aHeader,{|x| x =="C6_PRCVEN" })]),Nil})
			aadd(aLinha,{"C6_VALOR" ,val(aDados[nX][aScan(aHeader,{|x| x =="C6_VALOR" })]),Nil})
			aadd(aLinha,{"C6_QTDLIB" ,val(aDados[nX][aScan(aHeader,{|x| x =="C6_QTDLIB" })]),Nil})
			aadd(aLinha,{"C6_TES" ,aDados[nX][aScan(aHeader,{|x| x =="C6_TES" })],Nil})
			//-----------------------ERLANDESON---------------------------------------------------//	
				
			aadd(aLinha,{"C6_NUMPCOM" ,aDados[nX][aScan(aHeader,{|x| x =="C6_NUMPCOM" })],Nil})
			aadd(aLinha,{"C6_ITPC" ,aDados[nX][aScan(aHeader,{|x| x =="C6_ITPC" })],Nil})
			//-----------------------ERLANDESON---------------------------------------------------//	
				
			aadd(aItens,aLinha)


			nPedido := val(aDados[nX][aScan(aHeader,{|x| x =="C5_YNUM" })])

			lCabec := .F.

		Else


			/*	aadd(aLinha,{"C6_ITEM",StrZero(nX,2),Nil})	
				aadd(aLinha,{"C6_PRODUTO" ,aDados[nX][aScan(aHeader,{|x| x =="C6_PRODUTO" })],Nil})
				aadd(aLinha,{"C6_QTDVEN" ,val(aDados[nX][aScan(aHeader,{|x| x =="C6_QTDVEN" })]),Nil})
				aadd(aLinha,{"C6_PRCVEN" ,val(aDados[nX][aScan(aHeader,{|x| x =="C6_PRCVEN" })]),Nil})
				aadd(aLinha,{"C6_PRUNIT" ,val(aDados[nX][aScan(aHeader,{|x| x =="C6_PRCVEN" })]),Nil})
				aadd(aLinha,{"C6_VALOR" ,val(aDados[nX][aScan(aHeader,{|x| x =="C6_VALOR" })]),Nil})
				aadd(aLinha,{"C6_QTDLIB" ,val(aDados[nX][aScan(aHeader,{|x| x =="C6_QTDLIB" })]),Nil})
				aadd(aLinha,{"C6_TES" ,aDados[nX][aScan(aHeader,{|x| x =="C6_TES" })],Nil})
				aadd(aCabec,{"C5_EMAIL" ,aDados[nX][aScan(aHeader,{|x| x == "C5_EMAIL" })],NIL})*/
				
				aadd(aLinha,{"C6_ITEM",StrZero(nX,2),Nil})
				aadd(aLinha,{"C6_PRODUTO" ,aDados[nX][aScan(aHeader,{|x| x =="C6_PRODUTO" })],Nil})
				aadd(aLinha,{"C6_QTDVEN" ,val(aDados[nX][aScan(aHeader,{|x| x =="C6_QTDVEN" })]),Nil})
				aadd(aLinha,{"C6_PRCVEN" ,val(aDados[nX][aScan(aHeader,{|x| x =="C6_PRCVEN" })]),Nil})
				aadd(aLinha,{"C6_PRUNIT" ,val(aDados[nX][aScan(aHeader,{|x| x =="C6_PRCVEN" })]),Nil})
				aadd(aLinha,{"C6_VALOR" ,val(aDados[nX][aScan(aHeader,{|x| x =="C6_VALOR" })]),Nil})
				aadd(aLinha,{"C6_QTDLIB" ,val(aDados[nX][aScan(aHeader,{|x| x =="C6_QTDLIB" })]),Nil})
				aadd(aLinha,{"C6_TES" ,aDados[nX][aScan(aHeader,{|x| x =="C6_TES" })],Nil})
				//-----------------------ERLANDESON---------------------------------------------------//	
				aadd(aLinha,{"C6_NUMPCOM" ,aDados[nX][aScan(aHeader,{|x| x =="C6_NUMPCOM" })],Nil})
				aadd(aLinha,{"C6_ITPC" ,aDados[nX][aScan(aHeader,{|x| x =="C6_ITPC" })],Nil})
				
				//-----------------------ERLANDESON---------------------------------------------------//
				aadd(aItens,aLinha)
				
				//Andre Froes, 20201214, retirado nx++ indevido.
				// nX++
			
		EndIf
			aLinha := {}
		
	next nX

	//Cadastra ultimo Pedido de venda remanescente em aDados, se for o caso.
	//Se ja existe, exclui para depois reimportar
	cQuery := ""
	cQuery := " SELECT * "
	cQuery += "   FROM " + RETSQLNAME("SC5") + " SC5 "
	cQuery += "  WHERE SC5.D_E_L_E_T_ = ' ' "
	cQuery += "    AND SC5.C5_YNUM = " + cValToChar(nPedido) + " "
				
	dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "XSC5", .F., .T.)
				
	If XSC5->(!EOF())
	
		aCabecT := aClone(aCabec)
				
		aadd(aCabect,{"C5_NUM" ,XSC5->C5_NUM,Nil})		
			
		// MATA410(aCabect,aItens,5)
		MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 5)
				
	EndIf


	XSC5->(DBCLOSEAREA())
	
	// MATA410(aCabec,aItens,3)
	MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 3)
				
	If lMsErroAuto
		cErro := "Atencao: Pedido nao foi importado. Ao tentar realizar a importacao, o Protheus retornou o seguinte erro:"
		cErro += Chr(13) + Chr(10)
		cErro += Chr(13) + Chr(10)
		
		cErro += MostraErro( GetSrvProfString("Startpath","") , cArqErro )
		aAdd(Alog, MemoRead(  GetSrvProfString("Startpath","") + '\' + cArqErro ))

		aviso("Falha ao importar Pedido de Venda!",cErro,{"Confirmar"},3)
	Else
	
		AADD(aLog,"Pedido:  " + SC5->C5_NUM + " gerado com sucesso. Codigo sistema legado: " + cValToChar(nPedido))
			
	EndIf
	
	//Gerar arquivo de Log.
	for nX := 1 to len(alog)
		FWrite(nHandle,aLog[nX])
	next

	fclose(nHandle)
Return
