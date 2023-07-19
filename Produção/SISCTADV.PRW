/*//#########################################################################################
Project  : Melhorias nos processos - FonNet
Module   : Financeiro
Source   : SISCTADV
Objective: Se informado no título dados bancários será utilizado do título
           mas caso contrário será utilizado dos dados do fornecedor
*///#########################################################################################

/*/{Protheus.doc} SISCTADV
    Gerenciador de Processamento
    @author  Dilson Castro
    @table   SA2, SE2
    @since   15-06-2022
    @type    function
/*/

User Function SISCTADV()
    Local cCtaDv := ""
    If !Empty(Alltrim(SE2->E2_FORCTA))
        cCtaDv := PADR(ALLTRIM(SE2->E2_FORCTA)+ALLTRIM(SE2->E2_FCTADV),5)
    Else
        cCtaDv := PADR(ALLTRIM(SA2->A2_NUMCON)+ALLTRIM(SA2->A2_DVCTA),15)
    EndIf
Return cCtaDv
