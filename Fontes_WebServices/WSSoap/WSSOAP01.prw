#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} WSSOAP01
//TODO 
@description Função para iniciar processo Aprovação Pedido de Compras no Fluig
@author Willian Kaneta
@since 06/11/2019
@version 1.0
@type function
/*/
user function WSSOAP01(cPedido)
	Local aArea         := GetArea()
	Local lRet          := .T.
	Local cMensagem     := ''
	Local xRet          := ''
	Local cMsg          := ''
	Local cIdWF		    := "SUP-PC - Pedido de Compra" 
	Local oXml          := NIL
	Local cErro         := ''
	Local cAviso        := ''
	Local cTag          := ''
	Local aDadosPed		:= {}
	
	Private cUsuario   	:= "usuario.webservice"	//SuperGetMV('MV_ECMUSER',,'')
	Private cSenha     	:= "senha"		//SuperGetMV('MV_ECMPSW',,'')
	Private cEmpresa   	:= "001"			//SuperGetMV('MV_ECMEMP',,'0')
	Private cUrl       	:= //URL do Web Service
	Private aWsdl      	:= {}		 		// Carrega os objetos TWsdlManager ja utilizados para performance
	Private aValores   	:= {}
	Private aCardData  	:= {}

	aDadosPed := RETDADOSPED(cPedido)
	
	If Len(aDadosPed) > 0 
		Begin Sequence
	
			aadd(aValores, {"username"         , cUsuario      })
			aadd(aValores, {"password"         , JurEncUTF8(cSenha)})
			aadd(aValores, {"companyId"        , cEmpresa      })
			aadd(aValores, {"processId"        , cIdWF         })
			aadd(aValores, {"choosedState"     , "9"           })
			aadd(aValores, {"userId"           , "integracao"  })
			aadd(aValores, {"completeTask"     , "true"        })
			aadd(aValores, {"managerMode"      , "false"       })
			aadd(aValores, {"comments"         , "WF iniciado pelo PROTHEUS - APROVAÇÃO PEDIDO DE COMPRAS"       })				
		
			aAdd(aCardData,{"txt_Filial"		,  aDadosPed[1][1], 0, 0 })  //Filial Pedido
			aAdd(aCardData,{"txt_documento"		,  aDadosPed[2][1], 0, 0 })  //Número Pedido
			aAdd(aCardData,{"txt_fornecedor"	,  aDadosPed[3][1], 0, 0 })  //Nome Fornecedor
			aAdd(aCardData,{"txt_CondPagamento"	,  aDadosPed[4][1], 0, 0 })  //Nome Fornecedor
			aAdd(aCardData,{"txt_dataEmissao"	,  aDadosPed[5][1], 0, 0 })  //Data Emissão Pedido
			aAdd(aCardData,{"txt_ValorTotal"	,  aDadosPed[6][1], 0, 0 })  //Valor Pedido
			aAdd(aCardData,{"txt_nomeMoeda"		,  aDadosPed[7][1], 0, 0 })  //Moeda
			aAdd(aCardData,{"txt_NumAprovadores",  aDadosPed[8][1], 0, 0 })  //Codigo Aprovadores separador por ponto e virgula
			aAdd(aCardData,{"txt_Aprovadores"	,  aDadosPed[9][1], 0, 0 })  //Aprovadores separador por ponto e virgula
							
			If  !( WSTWSDL("startProcessClassic",aValores, aCardData, @xRet, @cMensagem) )
				Break
			EndIf
		
		  	//Obtem somente a Tag do XML de retorno
			cTag := '</result>'
			nC   := At(StrTran(cTag,"/",""),xRet)
			xRet := SubStr(xRet, nC, Len(xRet))
			nC   := At(cTag,xRet) + Len(cTag) - 1
			xRet := Left(xRet, nC)
		
		  	//Gera o objeto do Result Tag
			oXml := XmlParser( xRet, "_", @cErro, @cAviso )
		
			If Empty(oXml)
				cMensagem := JMsgErrFlg(oXML)
				Break
			EndIf
		
			//Analisa o tipo de retorno do Fluig
			If ValType(oXml) == "O" .And. XmlChildEx(oXml:_RESULT, "_ITEM") <> Nil
			
				If ValType(oXml:_RESULT:_ITEM) == "O"
				
					If AllTrim( Upper(oXml:_RESULT:_ITEM:_KEY:TEXT) ) == "ERROR"
						cMensagem  := AllTrim( oXml:_RESULT:_ITEM:_VALUE:TEXT )
						Break
					EndIf
				Else
			
				  	//Obtem o codigo do WorkFlow gerado no Fluig
					For nA := 1 to Len(oXml:_Result:_Item)
						If  (Upper(oXml:_Result:_Item[nA]:_Key:TEXT) != 'IPROCESS')
							Loop
						EndIf
				       
						cIdFluigWF := oXml:_Result:_Item[nA]:_Value:TEXT
						Exit
					Next nA
		    
				EndIf
			EndIf
		    
			If  Empty(cIdFluigWF)
				cMensagem := "Codigo do workflow do Fluig nao retornado!"
				Break
			Else
				MsgInfo("Aprovação enviada para o Fluig!!! Processo Fluig: " + cIdFluigWF)
			EndIf
		
		End Sequence
				
	EndIf
	
	If !( Empty(cMensagem) )
		Conout("Mensagem Erro: " + ' ' + cMensagem)
		lRet := .F.
	EndIf
	
	RestArea( aArea )
		
Return lRet

/*/{Protheus.doc} RETDADOSPED
//TODO 
@description Função para retornar os dados do pedido
@author willian.kaneta
@since 07/11/2019
@version 1.0
@return return, aRet = Dados Pedido + Alçada
@type function
/*/
Static Function RETDADOSPED(cPedido)
	Local aRet		:= {}
	Local aAreaSC7	:= {}
	Local aAlcada	:= {}
	Local cFornece	:= ""
	Local cCondPag	:= ""
	Local cValTotPed:= ""
	Local cMoeda 	:= ""

	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	
	If MsSeek(xFilial("SC7") + cPedido)
		aAreaSC7 := SC7->(GetArea())
			If SC7->C7_MOEDA == 1
				cMoeda := "REAL"
			ElseIf SC7->C7_MOEDA == 2
				cMoeda := "DOLAR"
			EndIf
			cValTotPed	:= RETVALPED(cPedido)
			aAlcada		:= RETALCADA(cPedido)
			cFornece	:= POSICIONE("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NREDUZ")
			cCondPag	:= POSICIONE("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI")
		RestArea(aAreaSC7)
		
		aAdd(aRet,{ SC7->C7_FILIAL			})	//Filial
		aAdd(aRet,{ SC7->C7_NUM				})	//Número Pedido
		aAdd(aRet,{ Alltrim(cFornece)		})  //Nome Fornecedor
		aAdd(aRet,{ Alltrim(cCondPag)		})  //Condição Pagamento
		aAdd(aRet,{	DTOC(SC7->C7_EMISSAO)	})  //Data Emissão Pedido
		aAdd(aRet,{ cValTotPed  			}) 	//Valor Pedido
		aAdd(aRet,{ cMoeda 					}) 	//Moeda
		aAdd(aRet,{ aAlcada[1][1]			}) 	//Código aprovadores
		aAdd(aRet,{ aAlcada[1][2]			}) 	//Alçada			
	EndIf
	
Return aRet

/*/{Protheus.doc} WSTWSDL
@description Prepara e executa a classe TWSDLManager
Uso generico.
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Willian Kaneta
@since 07/11/2019
@version 1.0
/*/
Static Function WSTWSDL(cWSMetodo, aValores, aCardData, xRet, cMensagem)
	Local oWsdl      := nil
	Local cMsg       := ""
	
	Default cWSMetodo  := ''
	Default aValores   := {}
	Default aCardData  := {}
	Default xRet       := ''
	Default cMensagem  := ''
	
	Begin Sequence
	
	//Cria e conecta no Wsdl
	oWsdl := RETOWSDL(cUrl, @cMensagem)
	
	If !Empty(cMensagem)
		Break
	Endif
	
	 //Define a operação
	If  !( oWsdl:SetOperation( cWSMetodo ) )
		cMensagem := If(!Empty(oWsdl:cError), oWsdl:cError, "Problema para configurar o método webservice!")
		Break
	EndIf
	
	  //Alterada a locação pois o wsdl do fluig traz o endereço como localhost.
	oWsdl:cLocation := cUrl
	
	//Retona a Mensagem SOAP Personalizada
	cMsg := RETMSG(aValores, aCardData)  
	//Envia a mensagem SOAP ao servidor
	xRet := oWsdl:SendSoapMsg(cMsg)
	
	// Pega a mensagem de resposta
	xRet := oWsdl:GetSoapResponse()
	
	//varinfo( "", xRet )
	End Sequence

Return Empty(cMensagem)

/*/{Protheus.doc} RETVALPED
//TODO
@description Função para retornar o valor total do pedido
@author willian.kaneta
@since 07/11/2019
@version 1.0
@return cRet: Valor total do Pedido
@type function
/*/
Static Function RETVALPED(cPedido)
	Local cRet 		:= ""
	Local nTotalPed	:= 0
	Local aAreaSC7	:= SC7->(GetArea())
	
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	
	If MsSeek(xFilial("SC7")+cPedido)
		While!(EOF()) .AND. xFilial("SC7")+cPedido == SC7->C7_FILIAL+SC7->C7_NUM
			nTotalPed	+= SC7->C7_TOTAL
			SC7->(DbSkip())
		EndDo
		
		If nTotalPed != 0
			cRet := cValToChar(nTotalPed)
		EndIf
	EndIf
	
	RestArea(aAreaSC7) 
Return cRet

/*/{Protheus.doc} RETALCADA
//TODO
@description Função para retornar a alçada de aprovação, separando por ponto e virgula
@author willian.kaneta
@since 07/11/2019
@version 1.0
@return cRet: Aprovadores
@type function
/*/
Static Function RETALCADA(cPedido)
	Local aRet 		:= {}
	Local aAreaSC7	:= SC7->(GetArea())
	Local aAreaSCR	:= SCR->(GetArea())
	
	DbSelectArea("SCR")
	SCR->(DbSetOrder(1))
	
	If MsSeek(xFilial("SCR") + "PC" + cPedido)
		While !(EOF()) .AND. Alltrim(xFilial("SCR"))+Alltrim(cPedido) == Alltrim(SCR->CR_FILIAL)+Alltrim(SCR->CR_NUM)
			If Len(aRet) == 0
				Aadd(aRet, {(Alltrim(SCR->CR_USER) + ";") , (Alltrim(UsrRetName(SCR->CR_USER)) + ";")})
			Else
				aRet[1][1] := aRet[1][1] + Alltrim(SCR->CR_USER) + ";"
				aRet[1][2] := aRet[1][2] + Alltrim(UsrRetName(SCR->CR_USER))+ ";"
			EndIf
			SCR->(DbSkip())
		EndDo
	EndIf
	
	RestArea(aAreaSC7)
	RestArea(aAreaSCR) 
Return aRet

/*/{Protheus.doc} RETOWSDL()
//TODO
@description Cria o objeto TWsdlManager a partir da Url
@return  oWsdl - objeto TWsdlManager
@author  Willian Kaneta
@since 	 31/08/17
@version 1.0
/*/
Static Function RETOWSDL(cUrl, cErro)

	//Cria o objeto da classe TWsdlManager
	Local oWsdl := Nil
	Local nWsdl := 0

	//Limpa a variavel de referencia antes de executar
	cErro := ""

	If ValType(aWsdl) != "A"
		aWsdl := {}
	EndIf

	//Valida se o objeto ja esta em cache
	If ( nWsdl := aScan(aWsdl, {|x| x[1] == AllTrim(cUrl)}) ) == 0

		oWsdl := TWsdlManager():New()

	 	//Faz o parse de uma URL
	  	If oWsdl:ParseURL(cUrl)
			cErro := ""
			Aadd(aWsdl, {AllTrim(cUrl), oWsdl})			//Cache do wsdl parseado
		Else
			cErro := "Problema ao configurar webservice (TWsdlManager): " + AllTrim(oWsdl:cError)
			JurConout(cErro)
		EndIf
	Else
		oWsdl := aWsdl[nWsdl][2]
	Endif

Return oWsdl

/*/{Protheus.doc} RETMSG
//TODO
@description Função para retornar a mensagem SOAP Personalizada
@author Willian Kaneta
@since 07/11/2019
@version 1.0
@type function
/*/
Static Function RETMSG()
	Local _cSoapMsg	:= ""
	Local nX		:= 0
	
	_cSoapMsg := "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:ws='http://ws.workflow.ecm.technology.totvs.com/'>"
	_cSoapMsg += " <soapenv:Header/>"
	_cSoapMsg += " <soapenv:Body>"
	_cSoapMsg += " <ws:startProcessClassic>" 
	_cSoapMsg += " <username>" 		+ aValores[1][2] + "</username>"
	_cSoapMsg += " <password>" 		+ aValores[2][2] + "</password>"
	_cSoapMsg += " <companyId>" 	+ aValores[3][2] + "</companyId>"
	_cSoapMsg += " <processId>" 	+ aValores[4][2] + "</processId>"
	_cSoapMsg += " <choosedState>" 	+ aValores[5][2] + "</choosedState>"
	_cSoapMsg += " <colleagueIds>"
	_cSoapMsg += " <item>" + EncodeUtf8( aValores[6][2] ) + "</item>"
	_cSoapMsg += " </colleagueIds>"
	_cSoapMsg += " <comments>" + EncodeUtf8( aValores[9][2] ) + "</comments>" 
	_cSoapMsg += " <userId>" + aValores[6][2] + "</userId>" 
	_cSoapMsg += " <completeTask>" + aValores[7][2] + "</completeTask>" 
	_cSoapMsg += " <attachments>" 
	_cSoapMsg += " </attachments>" 
	_cSoapMsg += " <cardData>" 
	
	For nX := 1 To Len(aCardData)
		_cSoapMsg += " <item>" 
		_cSoapMsg += " <key>"	+ aCardData[nX][1] 				+"</key>"
		_cSoapMsg += " <value>" + EncodeUtf8( aCardData[nX][2]) +"</value>" 
		_cSoapMsg += " </item>"
	Next nX
	
	_cSoapMsg += " </cardData>" 
	_cSoapMsg += " <appointment>" 
	_cSoapMsg += " </appointment>" 
	_cSoapMsg += " <managerMode>" + "false" + "</managerMode>" 
	_cSoapMsg += " </ws:startProcessClassic>"
	_cSoapMsg += " </soapenv:Body>"
	_cSoapMsg += "</soapenv:Envelope>"
	
Return 	_cSoapMsg