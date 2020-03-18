#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} FSCO01WK
//TODO
@description Fun��o Aprova��o Solicita��o
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
	oBrowse:SetDescription("Solita��o Insumos")
	
	// Defini��o da legenda
	oBrowse:AddLegend( "ZZ1_STATUS=='1'", "GREEN"	, "Aberta" 						)
	oBrowse:AddLegend( "ZZ1_STATUS=='2'", "BLUE"	, "Pendente contagem estoque" 	)
	oBrowse:AddLegend( "ZZ1_STATUS=='3'", "RED"		, "Finalizada" 					)
	oBrowse:AddLegend( "ZZ1_STATUS=='4'", "ORANGE"	, "Pendente" 					)
	oBrowse:AddLegend( "ZZ1_STATUS=='5'", "YELLOW"	, "Tr�nsito" 					)
	
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
	ADD OPTION aRotina TITLE "Finalizar Solita��o"    	ACTION "U_FINALIZ()"  		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Pendencias"    			ACTION "U_PENDENCIAS()"  	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Tr�nsito"    				ACTION "U_TRANSITO()"  		OPERATION 4 ACCESS 0
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
	
	oModel := MPFormModel():New('Solicita��o Insumos', /*bPreValidacao*/, { | oModel | POSVALID( oModel ) } , /*{ | oMdl | MVC001C( oMdl ) }*/ ,, /*bCancel*/ )
		
	//GATILHOS CABE�ALHO
	//SOLICITANTE
	oStrZZ1B:AddTrigger( 'ZZ1_LOGIST'	, 'ZZ1_LOGIST', , { || REPLLOGIST() } )
	
	//GATILHOS GRID ITENS SOLICITA��O
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
	oModel:getModel('ZZ1PENDE'):SetDescription('Pend�ncias'	)
	oModel:getModel('ZZ1LOGIS'):SetDescription('Log�stica'	)
	
	oModel:getModel('ZZ2UNICO'):SetDescription('Itens Solicita��o')
	
	oModel:setactivate({|oModel| Carrega(oModel)})
	//oModel:SetVldActivate( { |oModel| PREVALID( oModel ) } )
	
Return oModel

/*/{Protheus.doc} ViewDef
//TODO
@decription Camada de visualiza��o
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
	
	//Se��o Solicitante
	oStruZZ1A:RemoveField( "ZZ1_CODATE" )
	oStruZZ1A:RemoveField( "ZZ1_NOMATE" )
	oStruZZ1A:RemoveField( "ZZ1_DTATEN" )
	oStruZZ1A:RemoveField( "ZZ1_STATUS" )
	oStruZZ1A:RemoveField( "ZZ1_PENDEN" )
	oStruZZ1A:RemoveField( "ZZ1_LOGIST" )
 	oStruZZ1A:RemoveField( "ZZ1_DTDESP" )
	oStruZZ1A:RemoveField( "ZZ1_OBSLOG" )
	//Se��o Atendente
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
	//Se��o Pend�ncias
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
	//Se��o Log�stica
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
	//Grid Itens Solicita��o
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
	
	oView:SetViewCanActivate({|oView|�PREVALID(oModel)})

Return oView

/*/{Protheus.doc} PREVALID
//TODO
@description PREVALID Valida��o Dados ao incluir/alterar
@author Willian Kaneta
@since 08/03/2017
@version 1.0
@param oModel, object, descricao
@type function
/*/
Static Function PREVALID( oModel )

	Local lRet 		:= .T.
	
	If RetCodUsr() == ZZ1->ZZ1_CODSOL .AND. Empty(ZZ1->ZZ1_DTATEN) .AND. Empty(ZZ1->ZZ1_DTFINA) .AND. (oModel:GetOperation() == 4 .OR. oModel:GetOperation() == 5) .AND. !lFinal .AND. !lPende .AND. !lLogis
		MsgAlert("N�o � possivel Alterar/ Excluir a solicita��o!","Aten��o")
		lRet := .F.
	ElseIf RetCodUsr() == ZZ1->ZZ1_CODSOL .AND. (!Empty(ZZ1->ZZ1_DTATEN) .AND. !Empty(ZZ1->ZZ1_DTFINA)) .AND. (oModel:GetOperation() == 4 .OR. oModel:GetOperation() == 5) .AND. (!lFinal .AND. !lPende .AND. !lLogis)
		MsgAlert("Op��o n�o permitida, solicita��o finalizada!","Aten��o")
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} POSVALID
//TODO
@description POSVALID Valida��o Dados ao incluir/alterar
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
		MsgAlert("� obrigat�rio informar o email do solicitante!!!","Aten��o")
		lRet := .F. 
	EndIf
	
	If Empty(dDataEntr) .AND. oModel:GetOperation() == 3 .OR. (oModel:GetOperation() == 4 .AND. cStatusSC == "1" .AND. Empty(dDataEntr))
		MsgAlert("� obrigat�rio informar o campo Data Entrega!!!","Aten��o")
		lRet := .F. 
	EndIf
			
	If Empty(cCultura) .AND. oModel:GetOperation() == 3 .OR. (oModel:GetOperation() == 4 .AND. cStatusSC == "1" .AND. Empty(cCultura))
		MsgAlert("� obrigat�rio informar o campo Cultura!!!","Aten��o")
		lRet := .F. 
	EndIf

	If Empty(cLogisti) .AND. lAtend
		MsgAlert("� obrigat�rio informar o campo Logistica!!!","Aten��o")
		lRet := .F. 		
	EndIf
	
	If Empty(cPendenc) .AND. lPende
		MsgAlert("� obrigat�rio informar o campo Pend�ncias!!!","Aten��o")
		lRet := .F. 		
	EndIf

	If Empty(dDtDespa) .AND. lLogis
		MsgAlert("� obrigat�rio informar o campo Data de Despacho!!!","Aten��o")
		lRet := .F. 		
	EndIf
	
	nLinOld 	:= oZZ2UNI:nLine
	For nX := 1 To oZZ2UNI:Length()
		oZZ2UNI:GoLine( nX )
		If oZZ2UNI:GetValue( "ZZ2_QUANT" ) == 0
			MsgAlert("� obrigat�rio informar o campo Quantidade do item da solicita��o! Item: " + cValToChar(nX), "Aten��o")
			lRet := .F.
			Exit
		EndIf
		
		If Empty(oZZ2UNI:GetValue( "ZZ2_LOGIST" )) .AND. lAtend
			MsgAlert("� obrigat�rio informar o campo Logistica na grid Itens Solicita��o! Item: " + cValToChar(nX) + " Informe o campo manualmente para cada Item, ou infome no cabe�alho Atendente campo Logistica para replicar para todos os itens.", "Aten��o")
			lRet := .F.
			Exit
		EndIf		
		
		If Empty(oZZ2UNI:GetValue( "ZZ2_AUTORI" )) .AND. lAtend
			MsgAlert("Infomar o c�digo da autoriza��o, campo obrigat�rio!", "Aten��o")
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
		
	//Caso os campos obrigat�rios estejam preenchidos, envia o email
	If lRet
		//Envia email na inclus�o, ao realizar o atendimento da solicita��o e ao finalizar a solicita��o
		/*PARAMETROS UTILIZADOS NA USER FUNCTION FSCO02WK
		1:EMAIL
		2:OPERA��O = 1 = INCLUS�O SOLICITA��O/ 2 = ATENDIMENTO/ 3 = FINALIZA��O SOLICITA��O	
		3:ASSUNTO
		4:TEXTO EMAIL
		*/
		//Inclus�o Solicita��o
		If oModel:GetOperation() == 3 .AND. !Empty(cMailAten)
			cAssunto 	:= "Inclus�o Solicita��o " + cNumSolic
			cTexto		:= "<b>Email informativo:</b> Realizado a inclus�o de uma nova solicita��o, codigo da solicita��o: "  + cNumSolic
			U_FSCO02WK(Alltrim(cMailAten),1,cAssunto,cTexto)
		//Atendimento
		ElseIf oModel:GetOperation() == 4 .AND. RetCodUsr() != cCodSolic .AND. lAtend
			//Email Atendimento Solicita��o com Logistica envia para o Solicitante e Logistica
			If cLogisti == "1" .AND. !Empty(cEmailSol) .AND. !Empty(cMailLogi)
				cMailLoSo	:= Alltrim(cEmailSol) + "," + Alltrim(cMailLogi)
				cAssunto 	:= "Atendimento Solicita��o com Log�stica " + cNumSolic
				cTexto		:= "<b>Email informativo:</b> Foi realizado o antendimento da solicita��o <b>com necessidade de log�stica</b> C�digo Solicita��o: "  + cNumSolic 
				U_FSCO02WK(Alltrim(cMailLoSo),2,cAssunto,cTexto,Alltrim(cPendenc),cDtDespa,cOBSLogi,aItensSC)
			//Email Atendimento Solicita��o com Logistica envia somente para o Solicitante caso o email da Logistica n�o esteja informado no par�metro MV_XMAILLO
			ElseIf cLogisti == "1" .AND. !Empty(cEmailSol) .AND. Empty(cMailLogi)
				cMailLoSo	:= cEmailSol
				cAssunto 	:= "Atendimento Solicita��o com Log�stica " + cNumSolic
				cTexto		:= "<b>Email informativo:</b> Foi realizado o antendimento da solicita��o <b>com necessidade de log�stica</b> C�digo Solicita��o: "  + cNumSolic 
				U_FSCO02WK(Alltrim(cMailLoSo),2,cAssunto,cTexto,Alltrim(cPendenc),cDtDespa,cOBSLogi,aItensSC)
			//Email Atendimento Solicita��o sem Logistica envia somente para o Solicitante
			ElseIf cLogisti == "2" .AND.!Empty(cEmailSol)
				cAssunto 	:= "Atendimento Solicita��o " + cNumSolic
				cTexto		:= "<b>Email informativo:</b> Foi realizado o antendimento da solicita��o " + cNumSolic 
				U_FSCO02WK(Alltrim(cEmailSol),2,cAssunto,cTexto,Alltrim(cPendenc),cDtDespa,cOBSLogi,aItensSC)
			EndIf		
		//Finaliza��o Solicita��o
		ElseIf oModel:GetOperation() == 4 .AND. RetCodUsr() == cCodSolic .AND. lFinal
			If !Empty(cMailAten) .AND. !Empty(cMailLogi)
				cMailLoAt	:= Alltrim(cMailAten) + "," + Alltrim(cMailLogi)
				cAssunto 	:= "Solicita��o Finalizada " + cNumSolic
				cTexto		:= "<b>Email informativo:</b> A solicita��o "  + cNumSolic + " foi finalizada."	
				U_FSCO02WK(Alltrim(cMailLoAt),3,cAssunto,cTexto,Alltrim(cPendenc),cDtDespa,cOBSLogi)
			ElseIf !Empty(cMailAten) .AND. Empty(cMailLogi)
				cMailLoAt	:= Alltrim(cMailAten)
				cAssunto 	:= "Solicita��o Finalizada " + cNumSolic
				cTexto		:= "<b>Email informativo:</b> A solicita��o "  + cNumSolic + " foi finalizada."	
				U_FSCO02WK(Alltrim(cMailLoAt),3,cAssunto,cTexto,Alltrim(cPendenc),cDtDespa,cOBSLogi)
			ElseIf Empty(cMailAten) .AND. !Empty(cMailLogi)
				cMailLoAt	:= Alltrim(cMailLogi)
				cAssunto 	:= "Solicita��o Finalizada " + cNumSolic
				cTexto		:= "<b>Email informativo:</b> A solicita��o "  + cNumSolic + " foi finalizada."	
				U_FSCO02WK(Alltrim(cMailLoAt),3,cAssunto,cTexto,Alltrim(cPendenc),cDtDespa,cOBSLogi)			
			EndIf
		//Pendencias Solicita��o
		ElseIf oModel:GetOperation() == 4 .AND. RetCodUsr() == cCodSolic  .AND. !Empty(cMailAten) .AND. lPende
			cAssunto 	:= "Solicita��o com Pend�ncias " + cNumSolic
			cTexto		:= "<b>Email informativo:</b> A solicita��o "  + cNumSolic + " possui pend�ncias."	
			If !Empty(cPendenc)
				cPendenc	:= "<b>Pend�ncias:</b> "  + Alltrim(cPendenc)
			EndIf
			U_FSCO02WK(Alltrim(cMailAten),4,cAssunto,cTexto,Alltrim(cPendenc))
		//Solicita��o em Transito - Atendimento solicita��o pelo setor da Log�stica
		ElseIf oModel:GetOperation() == 4 .AND. RetCodUsr() != cCodSolic  .AND. lLogis
			If !Empty(cEmailSol) .AND. !Empty(cMailAten)
				cMailSoAt	:= Alltrim(cEmailSol) + "," + Alltrim(cMailAten)
				cAssunto 	:= "Log�stica Atendida - Solicita��o " + cNumSolic
				cTexto		:= "<b>Email informativo:</b> A solicita��o "  + cNumSolic + " foi atendida pelo setor de Log�stica/ Atendimento."	
				If !Empty(dDtDespa)
					cDtDespa := "<b>Data de Despacho: </b>" + DTOC(dDtDespa)
				EndIf
				If !Empty(cOBSLogi)
					cOBSLogi	:= "<b>Obs. Log�stica:</b> "  + Alltrim(cOBSLogi)
				EndIf
				U_FSCO02WK(Alltrim(cMailSoAt),5,cAssunto,cTexto,Alltrim(cPendenc),cDtDespa,cOBSLogi)
			EndIf
		EndIf	
	EndIf
Return lRet

/*/{Protheus.doc} REPLLOGIST
//TODO
@description Fun��o gatilho campo Logistica ZZ1 - ZZ1_LOGIST -> ZZ2_LOGIST
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
@description Gatilho para retornar a descri��o do produto
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
@description Fun��o para replicar o campo ZZ2_AUTORI
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
		If MsgYesNo("Deseja replicar a autoriza��o para todos os itens?")
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
@description Func�o para realizar o atendimento - Altera para Status ZZ1_STATUS = 2
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
		nRet := FWExecView('Atendimento Solicita��o Insumos', 'FSCO01WK', nOp,,{||.T.},,,aButtons,,,,)
	ElseIf	ZZ1->ZZ1_CODSOL == RetCodUsr()
		MsgAlert("Usu�rio sem permiss�o para realizar o atendimento da solicita��o","Aten��o")
	ElseIf ZZ1->ZZ1_CODSOL != RetCodUsr() .AND. !Empty(ZZ1->ZZ1_DTATEN) .AND. (ZZ1->ZZ1_STATUS == "4" .OR. ZZ1->ZZ1_STATUS == "5")
		MsgAlert("N�o � permitido realizar o atendimento de de uma solicita��o que possui pend�ncias ou foi atendida pelo setor de Log�stica!","Aten��o")
	ElseIf ZZ1->ZZ1_CODSOL != RetCodUsr() .AND. !Empty(ZZ1->ZZ1_DTFINA) .AND. ZZ1->ZZ1_STATUS == "3"
		MsgAlert("Op��o n�o permitida, esta solicita��o j� foi finalizada!","Aten��o")
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
@description Func�o para finalizar o atendimento - Altera para Status ZZ1_STATUS = 3
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
		nRet := FWExecView('Finalizar Solicita��o Insumos', 'FSCO01WK', nOp,,{||.T.},,,aButtons,,,,)
	ElseIf ZZ1->ZZ1_CODSOL != RetCodUsr()
		MsgAlert("Usu�rio sem permiss�o para finalizar a solicita��o!","Aten��o")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. Empty(ZZ1->ZZ1_CODATE)
		MsgAlert("N�o � poss�vel finalizar uma solicita��o que n�o foi atendida!","Aten��o")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. !Empty(ZZ1->ZZ1_DTFINA)
		MsgAlert("Esta solicita��o j� foi finalizada!","Aten��o")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. ZZ1->ZZ1_LOGIST == "1" .AND. ZZ1->ZZ1_STATUS != "5" .AND. ZZ1->ZZ1_STATUS != "4" .AND. Empty(ZZ1->ZZ1_DTDESP)
		MsgAlert("Esta solicita��o necessita de log�stica, s� � permitido finalizar solicita��o que n�o possui log�stica, ou que possua log�stica e j� foi atendida pelo setor de Log�stica/Atendimento!","Aten��o")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. Empty(ZZ1->ZZ1_LOGIST)	
		MsgAlert("N�o foi informado o campo Log�stica, verificar com o setor de atendimento!","Aten��o")
	EndIf
	
	If nRet == 0 
		lFinal := .F.
		MsgInfo("Solicita��o finalizada com Sucesso!!!")
	Else
		lFinal := .F.
	EndIf
	
Return

/*/{Protheus.doc} PENDENCIAS
//TODO
@description Func�o para gravar pend�ncias na solicita��o - Altera para Status ZZ1_STATUS = 4
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
		nRet := FWExecView('Pend�ncias Solicita��o Insumos', 'FSCO01WK', nOp,,{||.T.},,,aButtons,,,,)
	ElseIf ZZ1->ZZ1_CODSOL != RetCodUsr()
		MsgAlert("Usu�rio sem permiss�o para informar as pendencias da solicita��o!","Aten��o")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. Empty(ZZ1->ZZ1_CODATE)
		MsgAlert("N�o � poss�vel informar as pend�ncias de uma solicita��o que n�o foi atendida!","Aten��o")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. !Empty(ZZ1->ZZ1_DTFINA)
		MsgAlert("Esta solicita��o j� foi finalizada!","Aten��o")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. ZZ1->ZZ1_LOGIST == "1" .AND. ZZ1->ZZ1_STATUS != "5" .AND. ZZ1->ZZ1_STATUS != "4" .AND. Empty(ZZ1->ZZ1_DTDESP)
		MsgAlert("Esta solicita��o necessita de log�stica, s� � permitido informar pend�ncias da solicita��o que n�o possui log�stica, ou que possua log�stica e j� foi atendida pelo setor da Log�stica/Atendimento!","Aten��o")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr() .AND. Empty(ZZ1->ZZ1_LOGIST)	
		MsgAlert("N�o foi informado o campo Log�stica, verificar com o setor de atendimento!","Aten��o")
	EndIf
	
	If nRet == 0 
		lPende := .F.
		MsgInfo("Solicita��o alterada com Sucesso!!!")
	Else
		lPende := .F.
	EndIf
	
Return

/*/{Protheus.doc} TRANSITO
//TODO
@description Func�o para atendimento da Solicita��o pelo setor da Log�stica - Altera para Status ZZ1_STATUS = 5 
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
		nRet := FWExecView('Solicita��o Log�stica Insumos', 'FSCO01WK', nOp,,{||.T.},,,aButtons,,,,)
	ElseIf  ZZ1->ZZ1_CODSOL != RetCodUsr() .AND. ZZ1->ZZ1_LOGIST != "1" .AND. Empty(ZZ1->ZZ1_DTFINA) .AND. !Empty(ZZ1->ZZ1_CODATE)
		MsgAlert("Op��o permitida somente caso a solicita��o possua Log�stica (campo ZZ1_LOGIST = Sim)!","Aten��o")
	ElseIf ZZ1->ZZ1_CODSOL == RetCodUsr()
		MsgAlert("Usu�rio sem permiss�o para atendimento Log�stica da solicita��o!","Aten��o")
	ElseIf ZZ1->ZZ1_CODSOL != RetCodUsr() .AND. Empty(ZZ1->ZZ1_CODATE)
		MsgAlert("N�o � poss�vel realizar o atendimento log�stica de uma solicita��o que n�o foi atendida!","Aten��o")
	ElseIf ZZ1->ZZ1_CODSOL != RetCodUsr() .AND. !Empty(ZZ1->ZZ1_DTFINA)
		MsgAlert("Esta solicita��o j� foi finalizada!","Aten��o")
	EndIf
	
	If nRet == 0 
		lLogis := .F.
		MsgInfo("Solicita��o alterada com Sucesso!!!")
	Else
		lLogis := .F.
	EndIf
	
Return

/*/{Protheus.doc} CARREGA
//TODO
@description Fun��o que carrega informa��es dos campos
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
	
	//Inclus�o Solicita��o
	If nOp == 3
		oMdlZZ1A:LoadValue("ZZ1_CODSOL"	, RetCodUsr() ) 
		oMdlZZ1A:LoadValue("ZZ1_NOMSOL"	, UsrRetName(RetCodUsr()) )
		oMdlZZ1A:LoadValue("ZZ1_DTSOLI"	, dDataBase )	
	//Atendimento da Solicita��o
	ElseIf nOp == 4 .AND. RetCodUsr() != cCodSolic .AND. lAtend
		oMdlZZ1B:LoadValue("ZZ1_CODATE"	, RetCodUsr() )
		oMdlZZ1B:LoadValue("ZZ1_NOMATE"	, UsrRetName(RetCodUsr()) )
		oMdlZZ1B:LoadValue("ZZ1_DTATEN"	, dDataBase )
		oMdlZZ1B:LoadValue("ZZ1_STATUS"	, "2" )
	//Finaliza��o da Solicita��o
	ElseIf nOp == 4 .AND. RetCodUsr() == cCodSolic	 .AND. !Empty(cCodAtend) .AND. (cStatus == "2" .OR. cStatus == "4" .OR. cStatus == "5") .AND. lFinal
		oMdlZZ1A:LoadValue("ZZ1_DTFINA"	, dDataBase )
		oMdlZZ1A:LoadValue("ZZ1_STATUS"	, "3" )			
		oModel:GetModel( 'ZZ2UNICO' ):SetNoDeleteLine( .T. )
		oModel:GetModel( 'ZZ2UNICO' ):SetNoInsertLine( .T. )
	//Pendencia da Solicita��o
	ElseIf nOp == 4 .AND. RetCodUsr() == cCodSolic	 .AND. !Empty(cCodAtend)  .AND. (cStatus == "2" .OR. cStatus == "5") .AND. lPende
		oMdlZZ1A:LoadValue("ZZ1_STATUS"	, "4" )			
		oModel:GetModel( 'ZZ2UNICO' ):SetNoDeleteLine( .T. )
		oModel:GetModel( 'ZZ2UNICO' ):SetNoInsertLine( .T. )
	//Tr�nsito Solicita��o, atendimento Solicita��o Log�stica/ Atendente
	ElseIf nOp == 4 .AND. RetCodUsr() != cCodSolic .AND. lLogis .AND. cTrasito == "1"
		oMdlZZ1A:LoadValue("ZZ1_STATUS"	, "5" )
		oMdlZZ1D:LoadValue("ZZ1_DTDESP"	, dDataBase )
	EndIf

Return