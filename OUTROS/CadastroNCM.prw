#include "totvs.ch"

User Function ncmImpCsv() 
Local cDiret
Local cLinha  := ""
Local lPrimlin   := .T.
Local aCampos := {}
Local aDados  := {}
Local i
Local j 
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
		dbSelectArea("SYD")
		dbSetOrder(1)
		dbGoTop()
        // Se Não encontrar o codigo na SYD então ira realizar a inclusão:
		If !dbSeek(xFilial("SYD")+aDados[i,1])
			Reclock("SYD",.T.)
            //Cadastra a Filial na tabela
        SYD->YD_FILIAL := xFilial("SYD")
        SYD->YD_PER_II := 0
        SYD->YD_PER_IPI := 0
        SYD->YD_ICMS_RE := 0
        SYD->YD_NUM_EX := 0
        SYD->YD_ANUENTE := "2"
        SYD->YD_PER_PIS := 0
        SYD->YD_VLU_PIS := 0
        SYD->YD_RED_PIS := 0
        SYD->YD_PER_COF := 0
        SYD->YD_VLU_COF := 0
        SYD->YD_RED_COF := 0
        SYD->YD_GRVUSER := "Administrador"                 
        SYD->YD_GRVDATA := dDatabase
        SYD->YD_GRVHORA := "10:47:43"
        SYD->YD_CRDPRES := 0
        SYD->YD_ICMS_PC := 0
        SYD->YD_MAJ_COF := 0
        SYD->YD_ALIQIMP := 0
        SYD->YD_MAJ_PIS := 0
        SYD->YD_ALIQIM2 := 0
        SYD->YD_PER_IE := 0



            //Repete até i = a quantidade de registros no array aCampos
			For j:=1 to Len(aCampos)
				cCampo  := "SYD->" + aCampos[j] //SYD->B1_COD
                //"&" retira as aspas da string tornando ela uma função ou no caso variavel
				&cCampo := aDados[i,j] //SYD->B1_COD := 000008   SYD->B1_LOJA := 01 SYD->B1_NOME := JOSE
			//Proximo campo
            Next j
            //libera a tabela
			SYD->(MsUnlock())
		EndIf
        //proximo registro
	Next i
    //fim da transação
End Transaction
  
ApMsgInfo("Importação concluída com sucesso!","Sucesso!")
 
Return
