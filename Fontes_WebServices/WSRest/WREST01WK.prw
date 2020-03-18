#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'RestFul.ch'

//VERIFICAR PARA TRATAR REGRA DE NEGÓCIO SALDO APROVADOR DIRETO PELO FLUIG
//USANDO UM WS REST DO PROTHEUS
/*/{Protheus.doc} WREST01WK
//TODO
@description WebService Rest para realizar a manipulação de Pedidos de Compra
@author Willian Kaneta
@since 01/11/2019
@version 1.0
@type function
/*/
user function WREST01WK()
	
return

/*/{Protheus.doc} PEDIDO
@description WebService Rest para realizar a manipulação de Pedidos de Compra
@author Willian Kaneta
@since 01/11/2019
@type class
/*/
WSRESTFUL PEDIDO DESCRIPTION "Serviço REST Aprovação Pedido de Compras"
WSDATA FILIAL 		As String //Json Recebido no corpo da requição
WSDATA NUM_PED		As String //Em caso de PUT ou DELETE pega o FILIAL + C7_NUM por URL
WSDATA APROVACAO	As String //Em caso de PUT ou DELETE pega o FILIAL + C7_NUM por URL
WSDATA USUARIO		As String //Usuário aprovação
 
WSMETHOD GET  	DESCRIPTION "Retorna lista de Pedidos" 		WSSYNTAX ""
WSMETHOD PUT  	DESCRIPTION "Aprova um Pedido" 				WSSYNTAX "/PEDIDO || /PEDIDO/{FILIAL,NUM_PED,USUARIO,APROVACAO}}"
 
END WSRESTFUL

/*/{Protheus.doc} GET
@description Retorna uma lista de PEDIDO.
@author Willian Kaneta
@since 01/11/2019
@type function
/*/
WSMETHOD GET WSSERVICE PEDIDO
	Local aArea 	 := GetArea()
	Local cNextAlias := GetNextAlias()
	Local oPedido	 := PEDIDO():New() // --> Objeto da classe Pedido
	Local oResponse  := FULL_PEDIDO():New() // --> Objeto que será serializado
	Local cJSON		 := ""
	Local lRet		 := .T.
	
	::SetContentType("application/json")
	
	BeginSQL Alias cNextAlias
		SELECT TOP 10 C7_ITEM,C7_PRODUTO,C7_DESCRI,C7_UM,C7_SEGUM,C7_QUANT,C7_PRECO,C7_TOTAL,C7_QTSEGUM,C7_VALFRE,C7_DESPESA,C7_SEGURO,C7_VALEMB,C7_VALIPI,C7_ICMSRET
		FROM %table:SC7% SC7
		WHERE SC7.%notdel%
	EndSQL
	(cNextAlias)->( DbGoTop() )

	If (cNextAlias)->( !Eof() )
		While (cNextAlias)->( !Eof() )
						
			oPedido:SetItem( 	AllTrim((cNextAlias)->C7_ITEM		))
			oPedido:SetProd( 	AllTrim((cNextAlias)->C7_PRODUTO	))
			oPedido:SetDesc( 	AllTrim((cNextAlias)->C7_DESCRI		))
			oPedido:SetUMed( 	AllTrim((cNextAlias)->C7_UM			))
			oPedido:SetSegU( 	AllTrim((cNextAlias)->C7_SEGUM		))
			oPedido:SetPrec( 	AllTrim((cNextAlias)->C7_QUANT		))
			oPedido:SetQuan( 	AllTrim((cNextAlias)->C7_PRECO		))

			
			oResponse:Add(oPedido)
			oPedido := PEDIDO():New()
			(cNextAlias)->( DbSkip() )
		
		EndDo
		
		cJSON := FWJsonSerialize(oResponse, .T., .T.,,.F.)
		::SetResponse(cJSON)
			
	Else
		SetRestFault(400, "SC7 Empty")
		lRet := .F.
	EndIf
	RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} PUT
@description Altera as informações de um Pedido
@author Willian Kaneta
@since 01/11/2019
@type function
/*/
WSMETHOD PUT WSRECEIVE FILIAL,NUM_PED,USUARIO,APROVACAO WSSERVICE PEDIDO
	Local cJSON 		:= Self:GetContent() // --> Pega a string do JSON
	Local lRet  		:= .T.
	Local cJsonRet   	:= ""
	Local cChave		:= ""
	Local cEmp			:= "01"
	Local _cFilPC		:= ""
	Local lRecLock		:= .F. 
	Local aSaldo 		:= {}
	Local nSaldo 		:= 0	
	Local nTamFil		:= TamSX3("CR_FILIAL")[1]
	Local nTamNUM		:= TamSX3("CR_NUM")[1]
	Local nTamUser		:= TamSX3("CR_USER")[1]
	
	Private oParseJSON 	:= Nil 
	
	::SetContentType("application/json")
	
	// --> Deserializa a string JSON
	FWJsonDeserialize(cJson, @oParseJSON)
	
	_cFilPC 	:= PADR(oParseJSON:FILIAL,nTamFil)
	_cCodApr	:= oParseJSON:USUARIO
	
	RPCSetEnv(cEmp,_cFilPC,,,'COM')
	
	aSaldo 		:= MaSalAlc(_cFilPC,_cCodApr,dDataBase,.T.)
	nSaldo 		:= aSaldo[1]
	
	DbSelectArea("SCR")
	SCR->( DbSetOrder(2) )
	
	If (SCR->( MsSeek( PADR(oParseJSON:FILIAL,nTamFil) + "PC" + PADR(oParseJSON:NUM_PED,nTamNUM) + PADR(oParseJSON:USUARIO,nTamUser) ) ))
	    
	    nMoedaCalc := xMoeda(SCR->CR_TOTAL,SCR->CR_MOEDA,aSaldo[2],SCR->CR_EMISSAO,TamSX3('CR_TOTAL')[2],SCR->CR_TXMOEDA)	
	    cChave := xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM))
		
		dbSelectArea("SC7")
		SC7->(dbSetOrder(1))
		MsSeek(cChave)	
			
		If (nSaldo < nMoedaCalc)	
	 		//Retorna que o Aprovador não possui Limite para aprovação
			cJSONRet := '{"filial":"' + SC7->C7_FILIAL	+ '"';
				 				+ ',"pedido":"'  + SC7->C7_NUM 	+ '"';
				 				+ ',"msg":"'   + "SLDAPROV" 	+ '"';
				 				+'}'	
		Else
			//Caso Pedido Aprovado
			If oParseJSON:APROVACAO == "S"
				lRecLock := A097ProcLib(SCR->(Recno()),2,,,,,dDataBase) 
			//Caso Pedido Rejeitado
			ElseIf oParseJSON:APROVACAO == "N"
				lRecLock := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,,SCR->CR_APROV,,SCR->CR_GRUPO,,,,dDataBase}, dDataBase ,7,,,,,,,cChave)
			EndIf
			
			If lRecLock
				//Retorna que conseguiu realizar o RecLock na alçada - SCR
				cJSONRet := '{"filial":"' + SC7->C7_FILIAL	+ '"';
		 				+ ',"pedido":"'  + SC7->C7_NUM 	+ '"';
		 				+ ',"msg":"'   + "OK" 	+ '"';
		 				+'}'
		 	Else
		 		//Retorna que não conseguiu realizar o RecLock na alçada - SCR
				cJSONRet := '{"filial":"' + SC7->C7_FILIAL	+ '"';
					 				+ ',"pedido":"'  + SC7->C7_NUM 	+ '"';
					 				+ ',"msg":"'   + "NOTRECLOCK" 	+ '"';
					 				+'}'	 	
		 	EndIf
		
		EndIf
		
	    ::SetResponse( cJSONRet )				
		
	Else
		SetRestFault(400, "Pedido não encontrado.")
		lRet := .F.
	EndIf
	
	RpcClearEnv()
	
Return(lRet)

/*/{Protheus.doc} MaSalAlc
//TODO
@description Função para retornar Saldo do Aprovador
@author willian.kaneta
@since 20/11/2019
@version 1.0
@return Array Saldo Aprovador
@param cAprov, characters, descricao
@param dDataRef, date, descricao
@param lCriaSld, logical, descricao
@type function
/*/
Static Function MaSalAlc(_cFil,cAprov,dDataRef,lCriaSld)
	Local cSavAlias:= Alias()
	Local cSavOrd	:= Indexord()
	Local nSavRec	:= 1
	Local nSaldo	:= 0
	Local dDtSaldo	:= MaAlcDtRef(cAprov,dDataRef)
	Local nMoeda	:= 1
	Local aRet097SLD := {}
	DEFAULT lCriaSld	:= .T.
	
	DbSelectArea("SAK")
	SAK->(dbSetOrder(2))
	If SAK->(dbSeek(_cFil+cAprov))
	
		dbSelectArea("SCS")
		nSavRec := SCS->(RecNo())
		SCS->(dbSetOrder(2))
		
		If SCS->(dbSeek(_cFil + SAK->AK_COD + DTOS(dDtSaldo)))
			nSaldo := SCS->CS_SALDO
			nMoeda := SCS->CS_MOEDA
		Else
			If lCriaSld
				Reclock("SCS",.T.)
				SCS->CS_FILIAL := _cFil
				SCS->CS_COD		:= SAK->AK_USER
				SCS->CS_APROV	:= SAK->AK_COD
				SCS->CS_DATA	:= dDtSaldo
				SCS->CS_SALDO	:= SAK->AK_LIMITE
				SCS->CS_MOEDA	:= SAK->AK_MOEDA
				MsUnlock()
			EndIf
			nSaldo	:=  SAK->AK_LIMITE
			nMoeda	:=  SAK->AK_MOEDA
		EndIf
		
		SCS->(MsGoto(nSavRec))
		
		dbSelectArea(cSavAlias)
		dbSetOrder(cSavOrd)
	EndIf 

Return {nSaldo,nMoeda,dDtSaldo}