/*//#########################################################################################
Project  : Melhorias nos processos - FonNet
Module   : Financeiro
Source   : SISBANCO
Objective: Se informado no título dados bancários será utilizado do título
           mas caso contrário será utilizado dos dados do fornecedor
*///#########################################################################################

/*/{Protheus.doc} SISBANCO
    Gerenciador de Processamento
    @author  Dilson Castro
    @table   SA2, SE2
    @since   15-06-2022
    @type    function
/*/

User Function SISBANCO()
    Local cBanco := ""
    If !Empty(Alltrim(SE2->E2_FORBCO))
        cBanco := STRZERO(VAL(SE2->E2_FORBCO),3)
    Else
        cBanco := STRZERO(VAL(SA2->A2_BANCO),3)
    EndIf
Return cBanco
