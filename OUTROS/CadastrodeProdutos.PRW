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

	If lPrimlin  //Se a variavel lPrimlin for .T. significa que � a primeira linha(cabe�ario)
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
    //Repete at� i = a quantidade de registros no array aDados
	For i:=1 to Len(aDados)
 
		IncProc("Importando Registros...")
    // Seleciona a tabela e posiciona no topo
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbGoTop()
        // Se N�o encontrar o codigo na CTT ent�o ira realizar a inclus�o:
		If !dbSeek(xFilial("SB1")+aDados[i,1])
			Reclock("SB1",.T.)
            //Cadastra a Filial na tabela
        
        


            //Repete at� i = a quantidade de registros no array aCampos
			For j:=1 to Len(aCampos)
				cCampo  := "SB1->" + aCampos[j] //CTT->B1_COD
                //"&" retira as aspas da string tornando ela uma fun��o ou no caso variavel
				&cCampo := aDados[i,j] //CTT->B1_COD := 000008   CTT->B1_LOJA := 01 CTT->B1_NOME := JOSE
			//Proximo campo
            Next j
            //libera a tabela
			CTT->(MsUnlock())
		EndIf
        //proximo registro
	Next i
    //fim da transa��o
End Transaction
  clog := ArrTokStr(aDados)
  MsgAlert(clog, "aDados")
  clog := ArrTokStr(aCampos)
  MsgAlert(clog, "aCampos")
ApMsgInfo("Importa��o conclu�da com sucesso!","Sucesso!")
 
Return
