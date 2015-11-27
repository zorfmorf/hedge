
local container = nil

local function sellProduce()
    st_ingame.transition = Transition("fade_out", function()
        st_ingame:placePlayer(-8, 15)
        player.dir = "right"
        player:update(0)
            
        local earned = 0
        local sold = 0
        local sells = {}
        for i,item in ipairs(inventory.items) do
            if item and item.flags.produce then
                
                -- sell random amount of this produce
                local amount = math.floor(math.random() * (item.count+1))
                
                -- make sure that overall at least one item is sold
                if amount == 0 and sold == 0 then amount = 1 end
                
                table.insert(sells, { amount=amount, id=item.id, price=item:getSellPrice() })
            end
        end
        for i,sell in ipairs(sells) do
            sold = sold + sell.amount
            earned = math.floor(sell.price * sell.amount) -- full price if you sell yourself!
            inventory:remove(sell.id, sell.amount)
        end
        local hour = timeHandler.getHour()
        timeHandler.addTime((17 - hour) * 60)
        inventory:addMoney(earned)
        player:addFloatingText("Earned "..earned.." money and sold "..sold.." produce!", true)
    end)
end

local lines = {}

lines[1] = { text = function() return "It's too late in the day to sell produce. I should come back tomorrow." end, target=-1}
lines[2] = { text = function() return "I don't have any produce to sell..." end, target=-1}
lines[3] = { text = function() return "Should I sell my produce at the market? This will take most of the day..." end,
                options={ 
                    { target=-1, text="Better get to it!", func=function() sellProduce() end },
                    { target=-1, text="I've changed my mind."}
                }
            }

return lines
