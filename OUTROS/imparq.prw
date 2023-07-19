#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpArq    บAutor  ณ   บ Data ณ     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa de importacao de tabelas                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ImpArq() //U_ImpArq() 

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeclaracao de variaveis                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oWizard
	Local nMetGlob
	Local nMetParc
	Local oRadioArq
	Local nRadioArq	:= 1	
	Local cText
	Local cFile		:= replicate( " ", 80 )
	Local cHeader		:= "Importa็ใo de dados"
	Local cTpArq		:= "Delimitado (*.csv)|*.CSV|"
	Local cDelim		:= AllTrim(SuperGetMV("MV_TPDELI",.F.,';'))
	Local nLinCabec	:= 1 // Padrใo sem linha de cabe็alho
	Local cCabec		:= "" // String com o cabe็alho do arquivo original, se houver
	Local nQtdCab		:= 1 // String com o cabe็alho do arquivo original, se houver
	Local cNmAlias		:= "Clientes (SA1)"
	Local cTipo		:= "1"
	
	Private INCLUI	:= .T.
	Private ALTERA	:= .F.
	
	cText 	:= 	 "Esta rotina tem por objetivo importar registros, atrav้s " + ; 
				 "de um arquivo padrใo CSV (delimitado) , e armazena-los na tabela "+ ; 
				 "correspondente do sistema."+ CRLF + ; 
				 "Os nomes das colunas devem ser os mesmos nomes de campos a serem atualizados."+ CRLF + CRLF + ; 
				 "Ao final da importa็ใo serแ gerado um arquivo de log contendo as "+ ; 
				 "inconsist๊ncias."
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPrimeiro Painel - Abertura     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DEFINE WIZARD oWizard 	TITLE "Import็ใo de dados" ;
								HEADER cHeader ; 
								MESSAGE "Apresenta็ใo." ;
								TEXT cText ;
								NEXT { || .T. } ;
								FINISH {|| .T.} PANEL
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSegundo Painel - Arquivo e Contrato ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		CREATE PANEL oWizard 	HEADER cHeader ;
								MESSAGE "Selecione os tabela que deseja importar" ;
								BACK {|| .T. } ;
								NEXT {|| .T. } ;
								FINISH {|| .F. } ;
								PANEL         
		
		oPanel := oWizard:GetPanel( 2 )
		
		@ 15, 08 GROUP oGrpCon 	TO 120, 230 LABEL "Cadastro a ser importado" OF oPanel PIXEL DESIGN
		     
		/*@ 25,35 Radio oRadioArq Var nRadioArq Items "Clientes (SA1)",;
													"Produtos(SB1)",;													
													3D 	Size 170,10 Of oPanel PIXEL DESIGN ;
													ON CHANGE ImpChgRadio(nRadioArq,@cNmAlias)*/
													
													@ 25,35 Radio oRadioArq Var nRadioArq Items "Clientes (SA1)",;
													"Produtos(SB1)";												
													3D 	Size 170,10 Of oPanel PIXEL DESIGN ;
													ON CHANGE ImpChgRadio(nRadioArq,@cNmAlias)
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSegundo Painel - Arquivo e Contrato ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		CREATE PANEL oWizard 	HEADER cHeader ;
								MESSAGE "Selecione o arquivo para importa็ใo." ;
								BACK {|| .T. } ;
								NEXT {|| ! empty( cDelim ) .and. ! empty( cFile ) } ;
								FINISH {|| .F. } ;
								PANEL         
		
		oPanel := oWizard:GetPanel( 3 )
		
		@ 10, 08 GROUP oGrpCon 	TO 40, 280 LABEL "Selecione um arquivo." ; 
									OF oPanel ;
									PIXEL ;
		     						DESIGN
	
		@ 20, 15 MSGET oArq 	VAR cFile WHEN .F. OF oPanel SIZE 140, 10 PIXEL ;
								MESSAGE "Utilize o botใo ao lado para selecionar" ; 
	
		DEFINE SBUTTON oButArq 	FROM 21, 160 ;
						 			TYPE 14 ;
						 			ACTION cFile := cGetFile(cTpArq, , 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE) ; 
						 			OF oPanel ;
						 			ENABLE
		
		@ 50, 08 GROUP oGrpCon 	TO 130, 280 LABEL "Informe as configura็๕es do arquivo." ; 
									OF oPanel ;
									PIXEL ;
		     						DESIGN
		     
	  	@ 60,20 SAY "Delimitador" OF oPanel SIZE 35,8 PIXEL   
		@ 60,60 MSGET oDelim	VAR cDelim  ;
								PICTURE "@!" ;
								VALID !empty(cDelim) ;
								MESSAGE "Informe um delimitador de campo." ; 
								OF oPanel SIZE 10,8 PIXEL 
	                         	
	  	@ 80,20 SAY "Tipo" OF oPanel SIZE 35,8 PIXEL   
		@ 80,60 COMBOBOX oTipo  Var cTipo ITEMS {"1=Somente Log","2=Log + Importa็ใo"} 	SIZE 200,010 OF oPanel PIXEL  
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณTerceiro Painel - Confirmacao  / Processamento ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		CREATE PANEL oWizard 	HEADER cHeader ;
								MESSAGE "Confirma็ใo dos dados e inํcio de processamento." ; 
								BACK {|| .T. } ;
								NEXT {|| .T. } ;
								FINISH {|| .F. } ;
								PANEL         
								
		oPanel := oWizard:GetPanel( 4 )
	
		@ 010, 010 SAY "Arquivo" OF oPanel SIZE 140, 8 PIXEL   
		@ 010, 050 SAY cFile  OF oPanel SIZE 140, 8 COLOR CLR_HBLUE PIXEL  
		
		@ 030, 010 SAY  "Delimitador" OF oPanel SIZE 140, 8 PIXEL   
		@ 030, 050 SAY  cDelim  OF oPanel SIZE 140, 8 COLOR CLR_HBLUE PIXEL	
	
	
		@ 050, 010 SAY  "Alias" OF oPanel SIZE 140, 8 PIXEL   
		@ 050, 050 SAY  cNmAlias  OF oPanel SIZE 140, 8 COLOR CLR_HBLUE PIXEL	
	
	
		@ 070, 010 SAY  "Tipo Proc.:" OF oPanel SIZE 140, 8 PIXEL   
		@ 070, 050 SAY  IIf(cTipo=="1","Somente Log","Log+Importa็ใo")  OF oPanel SIZE 140, 8 COLOR CLR_HBLUE PIXEL	
	                                      	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuarto Painel - Processamento                  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		CREATE PANEL oWizard 	HEADER cHeader ;
								MESSAGE "Processamento da Importa็ใo." ; 
								BACK {|| .F. } ;
								NEXT {|| .T. } ;
								FINISH {|| .T. } ;
								EXEC {|| CursorWait(), IMPCADPro( oMetGlob, nRadioArq, cFile, cDelim, cTipo ), CursorArrow() } ;
								PANEL 
								        
		oPanel := oWizard:GetPanel( 5 )
	
		@ 25, 30 SAY "Importa็ใo" OF oPanel SIZE 140, 8 PIXEL   
		@ 40, 30 METER oMetGlob 	VAR nMetGlob ;
									TOTAL 100 ;
									SIZE 224,10 OF oPanel PIXEL UPDATE DESIGN ;
									BARCOLOR CLR_BLACK,CLR_WHITE ;
									COLOR CLR_WHITE,CLR_BLACK ;
								 	NOPERCENTAGE 
	
		
	ACTIVATE WIZARD oWizard CENTER
	
Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMPCADPro บAutor  ณCarlos Meneses   บ Data ณ  04/08/2014    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImportacao do arquivo selecionado                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function IMPCADPro( oMetGlob, nRadioArq, cFile, cDelim,cTipo )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local lFirst		:= .T.
	Local cLinha		:= ""
	Local aHeader		:= {}
	Local nHdl			:= 	0
	Local cEnvServ		:= GetEnvServer()
	Local cIniFile		:= GetADV97()
	Local cEnd			:= GetPvProfString(cEnvServ,"StartPath","",cIniFile)   
	Local cDtHr		:= DtoS(dDataBase)+"-"+Substr(time(),1,2)+"-"+Substr(time(),4,2)+"-"+Substr(time(),7,2)
	Local cPath		:= "C:\TEMP\"
	Local cTipoLog		:= "Import_"
	Local cNomeLog		:=	cPath+cTipoLog+cDtHr+"_Log.txt"	
//	Local cArq			:=	cEnd+cNomeLog
	Local cArq	 := cNomeLog              
	Local cLin			:= ""   
	Local cCdAlias		:= ""
	Local nQtReg		:= 0
	Local nQtNOk		:= 0
	Local nQtOk		:= 0
	Local aLog			:= {}
	Local lGrava		:= IIF(cTipo == "2",.T.,.F.)   //Ajuste Camila
	Local cRotina		:= ""
	Local nCont		:= 0
	
	MAKEDIR(cEnd+cPath)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValidacao do arquivo para importacao             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !File(cFile) .OR. Empty(cFile)
		ApMsgStop("Problemas com arquivo informado!")
		RestArea(aArea)
		Return
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณIdentifica Alias de importacao                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Do Case
		Case nRadioArq == 1		// "Clientes (SA1)",;
			cCdAlias	:= "SA1"
			cRotina	:= "MATA030"

		Case nRadioArq == 2		// "Fornecedores (SA2)",;
			cCdAlias	:= "SB1"
			cRotina	:= "MATA010"
	
		Case nRadioArq == 3		// "Contas a Receber - em aberto (SE1)",;
			cCdAlias	:= "SE1"
			cRotina	:= "FINA040"
	
		Case nRadioArq == 4		// "Contas a Pagar - em aberto (SE2)" 
			cCdAlias	:= "SE2"
			cRotina	:= "FINA050"
	
		Case nRadioArq == 5		// "Saldos Iniciais - Estoque (SB9)"
			cCdAlias	:= "CT1"
			cRotina	:= "CTBA020"

		OtherWise
			ApMsgStop("Nao existe tratamento para importa็ใo deste tipo de arquivo!")
			Return
	EndCase
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicia Log                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AAdd(aLog, Replicate( '=', 80 ) )
	AAdd(aLog, 'INICIANDO O LOG - I M P O R T A C A O   D E   D A D O S' )
	AAdd(aLog, Replicate( '-', 80 ) )
	AAdd(aLog, 'DATABASE...........: ' + DtoC( dDataBase ) )
	AAdd(aLog, 'DATA...............: ' + DtoC( Date() ) )
	AAdd(aLog, 'HORA...............: ' + Time() )
	AAdd(aLog, 'ENVIRONMENT........: ' + GetEnvServer() )
	AAdd(aLog, 'PATCH..............: ' + GetSrvProfString( 'StartPath', '' ) )
	AAdd(aLog, 'ROOT...............: ' + GetSrvProfString( 'RootPath', '' ) )
	AAdd(aLog, 'VERSรO.............: ' + GetVersao() )
	AAdd(aLog, 'MำDULO.............: ' + 'SIGA' + cModulo )
	AAdd(aLog, 'EMPRESA / FILIAL...: ' + SM0->M0_CODIGO + '/' + SM0->M0_CODFIL )
	AAdd(aLog, 'NOME EMPRESA.......: ' + Capital( Trim( SM0->M0_NOME ) ) )
	AAdd(aLog, 'NOME FILIAL........: ' + Capital( Trim( SM0->M0_FILIAL ) ) )
	AAdd(aLog, 'USUมRIO............: ' + SubStr( cUsuario, 7, 15 ) )
	AAdd(aLog, 'TABELA IMPORT......: ' + cCdAlias )
	AAdd(aLog, 'ARQUIVO IMPORT.....: ' + cFile )
	AAdd(aLog, 'DELIMITADOR........: ' + cDelim )
	AAdd(aLog, 'MODO PROCESSAMENTO.: ' + IIf(lGrava,"Atualizacao","Simulacao") )
	AAdd(aLog, Replicate( ':', 80 ) )
	AAdd(aLog, '' )
	
	AAdd(aLog, "Import = INICIO - Data "+DtoC(dDataBase)+ " as "+Time() )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLeitura do arquivo                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	FT_FUSE(cFile)
	
	nTot := FT_FLASTREC()
	nAtu := 0
	
	oMetGlob:SetTotal(nTot)
	CursorWait()     
	
	FT_FGOTOP()
	
	While !FT_FEOF()
	
		nAtu++
		oMetGlob:Set(nAtu)
	
		cLinha := LeLinha() //FT_FREADLN()
		
		If Empty(cLinha)
			FT_FSKIP()
			Loop
		EndIf
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณTratamento de colunas                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aCols := {}
		aCols := TrataCols(cLinha,cDelim)
		
		If lFirst
		
			aHeader := aClone(aCols)
			lFirst := .F.
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณValida nomes das colunas                   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cCpos := ImpVldCols(cCdAlias,aHeader)
			
			If !Empty(cCpos)
				ApMsgStop("Problemas na estrutura do arquivo, faltam as seguintes colunas "+cCpos)
				Return
			EndIf
	
		Else
	
			nQtReg++
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณValidacao de campos obrigatorios                     ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cMsg := ImpObrigat(cCdAlias,aCols,aHeader)
			
			If !Empty(cMsg)
				AtuLog("NO MOT: CAMPOS OBRIGATORIOS - REGISTRO IGNORADO - "+cMsg,@aLog,nAtu)
				nQtNOk++
				FT_FSKIP()
				Loop
			EndIf
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณChamada de rotina automatica de inclusao                ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If lGrava
			
				aRet := {}
				aRet := ImpGrava(cCdAlias,cRotina,aCols,aHeader)
				
				If aRet[1]
					nQtOk++
					AtuLog("OK MOT:REGISTRO INCLUIDO"+aRet[2],@aLog,nAtu)
				Else
					AtuLog("NO MOT: PROBLEMAS NA GRAVACAO ROTINA AUTOMATICA - "+cRotina+" - "+aRet[2],@aLog,nAtu)
					nQtNOk++
				EndIF
				
			Else
				nQtOk++
				AtuLog("OK MOT:REGISTRO INCLUIDO",@aLog,nAtu)
			EndIf
			
		EndIf
		
		FT_FSKIP()
		
	End
	
	FT_FUSE()
	
	AAdd(aLog, "Import = Total de Registros = "+ Alltrim(Str(nQtReg)))
	AAdd(aLog, "Import = Registros Nao importados = "+ Alltrim(Str(nQtNOk)))
	AAdd(aLog, "Import = Registros importados = "+ Alltrim(Str(nQtOk)))
	AAdd(aLog, "Import = FIM Data "+DtoC(dDataBase)+ " as "+Time() )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFinaliza arquivo de Log                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nHdl := fCreate(cArq)
	
	If nHdl == -1
		MsgAlert("O arquivo  "+cArq+" nao pode ser criado!","Atencao!")
		fClose(nHdl)
		fErase(cArq)
		RestArea(aArea)
	 	Return()
	EndIf
	
	For nCont := 1 to Len(aLog)
		
		cLin += aLog[nCont] + CHR(13)+CHR(10)
		
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			fClose(nHdl)
		    fErase(cArq)
		    cLin:=""
			RestArea(aArea)
		    Return()
		EndIf
		
		cLin := ""
		
	Next
	
	fClose(nHdl)
	
	ApMsgInfo("Verifique arquivo de log "+cArq)
	
	RestArea(aArea)
	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuLog    บAutor  ณCarlos Meneses   บ Data ณ  04/08/2014    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza Array de Log                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuLog(cMsg,aLog,nAtu)

	AAdd(aLog, " Import = Linha "+StrZero(nAtu,12)+" = "+;
				" LOG = "+cMsg )
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLeLinha   บAutor  ณCarlos Meneses   บ Data ณ  04/08/2014    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento de leitura de linha TXT, principalmente para     บฑฑ
ฑฑบ          ณcasos de ultrapassar 1Kb por linha                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LeLinha()

	Local cLinhaTmp	:= ""
	Local cLinhaM100	:= ""
	
	cLinhaTmp := FT_FReadLN()
	
	If !Empty(cLinhaTmp)
	
		cIdent:= Substr(cLinhaTmp,1,1)
		
		If Len(cLinhaTmp) < 1023
			cLinhaM100 := cLinhaTmp
		Else
		
			cLinAnt	:= cLinhaTmp
			cLinhaM100	+= cLinAnt
			
			Ft_FSkip()
			
			cLinProx := Ft_FReadLN()
			
			If Len(cLinProx) >= 1023 .and. Substr(cLinProx,1,1) <> cIdent
				While Len(cLinProx) >= 1023 .and. Substr(cLinProx,1,1) <> cIdent .and. !Ft_fEof()
					cLinhaM100 += cLinProx
					Ft_FSkip()
					cLinProx := Ft_fReadLn()
					If Len(cLinProx) < 1023 .and. Substr(cLinProx,1,1) <> cIdent
						cLinhaM100 += cLinProx
					Endif
				Enddo
			Else
				cLinhaM100 += cLinProx
			Endif
			
		Endif
		
	Endif

Return(cLinhaM100)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTrataCols บAutor  ณCarlos Meneses   บ Data ณ  04/08/2014    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna array com as colunas da linha informada             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TrataCols(cLinha,cSep)

	Local aRet		:= {}
	Local nPosSep	:= 0
	
	nPosSep	:= At(cSep,cLinha)
	
	While nPosSep <> 0
		AAdd(aRet, SubStr(cLinha,1,nPosSep-1)  )
		cLinha		:= SubStr(cLinha,nPosSep+1)
	 	nPosSep	:= At(cSep,cLinha)
	EndDo
		
	AAdd(aRet, cLinha )
	
Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetCol    บAutor  ณCarlos Meneses   บ Data ณ  04/08/2014    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna conteudo de coluna especifica                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetCol(cCpo,aCols,aHeader)

	Local cRet			:= ""
	Local nPos			:= 0
	Local aSX3Area		:= SX3->(GetArea())
	
	nPos := AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim(cCpo)) })
	
	If !Empty(nPos)
	
		If Upper(AllTrim(aCols[nPos])) <> "NULL"
				
			DbSelectArea("SX3")
			DbSetOrder(2)
		
			If MsSeek(cCpo)
				If SX3->X3_TIPO == "D"
					cRet := StoD(AllTrim(aCols[nPos]))
				ElseIf SX3->X3_TIPO == "N"
					cRet := VAL(STRTRAN(AllTrim(aCols[nPos]),",","."))
				Else
					cRet := PadR(Upper(AllTrim(aCols[nPos])),TamSX3(cCpo)[1])
				EndIf
			Else
				cRet := Upper(AllTrim(aCols[nPos]))
			EndIf
			
		EndIf
		
	EndIf
	
	SX3->(RestArea(aSX3Area))
	
Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpVldColsบAutor  ณCarlos Meneses   บ Data ณ  04/08/2014    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAnalise de colunas obrigatorias para cada alias             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpVldCols(cCdAlias,aHeader)

	Local cRet		:= ""
	Local cFilSA1 	:= ""
	
	Do Case
	
		Case cCdAlias == "SA1"
				
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_COD")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_COD"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_LOJA")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_LOJA"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_PESSOA")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_PESSOA"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_NOME")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_NOME"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_NREDUZ")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_NREDUZ"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_END")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_END"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_CEP")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_CEP"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_DDD")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_DDD"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_TEL")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_TEL"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_TIPO")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_TIPO"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_EST")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_EST"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_COD_MUN")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_COD_MUN"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_MUN")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_MUN"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_BAIRRO")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_BAIRRO"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_PAIS")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_PAIS"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_CGC")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_CGC"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_INSCR")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_INSCR"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_EMAIL")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_EMAIL"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("A1_YCODASS")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"A1_YCODASS"
			EndIf
			
	
		Case cCdAlias == "SB1"
	
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_COD")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"B1_COD"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_DESC")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"B1_DESC"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_TIPO")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"B1_TIPO"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_UM")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"B1_UM"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_LOCPAD")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"B1_LOCPAD"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_GRUPO")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"B1_GRUPO"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_PICM")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"B1_PICM"
			EndIf 
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_IPI")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"B1_IPI"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_POSIPI")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"B1_POSIPI"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_PESO")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"B1_PESO"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("B1_ORIGEM")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"B1_ORIGEM"
			EndIf
	
		Case cCdAlias == "SE1"
	
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_NUM")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"E1_NUM"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_TIPO")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E1_TIPO"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_NATUREZ")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E1_NATUREZ"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_CLIENTE")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E1_CLIENTE"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_LOJA")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E1_LOJA"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_EMISSAO")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E1_EMISSAO"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_VENCTO")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E1_VENCTO"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_VENCREA")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E1_VENCREA"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_VALOR")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E1_VALOR"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E1_VLCRUZ")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E1_VLCRUZ"
			EndIf
	
		Case cCdAlias == "SE2"
	
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_NUM")) })		== 0
				cRet += IIf(Empty(cRet),"","/")+"E2_NUM"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_TIPO")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E2_TIPO"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_NATUREZ")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E2_NATUREZ"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_FORNECE")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E2_FORNECE"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_LOJA")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E2_LOJA"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_EMISSAO")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E2_EMISSAO"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_VENCTO")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E2_VENCTO"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_VENCREA")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E2_VENCREA"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_VALOR")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E2_VALOR"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("E2_VLCRUZ")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"E2_VLCRUZ"
			EndIf
	
		//CAMPOS PARA IMPORTACAO
		Case cCdAlias == "CT1"	

			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("CT1_FILIAL")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"CT1_FILIAL"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("CT1_CONTA")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"CT1_CONTA"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("CT1_DESC01")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"CT1_DESC01"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("CT1_CLASSE")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"CT1_CLASSE"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("CT1_NORMAL")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"CT1_NORMAL"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("CT1_RES")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"CT1_RES"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("CT1_BLOQ")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"CT1_BLOQ"
			EndIf
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("CT1_CTASUP")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"CT1_CTASUP"
			EndIf  
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("CT1_DTEXIS")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"CT1_DTEXIS"
			EndIf 
			If AScan(aHeader,{|x| Upper(AllTrim(x)) == Upper(Alltrim("CT1_NTSPED")) })	== 0
				cRet += IIf(Empty(cRet),"","/")+"CT1_NTSPED"
			EndIf

	EndCase
	
Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpObrigatบAutor  ณCarlos Meneses   บ Data ณ  04/08/2014    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida preenchimento/conteudo de campos obrigatorios        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpObrigat(cCdAlias,aCols,aHeader)

	Local cRet := ""

	Do Case
	
		Case cCdAlias == "SA1"
		
			If Empty(RetCol("A1_LOJA",aCols,aHeader))
				cRet += " / Coluna A1_LOJA esta vazia! "
			EndIf
			If Empty(RetCol("A1_NOME",aCols,aHeader))
				cRet += " / Coluna A1_NOME esta vazia! "
			EndIf
			If Empty(RetCol("A1_NREDUZ",aCols,aHeader))
				cRet += " / Coluna A1_NREDUZ esta vazia! "
			EndIf
			If Empty(RetCol("A1_END",aCols,aHeader))
				cRet += " / Coluna A1_END esta vazia! "
			EndIf
			If Empty(RetCol("A1_TIPO",aCols,aHeader))
				cRet += " / Coluna A1_TIPO esta vazia! "
			EndIf
			If Empty(RetCol("A1_EST",aCols,aHeader))
				cRet += " / Coluna A1_EST esta vazia! "
			EndIf
	
		Case cCdAlias == "SB1"
		
			If Empty(RetCol("B1_COD",aCols,aHeader))
				cRet += " / Coluna B1_COD esta vazia! "
			EndIf
			If Empty(RetCol("B1_DESC",aCols,aHeader))
				cRet += " / Coluna B1_DESC esta vazia! "
			EndIf
			If Empty(RetCol("B1_TIPO",aCols,aHeader))
				cRet += " / Coluna B1_TIPO esta vazia! "
			EndIf
			If Empty(RetCol("B1_UM",aCols,aHeader))
				cRet += " / Coluna B1_UM esta vazia! "
			EndIf
			If Empty(RetCol("B1_LOCPAD",aCols,aHeader))
				cRet += " / Coluna B1_LOCPAD esta vazia! "
			EndIf
			If Empty(RetCol("B1_GRUPO",aCols,aHeader))
				cRet += " / Coluna B1_GRUPO esta vazia! "
			EndIf
			If Empty(RetCol("B1_PESO",aCols,aHeader))
				cRet += " / Coluna B1_PESO esta vazia! "
			EndIf
	
		Case cCdAlias == "SE1"
	
			If Empty(RetCol("E1_NUM",aCols,aHeader))
				cRet += " / Coluna E1_NUM esta vazia! "
			EndIf
			If Empty(RetCol("E1_TIPO",aCols,aHeader))
				cRet += " / Coluna E1_TIPO esta vazia! "
			EndIf
			If Empty(RetCol("E1_NATUREZ",aCols,aHeader))
				cRet += " / Coluna E1_NATUREZ esta vazia! "
			EndIf
			If Empty(RetCol("E1_CLIENTE",aCols,aHeader))
				cRet += " / Coluna E1_CLIENTE esta vazia! "
			EndIf
			If Empty(RetCol("E1_LOJA",aCols,aHeader))
				cRet += " / Coluna E1_LOJA esta vazia! "
			EndIf
			If Empty(RetCol("E1_EMISSAO",aCols,aHeader))
				cRet += " / Coluna E1_EMISSAO esta vazia! "
			EndIf
			If Empty(RetCol("E1_VENCTO",aCols,aHeader))
				cRet += " / Coluna E1_VENCTO esta vazia! "
			EndIf
			If Empty(RetCol("E1_VENCREA",aCols,aHeader))
				cRet += " / Coluna E1_VENCREA esta vazia! "
			EndIf
			If Empty(RetCol("E1_VALOR",aCols,aHeader))
				cRet += " / Coluna E1_VALOR esta vazia! "
			EndIf
			If Empty(RetCol("E1_VLCRUZ",aCols,aHeader))
				cRet += " / Coluna E1_VLCRUZ esta vazia! "
			EndIf
	
		Case cCdAlias == "SE2"
		
			If Empty(RetCol("E2_NUM",aCols,aHeader))
				cRet += " / Coluna E2_NUM esta vazia! "
			EndIf
			If Empty(RetCol("E2_TIPO",aCols,aHeader))
				cRet += " / Coluna E2_TIPO esta vazia! "
			EndIf
			If Empty(RetCol("E2_NATUREZ",aCols,aHeader))
				cRet += " / Coluna E2_NATUREZ esta vazia! "
			EndIf
			If Empty(RetCol("E2_FORNECE",aCols,aHeader))
				cRet += " / Coluna E2_FORNECE esta vazia! "
			EndIf
			If Empty(RetCol("E2_LOJA",aCols,aHeader))
				cRet += " / Coluna E2_LOJA esta vazia! "
			EndIf
			If Empty(RetCol("E2_EMISSAO",aCols,aHeader))
				cRet += " / Coluna E2_EMISSAO esta vazia! "
			EndIf
			If Empty(RetCol("E2_VENCTO",aCols,aHeader))
				cRet += " / Coluna E2_VENCTO esta vazia! "
			EndIf
			If Empty(RetCol("E2_VENCREA",aCols,aHeader))
				cRet += " / Coluna E2_VENCREA esta vazia! "
			EndIf
			If Empty(RetCol("E2_VALOR",aCols,aHeader))
				cRet += " / Coluna E2_VALOR esta vazia! "
			EndIf
			If Empty(RetCol("E2_VLCRUZ",aCols,aHeader))
				cRet += " / Coluna E2_VLCRUZ esta vazia! "
			EndIf
		    
		Case cCdAlias == "CT1"  
		                   
			If Empty(RetCol("CT1_FILIAL",aCols,aHeader))
				cRet += " / Coluna CT1_FILIAL esta vazia! "
			EndIf
			If Empty(RetCol("CT1_CONTA",aCols,aHeader))
				cRet += " / Coluna CT1_CONTA esta vazia! "
			EndIf 
			If Empty(RetCol("CT1_DESC01",aCols,aHeader))
				cRet += " / Coluna CT1_DESC01 esta vazia! "
			EndIf
			If Empty(RetCol("CT1_CLASSE",aCols,aHeader))
				cRet += " / Coluna CT1_CLASSE esta vazia! "
			EndIf
			If Empty(RetCol("CT1_NORMAL",aCols,aHeader))
				cRet += " / Coluna CT1_NORMAL esta vazia! "
			EndIf
			If Empty(RetCol("CT1_RES",aCols,aHeader))
				cRet += " / Coluna CT1_RES esta vazia! "
			EndIf 
			If Empty(RetCol("CT1_BLOQ",aCols,aHeader))
				cRet += " / Coluna CT1_BLOQ esta vazia! "
			EndIf
			If Empty(RetCol("CT1_CTASUP",aCols,aHeader))
				cRet += " / Coluna CT1_CTASUP esta vazia! "
			EndIf
			If Empty(RetCol("CT1_DTEXIS",aCols,aHeader))
				cRet += " / Coluna CT1_DTEXIS esta vazia! "
			EndIf
			If Empty(RetCol("CT1_YCODAN",aCols,aHeader))
				cRet += " / Coluna CT1_YCODAN esta vazia! "
			EndIf
			If Empty(RetCol("CT1_NTSPED",aCols,aHeader))
				cRet += " / Coluna CT1_NTSPED esta vazia! "
			EndIf
	
	EndCase
	
Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpGrava  บAutor  ณCarlos Meneses   บ Data ณ  04/08/2014    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChamada da rotina automatica de gravacao                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpGrava(cCdAlias,cRotina,aCols,aHeader)

	Local nX			:= 0
	Local lOk			:= .F.
	Local cMsg			:= ""
	Local lGeraNumSeq	:= .T.
	Local cArqErro		:= "ERRO_AUTO.TXT"
	Local lTemFilial	:= .F.
	Local cCpoFilial 	:= IIf( SubStr(cCdAlias,1,1) == "S", SubStr(cCdAlias,2,2), cCdAlias) + "_FILIAL"
	Local cFilAlias	:= xFilial(cCdAlias)
	
	Private lMsHelpAuto	:= .T.                                         
	Private lMsErroAuto	:= .F.    
	Private aReg		:= {}
	Private cRotAuto	:= ""
	Private aCab	    := {}
	Private aItens      := {}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta array com os campos do registro                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nX:=1 to Len(aHeader)
	
		AAdd(aReg, {	Upper(Alltrim(aHeader[nX]))					    ,;
						RetCol(Alltrim(aHeader[nX]),aCols,aHeader)	,;
						Nil} )
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se possui campo sequencial informado                       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If cCdAlias == "SA1" .AND. Upper(Alltrim(aHeader[nX])) == "A1_COD" .AND. !Empty(RetCol(Alltrim(aHeader[nX]),aCols,aHeader))
			lGeraNumSeq	:= .F.
		EndIf
		If cCdAlias == "SA2" .AND. Upper(Alltrim(aHeader[nX])) == "A2_COD" .AND. !Empty(RetCol(Alltrim(aHeader[nX]),aCols,aHeader))
			lGeraNumSeq	:= .F.
		EndIf
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se informou filial no arquivo              ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Upper(Alltrim(aHeader[nX])) == cCpoFilial
			lTemFilial := .T.
	    EndIf
	    
	Next
	
	If lGeraNumSeq
		If cCdAlias == "SA1"
			AAdd(aReg, {	"A1_COD"					    ,;
							GetSxeNum("SA1","A1_COD")	,;
							Nil} )
			ConfirmSx8()
		EndIf
		If cCdAlias == "SA2"
			AAdd(aReg, {	"A2_COD"					    ,;
							GetSxeNum("SA2","A2_COD")	,;
							Nil} )
			ConfirmSx8()
		EndIf
	EndIf
	
	If !lTemFilial
		DbSelectArea(cCdAlias)
		AAdd(aReg, {	cCpoFilial					    ,;
						cFilAlias						,;
						Nil} )
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณChamada da rotina automatica                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea(cCdAlias)
	
	IF cRotina	== "MATA010"
	
		cRotAuto := "MSExecAuto({|y,z| "+cRotina+"(Y,z)},aReg,3)"
		&cRotAuto
	
	ELSE
		cRotAuto := "MSExecAuto({|x,y,z| "+cRotina+"(x,y,z)},aReg,3)"
		&cRotAuto
	ENDIF
	
	
	If lMsErroAuto
		MostraErro( GetSrvProfString("Startpath","") , cArqErro )
		cMsg := MemoRead(  GetSrvProfString("Startpath","") + '\' + cArqErro )
	Else
		lOk := .T.
	EndIf
	
Return {lOk, cMsg }


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpChgRadioบAutor ณCarlos Meneses   บ Data ณ  04/08/2014    บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณtratamento de mudanca to tipo de arquivo para importacao    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Totvs                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpChgRadio(nRadioArq,cNmAlias)

	Do Case
		Case nRadioArq == 1		
			cNmAlias := "Clientes (SA1)"
		Case nRadioArq == 2		
			cNmAlias := "Produtos (SB1)"
		Case nRadioArq == 3		 
			cNmAlias := "Contas a Receber - em aberto (SE1)"
		Case nRadioArq == 4		 
			cNmAlias := "Contas a Pagar - em aberto (SE2)" 
		Case nRadioArq == 5
			cNmAlias := "Plano de contas (CT1)"
		OtherWise	
			cNmAlias := "Processamento nao implementado" 
	EndCase

Return
