#include 'protheus.ch'
#include 'parmtype.ch'

user function F200DB1()
	ALERT(" SE5" + ALLTRIM(STR(SE5->E5_VALOR)))
	ALERT(" FK5" + ALLTRIM(STR(FK5->FK5_VALOR)))
return