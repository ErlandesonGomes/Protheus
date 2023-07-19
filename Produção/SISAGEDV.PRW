/*//#########################################################################################
Project  : Melhorias nos processos - FonNet
Module   : Financeiro
Source   : SISAGEDV
Objective: Se informado no título dados bancários será utilizado do título
           mas caso contrário será utilizado dos dados do fornecedor
*///#########################################################################################

/*/{Protheus.doc} SISAGEDV
    Gerenciador de Processamento
    @author  Dilson Castro
    @table   SA2, SE2
    @since   15-06-2022
    @type    function
/*/

User Function SISAGEDV()
    Local cAgeDv := ""
    If !Empty(Alltrim(SE2->E2_FORAGE))
        cAgeDv := PADR(ALLTRIM(SE2->E2_FORAGE)+ALLTRIM(SE2->E2_FAGEDV),5)
    Else
        cAgeDv := PADR(ALLTRIM(SA2->A2_AGENCIA)+ALLTRIM(SA2->A2_DVAGE),5)
    EndIf
Return cAgeDv
