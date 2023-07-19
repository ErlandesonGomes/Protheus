#INCLUDE "totvs.ch"
#INCLUDE "TOPCONN.ch"

User Function zGatilhoProd()
    Local cTIPO := trim(M->B1_TIPO)
    Local cGRUPO := trim(M->B1_GRUPO)
    Local cprefixo := cTIPO+cGRUPO
    Local nUltimo := 0 
    Local aArea := SB1->(GetArea())
    Local cGatilho := trim(M->B1_COD)


        if LEN(cTIPO) > 1 .and. LEN(cGRUPO) > 1
            BeginSql Alias "TMP"
                SELECT SUBSTRING(MAX(B1_cod),6,10)+1 B1_codigo
                FROM SB1010 SB1
                WHERE       SUBSTRING(B1_COD,1,5)= %exp:cprefixo% and  Len( B1_COD ) = 10 and SB1.%NotDel%
                EndSql
                nUltimo := B1_codigo
                if nUltimo > 0
                        ("TMP")->(dbGoTop())
                        cprefixo += PADL((nUltimo),5,"0")
                        ("TMP")->(DbSkip())
                        ("TMP")->(dbCloseArea())
                        cGatilho := cprefixo
                    else
                        ("TMP")->(dbGoTop())
                        cprefixo += PADL((1),5,"0")
                        ("TMP")->(DbSkip())
                        ("TMP")->(dbCloseArea())
                        cGatilho := cprefixo
                    
                endif
            
        endif
        RestArea(aArea)

RETURN cGatilho
