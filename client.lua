--------------------------------------------------------------------

local screenW,screenH = guiGetScreenSize()
local resW, resH = 1366,768
local x, y = (screenW/resW), (screenH/resH)

--------------------------------------------------------------------

function Window(rnames)
  if isElement(myWindow) then return end
  local screenW, screenH = guiGetScreenSize()
	
  myWindow = guiCreateWindow((screenW - x*485) / 2, (screenH - y*404) / 2, x*485, y*404, "Rotas", false)
  rotas = guiCreateGridList(x*40, y*40, x*405, y*275, false, myWindow)
  guiWindowSetSizable(myWindow, false)
  guiSetAlpha(rotas, x*0.70)
  guiGridListAddColumn( rotas, "Rotas", x*0.85 )
	
  for k,v in pairs(rnames) do
   row =  guiGridListAddRow ( rotas )
   guiGridListSetItemText ( rotas, row, 1,  tostring(k), false, false )
  end
	
  showCursor(true)
	
  fechar = guiCreateButton(x*275, y*334, x*168, y*35, "Fechar", false, myWindow)
  escolher = guiCreateButton(x*42, y*334, x*168, y*35, "Carregar", false, myWindow)
end
addEvent("Hype>JOBEntregadorDeJornal>AbrirPainel<Client", true)
addEventHandler("Hype>JOBEntregadorDeJornal>AbrirPainel<Client", localPlayer, Window)

function botoes(bt,state)
	if state == "up" and bt == "left" then
		if source == fechar then
			if isElement(myWindow) then
				destroyElement(myWindow)
				showCursor(false)
			end
		end
		if source == escolher then
			local selectedItemx = guiGridListGetSelectedItem(rotas)
			local nome = guiGridListGetItemText(rotas, selectedItemx, 1)
			if nome == nil then outputChatBox("[ #00FF73Servidor #ffffff] - Selecione Uma Rota",255,255,255,true) return end
			triggerServerEvent("Hype>request>Startrota>Server>EntregadorDeJornal",localPlayer,localPlayer,nome)	
			if isElement(myWindow) then
				destroyElement(myWindow)
				showCursor(false)
			end			
		end
	end
end
addEventHandler("onClientGUIClick", root,botoes)


function blips(state,x,y,z)
	if state == true then
		if not isElement(blips) then
			blips = createBlip ( x, y, z, 0)
		end
	else
		if isElement(blips) then
			destroyElement(blips)
		end	
	end
end
addEvent("Hype>JOBEntregadorDeJornal>blips<Client", true)
addEventHandler("Hype>JOBEntregadorDeJornal>blips<Client", localPlayer, blips)

function DesligarAntiQuedaBike ()  
 setPedCanBeKnockedOffBike ( localPlayer, true )
end
addEvent( "Desligar:AntiQueda", true )
addEventHandler( "Desligar:AntiQueda", localPlayer, DesligarAntiQuedaBike )

function LigarAntiQuedaBike ()  
 setPedCanBeKnockedOffBike ( localPlayer, false )
end
addEvent( "Ligar:AntiQueda", true )
addEventHandler( "Ligar:AntiQueda", localPlayer, LigarAntiQuedaBike )
