#include "totvs.ch"

/*/{Protheus.doc} MT120OK
O ponto se encontra no final da função e é disparado após a confirmação dos
itens da getdados e antes do rodapé da dialog do PC, deve ser utilizado para
validações especificas do usuario onde será controlada pelo retorno do ponto de
entrada oqual se for .F. o processo será interrompido e se .T. será validado.
@type function
@since 27/02/2020
@return lRet, logical, indica se está ok ou não
/*/
User Function MT120OK()
    Local aArea     as array
    Local lRet      as logical
    Local nX        as numeric
    Local Cont        as numeric

    //Inicializa as variáveis
    aArea := SC7->(getArea())
    lRet  := .T.
    Cont  := 0
     For nX    := 1 To Len(aCols)
        //Verifica se a data de entrega está menor que a data atual
        IF aCols[nX][32] = "445"
            Cont += 1
        ENDIF
        
     Next nX
     If Cont > 0 .AND. CONT < LEN(aCols)
            lRet      := .F.
            MsgStop("A TES de compra nacional foi utilizada indevidamente.")
    EndIf
     restArea(aArea)

Return lRet
