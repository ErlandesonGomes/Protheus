#INCLUDE "totvs.ch"

User Function testenota() //u_testenota
    local cCodigoProd := PADR("ES01000001",TAMSX3("B1_COD")[1])         
    local nSaldoAtual
    local nSaldoResidual
    // Valida se existe req, devera ser criado o indice
    DbSelectArea("SB2")
    SB2->(DBSETORDER( 1 ))
    SB2->(DBGOTOP(  ))
    if DbSeek(xFilial("SB2")+cCodigoProd)
        nSaldoAtual := SB2->B2_QATU
    EndIF
    DBCLOSEAREA("SB2")

    BeginSql Alias "SCP_TMP"
                    SELECT sum(CP_QUANT) - sum(CP_QUJE) as qtd,CP_PRODUTO 
                    FROM SCP010 as SCP
                    WHERE CP_PRODUTO = %exp:cCodigoProd% and D_E_L_E_T_ = '' and CP_STATUS = ''
                    GROUP BY CP_PRODUTO
                    EndSql
    nSaldoResidual := SCP_TMP->qtd
    ("SCP_TMP")->(dbCloseArea())


    nSaldoAtual := nSaldoAtual - nSaldoResidual


Return nSaldoAtual






