#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} FSCO02WK
//TODO
@description Fun��o para enviar email
@author willian.kaneta
@since 30/12/2019
@version 1.0
@param cPara, characters, descricao
@param cAssunto, characters, descricao
@param cMensagem, characters, descricao
@param cArquivo, characters, descricao
@type function
/*/
user function FSCO02WK(cPara,nOperacao,cAssunto,cTexto,cPendenc,cDtDespa,cOBSLogi,aItensSC)
	Local cMsg 			:= ""
	Local nX			:= 0
	Local xRet			:= 0
	Local oServer, oMessage
	Local lMailAuth		:= SuperGetMv("MV_RELAUTH",,.T.)
	Local nPorta 		:= SuperGetMv("MV_PORSMTP",,587) //informa a porta que o servidor SMTP ir� se comunicar, podendo ser 25 ou 587
	Local cCompName 	:= FWFilName( cEmpAnt, cFilAnt )

	//A porta 25, por ser utilizada h� mais tempo, possui uma vulnerabilidade maior a 
	//ataques e intercepta��o de mensagens, al�m de n�o exigir autentica��o para envio 
	//das mensagens, ao contr�rio da 587 que oferece esta seguran�a a mais.
			
	Private cMailConta	:= SuperGetMv("MV_EMCONTA",,"")     //Conta utilizada para envio do email
	Private cMailServer	:= SuperGetMv("MV_RELSERV",,"")     //Servidor SMTP
	Private cMailSenha	:= SuperGetMv("MV_EMSENHA",,"")     //Senha da conta de e-mail utilizada para envio

	xHTM := '<HTML><BODY>'
	xHTM += '<head>'
	xHTM += '<style type="text/css">'
	xHTM += '.tg  {border-collapse:collapse;border-spacing:0;}'
	xHTM += '.tg td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:black;}'
	xHTM += '.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:black;}'
	xHTM += '.tg .tg-baqh{text-align:center;vertical-align:top}'
	xHTM += '.tg .tg-huc9{background-color:#9b9b9b;color:#ffffff;text-align:center;vertical-align:top}'
	xHTM += '</style>'	
	xHTM += '</head>'
	xHTM += '<hr>'
	xHTM += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
	xHTM += '<b><font face="Verdana" SIZE=3>'+cAssunto + " - Filial: "+ Alltrim(cFilAnt) +" - "+ Alltrim(cCompName) +" - "+' &nbsp; '+dtoc(date())+'&nbsp;&nbsp;&nbsp;'+time()+'</b></p>'
	xHTM += '<hr>'
	xHTM += '<br>'
	xHTM += '<br>'
	xHTM += cTexto + '<br><br>'
	//Pend�ncias
	If !Empty(cPendenc)
		xHTM += cPendenc + '<br><br>'	
	EndIf
	//Data Despacho - Atendimento Log�stica
	If !Empty(cDtDespa)
		xHTM += cDtDespa + '<br>'	
	EndIf
	//Observa��es Log�stica - Atendimento Log�stica
	If !Empty(cOBSLogi)
		xHTM += cOBSLogi + '<br><br>'
	EndIf
    
    //Itens que necessitam de logistica
    If nOperacao == 2
    	If Len(aItensSC) != 0
    		xHTM += '<b>ITENS DA SOLICITA��O</b><br>
    		xHTM += '	<table class="tg">'
			xHTM += '	  <tr>          '
			xHTM += '	    <th class="tg-huc9">Item</th>'
			xHTM += '	    <th class="tg-huc9">C�digo Solicita��o</th>'
			xHTM += '	    <th class="tg-huc9">C�digo Produto</th>'
			xHTM += '	    <th class="tg-huc9">Descri��o Produto</th>'
			xHTM += '	    <th class="tg-huc9">Quantidade Produto</th>'
			xHTM += '	    <th class="tg-huc9">Logistica Solicita��o</th>'
			xHTM += '	    <th class="tg-huc9">Autoriza��o de Entrega</th>'
			xHTM += '	    <th class="tg-huc9">Contrato Parceria</th>'
			xHTM += '	  </tr>         '
			For	nX := 1 To Len(aItensSC)
				xHTM += '	  <tr>          '
				xHTM += '	    <td class="tg-baqh">'+ aItensSC[nX,1]                              +'</td>   ' //Item
				xHTM += '	    <td class="tg-baqh">'+ aItensSC[nX,2]                              +'</td>   ' //C�digo Solicita��o
				xHTM += '	    <td class="tg-baqh">'+ aItensSC[nX,3]                              +'</td>   ' //C�digo Produto
				xHTM += '	    <td class="tg-baqh">'+ aItensSC[nX,4]                              +'</td>   ' //Descri��o Produto
				xHTM += '	    <td class="tg-baqh">'+ TRANSFORM(aItensSC[nX,5],"@E 999,999.9999") +'</td>   ' //Quantidade Produto
				xHTM += '	    <td class="tg-baqh">'+ IIF(aItensSC[nX,6] == "1","Sim","N�o")      +'</td>   ' //Logistica Solicita��o
				xHTM += '	    <td class="tg-baqh">'+ aItensSC[nX,7]                              +'</td>   ' //Autoriza��o de Entrega
				xHTM += '	    <td class="tg-baqh">'+ aItensSC[nX,8]                              +'</td>   ' //Contrato Parceria
				xHTM += '	  </tr>'
			Next nX

			xHTM += '	</table>'
    	EndIf
    EndIf
	xHTM += '</BODY></HTML>'
	      
   	oMessage:= TMailMessage():New()
	oMessage:Clear()
   
	oMessage:cDate	:= cValToChar( Date() )
	oMessage:cFrom 	:= cMailConta
	oMessage:cTo 	:= cPara
	oMessage:cSubject:= cAssunto + " Filial: "+ cFilAnt
	oMessage:cBody 	:= xHTM//cMensagem
	
   
	oServer := tMailManager():New()
	oServer:SetUseTLS( .T. ) //Indica se ser� utilizar� a comunica��o segura atrav�s de SSL/TLS (.T.) ou n�o (.F.)
   
	xRet := oServer:Init( "", cMailServer, cMailConta, cMailSenha, 0, nPorta ) //inicilizar o servidor
	if xRet != 0
		alert("O servidor SMTP n�o foi inicializado: " + oServer:GetErrorString( xRet ) )
		return
	endif
   
	xRet := oServer:SetSMTPTimeout( 60 ) //Indica o tempo de espera em segundos.
	if xRet != 0
		alert("N�o foi poss�vel definir " + cProtocol + " tempo limite para " + cValToChar( nTimeout ))
	endif
   
	xRet := oServer:SMTPConnect()
	if xRet <> 0
		alert("N�o foi poss�vel conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		return
	endif
   
	if lMailAuth
		//O m�todo SMTPAuth ao tentar realizar a autentica��o do 
		//usu�rio no servidor de e-mail, verifica a configura��o 
		//da chave AuthSmtp, na se��o [Mail], no arquivo de 
		//configura��o (INI) do TOTVS Application Server, para determinar o valor.
		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )
		if xRet <> 0
			cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
			alert( cMsg )
			oServer:SMTPDisconnect()
			return
		endif
   	Endif
	xRet := oMessage:Send( oServer )
	if xRet <> 0
		alert("N�o foi poss�vel enviar mensagem: " + oServer:GetErrorString( xRet ))
	endif
   
	xRet := oServer:SMTPDisconnect()
	if xRet <> 0
		alert("N�o foi poss�vel desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
	endif
return