#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} FSCO01WK
//TODO
@description Função Aprovação Solicitação
@author willian.kaneta
@since 02/12/2019
@version 1.0
@type function
/*/
user function FSCO01WK()
	
	Private oBrowse
	
	Public lFinal	:= .F.
	Public lAtend	:= .F.	
	Public lPende 	:= .F.	
	Public lLogis 	:= .F.
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZZ1")
	oBrowse:SetDescription("Solitação Insumos")
	
	// Definição da legenda
	oBrowse:AddLegend( "ZZ1_STATUS=='1'", "GREEN"	, "Aberta" 						)
	oBrowse:AddLegend( "ZZ1_STATUS=='2'", "BLUE"	, "Pendente contagem estoque" 	)
	oBrowse:AddLegend( "ZZ1_STATUS=='3'", "RED"		, "Finalizada" 					)
	oBrowse:AddLegend( "ZZ1_STATUS=='4'", "ORANGE"	, "Pendente" 					)
	oBrowse:AddLegend( "ZZ1_STATUS=='5'", "YELLOW"	, "Trânsito" 					)
	
	oBrowse:DisableDetails()
	oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
//TODO
@decription Menu
@author Willian Kaneta
@since 08/03/2017
@version 1.0

@type function
/*/
Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Pesquisar"  				ACTION 'PesqBrw' 		  	OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 				ACTION "VIEWDEF.FSCO01WK"  	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"   				ACTION "VIEWDEF.FSCO01WK"  	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    				ACTION "VIEWDEF.FSCO01WK"  	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Atender"    				ACTION "U_ATENDER()"  		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Finalizar Solitação"    	ACTION "U_FINALIZ()"  		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Pendencias"    			ACTION "U_PENDENCIAS()"  	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Trânsito"    				ACTION "U_TRANSITO()"  		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    				ACTION "VIEWDEF.FSCO01WK"  	OPERATION 5 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
//TODO
@decription Camada de modelo de dados
@author Willian Kaneta
@since 08/03/2017
@version 1.0

@type function
/*/
Static Function ModelDef()

	Local oModel
	Local oStrZZ1A		:= FWFormStruct( 1,'ZZ1')
	Local oStrZZ1B		:= FWFormStruct( 1,'ZZ1')
	Local oStrZZ1C		:= FWFormStruct( 1,'ZZ1')
	Local oStrZZ1D		:= FWFormStruct( 1,'ZZ1')
	Local oStrZZ2		:= FWFormStruct( 1,'ZZ2')
	
	oModel := MPFormModel():New('Solicitação Insumos', /*bPreValidacao*/, { | oModel | POSVALID( oModel ) } , /*{ | oMdl | MVC001C( oMdl ) }*/ ,, /*bCancel*/ )
		
	//GATILHOS CABEÇALHO
	//SOLICITANTE
	oStrZZ1B:AddTrigger( 'ZZ1_LOGIST'	, 'ZZ1_LOGIST', , { || REPLLOGIST() } )
	
	//GATILHOS GRID ITENS SOLICITAÇÃO
	oStrZZ2:AddTrigger( 'ZZ2_CODPRO'	, 'ZZ2_DESCPR', , { || RETDESCPRO() } )
	oStrZZ2:AddTrigger( 'ZZ2_AUTORI'	, 'ZZ2_AUTORI', , { || REPLAUTORI() } )
	
	oStrZZ1A:SetProperty("ZZ1_EMSOLI"  	, MODEL_FIELD_WHEN,{|oModel| IIF(oModel:GetOperation() == 3 .OR. !(lPende .OR. lFinal)										,.T.,.F.) })
	oStrZZ1A:SetProperty("ZZ1_CULTUR"  	, MODEL_FIELD_WHEN,{|oModel| IIF(oModel:GetOperation() == 3 .OR. !(lPende .OR. lFinal)										,.T.,.F.) })
	oStrZZ1A:SetProperty("ZZ1_DTENTR"  	, MODEL_FIELD_WHEN,{|oModel| IIF(oModel:GetOperation() == 4 .AND. (lPende .OR. lFinal)										,.F.,.T.) })
	
	oStrZZ1B:SetProperty("ZZ1_LOGIST"  	, MODEL_FIELD_WHEN,{|oModel| IIF((oModel:GetOperation() == 3 .OR. lPende .OR. lFinal .OR. lLogis) .AND. !lAtend				,.F.,.T.) })	
	
	oStrZZ1C:SetProperty("ZZ1_PENDEN"  	, MODEL_FIELD_WHEN,{|oModel| IIF(oModel:GetOperation() == 4 .AND. lPende													,.T.,.F.) })
	
	oStrZZ1D:SetProperty("ZZ1_DTDESP"  	, MODEL_FIELD_WHEN,{|oModel| IIF(oModel:GetOperation() == 4 .AND. lLogis													,.T.,.F.) })
	oStrZZ1D:SetProperty("ZZ1_OBSLOG"  	, MODEL_FIELD_WHEN,{|oModel| IIF(oModel:GetOperation() == 4 .AND. lLogis													,.T.,.F.) })
	
	oStrZZ2:SetProperty("ZZ2_LOGIST"  	, MODEL_FIELD_WHEN,{|oModel| IIF(!lAtend																					,.F.,.T.) })
	oStrZZ2:SetProperty("ZZ2_AUTORI"  	, MODEL_FIELD_WHEN,{|oModel| IIF(!lAtend																					,.F.,.T.) })
	oStrZZ2:SetProperty("ZZ2_CONTRA"  	, MODEL_FIELD_WHEN,{|oModel| IIF(oModel:GetOperation() == 3	.AND. !lAtend													,.F.,.T.) })
	oStrZZ2:SetProperty("ZZ2_CODPRO"  	, MODEL_FIELD_WHEN,{|oModel| IIF(oModel:GetOperation() == 3 .OR. !(lPende .OR. lFinal)										,.T.,.F.) })
	oStrZZ2:SetProperty("ZZ2_QUANT"  	, MODEL_FIELD_WHEN,{|oModel| IIF(oModel:GetOperation() == 3 .OR. !(lPende .OR. lFinal)										,.T.,.F.) })
	oStrZZ2:SetProperty("ZZ2_CONTRA"  	, MODEL_FIELD_WHEN,{|oModel| IIF(oModel:GetOperation() == 4 .AND. ZZ1->ZZ1_STATUS == '1'									,.T.,.F.) })	
		
	oModel:AddFields( "ZZ1SOLIC", Nil		, oStrZZ1A )
	oModel:AddFields( "ZZ1ATEND", "ZZ1SOLIC", oStrZZ1B )
	oModel:AddFields( "ZZ1PENDE", "ZZ1SOLIC", oStrZZ1C )
	oModel:AddFields( "ZZ1LOGIS", "ZZ1SOLIC", oStrZZ1D )

	oModel:SetPrimaryKey( { 'ZZ1_FILIAL', 'ZZ1_CODSC' } )
	oModel:AddGrid('ZZ2UNICO','ZZ1SOLIC',oStrZZ2)		
	oModel:SetRelation( "ZZ2UNICO", { { "ZZ2_FILIAL", "xFilial( 'ZZ2' )" }, { "ZZ2_CODSC","ZZ1_CODSC" } }, ZZ2->( IndexKey( 1 ) ) )
		
	oModel:getModel('ZZ1SOLIC'):SetDescription('Solicitante')
	oModel:getModel('ZZ1ATEND'):SetDescription('Atendente'	)
	oModel:getModel('ZZ1PENDE'):SetDescription('Pendências'	)
	oModel:getModel('ZZ1LOGIS'):SetDescription('Logística'	)
	
	oModel:getModel('ZZ2UNICO'):SetDescription('Itens Solicitação')
	
	oModel:setactivate({|oModel| Carrega(oModel)})
	//oModel:SetVldActivate( { |oModel| PREVALID( oModel ) } )
	
Return oModel

/*/{Protheus.doc} ViewDef
//TODO
@decription Camada de visualização
@author Willian Kaneta
@since 08/03/2017
@version 1.0

@type function
/*/
Static Function ViewDef()

	Local oModel 		:= ModelDef()
	Local oView  		:= FWFormView():New()
	Local oStruZZ1A  	:= FWFormStruct(2, 'ZZ1')
	Local oStruZZ1B  	:= FWFormStruct(2, 'ZZ1')
	Local oStruZZ1C  	:= FWFormStruct(2, 'ZZ1')
	Local oStruZZ1D  	:= FWFormStruct(2, 'ZZ1')
	Local oStruZZ2  	:= FWFormStruct(2, 'ZZ2')
	
	//Seção Solicitante
	oStruZZ1A:RemoveField( "ZZ1_CODATE" )
	oStruZZ1A:RemoveField( "ZZ1_NOMATE" )
	oStruZZ1A:RemoveField( "ZZ1_DTATEN" )
	oStruZZ1A:RemoveField( "ZZ1_STATUS" )
	oStruZZ1A:RemoveField( "ZZ1_PENDEN" )
	oStruZZ1A:RemoveField( "ZZ1_LOGIST" )
 	oStruZZ1A:RemoveField( "ZZ1_DTDESP" )
	oStruZZ1A:RemoveField( "ZZ1_OBSLOG" )
	//Seção Atendente
	oStruZZ1B:RemoveField( "ZZ1_CODSC" 	)
	oStruZZ1B:RemoveField( "ZZ1_CODSOL" )
	oStruZZ1B:RemoveField( "ZZ1_NOMSOL" )
	oStruZZ1B:RemoveField( "ZZ1_EMSOLI" )
	oStruZZ1B:RemoveField( "ZZ1_DTSOLI" )
	oStruZZ1B:RemoveField( "ZZ1_DTFINA" )
	oStruZZ1B:RemoveField( "ZZ1_DTENTR" )
	oStruZZ1B:RemoveField( "ZZ1_STATUS" )
	oStruZZ1B:RemoveField( "ZZ1_CULTUR" )
	oStruZZ1B:RemoveField( "ZZ1_PENDEN" )
	oStruZZ1B:RemoveField( "ZZ1_DTDESP" )
	oStruZZ1B:RemoveField( "ZZ1_OBSLOG" )
	//Seção Pendências
	oStruZZ1C:RemoveField( "ZZ1_CODSC" 	)
	oStruZZ1C:RemoveField( "ZZ1_CODATE" )
	oStruZZ1C:RemoveField( "ZZ1_NOMATE" )
	oStruZZ1C:RemoveField( "ZZ1_DTATEN" )
	oStruZZ1C:RemoveField( "ZZ1_STATUS" )
	oStruZZ1C:RemoveField( "ZZ1_CODSOL" )
	oStruZZ1C:RemoveField( "ZZ1_NOMSOL" )
	oStruZZ1C:RemoveField( "ZZ1_EMSOLI" )
	oStruZZ1C:RemoveField( "ZZ1_DTSOLI" )
	oStruZZ1C:RemoveField( "ZZ1_DTFINA" )
	oStruZZ1C:RemoveField( "ZZ1_DTENTR" )
	oStruZZ1C:RemoveField( "ZZ1_CULTUR" )
	oStruZZ1C:RemoveField( "ZZ1_LOGIST" )
	oStruZZ1C:RemoveField( "ZZ1_DTDESP" )
	oStruZZ1C:RemoveField( "ZZ1_OBSLOG" )
	//Seção Logística
	oStruZZ1D:RemoveField( "ZZ1_CODSC" 	)
	oStruZZ1D:RemoveField( "ZZ1_CODATE" )
	oStruZZ1D:RemoveField( "ZZ1_NOMATE" )
	oStruZZ1D:RemoveField( "ZZ1_DTATEN" )
	oStruZZ1D:RemoveField( "ZZ1_STATUS" )
	oStruZZ1D:RemoveField( "ZZ1_CODSOL" )
	oStruZZ1D:RemoveField( "ZZ1_NOMSOL" )
	oStruZZ1D:RemoveField( "ZZ1_EMSOLI" )
	oStruZZ1D:RemoveField( "ZZ1_DTSOLI" )
	oStruZZ1D:RemoveField( "ZZ1_DTFINA" )
	oStruZZ1D:RemoveField( "ZZ1_DTENTR" )
	oStruZZ1D:RemoveField( "ZZ1_CULTUR" )
	oStruZZ1D:RemoveField( "ZZ1_LOGIST" )
	oStruZZ1D:RemoveField( "ZZ1_PENDEN" )	
	//Grid Itens Solicitação
	oStruZZ2:RemoveField( "ZZ2_CODSC" )
	
	oView:SetModel( oModel )
	oView:SetContinuousForm(.T.)
	oView:AddField( "VIEW_ZZ1A"	, oStruZZ1A , "ZZ1SOLIC" )
	oView:AddField( "VIEW_ZZ1B"	, oStruZZ1B , "ZZ1ATEND" )
	oView:AddField( "VIEW_ZZ1C"	, oStruZZ1C , "ZZ1PENDE" )
	oView:AddField( "VIEW_ZZ1D"	, oStruZZ1D , "ZZ1LOGIS" )
	oView:AddGrid(  "VIEW_ZZ2"	, oStruZZ2 	, "ZZ2UNICO" )

	oView:CreateHorizontalBox( "CAMPOSA" 	, 30   )
	oView:CreateHorizontalBox( "CAMPOSB" 	, 10   )
	oView:CreateHorizontalBox( "CAMPOSC" 	, 10   )
	oView:CreateHorizontalBox( "CAMPOSD" 	, 10   )
	oView:CreateHorizontalBox( "GRID"   	, 40   )

	oView:SetOwnerView( "VIEW_ZZ1A", "CAMPOSA" )
	oView:SetOwnerView( "VIEW_ZZ1B", "CAMPOSB" )
	oView:SetOwnerView( "VIEW_ZZ1C", "CAMPOSC" )
	oView:SetOwnerView( "VIEW_ZZ1D", "CAMPOSD" )
	oView:SetOwnerView( "VIEW_ZZ2", "GRID"   )

	oView:EnableTitleView( "VIEW_ZZ1A" )
	oView:EnableTitleView( "VIEW_ZZ1B" )
	oView:EnableTitleView( "VIEW_ZZ1C" )
	oView:EnableTitleView( "VIEW_ZZ1D" )
	oView:EnableTitleView( "VIEW_ZZ2" )
	
	oView:AddIncrementField( 'VIEW_ZZ2', 'ZZ2_ITEM' )
	
	oView:SetViewCanActivate({|oView| PREVALID(oModel)})

Return oView

/*/{Protheus.doc} PREVALID
//TODO
@description PREVALID Validação Dados ao incluir/alterar
@author Willian Kaneta
@since 08/03/2017
@version 1.0
@param oModel, object, descricao
@type function
/*/
Static Function PREVALID( oModel )

	Local lRet 		:= .T.
	
	If RetCodUsr() == ZZ1->ZZ1_CODSOL .AND. Empty(ZZ1->ZZ1_DTATEN) .AND. Empty(ZZ1->ZZ1_DTFINA) .AND. (oModel:GetOperation() == 4 .OR. oModel:GetOperation() == 5) .AND. !lFinal .AND. !lPende .AND. !lLogis
		MsgAlert("Não é possivel Alterar/ Excluir a solicitação!","Atenção")
		lRet := .F.
	ElseIf RetCodUsr() == ZZ1->ZZ1_CODSOL .AND. (!Empty(ZZ1->ZZ1_DTATEN) .AND. !Empty(ZZ1->ZZ1_DTFINA)) .AND. (oModel:GetOperation() == 4 .OR. oModel:GetOperation() == 5) .AND. (!lFinal .AND. !lPende .AND. !lLogis)
		MsgAlert("Opção não permitida, solicitação finalizada!","Atenção")
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} POSVALID
//TODO
@description POSVALID Validação Dados ao incluir/alterar
@author Willian Kaneta
@since 08/03/2017
@version 1.0
@param oModel, object, descricao
@type function
/*/
Static Function POSVALID( oModel )

	Local lRet      := .T.
	Local cAssunto	:= ""
	Local cTexto	:= "" 
	Local cMailLoSo	:= ""
	Local cMailSoAt	:= ""
	Local cMailLoAt	:= ""
	Local cDtDespa	:= ""
	Local aItensSC	:= {}
	Local oMdlZZ1A 	:= oModel:GetModel("ZZ1SOLIC")
	Local oMdlZZ1B 	:= oModel:GetModel("ZZ1ATEND")
	Local oMdlZZ1C 	:= oModel:GetModel("ZZ1PENDE")
	Local oMdlZZ1D 	:= oModel:GetModel("ZZ1LOGIS")
	Local oZZ2UNI	:= oModel:GetModel( "ZZ2UNICO" )
	Local cEmailSol	:= oMdlZZ1A:GetValue("ZZ1_EMSOLI")
	Local cStatusSC	:= oMdlZZ1A:GetValue("ZZ1_STATUS")
	Local cNumSolic	:= oMdlZZ1A:GetValue("ZZ1_CODSC")
	Local cCodSolic	:= oMdlZZ1A:GetValue("ZZ1_CODSOL")	
	Local dDataEntr	:= oMdlZZ1A:GetValue("ZZ1_DTENTR")
	Local cCultura	:= oMdlZZ1A:GetValue("ZZ1_CULTUR")
	Local cLogisti	:= oMdlZZ1B:GetValue("ZZ1_LOGIST")
	Local cPendenc	:= oMdlZZ1C:GetValue("ZZ1_PENDEN")
	Local dDtDespa	:= oMdlZZ1D:GetValue("ZZ1_DTDESP")
	Local cOBSLogi	:= oMdlZZ1D:GetValue("ZZ1_OBSLOG")
	Local cMailAten	:= SuperGetMv("MV_XMAILAT",,"") //Email Atendentes	
	Local cMailLogi	:= SuperGetMv("MV_XMAILLO",,"")	//Email Logistica
	Local nLinOld	:= 0
	Local nX		:= 0

	If Empty(cEmailSol) .AND. oModel:GetOperation() == 3 .OR. (oModel:GetOperation() == 4 .AND. cStatusSC == "1" .AND. Empty(cEmailSol))
		MsgAlert("É obrigatório informar o email do solicitante!!!","Atenção")
		lRet := .F. 
	EndIf
	
	If Empty(dDataEntr) .AND. oModel:GetOperation() == 3 .OR. (oModel:GetOperation() == 4 .AND. cStatusSC == "1" .AND. Empty(dDataEntr))
		MsgAlert("É obrigatório informar o campo Data Entrega!!!","Atenção")
		lRet := .F. 
	EndIf
			
	If Empty(cCultura) .AND. oModel:GetOperation() == 3 .OR. (oModel:GetOperation() == 4 .AND. cStatusSC == "1" .AND. Empty(cCultura))
		MsgAlert("É obrigatório informar o campo Cultura!!!","Atenção")
		lRet := .F. 
	EndIf

	If Empty(cLogisti) .AND. lAtend
		MsgAlert("É obrigatório informar o campo Logistica!!!","Atenção")
		lRet := .F. 		
	EndIf
	
	If Empty(cPendenc) .AND. lPende
		MsgAlert("É obrigatório informar o campo Pendências!!!","Atenção")
		lRet := .F. 		
	EndIf

	If Empty(dDtDespa) .AND. lLogis
		MsgAlert("É obrigatório informar o campo Data de Despacho!!!","Atenção")
		lRet := .F. 		
	EndIf
	
	nLinOld 	:= oZZ2UNI:nLine
	For nX := 1 To oZZ2UNI:Length()
		oZZ2UNI:GoLine( nX )
		If oZZ2UNI:GetValue( "ZZ2_QUANT" ) == 0
			MsgAlert("É obrigatório informar o campo Quantidade do item da solicitação! Item: " + cValToChar(nX), "Atenção")
			lRet := .F.
			Exit
		EndIf
		
		If Empty(oZZ2UNI:GetValue( "ZZ2_LOGIST" )) .AND. lAtend
			MsgAlert("É obrigatório informar o campo Logistica na grid Itens Solicitação! Item: " + cValToChar(nX) + " Informe o campo manualmente para cada Item, ou infome no cabeçalho Atendente campo Logistica para replicar para todos os itens.", "Atenção")
			lRet := .F.
			Exit
		EndIf		
		
		If Empty(oZZ2UNI:GetValue( "ZZ2_AUTORI" )) .AND. lAtend
			MsgAlert("Infomar o código da autorização, campo obrigatório!", "Atenção")
			lRet := .F.
			Exit
		EndIf
		
		If oZZ2UNI:GetValue( "ZZ2_LOGIST" ) == "1"
			aAdd(aItensSC, { 	oZZ2UNI:GetValue( "ZZ2_ITEM" 	),;
								oZZ2UNI:GetValue( "ZZ2_CODSC" 	),;
			 					oZZ2UNI:GetValue( "ZZ2_CODPRO" 	),;
			 					oZZ2UNI:GetValue( "ZZ2_DESCPR" 	),;
			 					oZZ2UNI:GetValue( "ZZ2_QUANT" 	),;
			 					oZZ2UNI:GetValue( "ZZ2_LOGIST" 	),;
			 					oZZ2UNI:GetValue( "ZZ2_AUTORI" 	),;
			 					oZZ2UNI:GetValue( "ZZ2_CONTRA" 	), })
		EndIf 
		
	Next nX
		
	oZZ2UNI:GoLine( nLinOld )
		
	//Caso os campos obrigatórios estejam preenchidos, envia o email
	If lRet
		//Envia email na inclusão, ao realizar o atendimento da solicitação e ao finalizar a solicitação
		/*PARAMETROS UTILIZADOS NA USER FUNCTION FSCO02WK
		1:EMAIL
		2:OPERAÇÃO = 1 = INCLUSÃO SOLICITAÇÃO/ 2 = ATENDIMENTO/ 3 = FINALIZAÇÃO SOLICITAÇÃO	
		3:ASSUNTO
		4:TEXTO EMAIL
		*/
		//Inclusão Solicitação
		If oModel:GetOperation() == 3 .AND. !Empty(cMailAten)
			cAssunto 	:= "Inclusão Solicitação " + cNumSolic
			cTexto		:= "<b>Email informativo:</b> Realizado a inclusão de uma nova solicitação, codigo da solicitação: "  + cNumSolic
			U_FSCO02WK(Alltrim(cMailAten),1,cAssunto,cTexto)
		//Atendimento
		ElseIf oModel:GetOperation() == 4 .AND. RetCodUsr() != cCodSolic .AND. lAtend
			//Email Atendimento Solicitação com Logistica envia para o Solicitante e Logistica
			If cLogisti == "1" .AND. !Empty(cEmailSol) .AND. !Empty(cMailLogi)
				cMailLoSo	:= Alltrim(cEmailSol) + "," + Alltrim(cMailLogi)
				cAssunto 	:= "Atendimento Solicitação com Logística " + cNumSolic
				cTexto		:= "<b>Email informativo:</b> Foi realizado o antendimento da solicitação <b>com necessidade de logística</b> Código Solicitação: "  + cNumSolic 
				U_FSCO02WK(Alltrim(cMailLoSo),2,cAssunto,cTexto,Alltrim(cPendenc),cDtDespa,cOBSLogi,aItensSC)
			//Email Atendimento Solicitação com Logistica envia somente para o Solicitante caso o email da Logistica não esteja informado no parâmetro MV_XMAILLO
			ElseIf cLogisti == "1" .AND. !Empty(cEmailSol) .AND. Empty(cMailLogi)
				cMailLoSo	:= cEmailSol
				cAssunto 	:= "Atendimento Solicitação com Logística " + cNumSolic
				cTexto		:= "<b>Email informativo:</b> Foi realizado o antendimento da solicitação <b>com necessidade de logística</b> Código Solicitação: "  + cNumSolic 
				U_FSCO02WK(Alltrim(cMailLoSo),2,cAssunto,cTexto,Alltrim(cPendenc),cDtDespa,cOBSLogi,aItensSC)
			//Email Atendimento Solicitação sem Logistica envia somente para o Solicitante
			ElseIf cLogisti == "2" .AND.!Empty(cEmailSol)
				cAssunto 	:= "Atendimento Solicitação " + cNumSolic
				cTexto		:= "<b>Email informativo:</b> Foi realizado o antendimento da solicitação " + cNumSolic 
				U_FSCO02WK(Alltrim(cEmailSol),2,cAssunto,cTexto,Alltrim(cPendenc),cDtDespa,cOBSLogi,aItensSC)
			EndIf		
		//Finalização Solicitação
		ElseIf oModel:GetOperation() == 4 .AND. RetCodUsr() == cCodSolic .AND. lFinal
			If !Empty(cMailAten) .AND. !Empty(cMailLogi)
				cMailLoAt	:= Alltrim(cMailAten) + "," + Alltrim(cMailLogi)
				cAssunto 	:= "Solicitação Finalizada " + cNumSolic
				cTexto		:= "<b>Email informativo:</b> A solicitação "  + cNumSolic + " foi finalizada."	
				U_FSCO02WK(Alltrim(cMailLoAt),3,cAssunto,cTexto,Alltrim(cPendenc),cDtDespa,cOBSLogi)
			ElseIf !Empty(cMailAten) .AND. Empty(cMailLogi)
				cMailLoAt	:= Alltrim(cMailAten)
				cAssunto 	:= "Solicitação Finalizada " + cNumSolic
				cTexto		:= "<b>Email informativo:</b> A solicitação "  + cNumSolic + " foi finalizada."	
				U_FSCO02WK(Alltrim(cMailLoAt),3,cAssunto,cTexto,Alltrim(cPendenc),cDtDespa,cOBSLogi)
			ElseIf Empty(cMailAten) .AND. !Empty(cMailLogi)
				cMailLoAt	:= Alltrim(cMailLogi)
				cAssunto 	:= "Solicitação Finalizada " + cNumSolic
				cTexto		:= "<b>Email informativo:</b> A solicitação "  + cNumSolic + " foi finalizada."	
				U_FSCO02WK(Alltrim(cMailLoAt),3,cAssunto,cTexto,Alltrim(cPendenc),cDtDespa,cOBSLogi)			
			EndIf
		//Pendencias Solicitação
		ElseIf oModel:GetOperation() == 4 .AND. RetCodUsr() == cCodSolic  .AND. !Empty(cMailAten) .AND. lPende
			cAssunto 	:= "Solicitação com Pendências " + cNumSolic
			cTexto		:= "<b>Email informativo:</b> A solicitação "  + cNumSolic + " possui pendências."	
			If !Empty(cPendenc)
				cPendenc	:= "<b>Pendências:</b> "  + Alltrim(cPendenc)
			EndIf
			U_FSCO02WK(Alltrim(cMailAten),4,cAssunto,cTexto,Alltrim(cPendenc))
		//Solicitação em Transito - Atendimento solicitação pelo setor da Logística
		ElseIf oModel:GetOperation() == 4 .AND. RetCodUsr() != cCodSolic  .AND. lLogis
			If !Empty(cEmailSol) .AND. !Empty(cMailAten)
				cMailSoAt	:= Alltrim(cEmailSol) + "," + Alltrim(cMailAten)
				cAssunto 	:= "Logística Atendida - Solicitação " + cNumSolic
				cTexto		:= "<b>Email informativo:</b> A solicitação "  + cNumSolic + " foi atendida pelo setor de Logística/ Atendimento."	
				If !Empty(dDtDespa)
					cDtDespa := "<b>Data de Despacho: </b>" + DTOC(dDtDespa)
				EndIf
				If !Empty(cOBSLogi)
					cOBSLogi	:= "<b>Obs. Logística:</b> "  + Alltrim(cOBSLogi)
				EndIf
				U_FSCO02WK(Alltrim(cMailSoAt),5,cAssunto,cTexto,Alltrim(cPendenc),cDtDespa,cOBSLogi)
			EndIf
		EndIf	
	EndIf
Return lRet

/*/{Protheus.doc} REPLLOGIST
//TODO
@description Função gatilho campo Logistica ZZ1 - ZZ1_LOGIST -> ZZ2_LOGIST
@author willian.kaneta
@since 03/12/2019
@version 1.0
@type function
/*/
Static Function REPLLOGIST()
	Local oModel 	:= FWModelActive()
	Local oMdlZZ1B 	:= oModel:GetModel("ZZ1ATEND")
	Local oZZ2UNI	:= oModel:GetModel( "ZZ2UNICO" )
	Local cLogAte	:= oMdlZZ1B:GetValue("ZZ1_LOGIST")
	Local oView     := FwViewActive()
	Local nLinOld	:= 0
	Local nX		:= 0

	If !Empty(cLogAte) .AND. oZZ2UNI:Length() > 1
		If MsgYesNo("Deseja replicar o campo Logistica para todos os itens?")
			nLinOld 	:= oZZ2UNI:nLine
			For nX := 1 To oZZ2UNI:Length()
				oZZ2UNI:GoLine( nX )
				oZZ2UNI:LoadValue( "ZZ2_LOGIST", cLogAte )
			Next nX
			
			oZZ2UNI:GoLine( nLinOld )
			oView:Refresh()
		EndIf
	Else
		If !Empty(cLogAte)
		oZZ2UNI:GoLine( 1 )
		oZZ2UNI:LoadValue( "ZZ2_LOGIST", cLogAte )
		oView:Refresh()
		EndIf
	EndIf

Return

/*/{Protheus.doc} RETDESCPRO
//TODO 
@description Gatilho para retornar a descrição do produto
@author Willian Kaneta
@since 28/03/2017
@version 1.0

@type function
/*/
Static Function RETDESCPRO()

	Local oModel 	:= FWModelActive()
	Local oZZ2UNI	:= oModel:GetModel( "ZZ2UNICO" )
	Local cCodPro	:= ""
	Local cDescPro	:= ""
	
	cCodPro	:=	oZZ2UNI:GetValue( "ZZ2_CODPRO" )
	
	cDescPro	:= POSICIONE("SB1",1,xFilial("SB1")+cCodPro,"B1_DESC")	
	
Return(cDescPro)

/*/{Protheus.doc} REPLAUTORI
//TODO
@description Função para replicar o campo ZZ2_AUTORI
@author willian.kaneta
@since 03/12/2019
@version 1.0
@type function
/*/
Static Function REPLAUTORI()
	Local oModel 	:= FWModelActive()
	Local oZZ2UNI	:= oModel:GetModel( "ZZ2UNICO" )
	Local cAutoriz	:= ""
	Local oView     := FwViewActive()
	Local nLinOld	:= 0
	Local nX		:= 0
	Local aAreaSC7	:= SC7->(GetArea())

	If !Empty(oZZ2UNI:GetValue("ZZ2_AUTORI")) .AND. oZZ2UNI:Length() > 1
		If MsgYesNo("Deseja replicar a autorização para todos os itens?")
			nLinOld 	:= oZZ2UNI:nLine
			cAutoriz	:= oZZ2UNI:GetValue("ZZ2_AUTORI")
			cContrat	:= POSICIONE("SC7",1,xFilial("SC7")+cAutoriz,"C7_NUMSC")
			For nX := 1 To oZZ2UNI:Length()
				oZZ2UNI:GoLine( nX )
				If nX != nLinOld
					oZZ2UNI:LoadValue( "ZZ2_AUTORI", cAutoriz )
				EndIf
				oZZ2UNI:LoadValue( "ZZ2_CONTRA", cContrat )
			Next nX
			
			oZZ2UNI:GoLine( nLinOld )
			oView:Refresh()
		Else
			cAutoriz	:= oZZ2UNI:GetValue("ZZ2_AUTORI")
			cContrat	:= POSICIONE("SC7",1,xFilial("SC7")+cAutoriz,"C7_NUMSC")
			oZZ2UNI:LoadValue( "ZZ2_CONTRA", cContrat )
			oView:Refresh()
		EndIf
	Else
		cAutoriz	:= oZZ2UNI:GetValue("ZZ2_AUTORI")
		cContrat	:= POSICIONE("SC7",1,xFilial("SC7")+cAutoriz,"C7_NUMSC")
		oZZ2UNI:LoadValue( "ZZ2_CONTRA", cContrat )
		oView:Refresh()
	EndIf
	
	RestArea(aAreaSC7)
	
Return

/*/{Protheus.doc} ATENDER
//TODO
@description Funcão para realizar o atendimento - Altera para Status ZZ1_STATUS = 2
@author willian.kaneta
@since 02/12/2019
@version 1.0
@type function
/*/
User Function ATENDER()
	Local nOp		:= 4
	Local nRet		:= 1
	Local aButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Salvar"},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
		
	If ZZ1->ZZ1_CODSOL != RetCodUsr() .AND. Empty(ZZ1->ZZ1_DTFINA) .AND. !(ZZ1->ZZ1_STATUS == "3" .OR. ZZ1->ZZ1_STATUS == "4" .OR. ZZ1->ZZ1_STATUS == "5")
		lAtend := .T.
		nRet := FWExecView('Atendimento Solicitação Insumos', 'FSCO01WK', nOp,,{||.T.},,,aButtons,,,,)
	ElseIf	ZZ1->ZZ1_CODSOL == RetCodUsr()
		MsgAlert("Usuário sem permissão para realizar o atendimento da solicitação","Atenção")
	ElseIf ZZ1->ZZ1_CODSOL != RetCodUsr() .AND. !Empty(ZZ1->ZZ1_DTATEN) .AND. (ZZ1->ZZ1_STATUS == "4" .OR. ZZ1->ZZ1_STATUS == "5")
		MsgAlert("Não é permitido realizar o atendimento de de uma solicitação que possui pendências ou foi atendida pelo setor de Logística!","Atenção")
	ElseIf ZZ1->ZZ1_CODSOL != RetCodUsr() .AND. !Empty(ZZ1->ZZ1_DTFINA) .AND. ZZ1->ZZ1_STATUS == "3"
		MsgAlert("Opção não permitida, esta solicitação já foi finalizada!","Atenção")
	EndIf
	
	If nRet == 0 
		lAtend := .F.
		MsgInfo("Atendimento realizado com Sucesso!!!")
	Else
		lAtend := .F.
	EndIf
	
Return

/*/{Protheus.doc} FINALIZ
//TODO
@description Funcão para finalizar o atendimento - Altera para Status ZZ1_STATUS = 3
@author willian.kaneta
@since 02/12/2019
@version 1.0
@type function
/*/
User Function FINALIZ()
	Local nOp		:= 4
	Local nRet		:= 1
	Local aButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Salvar"},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
		
	If ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. !Empty(ZZ1->ZZ1_CODATE) .AND. Empty(ZZ1->ZZ1_DTFINA) .AND. ((ZZ1->ZZ1_LOGIST == "1" .AND. (ZZ1->ZZ1_STATUS == "5" .OR. ZZ1->ZZ1_STATUS == "4")) .OR. (ZZ1->ZZ1_LOGIST == "2") )
		lFinal := .T.
		nRet := FWExecView('Finalizar Solicitação Insumos', 'FSCO01WK', nOp,,{||.T.},,,aButtons,,,,)
	ElseIf ZZ1->ZZ1_CODSOL != RetCodUsr()
		MsgAlert("Usuário sem permissão para finalizar a solicitação!","Atenção")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. Empty(ZZ1->ZZ1_CODATE)
		MsgAlert("Não é possível finalizar uma solicitação que não foi atendida!","Atenção")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. !Empty(ZZ1->ZZ1_DTFINA)
		MsgAlert("Esta solicitação já foi finalizada!","Atenção")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. ZZ1->ZZ1_LOGIST == "1" .AND. ZZ1->ZZ1_STATUS != "5" .AND. ZZ1->ZZ1_STATUS != "4" .AND. Empty(ZZ1->ZZ1_DTDESP)
		MsgAlert("Esta solicitação necessita de logística, só é permitido finalizar solicitação que não possui logística, ou que possua logística e já foi atendida pelo setor de Logística/Atendimento!","Atenção")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. Empty(ZZ1->ZZ1_LOGIST)	
		MsgAlert("Não foi informado o campo Logística, verificar com o setor de atendimento!","Atenção")
	EndIf
	
	If nRet == 0 
		lFinal := .F.
		MsgInfo("Solicitação finalizada com Sucesso!!!")
	Else
		lFinal := .F.
	EndIf
	
Return

/*/{Protheus.doc} PENDENCIAS
//TODO
@description Funcão para gravar pendências na solicitação - Altera para Status ZZ1_STATUS = 4
@author willian.kaneta
@since 02/12/2019
@version 1.0
@type function
/*/
User Function PENDENCIAS()
	Local nOp		:= 4
	Local nRet		:= 1
	Local aButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Salvar"},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
		
	If ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. !Empty(ZZ1->ZZ1_CODATE) .AND. Empty(ZZ1->ZZ1_DTFINA) .AND. ((ZZ1->ZZ1_LOGIST == "1" .AND. (ZZ1->ZZ1_STATUS == "5" .OR. ZZ1->ZZ1_STATUS == "4")) .OR. (ZZ1->ZZ1_LOGIST == "2") )
		lPende := .T.
		nRet := FWExecView('Pendências Solicitação Insumos', 'FSCO01WK', nOp,,{||.T.},,,aButtons,,,,)
	ElseIf ZZ1->ZZ1_CODSOL != RetCodUsr()
		MsgAlert("Usuário sem permissão para informar as pendencias da solicitação!","Atenção")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. Empty(ZZ1->ZZ1_CODATE)
		MsgAlert("Não é possível informar as pendências de uma solicitação que não foi atendida!","Atenção")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. !Empty(ZZ1->ZZ1_DTFINA)
		MsgAlert("Esta solicitação já foi finalizada!","Atenção")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. ZZ1->ZZ1_LOGIST == "1" .AND. ZZ1->ZZ1_STATUS != "5" .AND. ZZ1->ZZ1_STATUS != "4" .AND. Empty(ZZ1->ZZ1_DTDESP)
		MsgAlert("Esta solicitação necessita de logística, só é permitido informar pendências da solicitação que não possui logística, ou que possua logística e já foi atendida pelo setor da Logística/Atendimento!","Atenção")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. Empty(ZZ1->ZZ1_LOGIST)	
		MsgAlert("Não foi informado o campo Logística, verificar com o setor de atendimento!","Atenção")
	EndIf
	
	If nRet == 0 
		lPende := .F.
		MsgInfo("Solicitação alterada com Sucesso!!!")
	Else
		lPende := .F.
	EndIf
	
Return

/*/{Protheus.doc} TRANSITO
//TODO
@description Funcão para atendimento da Solicitação pelo setor da Logística - Altera para Status ZZ1_STATUS = 5 
@author willian.kaneta
@since 02/12/2019
@version 1.0
@type function
/*/
User Function TRANSITO()
	Local nOp		:= 4
	Local nRet		:= 1
	Local aButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Salvar"},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
		
	If ZZ1->ZZ1_CODSOL != RetCodUsr() .AND. !Empty(ZZ1->ZZ1_CODATE) .AND. Empty(ZZ1->ZZ1_DTFINA) .AND. ZZ1->ZZ1_LOGIST == "1"
		lLogis := .T.
		nRet := FWExecView('Solicitação Logística Insumos', 'FSCO01WK', nOp,,{||.T.},,,aButtons,,,,)
	ElseIf  ZZ1->ZZ1_CODSOL != RetCodUsr() .AND. ZZ1->ZZ1_LOGIST != "1" .AND. Empty(ZZ1->ZZ1_DTFINA) .AND. !Empty(ZZ1->ZZ1_CODATE)
		MsgAlert("Opção permitida somente caso a solicitação possua Logística (campo ZZ1_LOGIST = Sim)!","Atenção")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr()
		MsgAlert("Usuário sem permissão para atendimento Logística da solicitação!","Atenção")
	ElseIf ZZ1->ZZ1_CODSOL != RetCodUsr() .AND. Empty(ZZ1->ZZ1_CODATE)
		MsgAlert("Não é possível realizar o atendimento logística de uma solicitação que não foi atendida!","Atenção")
	ElseIf ZZ1->ZZ1_CODSOL != RetCodUsr() .AND. !Empty(ZZ1->ZZ1_DTFINA)
		MsgAlert("Esta solicitação já foi finalizada!","Atenção")
	EndIf
	
	If nRet == 0 
		lLogis := .F.
		MsgInfo("Solicitação alterada com Sucesso!!!")
	Else
		lLogis := .F.
	EndIf
	
Return

/*/{Protheus.doc} CARREGA
//TODO
@description Função que carrega informações dos campos
@author willian.kaneta
@since 03/12/2019
@version 1.0
@param oModel, object, descricao
@type function
/*/
Static Function CARREGA(oModel)
	Local nOp      	:= oModel:GetOperation()
	Local oMdlZZ1A 	:= oModel:GetModel("ZZ1SOLIC")
	Local oMdlZZ1B 	:= oModel:GetModel("ZZ1ATEND")
	Local oMdlZZ1D	:= oModel:GetModel("ZZ1LOGIS")
	Local cCodSolic	:= oMdlZZ1A:GetValue("ZZ1_CODSOL")
	Local cCodAtend	:= oMdlZZ1A:GetValue("ZZ1_CODATE")
	Local cStatus	:= oMdlZZ1A:GetValue("ZZ1_STATUS")
	Local cTrasito	:= oMdlZZ1B:GetValue("ZZ1_LOGIST")
	
	//Inclusão Solicitação
	If nOp == 3
		oMdlZZ1A:LoadValue("ZZ1_CODSOL"	, RetCodUsr() ) 
		oMdlZZ1A:LoadValue("ZZ1_NOMSOL"	, UsrRetName(RetCodUsr()) )
		oMdlZZ1A:LoadValue("ZZ1_DTSOLI"	, dDataBase )	
	//Atendimento da Solicitação
	ElseIf nOp == 4 .AND. RetCodUsr() != cCodSolic .AND. lAtend
		oMdlZZ1B:LoadValue("ZZ1_CODATE"	, RetCodUsr() )
		oMdlZZ1B:LoadValue("ZZ1_NOMATE"	, UsrRetName(RetCodUsr()) )
		oMdlZZ1B:LoadValue("ZZ1_DTATEN"	, dDataBase )
		oMdlZZ1B:LoadValue("ZZ1_STATUS"	, "2" )
	//Finalização da Solicitação
	ElseIf nOp == 4 .AND. RetCodUsr() == cCodSolic	 .AND. !Empty(cCodAtend) .AND. (cStatus == "2" .OR. cStatus == "4" .OR. cStatus == "5") .AND. lFinal
		oMdlZZ1A:LoadValue("ZZ1_DTFINA"	, dDataBase )
		oMdlZZ1A:LoadValue("ZZ1_STATUS"	, "3" )			
		oModel:GetModel( 'ZZ2UNICO' ):SetNoDeleteLine( .T. )
		oModel:GetModel( 'ZZ2UNICO' ):SetNoInsertLine( .T. )
	//Pendencia da Solicitação
	ElseIf nOp == 4 .AND. RetCodUsr() == cCodSolic	 .AND. !Empty(cCodAtend)  .AND. (cStatus == "2" .OR. cStatus == "5") .AND. lPende
		oMdlZZ1A:LoadValue("ZZ1_STATUS"	, "4" )			
		oModel:GetModel( 'ZZ2UNICO' ):SetNoDeleteLine( .T. )
		oModel:GetModel( 'ZZ2UNICO' ):SetNoInsertLine( .T. )
	//Trânsito Solicitação, atendimento Solicitação Logística/ Atendente
	ElseIf nOp == 4 .AND. RetCodUsr() != cCodSolic .AND. lLogis .AND. cTrasito == "1"
		oMdlZZ1A:LoadValue("ZZ1_STATUS"	, "5" )
		oMdlZZ1D:LoadValue("ZZ1_DTDESP"	, dDataBase )
	EndIf

Return