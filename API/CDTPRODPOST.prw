#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"
#include "fwmvcdef.ch"

WSRESTFUL cdProdPost DESCRIPTION "ServiÃ§o REST para manipulaÃ§Ã£o de Produtos"

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
            Menssage += ","
        endif
        Menssage += '"' + cValToChar(nPCount) + '"' + " : "
            
            IF jProduto["Produtos"][nPCount]["OPERACAO"] = "I"
                if !SB1->( DbSeek( xFilial("SB1") + jProduto["Produtos"][nPCount]["CODPRODUTO"]) )
                    cOperation := MODEL_OPERATION_INSERT
                    ConOut( "Inserido")
                ELSE
                    ConOut( "Ja cadastrado")
                    Menssage += '"' + "Já cadastrado" + '"'
                    cError := "Já cadastrado"
                
                ENDIF
            ELSE
                IF jProduto["Produtos"][nPCount]["OPERACAO"] = "U"
                    SB1->(DbSetOrder(1))
                    If SB1->(DbSeek(xFilial("SB1") + jProduto["Produtos"][nPCount]["CODPRODUTO"]))
                        cOperation := MODEL_OPERATION_UPDATE
                        ConOut( "UPDATE")
                    else
                        ConOut( "Produto não cadastrado")
                        Menssage += '"' + "Produto não cadastrado" + '"'
                        cError := "Produto não cadastrado"
                    
                    endif
                ELSE
                    IF jProduto["Produtos"][nPCount]["OPERACAO"] = "D"
                    SB1->(DbSetOrder(1))
                    If SB1->(DbSeek(xFilial("SB1") + jProduto["Produtos"][nPCount]["CODPRODUTO"]))
                            cOperation := MODEL_OPERATION_DELETE
                    else
                            ConOut( "Produto não cadastrado")
                            Menssage += '"' + "Produto não cadastrado" + '"'
                            cError := "Produto não cadastrado"
                        endif
                    else
                    cError := "Operação não encontrada"
                    endif
                ENDIF
            ENDIF
        if Empty(cError)
                oModel := FwLoadModel("MATA010")

                oModel:setOperation(cOperation)
                oModel:Activate()
                if jProduto["Produtos"][nPCount]["OPERACAO"] != "D"
                    oModel:SetValue("SB1MASTER", "B1_FILIAL" , jProduto["Produtos"][nPCount]["FILIAL"]) // varchar
                    oModel:SetValue("SB1MASTER", "B1_DESC" , jProduto["Produtos"][nPCount]["PRODDESC"]) // varchar
                    oModel:SetValue("SB1MASTER", "B1_UM" , jProduto["Produtos"][nPCount]["PRODUM"]) // varchar
                    oModel:SetValue("SB1MASTER", "B1_LOCPAD" , jProduto["Produtos"][nPCount]["PRODLOCPAD"]) // varchar
                    oModel:SetValue("SB1MASTER", "B1_PICM" , jProduto["Produtos"][nPCount]["ALIQICMS"]) // float
                    oModel:SetValue("SB1MASTER", "B1_IPI" , jProduto["Produtos"][nPCount]["ALIQIPI"]) // float
                    oModel:SetValue("SB1MASTER", "B1_POSIPI" , jProduto["Produtos"][nPCount]["NCM"]) // varchar
                    oModel:SetValue("SB1MASTER", "B1_EX_NCM" , jProduto["Produtos"][nPCount]["EXNCM"]) // varchar
                    oModel:SetValue("SB1MASTER", "B1_PESO" , jProduto["Produtos"][nPCount]["PESO"]) // float
                    oModel:SetValue("SB1MASTER", "B1_ORIGEM" , jProduto["Produtos"][nPCount]["ORIGEM"]) // varchar
                    oModel:SetValue("SB1MASTER", "B1_CLASFIS" , jProduto["Produtos"][nPCount]["CLASSFISCAL"]) // varchar
                    oModel:SetValue("SB1MASTER", "B1_YPARTNU" , jProduto["Produtos"][nPCount]["PARTNUMBER"]) // varchar
                    oModel:SetValue("SB1MASTER", "B1_LOCALIZ" , jProduto["Produtos"][nPCount]["ENDERECAMENTO"]) // varchar
                    oModel:SetValue("SB1MASTER", "B1_CEST" , jProduto["Produtos"][nPCount]["CEST"]) // varchar
                    oModel:SetValue("SB1MASTER", "B1_TE" , jProduto["Produtos"][nPCount]["TES"]) // varchar
                    oModel:SetValue("SB1MASTER", "B1_GRTRIB" , jProduto["Produtos"][nPCount]["GRUPTRIB"]) // varchar
                    
                    IF jProduto["Produtos"][nPCount]["OPERACAO"] = "I"

                        oModel:SetValue("SB1MASTER", "B1_GRUPO" , jProduto["Produtos"][nPCount]["CODGRUPO"]) // varchar
                        oModel:SetValue("SB1MASTER", "B1_TIPO" , jProduto["Produtos"][nPCount]["PRODTIPO"]) // varchar
                        oModel:SetValue("SB1MASTER", "B1_COD" , jProduto["Produtos"][nPCount]["CODPRODUTO"]) // varchar
                    
                    END IF
                endif
                if oModel:VldData()
                    lOk := oModel:CommitData()
                    Menssage += '"' +"Success"+ '"'
                    ConOut("Sucesso")

                    
                else
                    Menssage += '"' + oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE] + '"'

                    
                endif

                oModel:Destroy()
                FreeObj(oModel)
        endif

            //RestAlias(aAreaSB1)

            if !Empty(cAlias)
                DBSelectArea(cAlias)
            endif
    NEXT
        Menssage += "}"
        ConOut(Menssage)
        ConOut(jProduto)
        ::SetResponse(EncodeUTF8(Menssage))
        else
            cError + "JSON OBTIDO: " + jProduto
            SetRestFault(418,EncodeUTF8(cError),.T.,/*nStatus*/,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
            Return .F.
        endif
    
        
        
return lOk


