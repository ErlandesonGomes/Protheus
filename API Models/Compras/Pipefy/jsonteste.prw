// BIBLIOTECAS NECESSÁRIAS
#Include "TOTVS.ch"

user Function Jsonteste()//U_Jsonteste
   Local cItem := "0001" 
   Local nQuantidade := 10 
   Local nV_Unitario := 10 
   Local nV_TOTAL := 100
   Local cTRI := "1010101010"
   Local oProduto := '{"Card":"627085031","DPI":"318090448","Total": 100,"Produto":[{"Quantidade": 10,"TRI":"1010101010","V_TOTAL": 100,"Item":"0001","V_Unitario": 10},{"Quantidade": 11,"TRI":"1010101010","V_TOTAL": 100,"Item":"0001","V_Unitario": 10}]}'
   Local oFinal := JsonObject():New()
   Local cCard := "627085031"
   Local nTotal := 100
   Local cDPI := "318090448"
    MsgAlert("OK", "FUNCIONA?")

   
   oFinal:FromJson(oProduto)
    ConOut( oFinal)

Return 



