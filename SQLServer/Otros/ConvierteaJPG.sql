-- Desde CMD, convierte a JPG
BCP "SELECT [campo] FROM [tabla] where [condicion]" queryout "D:\file.JPG" -S [HOST] -d [DATABASE] -U[usuario] -P[password]
pause
