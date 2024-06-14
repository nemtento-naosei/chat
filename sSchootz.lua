db = dbConnect('sqlite', 'dados.db')
dbExec(db, 'CREATE TABLE IF NOT EXISTS carros (id INTEGER PRIMARY KEY AUTOINCREMENT, user TEXT, model INTEGER, state TEXT, seguro TEXT, infos TEXT, dados TEXT, plate TEXT)')
dbExec(db, 'CREATE TABLE IF NOT EXISTS estoque (model INTEGER, value INTEGER)')

concessonaria = {}
detrans = {}
garagens = {}
blipdetran = {} 
blipgaragem = {}
blipconce = {}
tracker = {}

car = {} 
dados = {}
contaDono = {}
carTest = {} 
positionAtual = {} 
cooldownPlayer = {} 
cooldownPlayer2 = {} 

function Markers()
    for i,v in ipairs(config['Lojas']) do 
        concessonaria[i] = createMarker(v[1], v[2], v[3] -1, 'cylinder', 1.1, 139, 0, 255, 0)
        setElementData(concessonaria[i], "markerData", {title = "Concessionaria", desc = "Compre seu veículo aqui nesta loja!", icon = "exchange"})
        blipconce[i] = createBlip(v[1], v[2], v[3], 55)
    end
end
addEventHandler('onResourceStart', resourceRoot, Markers)

function PassarMarker(player)
    for i,v in ipairs(concessonaria) do 
        if source == v then 
            if isElement(player) and getElementType(player) == 'player' then 
                triggerClientEvent(player, 'Schootz.openConce', player)
            end 
            break 
        elseif i == #concessonaria then 
            for i,v in ipairs(garagens) do 
                if source == v then 
                    triggerClientEvent(player, 'Schootz.openGaragem', player)
                    break
                elseif i == #garagens then 
                    for i,v in ipairs(detrans) do 
                        if source == v then 
                            if player and isElement(player) and getElementType(player) == 'player' then
                                local carros = dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE user = ?', getAccountName(getPlayerAccount(player))), - 1)
                                triggerClientEvent(player, 'Schootz.openDetran', player, carros)
                                break
                            end
                        end 
                    end 
                end 
            end 
        end 
    end 
end
addEventHandler('onMarkerHit', root, PassarMarker)

function Markers1()
    for i,v in ipairs(config['Garagens']) do 
        garagens[i] = createMarker(v[1], v[2], v[3] -1, 'cylinder', 1.1, 139, 0, 255, 0)
        setElementData(garagens[i], "markerData", {title = "Garagem", desc = "Pegue seu veículo aqui!", icon = "garage"})
        blipgaragem[i] = createBlip(v[1], v[2], v[3], 53)
    end
    for i,v in ipairs(config['Detrans']) do 
        detrans[i] = createMarker(v[1], v[2], v[3] -1, 'cylinder', 1.1, 139, 0, 255, 0)
        setElementData(detrans[i], "markerData", {title = "Detran", desc = "Veja as pendencia do seu veículo!", icon = "office"})
        blipdetran[i] = createBlip(v[1], v[2], v[3], 24)
    end
end
addEventHandler('onResourceStart', resourceRoot, Markers1)


function setStock(player, _, model, estoque)
    if isPlayerAdmin(player) then
        notifyS(player, 'Você não tem permissão.', 'error')
    else
        if not (model and estoque) then
            notifyS(player, 'Você não inseriu um modelo e um estoque.', 'error')
        else
            local result = dbPoll(dbQuery(db, 'SELECT * FROM estoque WHERE model = ?', tonumber(model)), - 1)
            if (#result ~= 0) then
                dbExec(db, 'UPDATE estoque SET value = ? WHERE model = ?', tonumber(estoque), tonumber(model))
                notifyS(player, 'Você colocou "'..estoque..'" de estoque no veiculo "'..model..'" com sucesso!', 'success')
                --exports['[BAR]Util']:messageDiscord('O staff '..puxarNome(player)..'('..puxarID(player)..') adicionou '..estoque..' na concessionária ', 'https://discord.com/api/webhooks/1126236631637172235/MEiejqB4LDYL2SYu8-wrapLeBVThkoy6DQDgU5n7e3iuEESVF0w7RyFbVveWCzh_pRb7')
            else
                notifyS(player, 'Veiculo não encontrado.', 'error')
            end 
        end
    end
end
addCommandHandler('setestoque', setStock)

setTimer(function()
    for i, vei in ipairs(config['Veiculos']) do
        local data = dbPoll(dbQuery(db, 'SELECT * FROM estoque WHERE model = ?', vei[2]), -1)
        if (#data == 0) then
            dbExec(db, 'INSERT INTO estoque (model, value) VALUES(?, ?)', vei[2], 35)
        end
    end
end, 1000, 1)

local colshape = createColSphere(1321.813, 2673.429, 11.239, 68)

function leftCol(veh)
    if isElement(veh) and getElementType(veh) == 'vehicle' and carTest[veh] and isElement(carTest[veh]) then
        triggerClientEvent(carTest[veh], 'Schootz.onTesteDrive', carTest[veh], 'remove')
        if car[carTest[veh]] and isElement(car[carTest[veh]]) then
            destroyElement(car[carTest[veh]])
        end
        setTimer(function(player)
            if positionAtual[player] then
                notifyS(player, 'Você saiu do estacionamento e perdeu o teste.', 'error')
                setElementPosition(player, positionAtual[player][1], positionAtual[player][2], positionAtual[player][3])
            end
        end, 500, 1, carTest[veh])
    end
end
addEventHandler('onColShapeLeave', colshape, leftCol)

function testeDrive(model, color)
    if model then
        if not isTimer(cooldownPlayer[source]) then
            positionAtual[source] = {getElementPosition(source)}
            car[source] = createVehicle(model, 1369.293, 2648.308, 10.82, -0, 0, 359.342)
            setElementData(car[source], 'Owner', source)
            setElementData(car[source], "JOAO.fuel", 100)
            setVehicleColor(car[source], color[1], color[2], color[3], color[4], color[5], color[6], color[7], color[8], color[9])
            carTest[car[source]] = source
            warpPedIntoVehicle(source, car[source])
            triggerClientEvent(source, 'Schootz.closeConce', source)
            triggerClientEvent(source, 'Schootz.onTesteDrive', source, 'add')
            cooldownPlayer[source] = setTimer(function() end, 10*60000, 1)
            notifyS(source, 'Você está testando um veiculo.', 'info')
            cooldownPlayer2[source] = setTimer(function(player)
                if player and  isElement(player) then
                    triggerClientEvent(player, 'Schootz.onTesteDrive', player, 'remove')
                    if car[player] and isElement(car[player]) then
                        destroyElement(car[player])
                    end
                    setTimer(function(player)
                        if player and isElement(player) and  positionAtual[player] then
                            setElementPosition(player, positionAtual[player][1], positionAtual[player][2], positionAtual[player][3])
                            notifyS(player, 'Teste drive foi encerrado!', 'info')
                        end
                    end, 500, 1, player)
                end
            end, 60000, 1, source)
        else
            notifyS(source, 'Você já testou um veículo recentemente.', 'error')
        end
    end
end
addEvent('Schootz.TesteDrive', true)
addEventHandler('Schootz.TesteDrive', root, testeDrive)

function exitVehicle(player)
    if source == car[player] and isElement(car[player]) then
        destroyElement(car[player])
        triggerClientEvent(player, 'Schootz.onTesteDrive', player, 'remove')
        notifyS(player, 'Você saiu do veiculo e perdeu o teste drive.', 'error')
        setElementPosition(player, positionAtual[player][1], positionAtual[player][2], positionAtual[player][3])
    end
end
addEventHandler('onVehicleExit', root, exitVehicle)

function buyVehicle(player, model, color, type)
    if tonumber(model) and tostring(type) then 
        if not (#dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE user = ? AND model = ?', getAccountName(getPlayerAccount(player)), tonumber(model)), - 1) == 0) then
            notifyS(player, 'Você já possui este veiculo na garagem.', 'error')
        else
            local money = findPriceByModelVehicle(tonumber(model), tostring(type))
            local name = findNameByModelVehicle(tonumber(model))
            if isPlayerMoney(player, tostring(type)) < tonumber(money) then
                notifyS(player, 'Você não tem dinheiro suficiente!', 'error')
            else
                if not descEstoque(tonumber(model), tostring(type)) then
                    notifyS(player, 'Este veículo está fora de estoque.', 'error')
                else
                    if isPlayerVip(player) then
                        calculo = math.floor(tonumber((money / 100) * 90))
                    else  
                        calculo = tonumber(money)
                    end 
                    descPlayerMoney(player, tostring(type), tonumber(calculo))
                    notifyS(player, 'Você comprou o veiculo '..name..' por '..(type == 'dinheiro' and 'R$' or 'V$')..''..formatNumber(calculo)..' com sucesso!', 'success')
                    --exports['[BAR]Util']:messageDiscord('O jogador  '..puxarNome(player)..'('..puxarID(player)..') comprou o veiculo '..name..' por '..(type == 'dinheiro' and 'R$' or 'V$')..''..formatNumber(calculo)..' ', 'https://discord.com/api/webhooks/1126236631637172235/MEiejqB4LDYL2SYu8-wrapLeBVThkoy6DQDgU5n7e3iuEESVF0w7RyFbVveWCzh_pRb7')
                    notifyS(player, 'Vá ate a garagem mais próxima para pegar-lo!', 'info')
                    dados_veh = { vida = 1000, tunagem = {}, color = {color[1], color[2], color[3], color[4], color[5], color[6], color[7], color[8], color[9]}, light = {255, 255, 255}, gasolina = 100, malas = {} }
                    dbExec(db, 'INSERT INTO carros (user, model, state, seguro, infos, dados, plate) values(?, ?, ?, ?, ?, ?, ?)', getAccountName(getPlayerAccount(player)), tonumber(model), 'guardado', ((getRealTime().timestamp)+604800), toJSON({name, money, type}), toJSON({dados_veh}), createVehiclePlate())
                    local data = dbPoll(dbQuery(db, 'SELECT * FROM estoque'), -1)
                    triggerClientEvent(player, 'Schootz.InsertEstoqueC', player, data)
                end
            end
        end
    end
end
addEvent('Schootz.buyVehicle', true)
addEventHandler('Schootz.buyVehicle', root, buyVehicle)

function buyCashVehicle(player, name, model, money)
    if tonumber(model) then 
        if not (#dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE user = ? AND model = ?', getAccountName(getPlayerAccount(player)), tonumber(model)), - 1) == 0) then
            notifyS(player, 'Você já possui este veiculo na garagem.', 'error')
        else
            notifyS(player, 'Vá ate a garagem mais próxima para pegar seu novo veículo!', 'info')
            dados_veh = { vida = 1000, tunagem = {}, color = {255, 255, 255, 255, 255, 255, 255, 255, 255}, light = {255, 255, 255}, gasolina = 100, malas = {}, block_sell = true }
            dbExec(db, 'INSERT INTO carros (user, model, state, seguro, infos, dados, plate) values(?, ?, ?, ?, ?, ?, ?)', getAccountName(getPlayerAccount(player)), tonumber(model), 'guardado', ((getRealTime().timestamp)+604800), toJSON({name, money, "moneycoins"}), toJSON({dados_veh}), createVehiclePlate())
        end
    end
end
addEvent('MeloSCR:buyCashVehicle', true)
addEventHandler('MeloSCR:buyCashVehicle', root, buyCashVehicle)

function spawnVehicle(model, position)
    if (model) and (position) then
        local result = dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE model = ? AND user = ?', tonumber(model), getAccountName(getPlayerAccount(source))), - 1)
        if (#result ~= 0 and type(result) == 'table') then
            if result[1]['state'] == 'spawnado' then
                notifyS(source, 'Seu carro já está spawnado.', 'error')
            else
                if result[1]['state'] == 'recuperar' then
                    notifyS(source, 'Vá até o detran para recuperar o veículo.', 'error')
                else
                    if tonumber(result[1]["seguro"]) > getRealTime().timestamp then  
                        local vehicle = createVehicle(tonumber(model), unpack(position))
                        local table = fromJSON(result[1]['dados'])
                        setDadosVeh(vehicle, table[1])
                        setElementHealth( vehicle, tonumber(table[1].vida) )
                        setElementData(vehicle, 'Owner', source)
                        setElementData(vehicle, 'Schootz.idVehicle', result[1]['id'])
                        setVehiclePlateText(vehicle, result[1]['plate'])
                        setElementData(vehicle, 'Schootz.pesoMalas', getMalasByID(model))
                        contaDono[vehicle] = getAccountName(getPlayerAccount(source))
                        dbExec(db, 'UPDATE carros SET state = ? WHERE model = ? AND user = ?', 'spawnado', tonumber(model), getAccountName(getPlayerAccount(source)))
                        dados[vehicle] = {owner = source, account = getAccountName(getPlayerAccount(source)), id = result[1]['id']}
                        notifyS(source, 'Você spawnou o veículo '..findNameByModelVehicle(tonumber(model))..' com sucesso.', 'success')
                        triggerClientEvent(source, 'Schootz.closeGaragem', source)
                        warpPedIntoVehicle(source, vehicle)
                        setVehicleEngineState(vehicle, false)
                    else 
                        notifyS(source, 'Seu veículo possui impostos ativos, vá até o Detran para pagar!', 'error')
                    end 
                end
            end
        end
    end
end
addEvent('Schootz.spawnVehicle', true)
addEventHandler('Schootz.spawnVehicle', root, spawnVehicle)

function guardarVehicle(model)
    if model and tonumber(model) then
        local result = dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE model = ? AND user = ?', tonumber(model), getAccountName(getPlayerAccount(source))), - 1)
        if (#result ~= 0) then
            if result[1]['state'] == 'guardado' then
                notifyS(source, 'Este veículo não está spawnado.', 'error')
            else
                if not getVehicleCar(source, tonumber(model)) then 
                    notifyS(source, 'O veículo não está proximo a você.', 'error')
                else
                    local vehicle = getVehicleCar(source, tonumber(model))
                    if isElement(vehicle) then
                        destroyElement(vehicle)
                        notifyS(source, 'Você guardou o veículo com sucesso!', 'success')
                    end
                end
            end
        end
    end
end
addEvent('Schootz.guardarVehicle', true)
addEventHandler('Schootz.guardarVehicle', root, guardarVehicle)

dadosVenda = {}

function venderVehicle(model, action, id, value)
    if model and action then
        local result = dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE model = ? AND user = ?', tonumber(model), getAccountName(getPlayerAccount(source))), - 1)
        if (#result ~= 0) then
            if (action == 'loja') then
                local vehicle = getVehicleCar2(source, tonumber(model))
                if isElement(vehicle) then
                    destroyElement(vehicle)
                end
                local money = fromJSON(result[1]['infos'])
                if money[3] == 'aPoints' then
                    setElementData(source, 'aPoints', (getElementData(source, 'aPoints') or 0) + (money[2] / 100 * 80))
                else
                    givePlayerMoney(source, (money[2] / 100 * 80))
                end
                notifyS(source, 'Você vendeu o veiculo por R$'..formatNumber((money[2] / 100 * 80))..' com sucesso!', 'success')
                dbExec(db, 'delete from carros WHERE model = ? AND user = ?', tonumber(model), getAccountName(getPlayerAccount(source)))
                local result = dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE user = ?', getAccountName(getPlayerAccount(source))), - 1)
                triggerClientEvent(source, 'Schootz.insertGaragemC', source, result)
            elseif (action == "player") and value and tonumber(value) and id and tonumber(id) then
                if tonumber(value) <= 0 then
                    notifyS(source, 'Insira um valor válido.', 'error')
                else
                    local receiver = getPlayerFromID(tonumber(id))
                    if isElement(receiver) then
                        local result = dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE user = ? AND model = ?', getAccountName(getPlayerAccount(receiver)), tonumber(model)), - 1)
                        if (#result == 0) then
                            if getPlayerMoney(receiver) >= tonumber(value) then
                                triggerClientEvent(receiver, 'Schootz.onDrawOferta', receiver, getPlayerName(source), findNameByModelVehicle(tonumber(model)), tonumber(value))
                                dadosVenda[receiver] = {vendedor = source, modelVeh = model, valor = value}
                                notifyS(source, 'Oferta enviada para o jogador.', 'success')
                            else
                                notifyS(source, 'O jogador não possui dinheiro para comprar o veículo', 'error')
                            end
                        else
                            notifyS(source, 'O jogador já possui este modelo de veículo.', 'error')
                        end
                    else
                        notifyS(source, 'Este passaporte não está na cidade.', 'error')
                    end
                end
            end
        end
    end
end 
addEvent('Schootz.venderVehicle', true)
addEventHandler('Schootz.venderVehicle', root, venderVehicle)

addEvent("MeloSCR:PagarImpostoConce", true)
addEventHandler("MeloSCR:PagarImpostoConce", root, 
function (thePlayer, model)
    if thePlayer and isElement(thePlayer) and model and tonumber(model) then 
        local select = dbQuery(db, "SELECT * FROM carros WHERE user=? AND model=?", getAccountName(getPlayerAccount(thePlayer)), model)
        local sql = dbPoll(select, -1)
        if #sql > 0 and getRealTime().timestamp > tonumber(sql[1]["seguro"]) then 
            local valor = (findPriceByModelVehicle(model, "dinheiro")/100)*10
            if getPlayerMoney(thePlayer) >= valor then 
                takePlayerMoney(thePlayer, valor)
                notifyS(source, 'Você pagou os impostos deste veículo.', 'success')
                dbExec(db, "UPDATE carros SET seguro=? WHERE user=? AND model=?", ((getRealTime().timestamp)+604800), getAccountName(getPlayerAccount(thePlayer)), model)
            else 
                notifyS(source, 'Dinheiro Insuficiente para pagar os impostos deste veículo.', 'error')
            end 
        else 
            notifyS(source, 'Este veículo não tem impostos ativos.', 'error')
        end
    end 
end)

addEvent("Schootz.RecuperarVeh", true)
addEventHandler("Schootz.RecuperarVeh", root, 
function (thePlayer, model)
    if thePlayer and isElement(thePlayer) and model and tonumber(model) then
        local result = dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE user = ? AND model = ?', getAccountName(getPlayerAccount(thePlayer)), model), -1)
        if (#result ~= 0) then
            if result[1]['state'] ~= 'recuperar' then
                notifyS(source, 'Este veículo não precisa ser recuperado.', 'error')
            else
                local valor = (findPriceByModelVehicle(model, "dinheiro")/100)*20
                if getPlayerMoney(thePlayer) < tonumber(valor) then
                    notifyS(thePlayer, 'Você não tem dinheiro suficiente para recuperar o veículo', 'error')
                else
                    takePlayerMoney(thePlayer, valor)
                    notifyS(source, 'Você recuperou o veículo com sucesso.', 'success')
                    dbExec(db, 'UPDATE carros SET state=? WHERE user=? AND model=?', 'guardado', getAccountName(getPlayerAccount(thePlayer)), model)
                end
            end
        end
    end 
end)

function respostaOferta(action)
    if dadosVenda[source] and dadosVenda[source].vendedor and isElement(dadosVenda[source].vendedor) then
        if (action == 'aceitar') then
            local result = dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE user = ? AND model = ?', getAccountName(getPlayerAccount(dadosVenda[source].vendedor)), dadosVenda[source].modelVeh), - 1)
            if (#result ~= 0) then
                if getPlayerMoney(source) >= tonumber(dadosVenda[source].valor) then
                    local vehicle = getVehicleCar2(dadosVenda[source].vendedor, dadosVenda[source].modelVeh)
                    if isElement(vehicle) then
                        dados[vehicle] = {owner = source, account = getAccountName(getPlayerAccount(source)), id = result[1]['id']}
                    end
                    notifyS(source, 'Você aceitou a oferta do jogador.', 'success')
                    notifyS(dadosVenda[source].vendedor, 'O jogador aceitou sua oferta.', 'info') 
                    takePlayerMoney(source, tonumber(dadosVenda[source].valor))
                    givePlayerMoney(dadosVenda[source].vendedor, tonumber(dadosVenda[source].valor))
                    dbExec(db, 'UPDATE carros SET user = ? WHERE user = ? AND model = ?', getAccountName(getPlayerAccount(source)), getAccountName(getPlayerAccount(dadosVenda[source].vendedor)), dadosVenda[source].modelVeh)
                else
                    notifyS(source, 'Você não possui dinheiro suficiente.', 'error')
                end
            else
                notifyS(source, 'O veículo não está mais disponivel', 'error')
            end
        else
            notifyS(source, 'Você recusou a oferta do jogador.', 'error')
            notifyS(dadosVenda[source].vendedor, 'O jogador recusou a oferta.', 'error')
        end
    else
        notifyS(source, 'O vendedor está offilne.', 'error')
    end
end
addEvent('Schootz.respostaOferta', true)
addEventHandler('Schootz.respostaOferta', root, respostaOferta)

function insertEstoqueS()
    local data = dbPoll(dbQuery(db, 'SELECT * FROM estoque'), - 1)
    triggerClientEvent(source, 'Schootz.InsertEstoqueC', source, data)
end
addEvent('Schootz.insertEstoqueS', true)
addEventHandler('Schootz.insertEstoqueS', root, insertEstoqueS)

function insertGaragemS()
    local result = dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE user = ?', getAccountName(getPlayerAccount(source))), - 1)
    triggerClientEvent(source, 'Schootz.insertGaragemC', source, result)
end
addEvent('Schootz.insertGaragemS', true)
addEventHandler('Schootz.insertGaragemS', root, insertGaragemS)

setTimer(function()
    for _, vehicle in ipairs(getElementsByType('vehicle')) do
        if vehicle and isElement(vehicle) and getElementType(vehicle) == "vehicle" and isElementInWater(vehicle) and getVehicleType(vehicle) ~= "Boat" and dados[vehicle] then
            local result = dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE user = ? AND model = ?', dados[vehicle].account, getElementModel(vehicle)), - 1)
            if (#result ~= 0) then
                dbExec(db, 'UPDATE carros SET state = ? WHERE user = ? AND model = ?', 'recuperar', dados[vehicle].account, getElementModel(vehicle))
                destroyElement(vehicle)
            end
        end
    end
end, 60000, 0)

-- Funções Uteis --

function getPlayerFromID(id)
    if tonumber(id) then
        for _, player in ipairs(getElementsByType('player')) do
            if getElementData(player, 'ID') and (getElementData(player, 'ID') == tonumber(id)) then
                return player
            end
        end
    end
    return false
end

function findPriceByModelVehicle (model, type)
    for i, v in ipairs(config['Veiculos']) do
        if v[2] == model then
            if (type == 'dinheiro') then
                return v[3]
            else
                return v[4]
            end
        end
    end
    return 0
end

function findNameByModelVehicle(model)
    for i, v in ipairs(config['Veiculos']) do
        if v[2] == model then
            return v[1]
        end
    end
    return ''
end

addEventHandler('onPlayerLogin', root,
    function ()
        for i,v in ipairs(getElementsByType("vehicle")) do 
            if contaDono[v] and contaDono[v] == getAccountName(getPlayerAccount(source)) then 
                setElementData(v, "Owner", source)
                dados[v].owner = source 
            end 
        end 
    end
)

function getVehicleCar(player, model)
    if (model) then
        local posv = {getElementPosition(player)}
        for i, v in ipairs(getElementsByType('vehicle')) do
            if (getElementModel(v) == tonumber(model)) then
                local pos = {getElementPosition(v)}
                if (getDistanceBetweenPoints3D(posv[1], posv[2], posv[3], pos[1], pos[2], pos[3]) < 10) then
                    if (dados[v]) and (dados[v].owner == player) then
                        return v
                    end
                end
            end
        end
    end
    return false
end

function getVehicleCar2(player, model)
    if (model) then
        local posv = {getElementPosition(player)}
        for i, v in ipairs(getElementsByType('vehicle')) do
            if (getElementModel(v) == tonumber(model)) then
                if (dados[v]) and (dados[v].owner == player) then
                    return v
                end
            end
        end
    end
    return false
end

function joinVehicle(player, seat)
    if seat == 0 then
        outputChatBox('#49a6fc[BAR] #FFFFFFClique no veículo para abrir o porta-malas.', player, 255, 255, 255, true)
        outputChatBox('#49a6fc[BAR] #FFFFFFAperte \'L\' para ligar o farol.', player, 255, 255, 255, true)
        outputChatBox('#49a6fc[BAR] #FFFFFFAperte \'K\' para trancar o veiculo.', player, 255, 255, 255, true)
        outputChatBox('#49a6fc[BAR] #FFFFFFPressione a tecla \'J\' para ligar o veículo.', player, 255, 255, 255, true)
    end
end
addEventHandler('onVehicleEnter', root, joinVehicle)

function descEstoque(model, type)
    if type == 'dinheiro' then            
        local estoques = dbPoll(dbQuery(db, 'SELECT * FROM estoque WHERE model = ?', model), - 1)
        if tonumber(estoques[1]['value']) > 0 then
            dbExec(db, 'UPDATE estoque SET value = ? WHERE model = ?', (estoques[1]['value'] - 1), model)
            return true
        else
            return false
        end
    end
    return true
end

function saveDadosVeh (veh)
    if isElement(veh) and (getElementType(veh) == 'vehicle') then
        if (#dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE model = ? AND user = ?', getElementModel(veh), dados[veh].account), - 1) ~= 0) then
            local vehicle = getElementData(veh, 'Itens') or {}
            dados_veh = { vida = getElementHealth(veh), tunagem = getVehicleUpgrades(veh), color = {getVehicleColor(veh, true)}, light = {getVehicleHeadLightColor(veh)}, gasolina = (getElementData(veh, 'JOAO.fuel') or 100), malas = vehicle, position = {getElementPosition(veh)}, rotation = {getElementRotation(veh)}, engine = (getElementData(veh, 'tuning.engine') or 0), neon = (getElementData(veh, "JOAO.Neon") or nil), lsddoor = (getElementData(veh, "JOAO.Lsddoor") or nil), blindagem_pneu = (getElementData(veh, "JOAO.Armortires") or nil), horns = (getElementData(veh, "JOAO.Horns") or nil), engines = (getElementData(veh, "JOAO.Engines") or nil), traction = (getElementData(veh, "JOAO.Traction") or nil), weight = (getElementData(veh, "JOAO.Weight") or nil), direction_lock = (getElementData(veh, "JOAO.Directionlock") or nil), hydraulics = (getElementData(veh, "JOAO.Hydraulics") or nil), sizewhells = (getElementData(veh, "JOAO.SizeWheels") or nil) }
            dbExec(db, 'UPDATE carros SET dados = ? WHERE model = ? AND user = ?', toJSON({dados_veh}), getElementModel(veh), dados[veh].account)
        end
    end
end

function setDadosVeh (veh, table, painel)
    if isElement(veh) then
        if table.sizewhells then 
            setElementData(veh, "JOAO.SizeWhells", table.sizewhells)
        end 
        if table.weight then 
            setElementData(veh, "JOAO.Weight", table.weight)
        end 
        if table.engines and type(table.engines) == "table" then 
            setElementData(veh, "JOAO.Engines", table.engines)
        end 
        if table.traction then 
            setElementData(veh, "JOAO.Traction", table.traction)
        end 
        if table.hydraulics then 
            setElementData(veh, "JOAO.Hydraulics", table.hydraulics)
        end 
        if table.direction_lock then 
            setElementData(veh, "JOAO.Directionlock", table.direction_lock)
        end 
        if table.neon then 
            setElementData(veh, "JOAO.Neon", table.neon)
        end 
        if table.lsddoor then 
            setElementData(veh, "JOAO.Lsddoor", table.lsddoor)
        end 
        if table.blindagem_pneu then 
            setElementData(veh, "JOAO.Armortires", table.blindagem_pneu)
        end 
        if table.horns then 
            setElementData(veh, "JOAO.Horns", table.horns)
        end 
        setVehicleColor(veh, unpack(table.color))
        setVehicleHeadLightColor(veh, unpack(table.light))
        setElementData(veh, 'JOAO.fuel', tonumber(table.gasolina))
        setElementData(veh, 'tuning.engine', tonumber(table.engine))
        for _, upgrades in ipairs(table.tunagem) do
            addVehicleUpgrade(veh, tonumber(upgrades))
        end
        setElementData(veh, 'Itens', table.malas)
        if painel then
            if (table.position and type(table.position) == 'table') then
                setElementPosition(veh, unpack(table.position))
            end
            if (table.rotation and type(table.rotation) == 'table') then
                setElementRotation(veh, unpack(table.rotation))
            end
        end

    end
end

addEvent('onPlayerTrackVehicle', true)
addEventHandler('onPlayerTrackVehicle', root, 

    function(player, model)

        for i, v in ipairs(getElementsByType('vehicle')) do 

            if (tonumber(getElementModel(v)) == tonumber(model)) then 

                if (contaDono[v] and contaDono[v] == getAccountName(getPlayerAccount(player))) then 

                    if (isElement(tracker[player])) then 

                        destroyElement(tracker[player])

                    end 

                    tracker[player] = createBlipAttachedTo(v, 41, _, _, _, __, _, _, _, player)

                break end 

            end

        end
        
        notifyS(source, 'Veiculo localizado com sucesso.', 'success')

    end 

)


addEvent('onPlayerRequestCellphoneVehicles', true)
addEventHandler('onPlayerRequestCellphoneVehicles', root, 

    function(player)

        local vehiclesTable = {}
        local data = dbPoll(dbQuery(db, 'Select * from carros where user = ?', getAccountName(getPlayerAccount(player))), - 1)
        for i, v in ipairs(data) do 

            if (v['state'] == 'spawnado') then 

                table.insert(vehiclesTable, {findNameByModelVehicle(v['model']), v['model']})

            end

        end
        triggerClientEvent(player, 'onClientReceiveCellphoneVehicles', player, vehiclesTable)

    end 

)

addEventHandler('onPlayerQuit', root, 

    function()

        if (isElement(tracker[source])) then 

            destroyElement(tracker[source])

        end 

    end

)

function isPlayerMoney(player, type)
    if type == 'dinheiro' then
        return getPlayerMoney(player)
    else
        return tonumber(getElementData(player, 'aPoints') or 0)
    end
end

function descPlayerMoney(player, type, amount)
    if type == 'dinheiro' then
        return takePlayerMoney(player, tonumber(amount))
    else
        return setElementData(player, 'aPoints', (getElementData(player, 'aPoints') or 0) - tonumber(amount))
    end
end

function getMalasByID(id)
    for i, v in ipairs(config['Veiculos']) do
        if v[2] == id then
            return v[5]
        end
    end
    return 150
end

function stopResource()
    db = dbConnect('sqlite', 'dados.db')
    for i, v in ipairs(getElementsByType('vehicle')) do
        if dados[v] then
            saveDadosVeh(v)
            local result = dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE model = ? AND user = ?', getElementModel(v), dados[v].account), - 1)
            if (#result ~= 0) and (type(result) == 'table') then
                if result[1]['state'] == 'spawnado' then
                    dbExec(db, 'UPDATE carros SET state = ? WHERE model = ? AND user = ?', 'guardado', getElementModel(v), dados[v].account)
                end
            end
        end
    end
end
addEventHandler('onResourceStop', getResourceRootElement(getThisResource()), stopResource)

function elementDestroy()
    if (getElementType(source) == 'vehicle') then
        if dados[source] then
            saveDadosVeh(source)
            local result = dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE model = ? AND user = ?', getElementModel(source), dados[source].account), - 1)
            if (#result ~= 0) and (type(result) == 'table') then
                if result[1]['state'] == 'spawnado' then
                    dbExec(db, 'UPDATE carros SET state = ? WHERE model = ? AND user = ?', 'guardado', getElementModel(source), dados[source].account)
                end
            end
        end
    
        for i=0, 3 do
            local player = getVehicleOccupant(source, i)
            if (player and isElement(player) and getElementType(player) == 'player') then
                if getElementData(player, 'v.cinto') then
                    removeElementData(player, 'v.cinto')
                end
            end
        end
    end
end
addEventHandler('onElementDestroy', root, elementDestroy)

function exploseVehicle()
    if (getElementType(source) == 'vehicle') then
        if dados[source] then
            saveDadosVeh(source)
            local result = dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE model = ? AND user = ?', getElementModel(source), dados[source].account), - 1)
            if (#result ~= 0) and (type(result) == 'table') then
                if result[1]['state'] == 'spawnado' then
                    dbExec(db, 'UPDATE carros SET state = ? WHERE model = ? AND user = ?', 'guardado', getElementModel(source), dados[source].account)
                end
            end
        end
    end
end
addEventHandler('onVehicleExplode', root, exploseVehicle)

function setVehicleState(identity, state)
    if (identity) and (state) then
        local result = dbPoll(dbQuery(db, 'SELECT * FROM carros WHERE id = ?', identity), - 1)
        if (#result ~= 0) then
            if result[1]['id'] == identity then
                dbExec(db, 'UPDATE carros SET state = ? WHERE id = ?', state, identity)
                return true
            end
        end
    end
    return false
end

function getCarProx(player)
    local posv = {getElementPosition(player)}
    for i, v in ipairs(getElementsByType('vehicle')) do
        local pos = {getElementPosition(v)}
        if (getDistanceBetweenPoints3D(posv[1], posv[2], posv[3], pos[1], pos[2], pos[3]) < 5) then
            if ((getElementData(v, 'Schootz.idVehicle') or false)) then
                return v
            end
        end
    end
    return false
end

function getVehiclePrice(model)
    if (model) then
        for i,v in ipairs(config['Veiculos']) do
            if v[2] == model then
                return v[3]
            end
        end
    end
    return 0
end

function formatNumber(number)   
    local formatted = number   
    while true do       
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')     
        if ( k==0 ) then       
            break   
        end   
    end   
    return formatted 
end

function isPlayerVip(player) 
    for _, acl in ipairs(config['VIPs']) do 
        if isObjectInACLGroup('user.'..getAccountName(getPlayerAccount(player)), aclGetGroup(acl)) then 
            return true 
        end
    end
    return false
end

function isPlayerAdmin(player)
        if isObjectInACLGroup('user.'..getAccountName(getPlayerAccount(player)), aclGetGroup('Admin')) then
    end
end

function createVehiclePlate()
    local plate = ''
    local letters = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'R', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'}
    local nums = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
    for i = 1, 7 do
        if i <= 3 or i == 5 then 
            plate = plate..letters[math.random(1, #letters)]
        else
            plate = plate..nums[math.random(1, #nums)]
        end
    end
    return plate
end

function getVehicleDataFromPlate(plate)

    return dbPoll(dbQuery(db, 'Select * from carros where plate = ?', plate), - 1)

end

-- // INSERT PLATE 
for i, v in ipairs(dbPoll(dbQuery(db, 'Select * from carros'), - 1)) do 

    if not (v['plate']) then 

        dbExec(db, 'Update carros set plate = ? where id = ?', createVehiclePlate(), v['id'])
    
    end

end
