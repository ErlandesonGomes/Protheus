#Include "Protheus.Ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"  


/*/{Protheus.doc} RFIN025
Boleto Grafico.
@author  www.compila.com.br
@since 25/08/2017
@version 1.0
/*/
User Function RFIN025(aRECNO, oPrintExt, aRecSE1)

	Local cQuery	:= ""
	Local aDadosBol := {}
	Local aDadosTit := {}
	Local aParam1	:= {} 
	Local cLogErro	:= ""   
	Local oPrintExt
	Local _nNfSusTot := 0
	Local _aRecnoSE1 := {}

	Private aSF2RECNO
	Private oPrint
	Private lRelAuto	:= .F.

	Default aRECNO		:= {}
	Default aRecSE1		:= {}

	aSF2RECNO	:= aRECNO

	IF len(aSF2RECNO) > 0 .OR. Len(aRecSE1) > 0	
		lRelAuto	:= .T.

		oPrint	:=  @oPrintExt
	ENDIF

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� PORTAL DO CLIENTE                                                    �
	//� Adiciona boletos no final do impressao do TMSprinter                 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸     
	IF lRelAuto

		cQuery	:= " SELECT	SE1.E1_FILIAL , SE1.E1_PREFIXO , SE1.E1_NUM , SE1.E1_PARCELA , SE1.E1_TIPO "
		cQuery	+= " FROM "+RetSqlName("SE1")+"	SE1 (NOLOCK) "
		
		IF Len(aRecSE1) > 0
			cQuery	+= " WHERE	SE1.R_E_C_N_O_ IN "+U_omINquery(aRecSE1)
			cQuery	+= " AND	SE1.D_E_L_E_T_	= ''
		ELSE
			//| Garante que Query irar retornar vazia|
			cQuery	+= " WHERE	1 <> 1	= ''		
		ENDIF		

		cQuery	+= " AND	SE1.E1_SALDO > 0 "
		cQuery	+= " ORDER	BY SE1.E1_FILIAL , SE1.E1_PREFIXO , SE1.E1_NUM , SE1.E1_PARCELA , SE1.E1_TIPO "

	ELSEIf	ParamBox( 	{	;
						{1,"Filial De"			,CriaVar("E1_FILIAL",.F.)	,PesqPict("SE1","E1_FILIAL")	,"AllwaysTrue()","SM0",".T.",,.F.}, ;
						{1,"Filial At�"			,CriaVar("E1_FILIAL",.F.)	,PesqPict("SE1","E1_FILIAL")	,"AllwaysTrue()","SM0",".T.",,.F.}, ;
						{1,"Prefixo De"			,CriaVar("E1_PREFIXO",.F.)	,PesqPict("SE1","E1_PREFIXO")	,"AllwaysTrue()","",".T.",,.F.}, ;
						{1,"Prefixo At�"		,CriaVar("E1_PREFIXO",.F.)	,PesqPict("SE1","E1_PREFIXO")	,"AllwaysTrue()","",".T.",,.F.}, ;
						{1,"N�mero De"			,CriaVar("E1_NUM",.F.)		,PesqPict("SE1","E1_NUM")		,"AllwaysTrue()","",".T.",,.F.}, ;
						{1,"N�mero At�"			,CriaVar("E1_NUM",.F.)		,PesqPict("SE1","E1_NUM")		,"AllwaysTrue()","",".T.",,.F.}, ;
						{1,"Cliente De"			,CriaVar("E1_CLIENTE",.F.)	,PesqPict("SE1","E1_CLIENTE")	,"AllwaysTrue()","SA1",".T.",,.F.}, ;
						{1,"Loja De"			,CriaVar("E1_LOJA",.F.)		,PesqPict("SE1","E1_LOJA")		,"AllwaysTrue()","",".T.",,.F.}, ;
						{1,"Cliente At�"		,CriaVar("E1_CLIENTE",.F.)	,PesqPict("SE1","E1_CLIENTE")	,"AllwaysTrue()","SA1",".T.",,.F.}, ;
						{1,"Loja At�"			,CriaVar("E1_LOJA",.F.)		,PesqPict("SE1","E1_LOJA")		,"AllwaysTrue()","",".T.",,.F.}, ;
						{3,"Aceite Sustentavel",1, {"Sim", "Nao"}, 50,'.T.',.T.} ;
						},;
						"Boleto",;              
						@aParam1,,,.T.,,)


		cQuery	:= " SELECT	SE1.E1_FILIAL , SE1.E1_PREFIXO , SE1.E1_NUM , SE1.E1_PARCELA , SE1.E1_TIPO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.R_E_C_N_O_ AS SE1RECNO"
		cQuery	+= " FROM	"+RetSqlName("SE1")+"	SE1 (NOLOCK) "
		If	mv_par01 == mv_par02
			cQuery	+= " WHERE	SE1.E1_FILIAL	= '"+mv_par01+"' "
		Else
			cQuery	+= " WHERE	SE1.E1_FILIAL	BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
		EndIf
		cQuery	+= " AND	SE1.E1_PREFIXO	BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
		cQuery	+= " AND	SE1.E1_NUM		BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
		cQuery	+= " AND	SE1.E1_CLIENTE	BETWEEN '"+mv_par07+"' AND '"+mv_par09+"' "
		cQuery	+= " AND	SE1.E1_LOJA		BETWEEN '"+mv_par08+"' AND '"+mv_par10+"' "
		cQuery	+= " AND	SE1.E1_SALDO	> 0 "
		cQuery	+= " AND	SE1.D_E_L_E_T_	= ''  
		cQuery	+= " ORDER	BY SE1.E1_FILIAL , SE1.E1_PREFIXO , SE1.E1_NUM , SE1.E1_PARCELA , SE1.E1_TIPO "
	ENDIF

	// Paulo da Mata - (COMPILA) - 28/08/12 - Quando pressionada a tecla "Cancelar", a vari�vel "cQuery" est� vazia e a rotina � abortada
	If Empty(cQuery)
		Return()
	EndIf

	If Select("TRSE1") > 0   		
		dbSelectArea("TRSE1")   	
		DbCloseArea()           	
	EndIf           		   		
	

	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRSE1",.F.,.T.)                                                 

	DBSelectArea("TRSE1")
	TRSE1->(DBGoTop()) 

	IF !TRSE1->(Eof())
		While	!TRSE1->(Eof())

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Verifica se ha abatimento.										         �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If 	TRSE1->E1_TIPO $ MVABATIM
				TRSE1->(DBSkip())
				Loop
			EndIf


			aDadosTit := U_OmInfBol(TRSE1->E1_FILIAL,TRSE1->E1_PREFIXO,TRSE1->E1_NUM,TRSE1->E1_PARCELA,TRSE1->E1_TIPO, .T. , .F. ,Nil ,.F.  , @cLogErro , .T. , "1" )

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Inclui os dados do Titulo na matriz aDadosBol.					         �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If	ValType(aDadosTit) == "A" .And. Len(aDadosTit) > 0
				aAdd( aDadosBol , aDadosTit )
			EndIf

			TRSE1->(DBSkip())
		EndDo

		TRSE1->(DBCloseArea())

	Else
	//	MsgInfo("N�o existem titulos em aberto","Boleto")
	EndIf


	If	Len(aDadosBol) <= 0
		Return()
	EndIf

	IF lRelAuto
		fPrintBol(aDadosBol)
	ELSE


		LjMsgRun("Montando Boleto, aguarde...","Boleto Bradesco",{ || fPrintBol(aDadosBol) , CLR_HRED })
	ENDIF	

Return()


/*/{Protheus.doc} fPrintBol
Imprime Boleto Grafico Bradesco.
@version 1.0
/*/
Static Function fPrintBol(aDadosBol)

	Local nI		:= 0
	Local nX		:= 0
	Local aLinhaBol := {}
	Local cFileName		:= "BOL_"+Alltrim(UPPER(cusername))+"_"+dtos(ddatabase)+"_"+SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)+SUBSTR(TIME(), 7, 2) //ALTERA플O THIAGO FERREIRA 02/09/2016 - DIFERENCIAL NOME
	Local nDevice			:= IMP_PDF
	Local lViewPDF		:= .T.
	Local lDisabeSetup	:= .F.


	//Local oPrint	:= TMSPrinter():New( "Boleto Laser" )

	IF !(lRelAuto)
		//oPrint	:= FWMSPrinter():New( "Boleto Laser" )
		oPrint:= FWMSPrinter():New(cFileName, nDevice, , , lDisabeSetup, , , ,, , , lViewPDF,  )
	ENDIF

	For nI := 1 to Len(aDadosBol)

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Armazena a linha da matriz total na aLinhaBol para chamar as funcoes     �
		//� genericas.															     �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		aLinhaBol := aClone(aDadosBol[nI])

		oPrint:StartPage()

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿎abecalho.											                      �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		U_FWOmCabBol(@oPrint,aLinhaBol,10)

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿛ontilhado Separador.								                      �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		U_OmPontBol(@oPrint,590)

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿛rimeira parte.										                      �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		U_FWOmBodyBol(@oPrint,aLinhaBol,650,.T.,.T.)

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿛ontilhado Separador.								                      �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		U_OmPontBol(@oPrint,1690)

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿞egunda parte.										                      �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		U_FWOmBodyBol(@oPrint,aLinhaBol,1750,.T.,.F.,.T.)

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿔pressao do Codigo de Barra.							                      �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		U_FWOmBarBol(@oPrint,aLinhaBol,63.5)

		oPrint:EndPage()     // Finaliza a p�gina

	Next nI

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿗ibera a impress�o.									                      �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	IF !(lRelAuto)
		oPrint:Preview()     // Visualiza antes de imprimir
	ENDIF

Return() 



/*/{Protheus.doc} GERALOG
Geralog
@version 1.0
/*/
Static Function GERALOG(_nNfSusTot)

	Local cFileLog := ""
	Local cPath    := ""

	cFileLog := NomeAutoLog()

	If !cFileLog == Nil
		AutoGrLog("")
		AutoGrLog("---------------------------------------------")
		AutoGrLog("DATABASE...................: "+Dtoc(dDataBase))
		AutoGrLog("DATA.......................: "+Dtoc(MsDate()))
		AutoGrLog("HORA.......................: "+Time())
		AutoGrLog("USU핾IO....................: "+cUserName)
		AutoGrLog("TOTAL H� ENVIAR VIA WF.....: "+cValTochar(_nNfSusTot))
		cFileLog := NomeAutoLog()
		MostraErro(cPath,cFileLog)
	Endif

Return()