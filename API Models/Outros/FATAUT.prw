#INCLUDE "totvs.CH"
#INCLUDE "TBICONN.CH"
user Function Teste123()
local Pedido := "000008"
Local msg
    PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FAT" TABLES "SF2","SD2","SA1","SA2","SB1","SB2","SF4","SED","SE1"
MyPVLNFS(Pedido)

    RESET ENVIRONMENT
return

Static Function MyPVLNFS(Pedido)

    Local aPvlDocS := {}
    Local nPrcVen := 0
    Local cSerie  := "1"
    Local cEmbExp := ""
    Local cDoc    

    SC5->(DbSetOrder(1))
    SC5->(MsSeek(xFilial("SC5")+Pedido))

    SC6->(dbSetOrder(1))
    SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))

    //É necessário carregar o grupo de perguntas MT460A, se não será executado com os valores default.
    Pergunte("MT460A",.F.)

    // Obter os dados de cada item do pedido de vendas liberado para gerar o Documento de Saída
    While SC6->(!Eof() .And. C6_FILIAL == xFilial("SC6")) .And. SC6->C6_NUM == SC5->C5_NUM

        SC9->(DbSetOrder(1))
        SC9->(MsSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))) //FILIAL+NUMERO+ITEM

        SE4->(DbSetOrder(1))
        SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )  //FILIAL+CONDICAO PAGTO

        SB1->(DbSetOrder(1))
        SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))    //FILIAL+PRODUTO

        SB2->(DbSetOrder(1))
        SB2->(MsSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL))) //FILIAL+PRODUTO+LOCAL

        SF4->(DbSetOrder(1))
        SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))   //FILIAL+TES

        nPrcVen := SC9->C9_PRCVEN
        If ( SC5->C5_MOEDA <> 1 )
            nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
        EndIf

		If AllTrim(SC9->C9_BLEST) == "" .And. AllTrim(SC9->C9_BLCRED) == ""
        	AAdd(aPvlDocS,{ SC9->C9_PEDIDO,;
                        	SC9->C9_ITEM,;
                        	SC9->C9_SEQUEN,;
                        	SC9->C9_QTDLIB,;
                        	nPrcVen,;
                        	SC9->C9_PRODUTO,;
                        	.F.,;
                        	SC9->(RecNo()),;
                        	SC5->(RecNo()),;
                        	SC6->(RecNo()),;
                        	SE4->(RecNo()),;
                        	SB1->(RecNo()),;
                        	SB2->(RecNo()),;
                        	SF4->(RecNo())})
		EndIf

        SC6->(DbSkip())
    EndDo

	SetFunName("MATA461")
    cDoc := MaPvlNfs(  /*aPvlNfs*/         aPvlDocS,;  // 01 - Array com os itens a serem gerados
                       /*cSerieNFS*/       cSerie,;    // 02 - Serie da Nota Fiscal
                       /*lMostraCtb*/      .F.,;       // 03 - Mostra Lançamento Contábil
                       /*lAglutCtb*/       .F.,;       // 04 - Aglutina Lançamento Contábil
                       /*lCtbOnLine*/      .F.,;       // 05 - Contabiliza On-Line
                       /*lCtbCusto*/       .T.,;       // 06 - Contabiliza Custo On-Line
                       /*lReajuste*/       .F.,;       // 07 - Reajuste de preço na Nota Fiscal
                       /*nCalAcrs*/        0,;         // 08 - Tipo de Acréscimo Financeiro
                       /*nArredPrcLis*/    0,;         // 09 - Tipo de Arredondamento
                       /*lAtuSA7*/         .T.,;       // 10 - Atualiza Amarração Cliente x Produto
                       /*lECF*/            .F.,;       // 11 - Cupom Fiscal
                       /*cEmbExp*/         cEmbExp,;   // 12 - Número do Embarque de Exportação
                       /*bAtuFin*/         {||},;      // 13 - Bloco de Código para complemento de atualização dos títulos financeiros
                       /*bAtuPGerNF*/      {||},;      // 14 - Bloco de Código para complemento de atualização dos dados após a geração da Nota Fiscal
                       /*bAtuPvl*/         {||},;      // 15 - Bloco de Código de atualização do Pedido de Venda antes da geração da Nota Fiscal
                       /*bFatSE1*/         {|| .T. },; // 16 - Bloco de Código para indicar se o valor do Titulo a Receber será gravado no campo F2_VALFAT quando o parâmetro MV_TMSMFAT estiver com o valor igual a "2".
                       /*dDataMoe*/        dDatabase,; // 17 - Data da cotação para conversão dos valores da Moeda do Pedido de Venda para a Moeda Forte
                       /*lJunta*/          .F.)        // 18 - Aglutina Pedido Iguais
    
    If !Empty(cDoc)
        Conout("Documento de Saída: " + cSerie + "-" + cDoc + ", gerado com sucesso!!!")
    EndIf


Return cDoc

Static Function GeraNota()

aPVlNFs := {}

//Funcao automatica para pegar a serie e o numero da nota fiscal.
//lRet := Sx5NumNota()

DbSelectArea("SX5")
DbSetOrder(1)
If !DbSeek(xFilial("SX5")+"01"+cSerie)
     MsgInfo("Série Inválida!","Geração de NF")
     Return()     
     
Else
          RecLock("SX5",.F.)              
          //Alert(cNumero)
          //Alert(SX5->X5_DESCRI)
          SX5->X5_DESCRI := cNumero
          SX5->X5_DESCSPA := cNumero
          SX5->X5_DESCENG := cNumero
        //Alert(SX5->X5_DESCRI)
          MsUnlock()

EndIF


IncProc()
DbSelectArea("SC9")
DbSetOrder(1)
DbSeek(xFilial("SC9")+c_NumPed)
While !EOF() .And. (C9_FILIAL+C9_PEDIDO = xFilial("SC9")+c_NumPed)
     If SC9->C9_BLCRED == " " .And. SC9->C9_BLEST == " "
          
          cTes := Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,"C6_TES")
          cCondPag := Posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,"C5_CONDPAG")
          aadd(aPvlNfs,{ SC9->C9_PEDIDO,;
          SC9->C9_ITEM,;
          SC9->C9_SEQUEN,;
          SC9->C9_QTDLIB,;
          SC9->C9_PRCVEN,;
          SC9->C9_PRODUTO,;
          SF4->F4_ISS=="S",;
          SC9->(RecNo()),;
          SC5->(Recno(Posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,""))),;
          SC6->(Recno(Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,""))),;
          SE4->(Recno(Posicione("SE4",1,xFilial("SE4")+cCondPag,""))),;
          SB1->(Recno(Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,""))),;
          SB2->(Recno(Posicione("SB2",1,xFilial("SB2")+SC9->C9_PRODUTO,""))),;
          SF4->(Recno(Posicione("SF4",1,xFilial("SF4")+cTes,""))),;
          Posicione("SB2",1,xFilial("SB2")+SC9->C9_PRODUTO,"B2_LOCAL"),;
          1,;
          SC9->C9_QTDLIB2})
          
     EndIf
     DbSelectArea("SC9")
     DbSkip()
End


If Len(aPvlNfs) > 0
     
     Posicione("SA1",1,xFilial("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA,"")
     
     cNota := MAPVLNFS(aPVlNFs,cSerie,.F.,.F.,.F.,.F.,.F.,1,1,.T.,.F.,,,)
     
     If Empty(cNota)
          Alert("Ocorreu um problema na geração da Nota Fiscal")
     
     Else
          Aadd(_aNotas, AllTrim(cNota))
          //Alert(cNota)
     EndIf
     
Else
     Alert("Pedido com itens não liberados!")
EndIf

Return
