#INCLUDE "totvs.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "tOPCONN.CH" 

User Function testemt110() //U_testemt110
local aCabecEx := {}
local lFaturado := .F., lLiberado := .F.
local lPodeExcluir := .T.
local cPedido := "016478"


     if SC5->( dbSeek( cFilSC5 + cPedido ) )

          // avalia os itens, de modo a eliminar res�duos caso haja faturamento
          SC6->( dbGoTop() )
          SC6->( dbSeek( cFilSC6 + cPedido ) )
          while !SC6->(EOF()) .AND. SC6->C6_FILIAL == cFilSC6 .AND. SC6->C6_NUM == SC5->C5_NUM
               // tenta estornar as libera��es do item
               MaAvalSC6("SC6",4,"SC5",Nil,Nil,Nil,Nil,Nil,Nil)
               
               lFaturado := (SC6->C6_QTDENT > 0)
               lLiberado := (SC6->C6_QTDEMP > 0)

               // se h� libera��o ou faturamento, o pedido n�o pode ser excluido!
               if lLiberado .OR. lFaturado
                    lPodeExcluir := .F.
               endif

               // se n�o pode excluir e n�o estiver liberado, tento eliminar o res�duo do item
               if !lPodeExcluir .AND. !lLiberado
                    MaResDoFat()
               endif

               SC6->( dbSkip() )
          enddo

          // depois de processar cada item do pedido, verifico
          // a possibilidade de excluir o pedido
          // obs.: o procedimento de elimina��o de res�dios, dentro do loop
          // j� se encarrega de encerrar o pedido por res�duo
          if lPodeExcluir
               aAdd( aCabecEx, {"C5_NUM"          , SC5->C5_NUM          , Nil} )
               aAdd( aCabecEx, {"C5_TIPO"         , SC5->C5_TIPO          , Nil} )
               aAdd( aCabecEx, {"C5_CLIENTE"     , SC5->C5_CLIENTE     , Nil} )
               aAdd( aCabecEx, {"C5_LOJACLI"     , SC5->C5_LOJACLI     , Nil} )
               aAdd( aCabecEx, {"C5_LOJAENT"     , SC5->C5_LOJAENT     , Nil} )
               aAdd( aCabecEx, {"C5_CONDPAG"     , SC5->C5_CONDPAG     , Nil} )
               
               lMsErroAuto := .F.
               MATA410(aCabecEx, {} , 5)
               if lMsErroAuto
                    MostraErro()
               else
                    Alert("Pedido "+cPedido+" exclu�do com sucesso!")
               endif
          else
               if !EMPTY(SC5->C5_NOTA) .OR. (SC5->C5_LIBEROK = �E�)
                    Alert("Res�duos do pedido "+cPedido+" foram eliminados. O pedido foi encerrado!")
               endif
          endif

    endif
    AAdd(aCabecEx, {"C5_NUM", cPedido, NIL})
    MATA410(aCabecEx, {} , 5)
    if lMsErroAuto
        MostraErro()
    endif
return
