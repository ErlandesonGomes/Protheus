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

          // avalia os itens, de modo a eliminar resíduos caso haja faturamento
          SC6->( dbGoTop() )
          SC6->( dbSeek( cFilSC6 + cPedido ) )
          while !SC6->(EOF()) .AND. SC6->C6_FILIAL == cFilSC6 .AND. SC6->C6_NUM == SC5->C5_NUM
               // tenta estornar as liberações do item
               MaAvalSC6("SC6",4,"SC5",Nil,Nil,Nil,Nil,Nil,Nil)
               
               lFaturado := (SC6->C6_QTDENT > 0)
               lLiberado := (SC6->C6_QTDEMP > 0)

               // se há liberação ou faturamento, o pedido não pode ser excluido!
               if lLiberado .OR. lFaturado
                    lPodeExcluir := .F.
               endif

               // se não pode excluir e não estiver liberado, tento eliminar o resíduo do item
               if !lPodeExcluir .AND. !lLiberado
                    MaResDoFat()
               endif

               SC6->( dbSkip() )
          enddo

          // depois de processar cada item do pedido, verifico
          // a possibilidade de excluir o pedido
          // obs.: o procedimento de eliminação de resídios, dentro do loop
          // já se encarrega de encerrar o pedido por resíduo
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
                    Alert("Pedido "+cPedido+" excluído com sucesso!")
               endif
          else
               if !EMPTY(SC5->C5_NOTA) .OR. (SC5->C5_LIBEROK = ‘E‘)
                    Alert("Resíduos do pedido "+cPedido+" foram eliminados. O pedido foi encerrado!")
               endif
          endif

    endif
    AAdd(aCabecEx, {"C5_NUM", cPedido, NIL})
    MATA410(aCabecEx, {} , 5)
    if lMsErroAuto
        MostraErro()
    endif
return
