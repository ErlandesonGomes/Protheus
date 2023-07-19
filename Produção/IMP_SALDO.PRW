#INCLUDE "Protheus.ch" 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "TBICONN.CH"     

/*
===================================================================================
Programa............: IMP_SALDO
Autor...............: Marcelo Carneiro
Data................: 19/05/2015
Descricao / Objetivo: Importar arquivo de Saldos de Estoque, Produtos, Fornecedores,
                      Clientes, Saldo a Pagar e Saldo a Receber
====================================================================================
*/

User Function IMP_SALDO()    // U_IMP_SALDO()

Local aMensagem := {}
Local aBotoes   := {}                      
Local bSair     := .T.
                        
Private cTitulo     := "Importação de Cadastros Básicos"

Aadd( aMensagem, OemToAnsi("Este programa tem como objetivo importar cadastros padrões através de arquivos textos                              "))
Aadd( aMensagem, OemToAnsi("    "))
Aadd( aMensagem, OemToAnsi("Este arquivo deverá ser separado por virgulas e o primeiro registro conterá os  nomes dos campos a serem importados"))
Aadd( aMensagem, OemToAnsi("    "))
AAdd( aMensagem, OemToAnsi("Será questionado se deverá ser excluidos os registros das tabelas destinos antes da importação."))
AAdd( aBotoes, { 19, .T., { || FechaBatch(), bSair     := .F. } } )
AAdd( aBotoes, { 02, .T., { || FechaBatch(), bSair     := .T. } } )
FormBatch( cTitulo, aMensagem, aBotoes, , 260,700  )
IF !bSair
	aMensagem :={}
	aBotoes   :={}
	AAdd( aMensagem, OemToAnsi("Para importar a tabela de Produto, o arquivo deverá conter campos da SB1         "))
	AAdd( aMensagem, OemToAnsi("Para importar a tabela de Fornecedor o arquivo deverá conter campos da SA2       "))
	AAdd( aMensagem, OemToAnsi("Para importar a tabela de Clientes, o arquivo deverá conter campos da SA1        "))
	AAdd( aMensagem, OemToAnsi("Para importar a tabela de Saldo de Estoque, o arquivo deverá conter campos da SB9"))
	AAdd( aMensagem, OemToAnsi("Para importar a tabela de Saldo a Pagar, o arquivo deverá conter campos da SE2   "))
	AAdd( aMensagem, OemToAnsi("Para importar a tabela de Saldo a Receber, o arquivo deverá conter campos da SE1 "))
	AAdd( aMensagem, OemToAnsi("Para importar a tabela de Lotes do Estoque, o arquivo deverá conter campos da SD5"))
	AAdd( aBotoes, { 19, .T., { || FechaBatch(),Processa( { || ImpSal_Exec() }, cTitulo , 'Importando...', .F. )	 } } )
	AAdd( aBotoes, { 02, .T., { || FechaBatch() } } )
	FormBatch( cTitulo, aMensagem, aBotoes, , 260,700  )
ENDIF


Return
***********************************************************************************************************************
Static Function ImpSal_Exec
Local cArq	    := ""
Local cLinha    := ''
Local lPrim     := .T.    
Local aCampos   := {}           
Local aDados    := {} 
Local cBKFilial := cFilAnt
Local nCampos   := 0
Local cSQL      := ''         
Local aExecAuto := {}
Local aTipoImp  := {}
Local nTipoImp  := 0
Local cTipo     := ''
Local cTab      := ''
Private lMsErroAuto    := .F.            
Private aTabExclui     := { {'B1',{"SB1"}} ,;
                            {'B9',{"SB2","SB9"} },;
                            {'A2',{"SA2"} },;
                            {'A1',{"SA1"} },;
                            {'E2',{"SE2"} },;
                            {'E1',{"SE1"} },;
                            {'D5',{"SD5"} } }

cArq := cGetFile("Todos os Arquivos|*.csv", OemToAnsi("Informe o diretório que está o arquivo"), 0, "SERVIDOR\", .F., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE ,.T.)

If !File(cArq)
	MsgStop("O arquivo " +cArq + " não foi encontrado. A importação será abortada!","ATENCAO")
	Return
EndIf

FT_FUSE(cArq)
FT_FGOTOP()
cLinha    := FT_FREADLN()
aTipoImp  := Separa(cLinha,";",.T.)
cTipo     := SUBSTR(aTipoImp[1],1,2)

IF !(cTIPO $('B1 B9 A1 A2 E1 E2 D5'))
     MsgAlert('Não é possivel importar a tabela: '+cTipo+ '  !!') 
     Return
ENDIF

dbSelectArea("SX3")
DbSetOrder(2)
For nI := 1 To Len(aTipoImp)
   IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
       MsgAlert('Todos os campos devem pertencer a mesma tabela !!') 
       Return 
   ENDIF
   IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
       MsgAlert('Campo não encontrado na tabela :'+aTipoImp[nI]+' !!') 
       Return          
   ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
       MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!') 
       Return
   ENDIF
Next nI

nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )
    
cTab := ''
For nI := 1 To Len(aTabExclui[nTipoImp,2])
	cTab += aTabExclui[nTipoImp,2,nI]+' '
Next nI

If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importação ? ")
	For nI := 1 To Len(aTabExclui[nTipoImp,2])
		cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
		If (TCSQLExec(cSQL) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())
	  	EndIf
	Next nI
EndIf	

ProcRegua(FT_FLASTREC())
FT_FGOTOP()
While !FT_FEOF()
	IncProc("Lendo arquivo texto...")
	cLinha := FT_FREADLN()
	If lPrim
		aCampos := Separa(cLinha,";",.T.)
		lPrim := .F.
	Else
		AADD(aDados,Separa(cLinha,";",.T.))
	EndIf
	FT_FSKIP()
EndDo

ProcRegua(Len(aDados))      
For nI:=1 to  Len(aDados)
	
	IncProc("Importando arquivo...")
	aExecAuto := {}
	For nCampos := 1 To Len(aCampos)
		IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL' 
			IF !EMpty(aDados[nI,nCampos])
			     cFilAnt := aDados[nI,nCampos]
			ENDIF
		Else                                                            
		    IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
		        aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil}) 
		    ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
		        aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil}) 
		    ELSE 
		        aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	aDados[nI,nCampos] 	,Nil}) 
		    ENDIF
		ENDIF
	Next nCampos
	lMsErroAuto := .F.
	Begin Transaction                          
	   	IF cTipo == 'B1'       // Produto                     
	   	      MSExecAuto({|x,y| MATA010(x,y)},aExecAuto,3)
	   	ELSEIF cTipo == 'A2'   // Fornecedor
		      MSExecAuto({|x,y| MATA020(x,y)},aExecAuto,3)
		ELSEIF cTipo == 'A1'   //Cliente
		      MSExecAuto({|x,y| MATA030(x,y)},aExecAuto,3)
		ELSEIF cTipo == 'B9'   // Saldo de Estoque
		      MSExecAuto({|x,y| MATA220(x,y)}, aExecAuto, 3)
		ELSEIF cTipo == 'E2'   // Pagar 
		      MSExecAuto({|x,y| FINA050(x,y)},aExecAuto,3)
		ELSEIF cTipo == 'E1'   // Receber
		      MSExecAuto({|x,y| FINA040(x,y)},aExecAuto,3)
		ELSEIF cTipo == 'D5'   // Lotes Saldo
		      MSExecAuto({|x,y| Mata390(x,y)},aExecAuto,3)
	  	ENDIF 
	    If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			cFilAnt := cBKFilial
			Return
		EndIF
  	End Transaction
Next nI        

msgAlert('Arquivo importado com sucesso !!')

	
FT_FUSE()            

cFilAnt := cBKFilial

Return