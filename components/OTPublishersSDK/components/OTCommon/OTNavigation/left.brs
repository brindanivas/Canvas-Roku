function navigateLeft(key, press, currentValue)
    nextPath = [m.navDirections.key[0] - 1, m.navDirections.key[1]]
    if nextPath[0] > -1 and nextPath[0] < m.navDirections.value.count()
        navController(key,press, currentValue, nextPath)
    end if
end function