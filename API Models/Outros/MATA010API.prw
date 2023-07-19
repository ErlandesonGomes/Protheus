#INCLUDE "TBICONN.CH"
#INCLUDE 'Totvs.ch'
#INCLUDE 'FWMVCDef.ch'
 
//------------------------------------------------------------------------
/*
EXEMPLO DE INCLUSÃO MODELO 1
*/
//------------------------------------------------------------------------
User Function m010IncRa()//U_m010IncRa
Local oModel      := Nil
Local aDados := {"10101","1RU1-08-  3SL-BR - 19” 1U rackmount 8 inches in depth with 3 Single-width LGX slots","PC","1",0,7.5,"85177900","","0.023",;
"1","10","1RU1-08- 3SL-BR","S","2111000","416","4","1","ME","9906562"}
Private lMsErroAuto := .F.
 
//Abre Ambiente (não deve ser utilizado caso utilize interface ou seja chamado de uma outra rotina que já inicializou o ambiente)
 
oModel := FwLoadModel("MATA010")
oModel:setOperation(MODEL_OPERATION_INSERT)
oModel:Activate()
oModel:SetValue("SB1MASTER",    "B1_FILIAL"     ,  aDados[1])   // varchar
oModel:SetValue("SB1MASTER",    "B1_DESC"       ,  aDados[2])   // varchar
oModel:SetValue("SB1MASTER",    "B1_UM"         ,  aDados[3])   // varchar
oModel:SetValue("SB1MASTER",    "B1_LOCPAD"     ,  aDados[4])   // varchar
oModel:SetValue("SB1MASTER",    "B1_PICM"       ,  aDados[5])   // float
oModel:SetValue("SB1MASTER",    "B1_IPI"        ,  aDados[6])   // float
oModel:SetValue("SB1MASTER",    "B1_POSIPI"     ,  aDados[7])   // varchar
oModel:SetValue("SB1MASTER",    "B1_EX_NCM"     ,  aDados[8])   // varchar
oModel:SetValue("SB1MASTER",    "B1_PESO"       ,  aDados[9])   // float
oModel:SetValue("SB1MASTER",    "B1_ORIGEM"     ,  aDados[10])  // varchar
oModel:SetValue("SB1MASTER",    "B1_CLASFIS"    ,  aDados[11])  // varchar
//oModel:SetValue("SB1MASTER",    "B1_YPARTNU"    ,  aDados[12])  // varchar
oModel:SetValue("SB1MASTER",    "B1_LOCALIZ"    ,  aDados[13])  // varchar
oModel:SetValue("SB1MASTER",    "B1_CEST"       ,  aDados[14])  // varchar
oModel:SetValue("SB1MASTER",    "B1_TE"         ,  aDados[15])  // varchar
oModel:SetValue("SB1MASTER",    "B1_GRTRIB"     ,  aDados[16])  // varchar
oModel:SetValue("SB1MASTER",    "B1_GRUPO"      ,  aDados[17])  // varchar
oModel:SetValue("SB1MASTER",    "B1_TIPO"       ,  aDados[18])  // varchar
oModel:SetValue("SB1MASTER",    "B1_COD"        ,  aDados[19])  // varchar
 
 
If oModel:VldData()
    oModel:CommitData()
     MsgInfo("Registro INCLUIDO!", "Atenção")
Else
    VarInfo("",oModel:GetErrorMessage())
EndIf       
     
oModel:DeActivate()
oModel:Destroy()
 
oModel := NIL
 
Return Nil
/*
//------------------------------------------------------------------------

//EXEMPLO DE INCLUSÃO MODELO 1  (Utilizando a função FwMvcRotAuto apenas em caráter didático)

//------------------------------------------------------------------------
User Function m010Inc1Ra()
Local aDadoscab := {}
Local aDadosIte := {}
Local aItens := {}
 
Private oModel := Nil
Private lMsErroAuto := .F.
Private aRotina := {}
 
//Abre Ambiente (não deve ser utilizado caso utilize interface ou seja chamado de uma outra rotina que já inicializou o ambiente)
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "EST"
 
oModel := FwLoadModel ("MATA010")
 
//Adicionando os dados do ExecAuto cab
aAdd(aDadoscab, {"B1_COD" ,"RASB101" , Nil})
aAdd(aDadoscab, {"B1_DESC" ,"PRODUTO TESTE" , Nil})
aAdd(aDadoscab, {"B1_TIPO" ,"PA" , Nil})
aAdd(aDadoscab, {"B1_UM" ,"UN" , Nil})
aAdd(aDadoscab, {"B1_LOCPAD" ,"01" , Nil})
aAdd(aDadoscab, {"B1_LOCALIZ" ,"N" , Nil})
 
//Chamando a inclusão - Modelo 1
lMsErroAuto := .F.
 
FWMVCRotAuto( oModel,"SB1",MODEL_OPERATION_INSERT,{{"SB1MASTER", aDadoscab}})
 
//Se houve erro no ExecAuto, mostra mensagem
If lMsErroAuto
 MostraErro()
//Senão, mostra uma mensagem de inclusão
Else
 MsgInfo("Registro incluido!", "Atenção")
EndIf
 
 
Return Nil
 
//------------------------------------------------------------------------

//EXEMPLO DE INCLUSÃO MODELO 2 (Utilizando a função FwMvcRotAuto apenas em caráter didático)

//------------------------------------------------------------------------
 
User Function m010Inc2Ra()
Local aDadoscab := {}
Local aDadosIte := {}
Local aItens := {}
 
Private oModel := Nil
Private lMsErroAuto := .F.
Private aRotina := {}
 
//Abre Ambiente (não deve ser utilizado caso utilize interface ou seja chamado de uma outra rotina que já inicializou o ambiente)
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "EST"
 
oModel := FwLoadModel ("MATA010")
 
//Adicionando os dados do ExecAuto cab
aAdd(aDadoscab, {"B1_COD" ,"RASB102" , Nil})
aAdd(aDadoscab, {"B1_DESC" ,"PRODUTO TESTE" , Nil})
aAdd(aDadoscab, {"B1_TIPO" ,"PA" , Nil})
aAdd(aDadoscab, {"B1_UM" ,"UN" , Nil})
aAdd(aDadoscab, {"B1_LOCPAD" ,"01" , Nil})
aAdd(aDadoscab, {"B1_LOCALIZ" ,"N" , Nil})
 
//Adicionando os dados do ExecAuto Item
//Produtos alternativos (já deve existir na base)
If "SGI" $ SuperGetMv("MV_CADPROD",,"|SA5|SBZ|SB5|DH5|SGI|")
 aAdd(aDadosIte, {"GI_PRODALT" , "RASB101" , Nil})
 aAdd(aDadosIte, {"GI_ORDEM" , "1" , Nil})
 //no item o array precisa de um nivel superior.
 aAdd(aItens,aDadosIte)
EndIf
 
//Chamando a inclusão - Modelo 2
lMsErroAuto := .F.
 
FWMVCRotAuto( oModel,"SB1",MODEL_OPERATION_INSERT,{{"SB1MASTER", aDadoscab},{"SGIDETAIL", aItens}})
 
//Se houve erro no ExecAuto, mostra mensagem
If lMsErroAuto
 MostraErro()
//Senão, mostra uma mensagem de inclusão
Else
 MsgInfo("Registro incluido!", "Atenção")
EndIf
 
 
Return Nil
 
//------------------------------------------------------------------------

//EXEMPLO DE ALTERAÇÃO

//------------------------------------------------------------------------
 
User Function m010AltRa()
Local oModel := Nil
Private lMsErroAuto := .F.
 
//Abre Ambiente (não deve ser utilizado caso utilize interface ou seja chamado de uma outra rotina que já inicializou o ambiente)
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "EST"
 
//Posiciona
SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial("SB1") + "RASB101"))
 oModel := FwLoadModel ("MATA010")
 oModel:SetOperation(MODEL_OPERATION_UPDATE)
 oModel:Activate()
 oModel:SetValue("SB1MASTER","B1_DESC","PRODUTO ALTERADO")
 
If oModel:VldData()
 oModel:CommitData()
 MsgInfo("Registro ALTERADO!", "Atenção")
 Else
 VarInfo("",oModel:GetErrorMessage())
 EndIf
  
 oModel:DeActivate()
Else
 MsgInfo("Registro NAO LOCALIZADO!", "Atenção")
EndIf
 
Return Nil
 
//------------------------------------------------------------------------

//EXEMPLO DE EXCLUSÃO

//------------------------------------------------------------------------
 
User Function m010ExcRa()
Local oModel := Nil
Private aRotina := {}
 
//Abre Ambiente (não deve ser utilizado caso utilize interface ou seja chamado de uma outra rotina que já inicializou o ambiente)
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "EST"
//Posiciona
SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial("SB1") + "RASB101"))
 oModel := FwLoadModel ("MATA010")
 oModel:SetOperation(MODEL_OPERATION_DELETE)
 oModel:Activate()
 
If oModel:VldData()
 oModel:CommitData()
 MsgInfo("Registro EXCLUIDO!", "Atenção")
 Else
 VarInfo("",oModel:GetErrorMessage())
 EndIf
  
 oModel:DeActivate()
Else
 MsgInfo("Registro NAO LOCALIZADO!", "Atenção")
EndIf
 
Return Nil
/*
