#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} FSCO02WK
//TODO
@description Função para enviar email
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
	Local nPorta 		:= SuperGetMv("MV_PORSMTP",,587) //informa a porta que o servidor SMTP irá se comunicar, podendo ser 25 ou 587
	Local cCompName 	:= FWFilName( cEmpAnt, cFilAnt )

	//A porta 25, por ser utilizada há mais tempo, possui uma vulnerabilidade maior a 
	//ataques e interceptação de mensagens, além de não exigir autenticação para envio 
	//das mensagens, ao contrário da 587 que oferece esta segurança a mais.
			
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
	//Pendências
	If !Empty(cPendenc)
		xHTM += cPendenc + '<br><br>'	
	EndIf
	//Data Despacho - Atendimento Logística
	If !Empty(cDtDespa)
		xHTM += cDtDespa + '<br>'	
	EndIf
	//Observações Logística - Atendimento Logística
	If !Empty(cOBSLogi)
		xHTM += cOBSLogi + '<br><br>'
	EndIf
    
    //Itens que necessitam de logistica
    If nOperacao == 2
    	If Len(aItensSC) != 0
    		xHTM += '<b>ITENS DA SOLICITAÇÃO</b><br>
    		xHTM += '	<table class="tg">'
			xHTM += '	  <tr>          '
			xHTM += '	    <th class="tg-huc9">Item</th>'
			xHTM += '	    <th class="tg-huc9">Código Solicitação</th>'
			xHTM += '	    <th class="tg-huc9">Código Produto</th>'
			xHTM += '	    <th class="tg-huc9">Descrição Produto</th>'
			xHTM += '	    <th class="tg-huc9">Quantidade Produto</th>'
			xHTM += '	    <th class="tg-huc9">Logistica Solicitação</th>'
			xHTM += '	    <th class="tg-huc9">Autorização de Entrega</th>'
			xHTM += '	    <th class="tg-huc9">Contrato Parceria</th>'
			xHTM += '	  </tr>         '
			For	nX := 1 To Len(aItensSC)
				xHTM += '	  <tr>          '
				xHTM += '	    <td class="tg-baqh">'+ aItensSC[nX,1]                              +'</td>   ' //Item
				xHTM += '	    <td class="tg-baqh">'+ aItensSC[nX,2]                              +'</td>   ' //Código Solicitação
				xHTM += '	    <td class="tg-baqh">'+ aItensSC[nX,3]                              +'</td>   ' //Código Produto
				xHTM += '	    <td class="tg-baqh">'+ aItensSC[nX,4]                              +'</td>   ' //Descrição Produto
				xHTM += '	    <td class="tg-baqh">'+ TRANSFORM(aItensSC[nX,5],"@E 999,999.9999") +'</td>   ' //Quantidade Produto
				xHTM += '	    <td class="tg-baqh">'+ IIF(aItensSC[nX,6] == "1","Sim","Não")      +'</td>   ' //Logistica Solicitação
				xHTM += '	    <td class="tg-baqh">'+ aItensSC[nX,7]                              +'</td>   ' //Autorização de Entrega
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
	oServer:SetUseTLS( .T. ) //Indica se será utilizará a comunicação segura através de SSL/TLS (.T.) ou não (.F.)
   
	xRet := oServer:Init( "", cMailServer, cMailConta, cMailSenha, 0, nPorta ) //inicilizar o servidor
	if xRet != 0
		alert("O servidor SMTP não foi inicializado: " + oServer:GetErrorString( xRet ) )
		return
	endif
   
	xRet := oServer:SetSMTPTimeout( 60 ) //Indica o tempo de espera em segundos.
	if xRet != 0
		alert("Não foi possível definir " + cProtocol + " tempo limite para " + cValToChar( nTimeout ))
	endif
   
	xRet := oServer:SMTPConnect()
	if xRet <> 0
		alert("Não foi possível conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		return
	endif
   
	if lMailAuth
		//O método SMTPAuth ao tentar realizar a autenticação do 
		//usuário no servidor de e-mail, verifica a configuração 
		//da chave AuthSmtp, na seção [Mail], no arquivo de 
		//configuração (INI) do TOTVS Application Server, para determinar o valor.
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
		alert("Não foi possível enviar mensagem: " + oServer:GetErrorString( xRet ))
	endif
   
	xRet := oServer:SMTPDisconnect()
	if xRet <> 0
		alert("Não foi possível desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
	endif
return