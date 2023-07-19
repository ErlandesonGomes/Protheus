#Include "Protheus.Ch"
#Include "rwmake.ch"  
#include 'fileio.ch'
#include 'report.ch'
#Include "RPTDEF.CH"

#DEFINE EOL		CHR(13)+CHR(10)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Augusto Ribeiro     º Data ³ 09/02/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcaoes Genericas utilizadas na Publicacao dos arquivos   º±±
±±º          ³do portal                                                   º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³omGerPdf  ºAutor  ³Augusto Ribeiro     º Data ³ 09/02/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime relatório em PDF                                    º±±
±±º          ³ *ATENCAO* - Necessario que o Action do rel. seja uma       º±±
±±º          ³User Function                                               º±±
±±º          ³                                                            º±±
±±ºPARAMETROS³ oPrint      : Objeto do relatorio                          º±±
±±º          ³ cPathName   : Caminho onde o PDF sera gerado               º±±
±±º          ³ cNomeArq    : Nome do Arquivo                              º±±
±±º          ³ cTipoRel    : Tipo de Relatorio TReport ou TMSPriter       º±±
±±º          ³ cPDFPrinter : Nome da Impressora PDF utilizada             º±±
±±º          ³              Suporte *PDF995 ou CompilaPDF                 º±±
±±º          ³                                                            º±±
±±ºRETORNO   ³ aRet{lRelOK, cLOG_ERRO, P05_STATUS}                        º±±
±±º          ³ 1=Nao Processado;2=Processado;3=Inconsistencia;4=Desconsid º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Zatix.	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function omGerPdf(oPrint, cPathName, cNomeArq, cPathServer,cTipoRel, cPDFPrinter, lPrintSrv)
Local aChkFile 		:= {}
Local cArqIniPdf		:= ""
Local nOutFile		:= 0
Local cPrintPadrao	:= ""
Local aRet				:= {.F., "","3"}
Local cSession		:= GetPrinterSession()     
Local nY				:= 0
Local nTimeOut		:= 600 	//| Segundos
Local cTempPath		:= ""
Local cTempExt		:= "pd_"

Local lPDFPrint    	:= .F. 
Local aPriters      

Local cPSConvert


Default lPrintSrv	:= .T.
Default cTipoRel	:= "TReport"   
Default cPathServer	:= cPathName
Default cPDFPrinter	:= "PDF995"

Private nHdlSemaf		:= 0	//| Semaforo
        
cTipoRel	:= UPPER(ALLTRIM(cTipoRel))			
cPDFPrinter	:= UPPER(cPDFPrinter)

	CONOUT("********| INICIO - omGerPdf - "+cPathName)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a impressora está instalada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPriters		:= GetImpWindows(lPrintSrv)
For nY	:= 1 to LEN(aPriters) 
	IF upper(alltrim(aPriters[nY])) == cPDFPrinter
		lPDFPrint	:= .T.  
		exit
	ENDIF	
Next nY     
       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura Impressora PDF ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lPDFPrint
	IF cPDFPrinter == "PDF995"
		lPDFPrint := PDF995("A", nTimeOut, cPathName, cNomeArq)	
	
	ELSEIF cPDFPrinter == "COMPILAPDF"
	                                                               
		lPDFPrint := COMPILAPDF("A", nTimeOut, cPathName, cNomeArq, cPathServer, @nHdlSemaf)
	       
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fecha semaforo caso esteja aberto ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF !(lPDFPrint) .AND. nHdlSemaf > 0
			FechaSemaf(nHdlSemaf)
		ENDIF
	ENDIF                      
ENDIF

IF lPDFPrint                 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guarda impressao padrao.									         	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    //cPrintPadrao := GetProfString( cSession, "DEFAULT","",.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seta impressora de PDF como padrao.							         	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	WriteProfString( cSession , "DEFAULT", cPDFPrinter, .T. )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define impressao Local no Client.							         	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lPrintSrv
		IF ALLTRIM(GetClientIP()) == ALLTRIM(GetServerIP())		
			WriteProfString( cSession , "LOCAL", "CLIENT", .T. )
		ELSE
			WriteProfString( cSession , "LOCAL", "SERVER", .T. )
		ENDIF
	else
		WriteProfString( cSession , "LOCAL", "CLIENT", .T. )
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define impressora com  orientacao do relatorio	   	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF oPrint:GetOrientation() == 1
//		WriteProfString( cSession , "ORIENTATION", "PORTRAIT", .T. )
	ELSE
//		WriteProfString( cSession , "ORIENTATION", "LANDSCAPE", .T. ) 
	ENDIF
	

	IF cTipoRel == "TREPORT"			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dispara impressao do Relatorio  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		oPrint:SetEnvironment("SERVER")	//| {"SERVER","CLIENT"}
		oPrint:SetDevice("SPOOL")		//| {"FILE","SPOOL","PORT","EMAIL"}						
		oPrint:SetPreview(.F.) 
		oPrint:lParamPage	:= .F.	 
		
		oPrint:Print()	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Evita gerar arquivo com o mesmo nome.						         	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		nOutPrinting	:= 0
		While oPrint:Printing()
			Sleep(250)	//| 0,25 Segundos  
			nOutPrinting++
			CONOUT("********| Printing "+alltrim(str(nOutPrinting))) 
			IF nOutPrinting >= 200
				EXIT
			ENDIF
		ENDDO
        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o arquivo impresso está vazio ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        IF oPrint:NXLSROW <= 3
	        aRet	:= {.F., "Nao ha dados a serem exibidos.", "4"}
        ELSE             
	        aRet	:= {.T.,"","2"}
	   		Sleep(500)	//| 0,5 Segundos
	 	ENDIF
   		
	ELSEIF cTipoRel == "TMSPRINTER"
	
		oPrint:Print()		
		aRet	:= {.T.,"","2"}

		Sleep(3000)	//| 1 Segundos        
	ENDIF		                                            		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aguarda Termino da impressao do relatorio e fecha configuração da Impressora ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF cPDFPrinter == "PDF995"
		IF aRet[1]
			lPDFPrint := PDF995("F", nTimeOut, cPathName, cNomeArq)	
		ELSE                                                        
			PDF995("F", nTimeOut, cPathName, cNomeArq)			
		ENDIF	
		//Verificando se foi criado o arquivo PDF
		aRet[1] := FILE(cPathName+cNomeArq)
	ELSEIF cPDFPrinter == "COMPILAPDF"				                                                               
		IF aRet[1]
			aRet[1] := COMPILAPDF("F", nTimeOut, cPathServer, cNomeArq, cPathServer, @nHdlSemaf)
			IF !(aRet[1])
				aRet[3]	:= "3"
			ENDIF
		ELSE                                                                                     
			COMPILAPDF("F", nTimeOut, cPathServer, cNomeArq, cPathServer, @nHdlSemaf)		
		ENDIF
	ENDIF
	
	
/*------------------------------------------------------------|  Augusto Ribeiro - 06/05/2015
	Utiliza impressora do Protheus  
-------------------------------------------------------------------------------------------*/
ELSEIF cPDFPrinter == "PROTHEUS"

		cTempPath	:= GetTempPath()+"totvsprinter\"
		
		/*------------------------------------------------------------|  Augusto Ribeiro - 08/05/2015
			Necessario trocar a extencao do arquivo para evitar que o TotvsPrinter
			abra o arquivo apos impressao.
		-------------------------------------------------------------------------------------------*/
		cTempNome	:= LEFT(cNomeArq,LEN(cNomeArq)-3)+cTempExt

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dispara impressao do Relatorio  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		oPrint:SetEnvironment("CLIENT")	//| {"SERVER","CLIENT"}
		oPrint:nDevice := 6
		oPrint:SetPreview(.F.)
		 
		oPrint:lParamPage	:= .F.	 
		oPrint:nColSpace	:= 0
		//oPrint:cDIR		:= cPathName
		oPrint:cFile		:= cTempNome
		
		//oPrint:cPathPDF		:= "e:\temp\teste_augusto"

		
		//File2Printer("e:\temp\teste_augusto.pd_", "PDF")
		oPrint:Print(.f.)	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Evita gerar arquivo com o mesmo nome.						         	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		nOutPrinting	:= 0
		While oPrint:Printing()
			Sleep(250)	//| 0,25 Segundos  
			nOutPrinting++
			CONOUT("********| Printing "+alltrim(str(nOutPrinting))) 
			IF nOutPrinting >= 200
				EXIT
			ENDIF
		ENDDO
        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o arquivo impresso está vazio ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        IF oPrint:NXLSROW <= 3
	        aRet	:= {.F., "Nao ha dados a serem exibidos.", "4"}
        ELSE             
	       aRet	:= {.T.,"","2"}
			
			IF FILE(cTempPath+cTempNome+"."+cTempExt)	       
     
	       	__CopyFile(cTempPath+cTempNome+"."+cTempExt, cPathName+cNomeArq)
	       	
	       	FERASE(cTempPath+cTempNome+"."+cTempExt)
	       	FERASE(cTempPath+cTempNome+".rel")
	       	FERASE(cTempPath+cNomeArq)	       	
	       	
	       ELSE
	       	aRet	:= {.F., "Arquivo PDF nao encontrado.", "3"}
	       ENDIF

	   		//Sleep(500)	//| 0,5 Segundos
	 	ENDIF
	

ELSE
//	MSGBOX("Impressora PDF não encontrada - (PDF995 ou CompilaPDF)"+EOL+"Entre em contato com o TI.", "Impressora PDF não instalada", "ALERT")
	Conout("**ERRO**| Impressora PDF não encontrada - (PDF995 ou CompilaPDF)")
ENDIF  

CONOUT("********| FIM - omGerPdf - "+cPathName)
 
Return(aRet)   
                

                              
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PDF995   ºAutor  ³Augusto Ribeiro     º Data ³ 09/02/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Parametriza Impressora PDF995                              º±±
±±º          ³                                                            º±±
±±ºPARAMETROS³ cAcao   : A = Abre Configuracao, F = Fecha Configuracao    º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PDF995(cAcao, nTimeOut, cPathName, cNomeArq, lLocal)
Local lRet	:= .F.   
Local nTOut := 300 //| Segundos                       
Local cDirProg, cArqIniPdf, cPSConvert

Default nTimeOut := 60 //| Segundos
Default lLocal   := .F.

cDirProg 		:= GetEnv("ProgramFiles")                    

cArqIniPdf		:= alltrim(cDirProg)+"\pdf995\res\pdf995.ini"
cPSConvert		:= alltrim(cDirProg)+"\pdf995\res\drivedir\PSConvert.exe"    

//tratamento para (x86)
IF !(FILE(cPSConvert))
	cDirProg	:= REPLACE(UPPER(cDirProg)," (X86)","")

	cArqIniPdf		:= alltrim(cDirProg)+"\pdf995\res\pdf995.ini"
	cPSConvert		:= alltrim(cDirProg)+"\pdf995\res\drivedir\PSConvert.exe"    
	
	//Validação para Windows XP - Quando é windows XP a getenv
	IF !(FILE(cPSConvert))
		cDirProg	:= Upper("C:\Arquivos de Programas")
		
		cArqIniPdf		:= alltrim(cDirProg)+"\pdf995\res\pdf995.ini"
		cPSConvert		:= alltrim(cDirProg)+"\pdf995\res\drivedir\PSConvert.exe"    
	endif	
ENDIF 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configura Impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF cAcao == "A"

	If FILE(cArqIniPdf)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apaga ini da PDF995 para evitar que seja gera arquivo com nome incorreto ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF IF(FILE(cArqIniPdf), FERASE( cArqIniPdf )  == 0,.T.)                             
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera o INI para comando de impressao.						         	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nOutFile := MSFCreate(cArqIniPdf)
			
			FWrite(nOutFile,"[Parameters]"							+Chr(10))
			FWrite(nOutFile,"Quiet=0" 									+Chr(10))
			FWrite(nOutFile,"Install=1" 								+Chr(10))
			FWrite(nOutFile,"Use GPL Ghostcript=1" 				+Chr(10))
			FWrite(nOutFile,"Output File="+cPathName+cNomeArq	+Chr(10))
			FWrite(nOutFile,"Autolaunch=0" 						+Chr(10))   
			FWrite(nOutFile,"Document Name=Totvs Document" 		+Chr(10))  
			FWrite(nOutFile,"Default A4=1"				 		+Chr(10))   
			FWrite(nOutFile,"User File="+cPathName+cNomeArq		+Chr(10))   
			
			FClose(nOutFile)  
			
			lRet := .T.
		ENDIF
	ELSE
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Altera o INI para comando de impressao.						         	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOutFile := MSFCreate(cArqIniPdf)
		
		FWrite(nOutFile,"[Parameters]"						+Chr(10))
		FWrite(nOutFile,"Quiet=0" 							+Chr(10))
		FWrite(nOutFile,"Install=1" 						+Chr(10))
		FWrite(nOutFile,"Use GPL Ghostcript=1" 				+Chr(10))
		FWrite(nOutFile,"Output File="+cPathName+cNomeArq	+Chr(10))
		FWrite(nOutFile,"Autolaunch=0" 						+Chr(10))   
		FWrite(nOutFile,"Document Name=Totvs Document" 		+Chr(10))  
		FWrite(nOutFile,"Default A4=1"				 		+Chr(10))   
		FWrite(nOutFile,"User File="+cPathName+cNomeArq		+Chr(10))   
		
		FClose(nOutFile)  
		
		lRet := .T.
	ENDIF
	              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a impressao foi concluida e "Fecha" a  ³
//³  a configuração da Impressora                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ELSEIF cAcao == "F"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a impressão já foi concluida ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While nTimeOut > 0
	
		IF fRENAME(cPSConvert, UPPER(cPSConvert)) == 0
			lRet	:= .T.
			EXIT
		ELSE
			Sleep(500)	//| 0,5 Segundos
		ENDIF
		
		nTimeOut--
		
		IF nTimeOut <= 0
			lRet := .F.
			EXIT
		ENDIF
	ENDDO  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Remove arquivo para evitar que outra aplicacao gere o PDF ³
	//³ com o mesmo nome                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FERASE( cArqIniPdf )	
ENDIF

Return(lRet)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ COMPILAPDFºAutor ³Augusto Ribeiro     º Data ³ 12/02/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Parametriza Impressora CompilaPDF                          º±±
±±º          ³                                                            º±±
±±ºPARAMETROS³ cAcao   : A = Abre Configuracao e Semaforo                 º±±
±±º          ³         : F = Fecha Configuracao e Semaforo                º±±
±±º          ³ nTimeOut, cPathName, cNomeArq, cPathServer                 º±±
±±º          ³ nHdlSemaf : Handle do Semaforo alterado por referencia     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/            
Static Function COMPILAPDF(cAcao, nTimeOut, cPathName, cNomeArq, cPathServer, nHdlSemaf)
Local lRet	:= .F.                          
Local cDirProg, cArqIniPdf
Local cArqIniOrig 
Local nTime
Local nTimeMake		:= 10 //| Segundos, Timeout para criacao do PDF 
Local cFileSemaf	:= "pdf_compilapdf.lck"	//| Nome do Arquivo do Semaforo         
Local cLibPDF		:= ""

Default nTimeOut 	:= 60 //| Segundos
Default cPathServer	:= cPathName
Default nHdlSemaf	:= 0
	                            

	                                         
CONOUT("********| INICIO - COMPILAPDF - "+cAcao)	  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caminho abaixo do Protheus_data onde foi gerado o PDF ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPathServer		:= cPathServer+cNomeArq
   /*
//| ORIGINAL - PROGRAM FILES
cDirProg 		:= GetEnv("ProgramFiles")                    
cDirProg		:= alltrim(cDirProg)+"\gs"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adapta caminho para 32 ou 64 bits ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
cArqIniPdf		:= cDirProg+"\pdfwrite.txt"
IF !(FILE(cArqIniPdf))
	cDirProg	:= REPLACE(UPPER(cDirProg),"(X86)","")
ENDIF
 */

cDirProg		:= U_AFAT151G("00", "PDFINSTALL") 

cArqIniPdf		:= cDirProg+"\pdfwrite.txt"
cArqIniOrig		:= cDirProg+"\pdfwrite_original.txt"

cFileSemaf		:= cDirProg+"\"+cFileSemaf

cLibPDF			:= cDirProg+"\gs\lib"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configura Impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF cAcao == "A" 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre Semaforo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nHdlSemaf	:= AbreSemaf(cFileSemaf)  
	IF nHdlSemaf <= 0           
		Conout("********| Falha ao abrir Semaforo "+alltrim(cFileSemaf))
		Return(.F.)
	ENDIF				

	If FILE(cArqIniPdf)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apaga ini  para evitar que seja gera arquivo com nome incorreto ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF FERASE( cArqIniPdf )  == 0
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera o INI para comando de impressao.						         	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nOutFile := MSFCreate(cArqIniPdf)
					                  
//			FWrite(nOutFile,'-I"C:\Program Files\gs\gs8.71\lib";C:\Windows\Fonts'	+Chr(10))
			FWrite(nOutFile,'-I"'+cLibPDF+'";C:\Windows\Fonts'	+Chr(10))
			FWrite(nOutFile,' -sDEVICE=pdfwrite'									+Chr(10))
			FWrite(nOutFile,' -r600'												+Chr(10))
			FWrite(nOutFile,' -dNOPAUSE'											+Chr(10))
			FWrite(nOutFile,' -dSAFER'												+Chr(10))
			FWrite(nOutFile,' -sPAPERSIZE=a4'										+Chr(10))
			FWrite(nOutFile,' -dCompatibilityLevel=1.4'								+Chr(10))
			FWrite(nOutFile,' -dPDFSETTINGS=/prepress'								+Chr(10))
			FWrite(nOutFile,' -dAutoRotatePages=/PageByPage'						+Chr(10))
			FWrite(nOutFile,' -sOutputFile="'+cPathName+cNomeArq+'"'				+Chr(10))
			
			FClose(nOutFile)  
			
			lRet := .T. 
		ENDIF
	ELSE
		MSGBOX("Caminho da Impressora nao encontrado", "Impressora Nao Encontrada", "ALERT")
	ENDIF
	              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a impressao foi concluida e "Fecha" a  ³
//³  a configuração da Impressora                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ELSEIF cAcao == "F"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Timeout para criacao do PDF ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FOR nTime := 1 TO nTimeMake
		IF FILE(cPathServer)
			EXIT          
		ELSE
			Sleep(500)	//| 0,5 Segundos
		ENDIF	       
	NEXT nTime
        
                            
	IF FILE(cPathServer)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a impressão já foi concluida ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		FOR nTime := 1 TO nTimeOut
			  
		
			IF fRENAME(cPathServer, UPPER(cPathServer)) == 0
				lRet	:= .T.
				EXIT
			ELSE
				IF nTime >= nTimeOut
					lRet := .F.
					EXIT
				ENDIF			
				
				Sleep(500)	//| 0,25 Segundos
			ENDIF			
		NEXT nTime  		
	ELSE
		lRet := .F.		
	ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Remove arquivo para evitar que outra aplicacao gere o PDF ³
	//³ com o mesmo nome                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FERASE( cArqIniPdf )                
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura Arquivo ini Original caso exista ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF FILE(cArqIniOrig)
		__CopyFile(cArqIniOrig, cArqIniPdf)	
	ENDIF 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha Semaforo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FechaSemaf(@nHdlSemaf, cFileSemaf)	
ENDIF
         
CONOUT("********| FIM - COMPILAPDF - "+cAcao)	  

Return(lRet)





/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ omINqueryºAutor  ³Augusto Ribeiro     º Data ³ 10/10/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recebe String ou  Array separa por caracter "X" ou Numero  º±±
±±º          ³ de Caractres para "quebra" _nCaracX                        º±±
±±º          ³                                                            º±±
±±ºPARAMETROS³ _xVar     : String ou Array                                º±±
±±º          ³ _cCaracX  : Caracter para Quebra                           º±±
±±º          ³ _nCaracX  : Numero de caracteres para Quebra               º±±
±±º          ³                                                            º±±
±±ºRETORNO   ³ Exemplo: ('A','C','F')                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function omINquery(_xVar, _cCaracX, _nCaracX)
Local _cRet	:= ""                  
Local _xVar, _cCaracX, _nCaracX, nY
Local _aString	:= {}                            
Default	_nCaracX := 0                   
		                              

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso dado enviado seja STRING ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF ValType(_xVar) == "C" .AND. (!EMPTY(_cCaracX) .OR. _nCaracX > 0)
                                
	    	nString	:= LEN(_xVar)		
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Utiliza Separacao por Numero de Caracteres ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF _nCaracX > 0
				FOR nY := 1 TO nString STEP _nCaracX
				
					ADD(_aString, SUBSTR(_xVar,nY, _nCaracX) )
				
				Next nY
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Utiliza Separacao por caracter especifico ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ELSE
				_aString	:= WFTokenChar(_xVar, _cCaracX)		
			ENDIF
		ENDIF		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Caso dado enviado seja ARRAY ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF ValType(_xVar) == "A"  
			_aString	:= _xVar
		ENDIF
		   

		IF LEN(_aString) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta String para utilizar com IN em querys³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cRet	+=  "(
			FOR _nI := 1 TO Len(_aString)
		
				IF _nI > 1
					_cRet	+= ","
				ENDIF			

				IF VALTYPE(_aString[_nI]) == "C"
					_cRet	+=  "'"+ALLTRIM(_aString[_nI])+"'"
				ELSE                
					_cRet	+=  ALLTRIM(STR(_aString[_nI]))
				ENDIF
			Next _nI
			_cRet += ") " 
			 
		ENDIF
		
Return(_cRet) 


                                 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AbreSemaf ºAutor  ³Augusto Ribeiro     º Data ³ 28/02/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre o Semafaro.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AbreSemaf(cFile, nTimeOut )

Local nHdlSemaf	:= -1
Local nTimeOut

Default nTimeOut	:= 600 //| Segundos

nHdlSemaf := MSFCreate(cFile)
         
IF nHdlSemaf <= 0
   
	While nHdlSemaf <= 0
    
		nTimeOut--
	    IF nTimeOut <= 0
		    EXIT
	    ENDIF	    
		                              
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tenta Abrir Novamente ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Sleep(500)  
      
      	Conout("********| Abrindo Semaforo ("+alltrim(str(nTimeOut))+") "+cFile)
      
		nHdlSemaf := MSFCreate(cFile)
	EndDo         
    
ENDIF

Return(nHdlSemaf)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FechaSemafºAutor  ³Augusto Ribeiro     º Data ³ 28/02/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Fecha o Semafaro.                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FechaSemaf(nHdlSemaf, cFile)  
Local cFile                                   
Local nHdlSemaf

IF !(FCLOSE(nHdlSemaf))
   	Conout("**ERRO**| Falha ao Fechar Semaforo "+Str(FError(0)) )
ENDIF 

If ValType(cFile) == "C"
   Ferase(cFile)
EndIf   

Return()




/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ omPubArq ºAutor  ³Augusto Ribeiro     º Data ³ 07/03/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Publica arquivos no Portal                                 º±±
±±º          ³ 1. Copia Arquivo via FTP para Site                         º±±
±±º          ³ 2. Move Arquivo para Pasta Publicados                      º±±
±±º          ³ 3. Registra tabela de publicaca                            º±±
±±º          ³                                                            º±±
±±ºPARAMETROS³ aRecnoP04   : Recno dos Arquivos                           º±±
±±º          ³ cOpc        : "P" = "Publica", "R" = Remove                º±±
±±º          ³                                                            º±±
±±ºRETORNO   ³ aRet	:= {{lOK, Recno, cMsgErro}}    						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function omPubArq(aRecnoP04, cOpc)
Local aRet		:= {}
Local aArea		:= GetArea()
Local aAreaP04	:= P04->(GetArea())
Local nY
Local lRet		:= .F.
Local cMsgErro	:= ""
Local aRecREMOVE	:= {}

Local cFTPURL, cFTPUser, cFTPPass, cFTPDir 
Local cDirGerado, cDirRemov, cDirPublic
Local cPathOrig, cPathDest, aRetDirFTP 
Local cQuery := ""

Default	cOpc := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Configurações globais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFTPURL  	:= U_AFAT151G("00", "FTPPURL")
cFTPUser    := U_AFAT151G("00", "FTPPUSR")
cFTPPass	:= U_AFAT151G("00", "FTPPPAS")
cFTPDir		:= U_AFAT151G("00", "FTPPDIR")  

DBSELECTAREA("P04")
           



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ REPROCESSAR                                                      ³
//³ Necessario remover todos os arquivos vinculados a nota fiscal    ³
//³ Esta query tem o objetivo de completar o array com os recnos dos ³
//³ demais arquivos a serem removidos                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF cOpc == "4"	  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa 2 vezes a consulta para garantir que todo a estrutura ³
	//³ de vinculo com a NF foi removida                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FOR nI	:= 1 TO 2
	
			cQuery := " SELECT P04.R_E_C_N_O_ AS P04_RECNO "+EOL
			cQuery += " FROM "+RetSqlName("P05")+" P05 "+EOL
			cQuery += " INNER JOIN (SELECT P05_FILNF, P05_NOTA, P05_SERIE "+EOL
			cQuery += " 			FROM "+RetSqlName("P05")+" P05 "+EOL
			cQuery += " 			INNER JOIN "+RetSqlName("P04")+" P04 "+EOL
			cQuery += " 				ON P04.R_E_C_N_O_ in "+U_omINquery(aRecnoP04)
			cQuery += " 				AND P04_CODIGO = P05_CODARQ "+EOL
			cQuery += " 				AND P04.D_E_L_E_T_ = '' "+EOL
			cQuery += " 			WHERE P05_STATUS = '2' "+EOL
			cQuery += " 			AND P05.D_E_L_E_T_ = '' "+EOL
			cQuery += " 			GROUP BY P05_FILNF, P05_NOTA, P05_SERIE) A "+EOL
			cQuery += " 	ON A.P05_FILNF = P05.P05_FILNF "+EOL
			cQuery += " 	AND A.P05_NOTA = P05.P05_NOTA "+EOL
			cQuery += " 	AND A.P05_SERIE = P05.P05_SERIE "+EOL
			cQuery += " INNER JOIN "+RetSqlName("P04")+" P04 "+EOL
			cQuery += " 	ON P04.R_E_C_N_O_ NOT IN "+U_omINquery(aRecnoP04)
			cQuery += " 	AND P04_FILIAL = '' "+EOL
			cQuery += " 	AND P04_CODIGO = P05_CODARQ "+EOL
			cQuery += " 	AND P04.D_E_L_E_T_ = '' "+EOL
			cQuery += " WHERE P05.D_E_L_E_T_ = '' "+EOL
			cQuery += " GROUP BY P04.R_E_C_N_O_ "+EOL 
			
			If Select("REPR") > 0
				REPR->(DbCloseArea())
			EndIf                
			
			DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"REPR", .F., .T.)
			
			WHILE REPR->(!EOF())	 
				
				AADD(aRecnoP04,REPR->P04_RECNO)
			
				REPR->(DBSKIP())
			ENDDO	
			REPR->(DbCloseArea())		
	NEXT nI
ENDIF




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ REPROCESSAR                                                   ³
//³ Arquivos com status aguardando publicacao devem ser removidos ³
//³ sem a necessidade de conexao com o servidor FTP               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
IF cOpc == "4" .OR. cOpc == "3"

	FOR nY := 1 TO LEN(aRecnoP04)  
		IncProc("Processando...")		
	
		lRet		:= .F. 
		cMsgErro	:= ""
		
		P04->(DBGOTO(aRecnoP04[nY]))
		
		IF P04->P04_STATUS == "1"         
		
			cPathOrig	:= U_omPathPDF(P04->P04_STATUS)+alltrim(P04->P04_ARQUIV)
			cPathDest	:= U_omPathPDF(cOpc)+alltrim(P04->P04_ARQUIV)
				                                                                     
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Copia Arquivo para pasta Removidos  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			__CopyFile(cPathOrig , cPathDest)
				
			IF FILE(cPathDest)
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Desabilita visualizacao do arquivo no Portal ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				RECLOCK("P04", .F.)
					P04->P04_STATUS := cOpc   
					IF EMPTY(P04->P04_DTREM)
						P04->P04_DTREM 	:= DDATABASE
						P04->P04_HRREM	:= TIME()
					ENDIF							
				MSUNLOCK()
				
				lRet	:= .T.		
				Ferase(cPathOrig)	//| Remove arquivo da pasta de origem
				
				U_PCON2EXP(,"P04", P04->(RECNO()), "U" )
			ELSE
				cMsgErro	:= "Falha ao mover arquivo para a Pasta Removidos"
			ENDIF	
	
			aadd(aRet, {lRet, aRecnoP04[nY], cMsgErro})				
		ELSE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deixa no Array somente arquivos que devem ser removidos do Portal ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AADD(aRecREMOVE, aRecnoP04[nY])
		ENDIF		
	Next nY

	aRecnoP04	:= 	ACLONE(aRecREMOVE)
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conecta ao Servido FTP ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                           
IF LEN(aRecnoP04) > 0
	IF FTPCONNECT( cFTPURL, /*porta*/, cFTPUser, cFTPPass )
		
		IF !EMPTY(cFTPDir)
			IF !(FTPDirChange(cFTPDir))
	
				cMsgErro	:= "Falha ao posicionar na Pasta do FTP: "+cFTPDir    
				aadd(aRet, {.F., 0, cMsgErro})					
			ENDIF
		ENDIF
	
		FOR nY := 1 TO LEN(aRecnoP04)  
	                                
			IncProc("Processando...")		
			
			lRet		:= .F.
			cMsgErro	:= ""
		
			P04->(DBGOTO(aRecnoP04[nY]))
	        
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Publica Arquivos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF cOpc == "2" .AND. P04->P04_STATUS == "1"
	
				cPathOrig	:= U_omPathPDF(P04->P04_STATUS)+alltrim(P04->P04_ARQUIV)
				cPathDest	:= U_omPathPDF(cOpc)+alltrim(P04->P04_ARQUIV)			
					
				IF FTPUPLOAD(cPathOrig, alltrim(P04->P04_ARQUIV))
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se arquivo realmente existe no destino ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//aRetDirFTP := FTPDIRECTORY( alltrim(P04->P04_ARQUIV), ) 			
					//IF LEN(aRetDirFTP) > 0
						
		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Copia Arquivo para pasta Publicados ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						__CopyFile(cPathOrig , cPathDest)
						
						IF FILE(cPathDest)
							                         
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Habilita visualizacao do arquivo no Portal ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							RECLOCK("P04", .F.)
								P04->P04_DTPUBL := dDataBase
								P04->P04_HRPUBL := Time()
								P04->P04_STATUS := cOpc							
							MSUNLOCK()                
	
							lRet	:= .T.
	
							Ferase(cPathOrig)	//| Remove arquivo da pasta de origem
							
							/*-----------------------------------
								PROTHEUS CONNECTOR
							-------------------------------------*/							
							U_PCON2EXP(,"P04", P04->(RECNO()), "U" )
														
						ELSE
							cMsgErro:= "Falha ao mover arquivo para a Pasta Publicados"
						ENDIF				
					//ELSE                                                    
					//	cMsgErro	:= "Falha no UPLOAD do Arquivo(2): "+cPathOrig					
					//ENDIF	
				ELSE 
					cMsgErro	:= "Falha no UPLOAD do Arquivo: "+cPathOrig		
				ENDIF
	
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Remove Arquivos ³
			//³                 ³				
			//³ 3=Remover       ³		
			//³ 4=Reprocessar   ³		
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ELSEIF cOpc == "3" .OR. cOpc == "4"
		
				IF cOpc == "3" .AND. P04->P04_STATUS <> "2" //| Publicado
	                                         
					cMsgErro	:= "Acao nao permitida para o arquivo selecionado"
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso o status atual do registro seja igual a removido, somente     ³
				//³ altera status da tabela pois arquivos ja estao nas pastas corretas ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ELSEIF cOpc == "4" .AND. P04->P04_STATUS == "3" //| Removido
	
					RECLOCK("P04", .F.)
						P04->P04_STATUS	:= cOpc
						IF EMPTY(P04->P04_DTREM)
							P04->P04_DTREM 	:= DDATABASE
							P04->P04_HRREM	:= TIME()
						ENDIF
					MSUNLOCK()
									
					lRet	:= .T.		
					
					/*-----------------------------------
						PROTHEUS CONNECTOR 
						Remove arquivo do CRM
					-------------------------------------*/							
					U_PCON2EXP(,"P04", P04->(RECNO()), "U" )		
				ELSE
					
					cPathOrig	:= U_omPathPDF(P04->P04_STATUS)+alltrim(P04->P04_ARQUIV)
					cPathDest	:= U_omPathPDF(cOpc)+alltrim(P04->P04_ARQUIV)
						                                                                     
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Somente exclui arquivo do FTP caso o mesmo esteja publicado ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					IF IIF(P04->P04_STATUS=="2", FTPERASE( alltrim(P04->P04_ARQUIV) ), .T.)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Copia Arquivo para pasta Removidos  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						__CopyFile(cPathOrig , cPathDest)
						
						IF FILE(cPathDest)
						
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Desabilita visualizacao do arquivo no Portal ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
							RECLOCK("P04", .F.)
								P04->P04_STATUS := cOpc   
								IF EMPTY(P04->P04_DTREM)
									P04->P04_DTREM 	:= DDATABASE
									P04->P04_HRREM	:= TIME()
								ENDIF							
							MSUNLOCK()
							
							lRet	:= .T.
							
							Ferase(cPathOrig)	//| Remove arquivo da pasta de origem	
							
							/*-----------------------------------
								PROTHEUS CONNECTOR 
								Remove arquivo do CRM
							-------------------------------------*/							
							U_PCON2EXP(,"P04", P04->(RECNO()), "U" )	
						ELSE
							cMsgErro	:= "Falha ao mover arquivo para a Pasta Removidos"
						ENDIF
					ELSE
						cMsgErro	:= "Falha ao remover arquivo do FTP "+alltrim(P04->P04_ARQUIV)
					ENDIF
				ENDIF
			ELSE
				cMsgErro	:= "Acao nao permitida para o arquivo selecionado"
			ENDIF   
	
			aadd(aRet, {lRet, aRecnoP04[nY], cMsgErro})	
		Next nY		
	ELSE
		cMsgErro	:= "Falha ao conectar ao FTP: "+cFTPURL    
		aadd(aRet, {.F., 0, cMsgErro})		
	ENDIF     
	FTPDISCONNECT()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Função que envia WorkFlow para os clientes do aceite Sustentável. Thiago Nascimento | Compila | 02/11/2013.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//u_WFSCSEND("2") //| Comentado Augusto Ribeiro|
	
	/*------------------------------------------------------ Augusto Ribeiro | 09/12/2015 - 2:54:41 PM
		Envio de e-mail com faturas em anexo.
	------------------------------------------------------------------------------------------*/
	IF cOpc == "2" //| Publicacao de arquivos|
		MsgRun ( "Enviando e-mail com faturas em anexo", "Faturas por e-mail. [U_WFFAT01S]", {|| U_WFFAT01S() } )
	ENDIF
	
ENDIF

RestArea(aAreaP04)
RestArea(aArea)
Return(aRet)




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna Path de Acordo com o Status passado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ omPathPDFºAutor  ³Augusto Ribeiro     º Data ³ 13/03/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorno Path do PDF de acordo com o status do registro     º±±
±±º          ³                                                            º±±
±±ºPARAMETROS³ cStatus     : Status                                       º±±
±±º          ³                                                            º±±
±±ºRETORNO   ³ cRet	:= Pth do PDF                  						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function omPathPDF(cStatus)
Local cRet	:= ""
Local cDirGerado	:= U_AFAT151G("00", "PDFGERA")
Local cDirRemov		:= U_AFAT151G("00", "PDFREMO")
Local cDirPublic	:= U_AFAT151G("00", "PDFPUBL")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gerado             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
IF cStatus == "1"
	
	cRet	:= cDirGerado
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Publicado          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ELSEIF cStatus == "2"    

	cRet	:= cDirPublic	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Removido / Reprocessar ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ELSEIF cStatus == "3" .OR. cStatus == "4"

	cRet	:= cDirRemov		
ENDIF

cRet	:= ALLTRIM(cRet)

Return(cRet)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³omGerExc  ºAutor  ³Augusto Ribeiro     º Data ³ 13/4/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime relatório em Excel                                   º±±
±±º          ³ *ATENCAO* - Necessario que o Action do rel. seja uma       º±±
±±º          ³User Function                                               º±±
±±º          ³                                                            º±±
±±ºPARAMETROS³ oPrint      : Objeto do relatorio                          º±±
±±º          ³ cPathName   : Caminho onde o PDF sera gerado               º±±
±±º          ³ cNomeArq    : Nome do Arquivo                              º±±
±±º          ³ cTipoRel    : Tipo de Relatorio TReport ou TMSPriter       º±±
±±º          ³                                                            º±±
±±ºRETORNO   ³ aRet{lRelOK, cLOG_ERRO, P05_STATUS}                        º±±
±±º          ³ 1=Nao Processado;2=Processado;3=Inconsistencia;4=Desconsid º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Zatix.	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function omGerExc(oPrint, cPathName, cNomeArq, cPathServer,cTipoRel)
Local aChkFile 		:= {}
Local cArqIniPdf	:= ""
Local nOutFile		:= 0
Local cPrintPadrao	:= ""
Local aRet			:= {.F., "","3"}
Local cSession		:= GetPrinterSession()     
Local nY			:= 0
Local nTimeOut		:= 600 	//| Segundos

Local aPriters      

Local cPSConvert


Default cTipoRel	:= "TReport"   
Default cPathServer	:= cPathName

Private nHdlSemaf		:= 0	//| Semaforo
        
cTipoRel	:= UPPER(ALLTRIM(cTipoRel))			

CONOUT("********| INICIO - omGerExc - "+cPathName)
   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define impressora com  orientacao do relatorio	   	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF oPrint:GetOrientation() == 1
//		WriteProfString( cSession , "ORIENTATION", "PORTRAIT", .T. )
ELSE
//		WriteProfString( cSession , "ORIENTATION", "LANDSCAPE", .T. ) 
ENDIF


IF cTipoRel == "TREPORT"			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dispara impressao do Relatorio  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	oPrint:SetEnvironment("SERVER")	//| {"SERVER","CLIENT"}
	//oPrint:SetDevice("FILE")		//| {"FILE","SPOOL","PORT","EMAIL"}	
	oPrint:SetDevice(4) //| EXCEL 	
	oPrint:cFile	:= cPathName+cNomeArq
					
	oPrint:SetPreview(.F.) 
	oPrint:lParamPage	:= .F.	 
	//oPrint:LEMPTYLINEEXCEL	:= .F.	
	
	
	oPrint:Print()	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o arquivo impresso está vazio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    IF oPrint:NXLSROW <= 5
        aRet	:= {.F., "Nao ha dados a serem exibidos.", "4"}
        IF FILE(cPathName+cNomeArq)
        	FERASE(cPathName+cNomeArq)
        ENDIF
    ELSE             
        aRet	:= {.T.,"","2"}
   		//Sleep(500)	//| 0,5 Segundos
 	ENDIF
	     
ENDIF		                                            		




CONOUT("********| FIM - omGerExc - "+cPathName)
 
Return(aRet) 