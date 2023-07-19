#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#include "font.ch"
#include "colors.ch"
#include "totvs.ch"
#Include "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} DANFBOL
Imprime danfe com Boleto e
envia por e-mail
@author Jonatas Oliveira | www.compila.com.br
@since 21/08/2017
@version 1.0
/*/
User Function DANFBOL()

Local oSetup
Local aArea 	:= GetArea()
Local cIdEnt	:= ""
Local _cEmp 	:= "01"
Local _cFilial	:= "03"
Local cQuery	:= ""
Local lExtDir	:= .F.
Local nCont 	:= 0
Local cSession  := GetPrinterSession()
local oAux		:= oMainWnd
Local nOpcAviso := 0
// variaveis para gerar XML
Local aPerg   	    := {}
Local aParam  	    := {Space(If (TamSx3("F2_SERIE")[1] == 14,Len(SF2->F2_SDOC),Len(SF2->F2_SERIE))),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),Space(60),CToD(""),CToD(""),Space(14),Space(14)}
Local aRet          := {}
Local cCnpj         :=  ""
Local cAnexoXML     :=""
Local cIdEnt   	    := ""
Local _cFileLog     := ""
Local nTipo := 1
Local cParNfeExp := SM0->M0_CODIGO+SM0->M0_CODFIL+"NFEEXP"
Local lObrigat   := .F.
Local lUsaColab  := .F.
Local lCTe       := (FunName()$"SPEDCTE,TMSA500,TMSA200,TMSAE70,TMSA050")
Local lSdoc      := TamSx3("F2_SERIE")[1] == 14
//---------------

Private aRetPrint 	:= {}
Private cDirPrint	:= "C:\TEMP\"
Private cDirTemp	:= "\DATA\PDF_TEMP"
Private cDirGerado	:= "\DANFE_BOLETO"
Private _cFileLog
Private _cLogPath
Private _Handle
Private cPathSrv	:= "C:\TEMP\"


lUsaColab := UsaColaboracao( IIF(lCte,"2","1") )


aadd(aPerg,{1,"Serie da Nota Fiscal" ,aParam[01],"",".T.","",".T.",30,.F.})      //"Serie da Nota Fiscal"
aadd(aPerg,{1,"Nota fiscal inicial"  ,aParam[02],"",".T.","",".T.",30,lObrigat}) //"Nota fiscal inicial"
aadd(aPerg,{1,"Nota fiscal final"    ,aParam[03],"",".T.","",".T.",30,lObrigat}) //"Nota fiscal final"
aadd(aPerg,{6,"Diretório de destino" ,aParam[04],"",".T.","!Empty(MV_PAR03)",80,.T.,"Arquivos XML |*.XML","",GETF_RETDIRECTORY+GETF_LOCALHARD,.F.}) //"Diretório de destino"
aadd(aPerg,{1,"Data Inicial"         ,aParam[05],"",".T.","",".T.",50,lObrigat}) //"Data Inicial"
aadd(aPerg,{1,"Data Final"           ,aParam[06],"",".T.","",".T.",50,lObrigat}) //"Data Final"


If nTipo == 1 .Or. nTipo == 3
	aadd(aPerg,{1,"CNPJ Inicial",aParam[07],"              ",".T.","",".T.",50,.F.}) //"CNPJ Inicial"
	aadd(aPerg,{1,"CNPJ final",aParam[08],"ZZZZZZZZZZZZZZ",".T.","",".T.",50,.F.}) //"CNPJ final"
EndIF

aParam[01] := ParamLoad(cParNfeExp,aPerg,1,aParam[01])
aParam[02] := ParamLoad(cParNfeExp,aPerg,2,aParam[02])
aParam[03] := ParamLoad(cParNfeExp,aPerg,3,aParam[03])
aParam[04] := ParamLoad(cParNfeExp,aPerg,4,aParam[04])

aParam[05] := ParamLoad(cParNfeExp,aPerg,5,aParam[05])
aParam[06] := ParamLoad(cParNfeExp,aPerg,6,aParam[06])

If nTipo == 1 .Or. nTipo == 3
	aParam[07] := ParamLoad(cParNfeExp,aPerg,7,aParam[07])
	aParam[08] := ParamLoad(cParNfeExp,aPerg,8,aParam[08])
EndIF


nDevice				:= IMP_PDF
lToLegacy			:= .F.

lDisabeSetup		:= .T.
lTReport			:= NIL
cPrinter			:= ""
lServer				:= .f.
lPDFAsPNG			:= NIL
lRaw				:= NIL
c					:= .T.
nQtdCopy			:= 1


fGrvLog(1,"Iniciando gravação de Log. "+TIME()+". "+ DToC(ddatabase)  )	//||Opcao:  1= Cria Arquivo de Log, 2= Grava Log, 3 = Apresenta Log

cIdEnt := RetIdEnti()

cFileName	 		:= "DANFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")

lAdjustToLegacy := .F.

aDevice	:= {}
AADD(aDevice,"DISCO") // 1
AADD(aDevice,"SPOOL") // 2
AADD(aDevice,"EMAIL") // 3
AADD(aDevice,"EXCEL") // 4
AADD(aDevice,"HTML" ) // 5
AADD(aDevice,"PDF"  ) // 6


nLocal       	:= If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
nOrientation 	:= If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
cDevice     	:= If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
nPrintType      := aScan(aDevice,{|x| x == cDevice })

oDanfe	:=	FWMsPrinter():New( cFileName, IMP_PDF, lToLegacy, , lDisabeSetup, lTReport, @oSetup, cPrinter,lServer, lPDFAsPNG, lRaw, .f., nQtdCopy )

oDanfe:nDevice	:= nDevice
oDanfe:cPathPDF	:= cDirPrint
oDanfe:nDevice  := IMP_PDF


nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
oSetup := FWPrintSetup():New(nFlags, "DANFE")
// ----------------------------------------------
// Define saida
// ----------------------------------------------
//oSetup:SetPropert(PD_DESTINATION , AMB_CLIENT)
oSetup:SetPropert(PD_PRINTTYPE   , IMP_PDF)
oSetup:SetPropert(PD_ORIENTATION , nOrientation)
oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
oSetup:SetPropert(PD_PAPERSIZE   , 2)

oSetup:Activate()

nOpcAviso := Aviso("Impressão e envio de boleto","Os boletos da nota número: "+SF2->F2_DOC+", série: "+SF2->F2_SERIE+", serão encaminhados para o cliente, deseja continuar?",{"Continuar","Cancelar"},2)

IF nOpcAviso == 1

Pergunte("NFSIGW",.F.)
MV_PAR01 := SF2->F2_DOC
MV_PAR02 := SF2->F2_DOC
MV_PAR03 := SF2->F2_SERIE
MV_PAR04 := 2	//[Operacao] NF de Saida
MV_PAR05 := 2	//[Frente e Verso] Sim
MV_PAR06 := 2	//[DANFE simplificado] Sim


//IF Pergunte("ZNFSIGW",.t.) //ParamBox(aPerg,"SPED - NFe",@aParam,,,,,,,cParNfeExp,.T.,.T.)
//Pergunte("NFSIGW",.t.)
 
//cDirPrint := Alltrim(aParam[04])
 
//MV_PAR03 := 2 
//MV_PAR01 := aParam[02]
//MV_PAR02 := aParam[03]
//MV_PAR02 := aParam[01]
 
	//IF MV_PAR03 == 2
	
		/*cQuery += " SELECT R_E_C_N_O_ AS RECSF2 ,F2_DOC "
		cQuery += " FROM "+Retsqlname("SF2")+" F2 "
		cQuery += " WHERE F2.D_E_L_E_T_ = '' "
		cQuery += " 	AND F2_FILIAL = '"+ XFILIAL("SF2") +"' "
		cQuery += " 	AND F2_DOC = '"+ MV_PAR01 +"' "
		cQuery += " 	AND F2_SERIE = '"+ MV_PAR02 +"' "
		
		If Select("QRYDANF") > 0
			QRYDANF->(DbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRYDANF')
		
		DBSELECTAREA("SF2")
		SF2->(DBSETORDER(1))*/
		
		IF !ExistDir(cDirGerado) .or.!ExistDir(cDirTemp) .or.!ExistDir(cDirPrint)
			
			IF MakeDir( cDirGerado ) > 0
				lExtDir := .T.
			ENDIF
			IF !ExistDir(cDirTemp)
				IF MakeDir( cDirTemp ) > 0
					lExtDir := .T.
				ENDIF
			ENDIF
			IF !ExistDir(cDirPrint)
				IF MakeDir( cDirPrint ) > 0
					lExtDir := .T.
				ENDIF
			ENDIF
			
		ELSE
			lExtDir := .T.
		ENDIF
		
		IF lExtDir
			//WHILE QRYDANF->(!EOF())
				//nCont++
				//If nCont ==  1
				//	cMvpar01 := QRYDANF->F2_DOC
				//EndIf
				aRetPrint := {}
				//SF2->(DBGOTO(QRYDANF->RECSF2))
								
				/* THI 
				If nCont > 1
					
					cFileName	:= "DANFE_"+cIdEnt+ SF2->(F2_DOC + F2_SERIE)+Dtos(MSDate())+StrTran(Time(),":","")
					oDanfe	:=	FWMsPrinter():New( cFileName, IMP_PDF, lToLegacy, , lDisabeSetup, lTReport, @oSetup, cPrinter,lServer, lPDFAsPNG, lRaw, .f., nQtdCopy )
					oDanfe:nDevice	:= nDevice
					oDanfe:cPathPDF	:= cDirPrint
					oDanfe:nDevice  := IMP_PDF
								
				EndIf
				*/
				
				//  U_PRTNFESEF(cIdEnt,,,oDanfe,oSetup,"PROTHEUS",.F.,,{QRYDANF->RECSF2}, Alltrim(aParam[04]), cFileName,Alltrim(aParam[04]),.T.,nCont, cMvpar01)
				aRetPrint	:= U_PRTNFESEF(cIdEnt,,,oDanfe,oSetup,"PROTHEUS",   ,,{SF2->(RECNO())}/*{QRYDANF->RECSF2}*/, cDirPrint, cFileName,cDirPrint,.F.,nCont)
				//aRetPrint	:= U_FONDANFE(QRYDANF->RECSF2, nCont)
							    
				 //mv_par01 := /*QRYDANF*/SF2->F2_DOC 
				 
				
					
			    cOrigemPrint := U_CPSpedPExp(cIdEnt,/*MV_PAR02*/SF2->F2_SERIE,/*mv_par01*/SF2->F2_DOC ,/*mv_par01*/SF2->F2_DOC ,cDirPrint,SF2->F2_EMISSAO/*MV_PAR04*/,SF2->F2_EMISSAO;
				/*IIF(Empty(MV_PAR05),dDataBase,MV_PAR05)*/,"              ","zzzzzzzzzzzzzz",nTipo,,SF2->F2_SERIE/*MV_PAR02*/)
						                                
			 //   cOrigemPrint := U_CPSpedPExp(cIdEnt,aParam[01],aParam[02],aParam[03],aParam[04],aParam[05],IIF(Empty(aParam[06]),;
						                         //       dDataBase,aParam[06]),aParam[07],aParam[08],nTipo,,If(lSdoc,aParam[Len(aParam)],aParam[1]))
						                                
						                                
				cNotaNfe := SF2->F2_SERIE + SF2->F2_DOC
				_cFileLog :=  substr(cOrigemPrint,9, len(cOrigemPrint))
				
				If !Empty(cOrigemPrint)		
						IF __CopyFile(  cOrigemPrint , cDirGerado + "\" + _cFileLog )
							IF FILE(cDirGerado + "\" +_cFileLog )
									cAnexoXml := cDirGerado + "\" + _cFileLog
							ENDIF
						ENDIF
				EndIf
				
				IF aRetPrint[1]
					IF FILE(aRetPrint[2])
						IF __CopyFile(aRetPrint[2] , cDirGerado + "\" + cFileName+'.pdf' )
							IF FILE(cDirGerado + "\" + cFileName+'.pdf')
								WFPror(SF2->(RECNO()), cDirGerado + "\" + cFileName+'.pdf',cAnexoXml)
								cDirPrint := cDirPrint
							ENDIF
						ELSE
							fGrvLog(2,"NF " + SF2->(F2_DOC + F2_SERIE) + "FALHA NA COPIA: DE " + aRetPrint[2] + " PARA " + cDirGerado + "\" + cFileName + " " + TIME()+". "+ DToC(ddatabase))
						ENDIF
					ENDIF
				ENDIF

				//QRYDANF->(DBSKIP())
			//ENDDO
			
			
			cFileName	:= "DANFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
			
			oDanfe	:=	FWMsPrinter():New( cFileName, IMP_PDF, lToLegacy, , lDisabeSetup, lTReport, @oSetup, cPrinter,lServer, lPDFAsPNG, lRaw, .T., nQtdCopy )
			oDanfe:nDevice	:= nDevice
			oDanfe:cPathPDF	:= cDirPrint
			oDanfe:nDevice  := IMP_PDF
			
			//QRYDANF->(DBGOTOP())
			
			//nCont:=0
			//WHILE QRYDANF->(!EOF())
				//nCont++
				//If nCont ==  1
					//cMvpar01 := /*QRYDANF*/SF2->F2_DOC
				//EndIf
				aRetPrint := {}
				//SF2->(DBGOTO(QRYDANF->RECSF2))
								
				//If nCont > 1
					
					cFileName	:= "DANFE_"+cIdEnt+ SF2->(F2_DOC + F2_SERIE)+Dtos(MSDate())+StrTran(Time(),":","")
					oDanfe	:=	FWMsPrinter():New( cFileName, IMP_PDF, lToLegacy, , lDisabeSetup, lTReport, @oSetup, cPrinter,lServer, lPDFAsPNG, lRaw, .f., nQtdCopy )
					oDanfe:nDevice	:= nDevice
					oDanfe:cPathPDF	:= cDirPrint
					oDanfe:nDevice  := IMP_PDF
								
				//EndIf
				
						
				aRetPrint	:= U_PRTNFESEF(cIdEnt,,,oDanfe,oSetup,"PROTHEUS",.F.,,{SF2->(RECNO())}/*{QRYDANF->RECSF2}*/, cDirPrint, cFileName, cDirPrint,.T.,nCont, SF2->F2_DOC/*cMvpar01*/)
			
			
				//QRYDANF->(DBSKIP())
			//ENDDO
			
			
			
		ELSE
				fGrvLog(2,"NF " + SF2->(F2_DOC + F2_SERIE) + "Diretorio Não criado: " + cDirGerado + " " + TIME()+". "+ DToC( ddatabase))
		ENDIF
	//ENDIF
//ENDIF
ENDIF
fGrvLog(3,"Fim da Gravação . "+TIME()+". "+ DToC(ddatabase))

RestArea(aArea)
Return .T.



/*/{Protheus.doc} WFPror
Envia Email ao cliente
@author Jonatas Oliveira | www.compila.com.br
@since 03/01/2017
@version 1.0
/*/
Static Function WFPror(nRecSf2, cAnexo,cAnexoXML)

Local cOrigemPrint  := ""
Local cTipoDesc     := ""
Local cCodProc 		:= "STATUS_PF"
Local cDescProc		:= "Sua Fatura Fonnet - IMPORTANTE"
Local cHTMLModelo	:= "\WORKFLOW\wffonnetSemBol.html"
Local cSubject		:= "Sua Fatura Fonnet | IMPORTANTE"
Local cFromName		:= "Financeiro Fonnet"
Local lEnvia		:= .F.
Local cQryZ1		:= ""
Local cMailFin		:= GetNewPar("MV_MAILCP", "davi.monte@fonnet.com.br" )// --- "jonatas.oliveira@compila.com.br;spsantos43@gmail.com"
Local cMailHom		:= GetNewPar("MV_NFHOM", "" )
Local cStatus		:= ""
Local cMesAnt		:= STRZERO(MONTH(DDATABASE)-1,2)
Local cMesAtu		:= STRZERO(MONTH(DDATABASE),2)
Local cAno 			:= ALLTRIM(STR(YEAR(DDATABASE)))
Local nY			:= 0
Local nQtdParc		:= 0
Local nTotalNeg		:= 0
Local cMailDest 	:= ""
Local cQryE1		:= ""
Local cPlacas		:= ""
Local cIdPedido     := ""
Local cPedido       := ""
Local cParcela      := ""
Local cVencimento   := ""
Local cValor        := ""
Local cNotaNfe      := ""
Local oProcess, oHtml, nI
Local cFormPg		:= ""
Local lValor		:= .T.
Local lComBordero	:= .F.
Local aTitulos		:= {}


IF nRecSf2 > 0
	
	DBSELECTAREA("SF2")
	SF2->(DBGOTO(nRecSf2))
	
	DBSELECTAREA("SD2")
	SD2->(DBSETORDER(3)) //| D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, R_E_C_N_O_, D_E_L_E_T_
	
	IF SD2->( DBSEEK( SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )))
		
		DBSELECTAREA("SC5")
		SC5->(DBSETORDER(1))
		SC5->(DBSEEK( SD2->D2_FILIAL + SD2->D2_PEDIDO ))
		
		cIdPedido := SC5->C5_YPEDCLI //Posicione("SC5",1, xFilial("SC5") + cIdPedido,"C5_YPEDCLI")
		
		DBSELECTAREA("SA1")
		SA1->(DBSETORDER(1))
		IF SA1->(DBSEEK(xfilial("SA1") + SF2->(F2_CLIENTE+F2_LOJA)))
			
			/*----------------------------------------
			14/03/2017 - Jonatas Oliveira - Compila
			E-mail do cliente.
			------------------------------------------*/
			//daniele.maranhao@fonnet.com.br;
			cMailDest := ALLTRIM(SC5->C5_EMAIL)//ALLTRIM(SA1->A1_EMAIL2)//"daniele.maranhao@fonnet.com.br;sivaldo.santos@compila.com.br"//ALLTRIM(SA1->A1_EMAIL)
			
			IF EMPTY(cMailDest)
				cMailDest := cMailFin
			ENDIF

			
			cQryE1 += " SELECT E1_PARCELA, E1_VALOR, E1_VENCREA, E1_NUMBOR "
			cQryE1 += " FROM "+Retsqlname("SE1")+" E1 "
			cQryE1 += " WHERE E1.D_E_L_E_T_ = '' "
			cQryE1 += " 	AND E1_FILIAL = '"+ XFILIAL("SF2") +"' "
			cQryE1 += " 	AND E1_CLIENTE  = '"+ SF2->F2_CLIENTE +"' "
			cQryE1 += " 	AND E1_LOJA = '"+ SF2->F2_LOJA  +"' "
			cQryE1 += " 	AND E1_PREFIXO = '"+ SF2->F2_SERIE +"' "
			cQryE1 += " 	AND E1_NUM  = '"+ SF2->F2_DOC + "' "
			cQryE1 += " 	ORDER BY 1 "
			//cQryE1 += " 	AND E1_SALDO > 0  "
			//cQryE1 += " 	AND E1_BAIXA = ''"
			
			
			If Select("QRYSE1") > 0
				QRYSE1->(DbCloseArea())
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryE1),'QRYSE1')

			aTitulos	:= {}
			While QRYSE1->( !EOF())
			
				IF !EMPTY(QRYSE1->E1_NUMBOR)
					lComBordero	:= .T.
				ENDIF

				
				cParcela 	:= Alltrim(QRYSE1->E1_PARCELA)
				cVencimento  := (QRYSE1->E1_VENCREA)
				cVencimento	:= substr(cVencimento,7,2) +"/" +substr(cVencimento,5,2)+"/" +substr(cVencimento,1,4)
				cValor 		:= TRANSFORM( QRYSE1->E1_VALOR ,"@E 999,999,999.99" )
				
				aadd(aTitulos, {cParcela, cVencimento, cValor})

				QRYSE1->(DBSKIP())
			ENDDO
			QRYSE1->(DbCloseArea())
			
			
			IF lComBordero
				cHTMLModelo	:= "\WORKFLOW\wffonnet.html"		
			ENDIF
			
					
			/*----------------------------------------
			14/03/2017 - Jonatas Oliveira - Compila
			Cria Processo de Workflow
			------------------------------------------*/
			oProcess := TWFProcess():New(cCodProc,cDescProc)
			
			oProcess:NewTask(cDescProc,cHTMLModelo)
			
			oHtml 		:= oProcess:oHtml
			
			IF EMPTY(aTitulos)
					aadd( ( oHtml:ValByName("item.E1_PARCELA")) ,	"" )
					aadd( ( oHtml:ValByName("item.E1_VENCREA" )),	"" )
					aadd( ( oHtml:ValByName("item.E1_VALOR"	)) ,	"" )		
			ELSE
				FOR nI := 1 to len(aTitulos)
					aadd( ( oHtml:ValByName("item.E1_PARCELA")) ,	aTitulos[nI,1] )
					aadd( ( oHtml:ValByName("item.E1_VENCREA" )),	aTitulos[nI,2] )
					aadd( ( oHtml:ValByName("item.E1_VALOR"	)) ,	aTitulos[nI,3] )
				NEXT nI
			endif

			
			oHtml:ValByName("ccliente"	,		CAPITAL(ALLTRIM(UPPER(SA1->A1_NOME))))
			//	oHtml:ValByName("CPF"		,		IIF(SA1->A1_PESSOA == "J",TRANSFORM(SA1->A1_CGC,"@R 99.999.999/9999-99"),TRANSFORM(SA1->A1_CGC,"@R 999.999.999-99")))
			//	oHtml:ValByName("CODIGO"	,		SA1->(A1_COD + A1_LOJA) )
			oHtml:ValByName("idPedido"	      ,	Alltrim(cIdPedido))
			oHtml:ValByName("cDanfe"	      ,	CAPITAL(SF2->F2_DOC))
			
			IF !EMPTY(cMailHom)
				cMailDest	:= cMailHom
			ENDIF
						
			oProcess:ClientName(Subs(cUsuario,7,15))
			oProcess:cTo 		:= cMailDest
			
			IF !EMPTY(cMailFin)
				oProcess:cCC  		:= cMailFin
			ENDIF
			
			oProcess:cSubject 	:= cSubject
			oProcess:CFROMNAME 	:= cFromName
			oProcess:attachfile(cAnexo) // anexa Danfe
			IF !Empty(cAnexoXML)
				oProcess:attachfile(cAnexoXML) // anexa xml
			EndIF
			oProcess:Start()
			oProcess:Free()
			
			fGrvLog(2,"NF " + SF2->(F2_DOC + F2_SERIE) + " E-Mail enviado para " + cMailDest + " " + TIME()+". "+ DToC(ddatabase))
		ELSE	
			//| Cliente não localizado	
		ENDIF
	ELSE
		//| pEDIDO NAO ENCONTRADO
	ENDIF
ENDIF

Return()




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a Criação, Gravacao, Apresentacao do Log de acordo com o Pametro passado ³
//³                                                                                  ³
//³ PARAMETRO	DESCRICAO                                                            ³
//³ _nOpc		Opcao:  1= Cria Arquivo de Log, 2= Grava Log, 3 = Apresenta Log      ³
//³ _cTxtLog	Log a ser gravado                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function fGrvLog(_nOpc, _cTxtLog)
Local _lRet	:= Nil
Local _nOpc, _cTxtLog
Local _EOL	:= chr(13)+chr(10)

Default _nOpc		:= 0
Default _cTxtLog 	:= ""
_cTxtLog += _EOL
Do Case
	Case _nOpc == 1
		_cFileLog	 	:= Criatrab(,.F.)
		_cLogPath		:= AllTrim(GetTempPath())+_cFileLog+".txt"
		_Handle			:= FCREATE(_cLogPath,0)	//| Arquivo de Log
		IF !EMPTY(_cTxtLog)
			FWRITE (_Handle, _cTxtLog)
		ENDIF
		
	Case _nOpc == 2
		IF !EMPTY(_cTxtLog)
			FWRITE (_Handle, _cTxtLog)
		ENDIF
		
	Case _nOpc == 3
		IF !EMPTY(_cTxtLog)
			FWRITE (_Handle, _cTxtLog)
		ENDIF
		FCLOSE(_Handle)
		WINEXEC("NOTEPAD "+_cLogPath)
EndCase


Return( _lRet)


User Function CPSpedPExp(cIdEnt,cSerie,cNotaIni,cNotaFim,cDirDest,dDataDe,dDataAte,cCnpjDIni,cCnpjDFim,nTipo,lCTe,cSerMax)

Local aDeleta  			:= {}
Local cAlias         	:= GetNextAlias()
Local cAnoInut  		:= ""
Local cAnoInut1 		:= ""
Local cCanc             := ""
Local cChvIni      		:= ""
Local cChvFin     		:= ""
Local cChvNFe  			:= ""
Local cCNPJDEST 		:= Space(14)
Local cCondicao         := ""
Local cDestino   		:= "C:\TEMP\"
Local cDrive        	:= ""
Local cIdflush  		:= cSerie+cNotaIni
Local cModelo  			:= ""
Local cNFes     		:= ""
Local cPrefixo    		:= ""
Local cURL          	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cXmlInut  		:= ""
Local cXml              := ""
Local cWhere    		:= ""
Local cXmlProt  		:= ""
local cAviso    		:= ""
local cErro     		:= ""
local cTab              := ""
local cCmpNum           := ""
local cCmpSer     		:= ""
local cCmpTipo  		:= ""
local cCmpLoja  		:= ""
local cCmpCliFor		:= ""
local cCnpj             := ""
Local cEventoCTe        := ""
Local cRetEvento        := ""
Local cRodapCTe  		:=""
local cCabCTe    		:=""
Local cIdEven       	:= ""
Local lOk               := .F.
Local lFlush            := .T.
Local lFinal            := .F.
Local lClearFilter      := .F.
Local lExporta          := .F.
Local lUsaColab         := .F.
Local lSdoc             := TamSx3("F2_SERIE")[1] == 14
Local nHandle           := 0
Local nX                := 0
Local nY                := 0
Local aInfXml           := {}
Local oRetorno
Local oWS
Local oXML
Local cDirPrintXML  := ""

Default nTipo    := 1
Default cNotaIni:=""
Default cNotaFim:=""
Default dDataDe:=CtoD("  /  /  ")
Default dDataAte:=CtoD("  /  /  ")
Default lCTe       := .T.
Default cSerMax := cSerie

Set(_SET_DATEFORMAT, 'dd/mm/yy')

lUsaColab := UsaColaboracao( IIF(lCte,"2","1") )

If nTipo == 3
	If !Empty( GetNewPar("MV_NFCEURL","") )
		cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	Endif
Endif

If IntTMS() .and. lCTe//Altera o conteúdo da variavel quando for carta de correção para o CTE
	cTipoNfe := "SAIDA"
EndIf
ProcRegua(Val(cNotaFim)-Val(cNotaIni))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Corrigi diretorio de destino                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SplitPath(cDirDest,@cDrive,@cDestino,"","")
cDestino := cDrive+cDestino
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia processamento                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do While lFlush
	
	If ( nTipo == 1 .And. !lUsaColab ).Or. nTipo == 3
		
		WSDLDbgLevel(2)  //| ### REMOVER
		
		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN        := "TOTVS"
		oWS:cID_ENT           := cIdEnt
		oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:cIdInicial        := cSerie+cNotaIni
		oWS:cIdFinal          := cSerMax+cNotaFim
		oWS:dDataDe           := dDataDe
		oWS:dDataAte          := dDataAte
		oWS:cCNPJDESTInicial  := cCnpjDIni
		oWS:cCNPJDESTFinal    := cCnpjDFim
		oWS:nDiasparaExclusao := 0
		lOk:= oWS:RETORNAFX()
		oRetorno := oWS:oWsRetornaFxResult
		
		If lOk
			ProcRegua(Len(oRetorno:OWSNOTAS:OWSNFES3))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exporta as notas                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			For nX := 1 To Len(oRetorno:OWSNOTAS:OWSNFES3)
				
				//Ponto de Entrada para permitir filtrar as NF
				If ExistBlock("SPDNFE01")
					If !ExecBlock("SPDNFE01",.f.,.f.,{oRetorno:OWSNOTAS:OWSNFES3[nX]})
						loop
					Endif
				Endif
				
				oXml    := oRetorno:OWSNOTAS:OWSNFES3[nX]
				oXmlExp := XmlParser(oRetorno:OWSNOTAS:OWSNFES3[nX]:OWSNFE:CXML,"","","")
				cXML     := ""
				If Type("oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ")<>"U"
					cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
				ElseIF Type("oXmlExp:_NFE:_INFNFE:_DEST:_CPF")<>"U"
					cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CPF:TEXT)
				Else
					cCNPJDEST := ""
				EndIf
				cVerNfe := IIf(Type("oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT") <> "U", oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT, '')
				cVerCte := Iif(Type("oXmlExp:_CTE:_INFCTE:_VERSAO:TEXT") <> "U", oXmlExp:_CTE:_INFCTE:_VERSAO:TEXT, '')
				If !Empty(oXml:oWSNFe:cProtocolo)
					cNotaIni := oXml:cID
					cIdflush := cNotaIni
					cNFes := cNFes+cNotaIni+CRLF
					cChvNFe  := NfeIdSPED(oXml:oWSNFe:cXML,"Id")
					cModelo := cChvNFe
					cModelo := StrTran(cModelo,"NFe","")
					cModelo := StrTran(cModelo,"CTe","")
					cModelo := SubStr(cModelo,21,02)
					
					Do Case
						Case cModelo == "57"
							cPrefixo := "CTe"
						Case cModelo == "65"
							cPrefixo := "NFCe"
						OtherWise
							if '<cStat>302</cStat>' $ oXml:oWSNFe:cxmlPROT
								cPrefixo := "den"
							else
								cPrefixo := "NFe"
							endif
					EndCase
					
					nHandle := FCreate(cDestino+SubStr(cChvNFe,4,44)+"-"+cPrefixo+".xml")
					cDirPrintXML := cDestino+SubStr(cChvNFe,4,44)+"-"+cPrefixo+".xml"
					If nHandle > 0
						cCab1 := '<?xml version="1.0" encoding="UTF-8"?>'
						If cModelo == "57"
							cCab1  += '<cteProc xmlns="http://www.portalfiscal.inf.br/cte" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/cte procCTe_v'+cVerCte+'.xsd" versao="'+cVerCte+'">'
							cRodap := '</cteProc>'
						Else
							Do Case
								Case cVerNfe <= "1.07"
									cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/nfe procNFe_v1.00.xsd" versao="1.00">'
								Case cVerNfe >= "2.00" .And. "cancNFe" $ oXml:oWSNFe:cXML
									cCab1 += '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
								OtherWise
									cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
							EndCase
							cRodap := '</nfeProc>'
						EndIf
						FWrite(nHandle,AllTrim(cCab1))
						FWrite(nHandle,AllTrim(oXml:oWSNFe:cXML))
						FWrite(nHandle,AllTrim(oXml:oWSNFe:cXMLPROT))
						FWrite(nHandle,AllTrim(cRodap))
						FClose(nHandle)
						aadd(aDeleta,oXml:cID)
						cXML := AllTrim(cCab1)+AllTrim(oXml:oWSNFe:cXML)+AllTrim(cRodap)
						If !Empty(cXML)
							If ExistBlock("FISEXPNFE")
								ExecBlock("FISEXPNFE",.f.,.f.,{cXML})
							Endif
						EndIF
						
					EndIf
				EndIf
				
				If ( oXml:OWSNFECANCELADA <> Nil .And. !Empty(oXml:oWSNFeCancelada:cProtocolo) )
					cChave                   := oXml:OWSNFECANCELADA:CXML
					If cModelo == "57" .and. cVerCte >='2.00'
						cChaveCc1 := At("<chCTe>",cChave)+7
					else
						cChaveCc1 := At("<chNFe>",cChave)+7
					endif
					cChaveCan := SubStr(cChave,cChaveCc1,44)
					
					oWS:= WSNFeSBRA():New()
					oWS:cUSERTOKEN          := "TOTVS"
					oWS:cID_ENT             := cIdEnt
					oWS:_URL                := AllTrim(cURL)+"/NFeSBRA.apw"
					oWS:cID_EVENTO          := "110111"
					oWS:cChvInicial               := cChaveCan
					oWS:cChvFinal  := cChaveCan
					lOk                                                        := oWS:NFEEXPORTAEVENTO()
					oRetEvCanc       := oWS:oWSNFEEXPORTAEVENTORESULT
					
					
					if lOk
						
						ProcRegua(Len(oRetEvCanc:CSTRING))
						//---------------------------------------------------------------------------
						//| Exporta Cancelamento do Evento da Nf-e                                  |
						//---------------------------------------------------------------------------
						
						For nY := 1 To Len(oRetEvCanc:CSTRING)
							cXml    := SpecCharc(oRetEvCanc:CSTRING[nY])
							oXmlExp := XmlParser(cXml,"_",@cErro,@cAviso)
							If cModelo == "57" .and. cVerCte >='2.00'
								if Type("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE:_INFEVENTO:_CHCTE")<>"U"
									cIdEven               := 'ID'+oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE:_INFEVENTO:_CHCTE:TEXT
								elseIf Type("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE:_INFEVENTO:_CHCTE")<>"U"
									cIdEven               := 'ID'+oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE:_INFEVENTO:_CHCTE:TEXT
								endif
								
								If (Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE")<>"U") .and. (Type("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE")<>"U")
									cCabCTe   := '<procEventoCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">'
									cEventoCTe:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE,.F.)
									cRetEvento:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE,.F.)
									cRodapCTe := '</procEventoCTe>'
									CxML:= cCabCTe+cEventoCTe+cRetEvento+cRodapCTe
								ElseIf (Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE")<>"U") .and. (Type("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE:_INFEVENTO")<>"U")
									cCabCTe   := '<procEventoCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">'
									cEventoCTe:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE,.F.)
									cRetEvento:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE,.F.)
									cRodapCTe := '</procEventoCTe>'
									CxML:= cCabCTe+cEventoCTe+cRetEvento+cRodapCTe
								EndIf
								
							else
								if Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID")<>"U"
									cIdEven               := oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID:TEXT
								else
									cIdEven  := oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT
								endif
							endif
							
							
							nHandle := FCreate(cDestino+SubStr(cIdEven,3)+"-Canc.xml")
							if nHandle > 0
								FWrite(nHandle,AllTrim(cXml))
								FClose(nHandle)
							endIf
						Next nY
					Else
						cChvNFe  := NfeIdSPED(oXml:oWSNFeCancelada:cXML,"Id")
						cNotaIni := oXml:cID
						cIdflush := cNotaIni
						cNFes := cNFes+cNotaIni+CRLF
						If !"INUT"$oXml:oWSNFeCancelada:cXML
							nHandle := FCreate(cDestino+SubStr(cChvNFe,3,44)+"-ped-can.xml")
							If nHandle > 0
								cCanc := oXml:oWSNFeCancelada:cXML
								If cModelo == "57"
									oXml:oWSNFeCancelada:cXML := '<procCancCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="' + cVerCte + '">' + oXml:oWSNFeCancelada:cXML + "</procCancCTe>"
								Else
									oXml:oWSNFeCancelada:cXML := '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">' + oXml:oWSNFeCancelada:cXML + "</procCancNFe>"
								EndIf
								FWrite(nHandle,oXml:oWSNFeCancelada:cXML)
								FClose(nHandle)
								aadd(aDeleta,oXml:cID)
							EndIf
							nHandle := FCreate(cDestino+"\"+SubStr(cChvNFe,3,44)+"-can.xml")
							If nHandle > 0
								If cModelo == "57"
									FWrite(nHandle,'<procCancCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="' + cVerCte + '">' + cCanc + oXml:oWSNFeCancelada:cXMLPROT + "</procCancCTe>")
								Else
									FWrite(nHandle,'<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">' + cCanc + oXml:oWSNFeCancelada:cXMLPROT + "</procCancNFe>")
								EndIF
								FClose(nHandle)
							EndIf
						Else
							
							// If Type("oXml:OWSNFECANCELADA:CXML")<>"U"
							cXmlInut  := oXml:OWSNFECANCELADA:CXML
							cAnoInut1 := At("<ano>",cXmlInut)+5
							cAnoInut  := SubStr(cXmlInut,cAnoInut1,2)
							cXmlProt  := EncodeUtf8(oXml:oWSNFeCancelada:cXMLPROT)
							// EndIf
							nHandle := FCreate(cDestino+SubStr(cChvNFe,3,2)+cAnoInut+SubStr(cChvNFe,5,39)+"-ped-inu.xml")
							If nHandle > 0
								FWrite(nHandle,oXml:OWSNFECANCELADA:CXML)
								FClose(nHandle)
								aadd(aDeleta,oXml:cID)
							EndIf
							nHandle := FCreate(cDestino+"\"+cAnoInut+SubStr(cChvNFe,5,39)+"-inu.xml")
							If nHandle > 0
								FWrite(nHandle,cXmlProt)
								FClose(nHandle)
							EndIf
						EndIf
					EndIf
				EndIf
				IncProc()
			Next nX
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui as notas                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aDeleta) .And. GetNewPar("MV_SPEDEXP",0)<>0
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN        := "TOTVS"
				oWS:cID_ENT           := cIdEnt
				oWS:nDIASPARAEXCLUSAO := GetNewPar("MV_SPEDEXP",0)
				oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"
				oWS:oWSNFEID          := NFESBRA_NFES2():New()
				oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
				For nX := 1 To Len(aDeleta)
					aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
					Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aDeleta[nX]
				Next nX
				If !oWS:RETORNANOTAS()
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Informe o nome do arquivo da private key"},3)
					lFlush := .F.
				EndIf
			EndIf
			aDeleta  := {}
			If ( Len(oRetorno:OWSNOTAS:OWSNFES3) == 0 .And. Empty(cNfes) )
				Aviso("SPED", "Não há dados",{"Ok"})  // "Não há dados"
				lFlush := .F.
			EndIf
		Else
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))+CRLF+"Informe o nome do arquivo da private key",{"OK"},3)
			lFinal := .T.
		EndIf
		
		If lSdoc
			cIdflush := AllTrim(Substr(cIdflush,1,14) + StrZero((Val( Substr(cIdflush,15,Len(AllTrim(cNotaFim))))) + 1 ,Len(AllTrim(cNotaFim))))
		Else
			cIdflush := AllTrim(Substr(cIdflush,1,3) + StrZero((Val( Substr(cIdflush,4,Len(AllTrim(cNotaFim))))) + 1 ,Len(AllTrim(cNotaFim))))
		EndIf
		
		If cIdflush <= AllTrim(cNotaIni) .Or. Len(oRetorno:OWSNOTAS:OWSNFES3) == 0 .Or. Empty(cNfes) .Or. ;
			cIdflush <= If(lSdoc,Substr(cNotaIni,1,14)+Replicate('0',Len(AllTrim(cNotaFim))-Len(Substr(Rtrim(cNotaIni),15)))+Substr(Rtrim(cNotaIni),15),;
			Substr(cNotaIni,1,3)+Replicate('0',Len(AllTrim(cNotaFim))-Len(Substr(Rtrim(cNotaIni),4)))+Substr(Rtrim(cNotaIni),4))// Importou o range completo
			lFlush := .F.
		/*	If !Empty(cNfes)
				If Aviso("SPED","Solicitação processada com sucesso.",{"Sim","Não"}) == 1    //"Solicitação processada com sucesso."
					Aviso("Detalhes","XML's Exportados para"+" "+Upper(cDestino)+CRLF+CRLF+cNFes,{"Ok"})
				EndIf
			EndIf  */
		EndIf
	ElseIf nTipo == 2  .Or. lUsaColab //Carta de Correcao e NF-e(QUANDO FOR TOTVS COLABORAÇÃO 2.0)
		
		cWhere:="D_E_L_E_T_=''"
		If !Empty(cSerie)
			
			If lSdoc
				If cTipoNfe == "SAIDA"
					cWhere                               += " AND F2_SDOC ='"+SubStr(cSerie,1,3)+"'"
					cCondicao           += AllTrim("F2_SDOC ='"+SubStr(cSerie,1,3)+"'")
				Else
					cWhere                               += " AND F1_SDOC ='"+SubStr(cSerie,1,3)+"'"
					cCondicao           += AllTrim("F1_SDOC ='"+SubStr(cSerie,1,3)+"'")
				Endif
			Else
				If cTipoNfe == "SAIDA"
					cWhere                               += " AND F2_SERIE ='"+cSerie+"'"
					cCondicao           += AllTrim("F2_SERIE ='"+cSerie+"'")
				Else
					cWhere                               += " AND F1_SERIE ='"+cSerie+"'"
					cCondicao           += AllTrim("F1_SERIE ='"+cSerie+"'")
				Endif
			EndIf
			
		EndIf
		If !Empty(cNotaIni)
			If cTipoNfe == "SAIDA"
				cWhere                               += " AND F2_DOC >='"+cNotaIni+"'"
				cCondicao           += AllTrim(" .AND. F2_DOC >='"+cNotaIni+"'")
			Else
				cWhere                               += " AND F1_DOC >='"+cNotaIni+"'"
				cCondicao           += AllTrim(" .AND. F1_DOC >='"+cNotaIni+"'")
			Endif
		EndIf
		If !Empty(cNotaFim)
			If cTipoNfe == "SAIDA"
				cWhere                               += " AND F2_DOC <='"+cNotaFim+"'"
				cCondicao           += AllTrim(" .AND. F2_DOC <='"+cNotaFim+"'")
			Else
				cWhere                               += " AND F1_DOC <='"+cNotaFim+"'"
				cCondicao           += AllTrim(" .AND. F1_DOC <='"+cNotaFim+"'")
			Endif
		EndIf
		If !Empty(dDataDe)
			If cTipoNfe == "SAIDA"
				cWhere                               += " AND F2_EMISSAO >='"+DtoS(dDataDe)+"'"
				cCondicao           += " .AND. DTOS(F2_EMISSAO) >='"+DtoS(dDataDe)+"'"
			Else
				cWhere                               += " AND F1_EMISSAO >='"+DtoS(dDataDe)+"'"
				cCondicao           += " .AND. DTOS(F1_EMISSAO) >='"+DtoS(dDataDe)+"'"
			Endif
		EndIf
		If !Empty(dDataAte)
			If cTipoNfe == "SAIDA"
				cWhere                               += " AND F2_EMISSAO <='"+DtoS(dDataAte)+"'"
				cCondicao           += " .AND. DTOS(F2_EMISSAO) <='"+DtoS(dDataAte)+"'"
			Else
				cWhere                               += " AND F1_EMISSAO <='"+DtoS(dDataAte)+"'"
				cCondicao           += " .AND. DTOS(F1_EMISSAO) <='"+DtoS(dDataAte)+"'"
			Endif
		EndiF
		cWhere:="%"+cWhere+"%"
		#IFDEF TOP
			If cTipoNfe == "SAIDA"
				if lUsaColab
					BeginSql Alias cAlias
						SELECT F2_DOC, F2_SERIE, F2_TIPO, F2_CLIENTE, F2_LOJA
						FROM %Table:SF2%
						WHERE F2_FILIAL= %xFilial:SF2%
						AND      %Exp:cWhere%
					EndSql
					lExporta:=!(cAlias)->(Eof())
				else
					BeginSql Alias cAlias
						SELECT MIN(R_E_C_N_O_) AS RECINI,MAX(R_E_C_N_O_) AS RECFIN
						FROM %Table:SF2%
						WHERE F2_FILIAL= %xFilial:SF2%
						AND      %Exp:cWhere%
					EndSql
					SF2->(dbGoTo((cAlias)->RECINI))
					cChvIni := SF2->F2_CHVNFE
					SF2->(dbGoTo((cAlias)->RECFIN))
					cChvFin := SF2->F2_CHVNFE
					lExporta:=!(cAlias)->(Eof())
				endif
			Else
				if lUsaColab
					BeginSql Alias cAlias
						SELECT F1_DOC, F1_SERIE, F1_TIPO, F1_FORNECE, F1_LOJA
						FROM %Table:SF2%
						WHERE F2_FILIAL= %xFilial:SF2%
						AND      %Exp:cWhere%
					EndSql
					lExporta:=!(cAlias)->(Eof())
				else
					BeginSql Alias cAlias
						SELECT MIN(R_E_C_N_O_) AS RECINI,MAX(R_E_C_N_O_) AS RECFIN
						FROM %Table:SF1%
						WHERE F1_FILIAL= %xFilial:SF1%
						AND      %Exp:cWhere%
					EndSql
					SF1->(dbGoTo((cAlias)->RECINI))
					cChvIni := SF1->F1_CHVNFE
					SF1->(dbGoTo((cAlias)->RECFIN))
					cChvFin := SF1->F1_CHVNFE
					lExporta:=!(cAlias)->(Eof())
				endif
			Endif
		#ELSE
			If cTipoNfe == "SAIDA"
				cAlias := "SF2"
				dbSetFilter({|| &cCondicao},cCondicao)
				if !lUsaColab
					(cAlias)->(dbGotop())
					cChvIni := SF2->F2_CHVNFE
					(cAlias)->(DbGoBottom())
					cChvFin := SF2->F2_CHVNFE
					lExporta:=!SF2->(Eof())
					(cAlias)->(dbClearFilter())
				else
					lClearFilter := .T.
					lExporta:=!SF2->(Eof())
				endif
			Else
				cAlias := "SF1"
				dbSetFilter({|| &cCondicao},cCondicao)
				If !lUsaColab
					(cAlias)->(dbGotop())
					cChvIni := SF1->F1_CHVNFE
					(cAlias)->(DbGoBottom())
					cChvFin := SF1->F1_CHVNFE
					lExporta:=!SF1->(Eof())
					(cAlias)->(dbClearFilter())
				else
					lClearFilter := .T.
					lExporta:=!SF1->(Eof())
				endif
			Endif
		#ENDIF
		
		If lExporta
			If lUsaColab
				
				cCnpjDFim := iif(empty(cCnpjDFim),"99999999999999", cCnpjDFim)
				
				(cAlias)->(dbGoTop())
				
				While !(cAlias)->(Eof())
					
					if cTipoNfe == "SAIDA"
						cTab := 'F2_'
						cCmpCliFor := cTab+'CLIENTE'
					else
						cTab := 'F1_'
						cCmpCliFor := cTab+'FORNECE'
					endif
					
					cCmpNum          := cTab+'DOC'
					cCmpSer             := cTab+'SERIE'
					cCmpTipo           := cTab+'TIPO'
					cCmpLoja            := cTab+'LOJA'
					cPrefix := iif(nTipo == 1,IIF(lCTe,"CTe","NFe"),"CCe")
					
					//Tratamento para verificar se o CNPJ está no range inserido pelo usuário.
					lCnpj := .F.
					
					if cPrefix $ "CCe"
						lCnpj := .T.
					else
						
						If cTipoNfe == "SAIDA"
							if (cAlias)->&cCmpTipo $ 'D|B'
								cCnpj := Posicione("SA2",1,xFilial("SA2")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A2_CGC")
							else
								cCnpj := Posicione("SA1",1,xFilial("SA1")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A1_CGC")
							endif
						else
							if (cAlias)->&cCmpTipo $ 'D|B'
								cCnpj := Posicione("SA1",1,xFilial("SA1")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A1_CGC")
							else
								cCnpj := Posicione("SA2",1,xFilial("SA2")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A2_CGC")
							endif
						endif
						
						if cCnpj >= cCnpjDIni .And. cCnpj <= cCnpjDFim
							lCnpj := .T.
						endif
					endif
					
					If lCnpj
						cXML := ""
						
						aInfXml                := {}
						aInfXml := ColExpDoc((cAlias)->&cCmpSer,(cAlias)->&cCmpNum,iif(nTipo == 1,IIF(lCTe,"CTE","NFE"),"CCE"),@cXml)
						/*
						aInfXml
						[1] - Logico se encotra documento .T.
						[2] - Chave do documento
						[3] - XML autorização - someente se autorizado
						[4] - XML Cancelamento Evento- somente se autorizado
						[5] - XML Ped. Inutilização - somente se autorizado
						[6] - XML Prot. Inutilização - somente se autorizado
						*/
						//Ponto de Entrada para permitir filtrar as NF
						If ExistBlock("SPDNFE01")
							If !ExecBlock("SPDNFE01",.f.,.f.,{aInfXml})
								(cAlias)->(dbSkip())
								loop
							Endif
						Endif
						//Encontrou documento
						if aInfXMl[1]
							
							if cPrefix == "CCe" .And. !Empty( aInfXMl[3] )
								nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3)+"-CCe.xml")
								cXML := aInfXMl[3]
								
								If nHandle > 0
									FWrite(nHandle,AllTrim(cXml))
									FClose(nHandle)
								EndIf
								cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF
								
							elseif cPrefix $ "NFe|CTe"
								//Iinutilização
								if !Empty( aInfXMl[5] )
									cXmlInut  := aInfXMl[5]
									cAnoInut1 := At("<ano>",cXmlInut)+5
									cAnoInut  := SubStr(cXmlInut,cAnoInut1,2)
									cXmlProt  := aInfXMl[6]
									
									
									nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3,2)+cAnoInut+SubStr(aInfXMl[2],5,39)+"-ped-inu.xml")
									If nHandle > 0
										FWrite(nHandle,oXml:OWSNFECANCELADA:CXML)
										FClose(nHandle)
										aadd(aDeleta,oXml:cID)
									EndIf
									nHandle := FCreate(cDestino+"\"+cAnoInut+SubStr(aInfXMl[2],5,39)+".xml")
									cDirPrintXML := cDestino+"\"+cAnoInut+SubStr(aInfXMl[2],5,39)+".xml"
									If nHandle > 0
										FWrite(nHandle,cXmlProt)
										FClose(nHandle)
									EndIf
									cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF
								endif
								//Cancelamento
								if !Empty( aInfXMl[4] )
									cXml    := SpecCharc(aInfXMl[4])
									nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3)+"-canc.xml")
									if nHandle > 0
										FWrite(nHandle,AllTrim(cXml))
										FClose(nHandle)
									endIf
									cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF
								endif
								
								if !Empty( aInfXML[3] )
									cXml    := SpecCharc(aInfXMl[3])
									
									If ExistBlock("FISEXPNFE")
										ExecBlock("FISEXPNFE",.f.,.f.,{cXML})
									EndIF
									
									nHandle := FCreate(cDestino+SubStr(aInfXMl[2],4)+"-"+cPrefix+".xml")
									cDirPrintXML := cDestino+SubStr(aInfXMl[2],4)+"-"+cPrefix+".xml"
									if nHandle > 0
										FWrite(nHandle,AllTrim(cXml))
										FClose(nHandle)
									endIf
									
									cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF
								endif
							endif
							IncProc()
						endif
					endif
					(cAlias)->(dbSkip())
				enddo
			/*	If !Empty(cNfes)
					If Aviso("SPED","Solicitação processada com sucesso.",{"Sim","Não"}) == 1    //"Solicitação processada com sucesso."
						Aviso("Detalhes","XML's Exportados para"+" "+Upper(cDestino)+CRLF+CRLF+cNFes,{"OK"},3)
					EndIf
				endif  */
				
			else
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN          := "TOTVS"
				oWS:cID_ENT             := cIdEnt
				oWS:_URL                := AllTrim(cURL)+"/NFeSBRA.apw"
				oWS:cChvInicial         := cChvIni
				oWS:cChvFinal  			:= cChvFin
				lOk:= oWS:NFEEXPORTAEVENTO()
				oRetorno := oWS:oWSNFEEXPORTAEVENTORESULT
				
				If lOk
					
					ProcRegua(Len(oRetorno:CSTRING))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Exporta as cartas                                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					For nX := 1 To Len(oRetorno:CSTRING)
						cXml    := oRetorno:CSTRING[nX]
						cXml      := EncodeUTF8(cXml)
						oXmlExp := XmlParser(cXml,"_",@cErro,@cAviso)
						If Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID")<>"U"
							cIdCCe  := oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID:TEXT
						Elseif Type("oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT")<> "U"
							cIdCCe  := oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT
						Else
							cIdCCe  := oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE:_INFEVENTO:_ID:TEXT
						Endif
						nHandle := FCreate(cDestino+SubStr(cIdCCe,3)+"-CCe.xml")
						If nHandle > 0
							FWrite(nHandle,AllTrim(cXml))
							FClose(nHandle)
						EndIf
						IncProc()
						cNFes+=SubStr(cIdCCe,31,3)+"/"+SubStr(cIdCCe,34,9)+CRLF
					Next nX
					
				/*	If Aviso("SPED","Solicitação processada com sucesso.",{"Sim","Não"}) == 1    //"Solicitação processada com sucesso."
						Aviso("Detalhes","XML's Exportados para"+" "+Upper(cDestino)+CRLF+CRLF+cNFes,{"OK"},3)
					EndIf*/
				Else
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
					lFinal := .T.
				EndIF
			endif
		EndIf
		#IFDEF TOP
			If select (cAlias)>0
				(cAlias)->(dbCloseArea())
			EndIf
		#ENDIF
		lFlush := .F.
	EndIF
EndDo

Return(cDirPrintXML)



