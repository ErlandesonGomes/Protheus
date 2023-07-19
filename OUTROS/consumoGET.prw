#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} User Function nomeFunction
    (long_description)private
    @type  Function
    @author user
    @since 18/07/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function APIFILME()
    private oRest := FWRest():New("http://127.0.0.1:4000")
    private aHeader := {}

    oRest:SetPath("/filmes")

    aAdd(aHeader,"Accept-Encoding: UTF-8")
    aAdd(aHeader,"Content-Type: application/json; charset=utf-8")


    IF oRest:Get(aHeader)
        ConOut("GET", oRest:GetResult())
    else
        ConOut("GET", oRest:GetLastError())
    ENDIF
    Private resultado := oRest:GetResult()
    Private erro := oRest:GetLastError()
    Alert(resultado)
    Alert(erro) 
Return 
