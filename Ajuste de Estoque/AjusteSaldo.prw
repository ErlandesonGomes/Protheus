#include "totvs.ch"

User Function AtlCusto() 
Local cDiret
Local _aCab1 := {}
Local _aItem := {}
Local _atotitem:={}

Local cLinha  := ""
Local lPrimlin   := .T.
Local aCampos := {}
Local aDados  := {}
Local i
local clog := ""
local aErro := {}
LOCAL cError := ""
local j
Private lMsErroAuto   := .F.
Private lMsHelpAuto   := .F.
Private lAutoErrNoFile:= .T.
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

	ProcRegua(Len(aDados))
    //Repete at� i = a quantidade de registros no array aDados
    AADD(_aCab1,{aCampos[5] ,aDados[1,5] ,NIL})
    AADD(_aCab1,{aCampos[6] ,aDados[1,6] ,NIL})
	For i:=1 to Len(aDados)
 
		IncProc("Importando Registros...")
        _aItem := {}
        AADD(_aItem,{aCampos[1] ,aDados[i,1] ,NIL}) 
        AADD(_aItem,{aCampos[2] ,val(aDados[i,2]) ,NIL}) 
        AADD(_aItem,{aCampos[3] ,PadL(aDados[i,3], 2, '0') ,NIL})
        AADD(_aItem,{aCampos[4] ,val(aDados[i,4]) ,NIL}) 
        aadd(_atotitem,_aitem) 
	Next i
    //fim da transa��o  

  clog := ArrTokStr(_aCab1)
  MsgAlert(clog, "aDados")
  clog := ArrTokStr(_atotitem)
  MsgAlert(clog, "aCampos")
MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)

If lMsErroAuto 
    
    aErro := GetAutoGRLog()
            cError += "1"
            
            For j := 1 To Len(aErro)
                cError += aErro[j] + CRLF + (" ")
                ConOut(OemToAnsi(aErro[j]))
            Next

            ConOut(OemToAnsi("Erro!"))
        Else

         
            ConOut(OemToAnsi("Atualizacao realizada com exito!")) 
     
    DisarmTransaction() 
    break

EndIf

if cError <> "" 
    ConOut(OemToAnsi("Houve falhas!")) 
    ConOut(OemToAnsi(cError)) 
    RERPM01(cError)
    ApMsgInfo("Importa��o Falhou! :( ","Error!")    
else
    ApMsgInfo("Importacao concluida com sucesso!","Sucesso!")
end if

Return 



Static Function RERPM01 (texto)

Local cDir    := "C:\Temp\"
Local cArq    := "ResultadoInventario.txt"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³FCreate - É o comando responsavel pela criaaoo do arquivo.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nHandle := FCreate(cDir+cArq)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³nHandle - A funaoo FCreate retorna o handle, que indica se foi possível ou não criar o arquivo. Se o valor for     ³
//³menor que zero, não foi possível criar o arquivo.                                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nHandle < 0
	MsgAlert("Erro durante criaaoo do arquivo." + FError())
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FWrite - Comando reponsavel pela gravaaoo do texto.                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		FWrite(nHandle, texto)
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FClose - Comando que fecha o arquivo, liberando o uso para outros programas.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    FClose(nHandle)
EndIf


