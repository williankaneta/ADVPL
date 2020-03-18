#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SOAPTEST
//TODO
@description Função Teste Classe TWsdlManager - Consumindo WebService SOAP
@author willian.kaneta
@since 10/11/2019
@version 1.0
@type function
/*/
user function SOAPTEST()
	Local oWsdl := TWsdlManager():New()
	Local lRet 	:= .F.
		
	oWsdl:lSSLInsecure := .T.
	oWsdl:lProcResp := .F.
	lRet := oWsdl:ParseURL( "http://linkwebservicesoap.com.br" )	
	
	If lRet 
		Alert("Conseguiu realizar o parse")
	Else
		cErro := "Problema ao configurar webservice (TWsdlManager): " + AllTrim(oWsdl:cError)
		Alert(cErro)
	EndIf
	
return
