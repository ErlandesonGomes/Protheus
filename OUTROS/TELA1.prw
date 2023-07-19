#INCLUDE 'TOTVS.CH'


User Function TELA1

/* 
Declaração de cVariable dos componentes                                 
*/
Private cGcodigo   := Space(5)
Private cGNome     := Space(10)
Private cGender    := Space(15)

Private aDados := {}


//Declaração de Variaveis Private dos Objetos

SetPrvt("oDlg1","oSCod","oSnome","oSend","oGcodigo","oGNome","oGender","oBcreat","oBread","oBupdat","oGdell")


//Definicao do Dialog e todos os seus componentes.

//ROTULOS
oDlg1    := MSDialog():New(110, 265, 476                                      , 717  , "CRUD ADVPL",    ,    , .F.  ,          ,          ,          ,          ,    , .T.,   ,   , .T.)
oSCod    := TSay()    :New(020, 008, {||" CODIGO"}                            , oDlg1,             ,    , .F., .F.  , .F.      , .T.      , CLR_BLACK, CLR_WHITE, 060, 008)
oSnome   := TSay()    :New(020, 080, {||" NOME"}                              , oDlg1,             ,    , .F., .F.  , .F.      , .T.      , CLR_BLACK, CLR_WHITE, 060, 008)
oSend    := TSay()    :New(021, 153, {||" ENDEREÇO"}                          , oDlg1,             ,    , .F., .F.  , .F.      , .T.      , CLR_BLACK, CLR_WHITE, 060, 008)
//GETS
oGcodigo := TGet()    :New(032, 008, {|u| If(PCount()>0,cGcodigo:=u,cGcodigo)}, oDlg1, 060         , 008, '' ,      , CLR_BLACK, CLR_WHITE,          ,          ,    , .T., "",   ,    , .F., .F., , .F., .F., "", "cGcodigo", ,)
oGNome   := TGet()    :New(032, 080, {|u| If(PCount()>0,cGNome:=u,cGNome)}    , oDlg1, 060         , 008, '' ,      , CLR_BLACK, CLR_WHITE,          ,          ,    , .T., "",   ,    , .F., .F., , .F., .F., "", "cGNome"  , ,)
oGender  := TGet()    :New(032, 152, {|u| If(PCount()>0,cGender:=u,cGender)}  , oDlg1, 060         , 008, '' ,      , CLR_BLACK, CLR_WHITE,          ,          ,    , .T., "",   ,    , .F., .F., , .F., .F., "", "cGender" , ,)
//Botões
oBcreat := TButton():New(052, 008, "CREATE", oDlg1, {|u| crudc(cGcodigo,cGNome,cGender), cGcodigo := Space(5), cGNome := Space(10), cGender := Space(15)}, 037, 012, , , , .T., , "", , , , .F.)
oBread  := TButton():New(052, 064, "READ"  , oDlg1, {|u| crudr(cGcodigo)               , cGcodigo := Space(5)}                                                          , 037, 012, , , , .T., , "", , , , .F.)
oBupdat := TButton():New(052, 120, "UPDATE", oDlg1,              , 037, 012, , , , .T., , "", , , , .F.)
oGdell   := TButton() :New(052, 176, "DELETE"                                 , oDlg1,             , 037, 012,      ,          ,          , .T.      ,          , "" ,    ,   ,   , .F.)
//Lista
oLBox1   := TListBox():New(072, 004,                                          ,      , 212         , 096,    , oDlg1,          , CLR_BLACK, CLR_WHITE, .T.      ,    ,    ,   , "",    ,    ,    , ,    ,    ,)

oDlg1:Activate(,,,.T.)

Return


Static Function crudc(cCod,cNome,cEnde)
Local bExiste := .F.
    if Empty(Alltrim(cCod)) .or. Empty(Alltrim(cNome)) .or. Empty(Alltrim(cEnde))
        MsgAlert("Existe Campos Vazios, Favor Preencher!", "ERROR")
        else
            DbSelectArea("ZZA")
            ZZA->(DbSetOrder(1))
            ZZA->(DbGoTop())
            If DbSeek(xFilial("ZZA")+cCod)
            RecLock('ZZA', .T.)
            ZZA->ZZA_FILIAL := FWCodFil()
            ZZA->ZZA_COD    := Alltrim(cCod)
            ZZA->ZZA_Nome   := Alltrim(cNome)
            ZZA->ZZA_END    := Alltrim(cEnde)
            ZZA->(MsUnlock())
            ZZA->(DbCloseArea())
            MsgInfo("Inclusão Concluida", "Alerta")
            else    
            MsgInfo("O Registro da Existe", "Alerta")
            ZZA->(MsUnlock())
            ZZA->(DbCloseArea())
            ENDIF
         ENDIF   
    
Return 

Static Function crudr(cCod)
 Local bExiste := .F.
 DbSelectArea("ZZA")
 ZZA->(DbGoTop())
 ZZA->(DbSetOrder(1))
 If ZZA->(DbSeek("01"+ cCod))
    MsgAlert("Codigo -> "+ ZZA->ZZA_COD +"<BR>"+;
             "Nome -> "+ ZZA->ZZA_Nome +"<BR>"+;
             "Endereço -> "+ ZZA->ZZA_END , "Encontrado")
 EndIf

Return
