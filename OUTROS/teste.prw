#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"
#include "fwmvcdef.ch"

WSRESTFUL cdProdPost DESCRIPTION "Servi�o REST para manipula��o de Produtos"

    WSDATA CodProduto as String

    WSMETHOD POST DESCRIPTION "Retorna o produto informado na URL" WSSYNTAX "/cdProdPost" PATH "/cdProdPost" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD POST WSSERVICE cdProdPost
    local jProduto
    local cError as char
    local Menssage := "{ "
    local cAlias as char
    local lOk as logical
    local aAreaSB1 as array
    local cOPERATION := 0
    local nPCount := 0
    Private lMsErroAuto := .F.

    Self:SetContentType("application/json")

    jProduto := JsonObject():New()
    cError := jProduto:fromJson( self:getContent() )
    lOk := .F.
        
    if Empty(cError)
        cAlias := Alias()
        aAreaSB1 := SB1->( GetArea() )

        For nPCount := 1 to Len(jProduto["Produtos"])
            cError := ""
            if nPCount != 1
                Menssage := ","
            endif
            Menssage := '"' + cValToChar(nPCount) + '"' + " : "
            
            IF jProduto["Produtos"][nPCount]["OPERACAO"] = "I"
                if !SB1->( DbSeek( xFilial("SB1") + jProduto["Produtos"][nPCount]["CODPRODUTO"]) )
                    cOperation := MODEL_OPERATION_INSERT
                    ConOut( "Inserido")
                ELSE
                    ConOut( "Ja cadastrado")
                    Menssage := '"' + "J� cadastrado" + '"'
                    cError := "J� cadastrado"
                
                ENDIF
            ELSE
                IF jProduto["Produtos"][nPCount]["OPERACAO"] = "U"
                    SB1->(DbSetOrder(1))
                    If SB1->(DbSeek(xFilial("SB1") + jProduto["Produtos"][nPCount]["CODPRODUTO"]))
                        cOperation := MODEL_OPERATION_UPDATE
                        ConOut( "UPDATE")
                    else
                        ConOut( "Produto n�o cadastrado")
                        Menssage := '"' + "Produto n�o cadastrado" + '"'
                        cError := "Produto n�o cadastrado"
                                    
                    endif
                ELSE
                    IF jProduto["Produtos"][nPCount]["OPERACAO"] = "D"
                        SB1->(DbSetOrder(1))
                        If SB1->(DbSeek(xFilial("SB1") + jProduto["Produtos"][nPCount]["CODPRODUTO"]))
                            cOperation := MODEL_OPERATION_DELETE
                        else
                            ConOut( "Produto n�o cadastrado")
                            Menssage := '"' + "Produto n�o cadastrado" + '"'
                            cError := "Produto n�o cadastrado"
                        endif
                    else
                        cError := "Opera��o n�o encontrada"
                    endif
                ENDIF
            ENDIF
