#INCLUDE "totvs.ch"
#INCLUDE "TBICONN.CH"
/*/{Protheus.doc} TesteCli
)
    @type  Function
    @author user
    @since 21/10/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

USER Function testecli2()//U_TesteCli2
Local codiloj := "23461 01"
Local natureza := "101001"
local cMensagem := ""
PREPARE ENVIRONMENT EMPRESA '01' FILIAL '010101' USER 'admin' PASSWORD ' ' TABLES 'SA1' MODULO 'SIGAFAT'
cMensagem += NatuCli(codiloj,natureza)
RESET ENVIRONMENT
return


Static Function NatuCli(codiloj,natureza)//U_TesteCli
    Local cMensagem := ""
    Local aDados
    Local aLogAutoCli 
    Local i
    Private lMSHelpAuto    := .T.
    Private lAutoErrNoFile := .T.
    Private lMsErroAuto    := .F.
    
    DbSelectArea("SA1")
    dbSetOrder(1)
    SA1->(DBGOTOP(  ))
    DbSeek("0101  "+codiloj) //Alteração deve ter o registro SA1 posicionado
    ConOut(Repl("-", 80))
    ConOut(Repl("-", 80))
    ConOut(Repl("-", 80))
    ConOut(PadC("0101  "+codiloj, 80))
    ConOut(PadC("codiloj:"+codiloj, 80))
    ConOut(PadC("natureza:"+natureza, 80))
    ConOut(PadC(SA1->A1_FILIAL, 80))
    ConOut(PadC(SA1->A1_COD, 80))
    ConOut(PadC(SA1->A1_LOJA, 80))
    ConOut(PadC(SA1->A1_NOME, 80))
    ConOut(PadC(SA1->A1_PESSOA, 80))
    ConOut(PadC(SA1->A1_END, 80))
    ConOut(PadC(SA1->A1_NATUREZ, 80))
    ConOut(Repl("-", 80))
    ConOut(Repl("-", 80))
    ConOut(Repl("-", 80))


















    
    MsExecAuto( { |x,y| Mata030(x,y)},aDados, 4) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
    ConOut(Repl("-", 80))
    ConOut(Repl("-", 80))
    ConOut(Repl("-", 80))
    ConOut(PadC(SA1->A1_NATUREZ, 80))
    ConOut(PadC(lMsErroAuto, 80))
    ConOut(Repl("-", 80))
    ConOut(Repl("-", 80))
    ConOut(Repl("-", 80))
        If (lMsErroAuto)
            aLogAutoCli := GetAutoGRLog()
            For i := 1 To Len(aLogAutoCli)
                cMensagem += aLogAutoCli[i] + CRLF + (" ")
            Next
            //cMensagem += Mostraerro()
            ConOut(Repl("-", 80))
            ConOut(PadC("Mata030 automatic routine ended with error", 80))
            ConOut(PadC("Ended at: " + Time(), 80))
            ConOut(Repl("-", 80))
        Else
            ConOut(Repl("-", 80))
            ConOut(PadC("Mata030 automatic routine successfully ended", 80))
            ConOut(PadC("Ended at: " + Time(), 80))
            ConOut(Repl("-", 80))
        EndIf
    lMSHelpAuto    := .T.
    lAutoErrNoFile := .T.
    lMsErroAuto    := .F.
    SA1->(DbCloseArea())
Return  cMensagem
