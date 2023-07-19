/*//#########################################################################################
Project  : Melhorias nos processos - FonNet
Module   : Financeiro
Source   : WFON006
Objective: Atualização tabela de Clientes (SA1) campos: A1_EMAIL, A1_YDIALEM, A1_YDIACOB
*///#########################################################################################

#INCLUDE "RwMake.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FileIo.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TbiCode.ch"

#DEFINE SALTO CHR(13) + CHR(10)

/*/{Protheus.doc} WFON006
    Gerenciador de Processamento
    @author  Dilson Castro
    @table   SA1
    @since   03-09-2021
    @type    function
/*/

USER FUNCTION WFON006()
	//Local aParam	:= {}
	Local aPergs	:= {}
	Local aRet		:= {}
	Local cArquivo  := Space(200)
	Private cNomeArq := dtos(dDataBase) + strtran(time(),":", "") + ".TXT"
	aAdd(aPergs,{6,"Selecione o arquivo",cArquivo,"","","",90,.F.,"Arquivo CSV (*.csv) |*.csv"})
	If ParamBox(aPergs,"Caminho",@aRet,,,,,,,"",.T.,.T.)
		If MessageBox("Deseja realizar atualização dos clientes (e-mail)?","MCONSULT",4) ==  6
			Processa({||ProcSA1(aRet[1])}, "Atualizando dados...")
		EndIf
	EndIf
RETURN

//---------------------------------------------------------------------------------------------------------------------------
STATIC FUNCTION ProcSA1(cFile)
	Local cLinha  := ""
	Local aDados  := {}
	Local lPrim   := .T.
	Local nHandle := 0
	Local nTotal  := 0
	Local nAtual  := 0
	Private lMsErroAuto := .F.
	If !File(cFile)
		MsgStop("O arquivo " + cFile + " não foi encontrado. A atualização será abortada!","[WFON006] - ATENCAO")
		Return
	EndIf
	FT_FUSE(cFile)
	nTotal := FT_FLASTREC()-1
	FT_FGOTOP()
	nHandle := FCREATE('C:\TEMP\' + cNomeArq, FC_NORMAL)
	FWrite(nHandle,"LOG DE IMPORTAÇÃO"+SALTO)//Salva no arquivo os nomes dos campos na primeira linha
	aDados := {}
	//Conta quantos registros existem, e seta no tamanho da régua
    ProcRegua(nTotal)
	//Ler arquivo e preencher aDados.
	While !FT_FEOF()
		cLinha := FT_FREADLN()
		If lPrim
			aCampos := Separa(cLinha,"|",.T.)
			lPrim := .F.
		Else
			AADD(aDados,Separa(cLinha,"|",.T.))
		EndIf
		FT_FSKIP()
		nAtual++
		INCPROC("Lendo arquivo... linha " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...") 
	EndDo
	FCLOSE()
	If	MSGYESNO("Leitura do arquivo TXT concluída. Deseja Continuar ? ","Confirme !")
		AtuSA1(aDados)
	Else
		Return
	EndIf
RETURN

//---------------------------------------------------------------------------------------------------------------------------
STATIC FUNCTION AtuSA1(xDados)
	Local I      := 1
	Local aArea  := GetArea()
	Local nTotal := 0
	Local nAtual := 0
	nTotal := LEN(xDados)
	//Conta quantos registros existem, e seta no tamanho da régua
    ProcRegua(nTotal)
	FOR I=1 TO LEN(xDados)
		QSA1:= "SELECT A1_CGC FROM "+RETSQLNAME("SA1")+" SA1 WHERE SA1.D_E_L_E_T_ != '*' AND A1_CGC = '"+xDados[I,1]+"' ORDER BY A1_CGC "
		QSA1 := ChangeQuery(QSA1)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,QSA1),"QSA1", .F., .T.)
		DbSelectArea("QSA1")
		QSA1->(DbGoTop())
		While !(QSA1->(EOF()))
			DbSelectArea("SA1")
			SA1->(DbGoTop())
			SA1->(DbSetOrder(3))
			If (DbSeek(xFilial("SA1")+xDados[I,1]))
				RecLock("SA1",.F.)
				SA1->A1_EMAIL   := AllTrim(xDados[i,2])
				SA1->A1_YDIALEM := AllTrim(xDados[i,3])
				SA1->A1_YDIACOB := AllTrim(xDados[i,4])
				MsUnlock()
			EndIf
			QSA1->(DbSkip())
			nAtual++
			INCPROC("Atualizando clientes... linha " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...") 
		EndDo
		QSA1->(dbclosearea())
	NEXT I
	RestArea(aArea)
RETURN	
