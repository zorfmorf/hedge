
return {
        id = 3,
        name = "Karen",
        use = function(self, x, y)
            print( "Karen got used", x, y)
            st_ingame:startDialog("d_karen", 1, x, y)
        end,
        charset = "karen"
    }