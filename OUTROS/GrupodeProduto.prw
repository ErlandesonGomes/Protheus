#include "totvs.ch"

User Function fImpCsvGP() 
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
		dbSelectArea("SBM")
		dbSetOrder(1)
		dbGoTop()
        // Se Não encontrar o codigo na SBM então ira realizar a inclusão:
		If !dbSeek(xFilial("SBM")+aDados[i,1])
			Reclock("SBM",.T.)
            //Cadastra a Filial na tabela
        SBM->BM_FILIAL := xFilial("SBM")
        SBM->BM_MARKUP = 0
        SBM->BM_MARGPRE = 0
        SBM->BM_LENREL = 0
        SBM->BM_CORP = .F.
        SBM->BM_EVENTO = .F.
        SBM->BM_LAZER = .F.

            //Repete até i = a quantidade de registros no array aCampos
			For j:=1 to Len(aCampos)
				cCampo  := "SBM->" + aCampos[j] //SBM->BM_COD


                //"&" retira as aspas da string tornando ela uma função ou no caso variavel
				&cCampo := aDados[i,j] //SBM->BM_COD := 000008   SBM->BM_LOJA := 01 SBM->BM_NOME := JOSE
			//Proximo campo
            Next j
            //libera a tabela
			SBM->(MsUnlock())
		EndIf
        //proximo registro
	Next i
    //fim da transação
End Transaction
  
ApMsgInfo("Importação concluída com sucesso!","Sucesso!")
 
Return
