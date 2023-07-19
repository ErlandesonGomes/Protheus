#Include 'Protheus.ch'



/*/{Protheus.doc} F200VAR
Tratamento para desconsiderar despesa bancária no retorno do CNAB
@author Augusto Ribeiro | www.compila.com.br
@since 07/10/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function F200VAR(aValores)
Local aRet	:= aclone(PARAMIXB)

NVALREC 	:= PARAMIXB[1,8]+PARAMIXB[1,5] //| |
nDespes		:= 0

aRet[1,8]	:= NVALREC
aRet[1,5] 	:= nDespes

/*
// Estrutura de aValores
//	Numero do Tulo		- 01
//	data da Baixa		- 02
// Tipo do Tiulo		- 03
// Nosso Numero			- 04
// Valor da Despesa		- 05
// Valor do Desconto	- 06
// Valor do Abatiment	- 07
// Valor Recebido    	- 08
// Juros				- 09
// Multa				- 10
// Outras Despesas		- 11
// Valor do Credito		- 12
// Data Credito			- 13
// Ocorrencia			- 14
// Motivo da Baixa 		- 15
// Linha Inteira		- 16
// Data de Vencto	   	- 17

aValores := ( { cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nOutrDesp, nValCc, dDataCred, cOcorr, cMotBan, xBuffer,dDtVc,{} })

*/
Return(aRet)


