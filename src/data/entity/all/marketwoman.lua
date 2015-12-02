
return {
        id = 6,
        name = "Market woman",
        use = function(self, x, y)
            st_ingame:startDialog("d_marketwoman", 1, x, y)
        end,
        charset = "marketwoman",
        ai = "stroll"
    }
