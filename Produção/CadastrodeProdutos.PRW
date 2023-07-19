#include "totvs.ch"

User Function fImpCsv() 
Local cDiret
Local cLinha  := ""
Local lPrimlin   := .T.
Local aCampos := {}
Local aDados  := {}
Local i
Local j 
local clog := ""
Private aErro := {}

 //Cria Tela de captura de itens
cDiret :=  cGetFile( 'Arquito CSV|*.csv| Arquivo TXT|*.txt| Arquivo XML|*.xml',; //[ cMascara], 
                         'Selecao de Arquivos',;                  //[ cTitulo], 
                         0,;                                      //[ nMascpadrao], 
                         'C:\TOTVS\',;                            //[ cDirinicial], 
                         .F.,;                                    //[ lSalvar], 
                         GETF_LOCALHARD  + GETF_NETWORKDRIVE,;    //[ nOpcoes], 
                         .T.)         
//Cria Tela de captura de itens

//Analisa Arquivo
FT_FUSE(cDiret)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()
//Verifica Arquivo de Cima a Baixo
While !FT_FEOF()
 
	IncProc("Lendo arquivo texto...")
 
	cLinha := FT_FREADLN()

	If lPrimlin  //Se a variavel lPrimlin for .T. significa que é a primeira linha(cabeçario)
		aCampos := Separa(cLinha,";",.T.)  //Verifica a linha e separa os campos por ;
	    lPrimlin := .F. //Variavel recebe Falso para passar a integrar o segundo array contendo agora os dados
	Else
		AADD(aDados,Separa(cLinha,";",.T.))  //Verifica a linha e separa os campos por ;
	    EndIf

	FT_FSKIP() //Pula a Linha
EndDo
 //BeginTran
Begin Transaction
	ProcRegua(Len(aDados))
    //Repete até i = a quantidade de registros no array aDados
	For i:=1 to Len(aDados)
 
		IncProc("Importando Registros...")
    // Seleciona a tabela e posiciona no topo
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbGoTop()
        // Se Não encontrar o codigo na SB1 então ira realizar a inclusão:
		If !dbSeek(xFilial("SB1")+aDados[i,1])
			Reclock("SB1",.T.)
            //Cadastra a Filial na tabela
        SB1->B1_FILIAL := xFilial("SB1")
        SB1->B1_PICM := 0
        SB1->B1_IPI := 0
        SB1->B1_ALIQISS := 0
        SB1->B1_PICMRET := 0
        SB1->B1_PICMENT := 0
        SB1->B1_CONV := 0
        SB1->B1_TIPCONV := "M"
        SB1->B1_QE := 0
        SB1->B1_PRV1 := 0
        SB1->B1_EMIN := 0
        SB1->B1_CUSTD := 0
        SB1->B1_UPRC := 0
        SB1->B1_MCUSTD := "1"
        SB1->B1_PESO := 0
        SB1->B1_ESTSEG := 0
        SB1->B1_PE := 0
        SB1->B1_LE := 0
        SB1->B1_LM := 0
        SB1->B1_TOLER := 0
        SB1->B1_QB := 0
        SB1->B1_TIPODEC := "N"
        SB1->B1_RASTRO := "N"
        SB1->B1_UREV := dDatabase
        SB1->B1_DATREF := dDatabase
        SB1->B1_COMIS := 0
        SB1->B1_PERINV := 0
        SB1->B1_MRP := "S"
        SB1->B1_NOTAMIN := 0
        SB1->B1_PRVALID := 0
        SB1->B1_NUMCOP := 0
        SB1->B1_LOCALIZ := "N"
        SB1->B1_CONTRAT := "N"
        SB1->B1_VLREFUS := 0
        SB1->B1_IMPORT := "N"
        SB1->B1_ANUENTE := "2"
        SB1->B1_TIPOCQ := "M"
        SB1->B1_SOLICIT := "N"
        SB1->B1_AGREGCU := "2"
        SB1->B1_DESPIMP := "N"
        SB1->B1_NUMCQPR := 0
        SB1->B1_CONTCQP := 0
        SB1->B1_INSS := "N"
        SB1->B1_REDINSS := 0
        SB1->B1_REDIRRF := 0
        SB1->B1_REDPIS := 0
        SB1->B1_REDCOF := 0
        SB1->B1_PCSLL := 0
        SB1->B1_PCOFINS := 0
        SB1->B1_PPIS := 0
        SB1->B1_MTBF := 0
        SB1->B1_MTTR := 0
        SB1->B1_FLAGSUG := "1"
        SB1->B1_CLASSVE := "1"
        SB1->B1_MIDIA := "2"
        SB1->B1_QTMIDIA := 0
        SB1->B1_VLR_IPI := 0
        SB1->B1_ENVOBR := "0"
        SB1->B1_QTDSER := "1"
        SB1->B1_FAIXAS := 0
        SB1->B1_NROPAG := 0
        SB1->B1_ATIVO := "S"
        SB1->B1_EMAX := 0
        SB1->B1_PESBRU := 0
        SB1->B1_FRACPER := 0
        SB1->B1_INT_ICM := 0
        SB1->B1_VLR_ICM := 0
        SB1->B1_VLRSELO := 0
        SB1->B1_CPOTENC := "2"
        SB1->B1_POTENCI := 0
        SB1->B1_QTDACUM := 0
        SB1->B1_QTDINIC := 0
        SB1->B1_LOTVEN := 0
        SB1->B1_USAFEFO := "1"
        SB1->B1_AFASEMT := 0
        SB1->B1_AIMAMT := 0
        SB1->B1_AFUNDES := 0
        SB1->B1_UMOEC := 0
        SB1->B1_UVLRC := 0
        SB1->B1_PIS := "2"
        SB1->B1_VLR_PIS := 0
        SB1->B1_PMACNUT := 0
        SB1->B1_PMICNUT := 0
        SB1->B1_QBP := 0
        SB1->B1_PRODSBP := "P"
        SB1->B1_LOTESBP := 0
        SB1->B1_FECP := 0
        SB1->B1_VLCIF := 0
        SB1->B1_MOPC := "NULL"
        SB1->B1_ESCRIPI := "3"
        SB1->B1_CRICMS := "0"
        SB1->B1_DCRII := 0
        SB1->B1_COEFDCR := 0
        SB1->B1_MARKUP := 0
        SB1->B1_AFABOV := 0
        SB1->B1_MSBLQL := "2"
        SB1->B1_RETOPER := "2"
        SB1->B1_COFINS := "2"
        SB1->B1_CSLL := "2"
        SB1->B1_VLR_COF := 0
        SB1->B1_PRFDSUL := 0
        SB1->B1_CRDEST := 0
        SB1->B1_FETHAB := "N"
        SB1->B1_PAUTFET := 0
        SB1->B1_PR43080 := 0
        SB1->B1_PERGART := 0
        SB1->B1_GARANT := "2"
        SB1->B1_RICM65 := "2"
        SB1->B1_AFETHAB := 0
        SB1->B1_ALFECST := 0
        SB1->B1_CFEMA := 0
        SB1->B1_FECPBA := 0
        SB1->B1_ALFECOP := 0
        SB1->B1_ALFUMAC := 0
        SB1->B1_PRN944I := "S"
        SB1->B1_PRINCMG := 0
        SB1->B1_CRDPRES := 0
        SB1->B1_AFACS := 0
        SB1->B1_ALFECRN := 0
        SB1->B1_IMPNCM := 0


            //Repete até i = a quantidade de registros no array aCampos
			For j:=1 to Len(aCampos)
				cCampo  := "SB1->" + aCampos[j] //SB1->B1_COD
                //"&" retira as aspas da string tornando ela uma função ou no caso variavel
				&cCampo := aDados[i,j] //SB1->B1_COD := 000008   SB1->B1_LOJA := 01 SB1->B1_NOME := JOSE
			//Proximo campo
            Next j
            //libera a tabela
			SB1->(MsUnlock())
		EndIf
        //proximo registro
	Next i
    //fim da transação
End Transaction
  clog := ArrTokStr(aDados)
  MsgAlert(clog, "aDados")
  clog := ArrTokStr(aCampos)
  MsgAlert(clog, "aCampos")
ApMsgInfo("Importação concluída com sucesso!","Sucesso!")
 
Return
