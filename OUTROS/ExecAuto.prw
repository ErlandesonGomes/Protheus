#INCLUDE "TOTVS.CH"

USER FUNCTION EXECA()
aCabec := {}
aItens := {}

    aCabec :=           {{"C1_FILIAL", xFilial("SC1"), NIL},;
                        {"C1_SOLICIT"                     , "Administrador", NIL},;
                        {"C1_EMISSAO"                     , dDatabase      , NIL},;
                        {"C1_UNIDREQ"                     , ""             , NIL},;
                        {"C1_CODCOMP"                     , "001"          , NIL}}

    aadd(aItens,       {{"C1_ITEM", "0001", NIL},;
                        {"C1_PRODUTO"                     , "CD00300004"   , NIL},;
                        {"C1_QUANT"                       , 1              , NIL}})

    

MSExecAuto({|x,y,z| Mata110(x,y,z)},aCabec,aItens,3)


cErro := MostraErro("C:\temp\Log\", "teste.log")
                nLinhaErro := MLCount(cErro)
                cBuffer := ""
                cCampo := ""
                nErrLin := 1
                cBuffer := RTrim(MemoLine(cErro,,nErrLin))

                // Carrega o nome do campo
                While (nErrLin <= nLinhaErro)
                    nErrLin++
                    cBuffer := RTrim(MemoLine(cErro,,nErrLin))
                    If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO")
                        cCampo := cBuffer
                        xTemp := AT("-",cBuffer)
                        cCampo := AllTrim(SubStr(cBuffer,xTemp+1,AT(":",cBuffer)-xTemp-2))
                        Exit
                    EndIf
                EndDo


RETURN
