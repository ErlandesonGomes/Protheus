#INCLUDE 'TOTVS.ch'

User Function LogPrd()
    Private cTitulo := "Log de Eventos de Produtos"
    Private aRotina :={}
    
    AADD(aRotina,{"Pesquisa" , "AxPesqui",0,1})
    AADD(aRotina,{"Visualizar" , "AxVisual",0,2})
    DbSelectArea("YPL")
    DbSetOrder(1)
    mBrowse(,,,,"YPL")
Return Nil
