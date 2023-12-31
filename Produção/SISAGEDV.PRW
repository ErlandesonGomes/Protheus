/*//#########################################################################################
Project  : Melhorias nos processos - FonNet
Module   : Financeiro
Source   : SISAGEDV
Objective: Se informado no t�tulo dados banc�rios ser� utilizado do t�tulo
           mas caso contr�rio ser� utilizado dos dados do fornecedor
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
