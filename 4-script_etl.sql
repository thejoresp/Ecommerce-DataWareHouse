-- Script ETL de actualización

-- Populando DimTiempo
INSERT INTO TiendaElectronicaOnline_DW.dbo.DimTiempo (Fecha, Anio, Mes, NombreMes, Trimestre, NombreTrimestre, DiaSemana, NombreDiaSemana, DiaDelAnio)
SELECT DISTINCT
    p.FechaPedido AS Fecha,
    YEAR(p.FechaPedido) AS Anio,
    MONTH(p.FechaPedido) AS Mes,
    DATENAME(MONTH, p.FechaPedido) AS NombreMes,
    DATEPART(QUARTER, p.FechaPedido) AS Trimestre,
    'Q' + CAST(DATEPART(QUARTER, p.FechaPedido) AS VARCHAR(1)) AS NombreTrimestre,
    DATEPART(WEEKDAY, p.FechaPedido) AS DiaSemana,
    DATENAME(WEEKDAY, p.FechaPedido) AS NombreDiaSemana,
    DATEPART(DAYOFYEAR, p.FechaPedido) AS DiaDelAnio
FROM
    TiendaElectronicaOnline.dbo.Pedidos p
    LEFT JOIN TiendaElectronicaOnline_DW.dbo.DimTiempo dt ON dt.Fecha = p.FechaPedido
WHERE dt.Fecha IS NULL;

-- Populando DimProducto
INSERT INTO TiendaElectronicaOnline_DW.dbo.DimProducto (ProductoID, NombreProducto, Categoria, PrecioActual)
SELECT DISTINCT
    p.ProductoID,
    p.NombreProducto,
    p.Categoria,
    p.Precio
FROM
    TiendaElectronicaOnline.dbo.Productos p
    LEFT JOIN TiendaElectronicaOnline_DW.dbo.DimProducto dp ON dp.ProductoID = p.ProductoID
WHERE dp.ProductoID IS NULL;

-- Populando DimCliente
INSERT INTO TiendaElectronicaOnline_DW.dbo.DimCliente (ClienteID, NombreCompleto, CorreoElectronico, Ciudad, Direccion, Pais)
SELECT DISTINCT
    c.ClienteID,
    c.Nombre + ' ' + c.Apellido AS NombreCompleto,
    c.CorreoElectronico,
    c.Ciudad,
    c.Direccion,
    c.Pais
FROM
    TiendaElectronicaOnline.dbo.Clientes c
    LEFT JOIN TiendaElectronicaOnline_DW.dbo.DimCliente dc ON dc.ClienteID = c.ClienteID
WHERE dc.ClienteID IS NULL;


-- Populando DimProveedor de polulacion de primera intacia, primera carga
INSERT INTO TiendaElectronicaOnline_DW.dbo.DimProveedor (ProveedorSK, NombreProveedor, Ciudad, Pais, Clasificacion, EsProveedorCertificado, FechaInicio, FechaFin, Activo)
SELECT DISTINCT
    p.ProveedorID,
    p.NombreProveedor,
    p.Ciudad,
    p.Pais,
    p.Clasificacion,
    p.EsProveedorCertificado,
    p.FechaInicio,
    p.FechaFin,
    CASE WHEN p.FechaFin IS NULL THEN 1 ELSE 0 END AS Activo
FROM

        TiendaElectronicaOnline.dbo.Proveedores p
        LEFT JOIN TiendaElectronicaOnline_DW.dbo.DimProveedor dp ON dp.ProveedorSK = p.ProveedorID
WHERE dp.ProveedorSK IS NULL;




-- Populando DimMoneda (cotización de dólar para conversión a pesos)
INSERT INTO TiendaElectronicaOnline_DW.dbo.DimMoneda (Cotizacion, Moneda, Fecha)
SELECT DISTINCT
    m.Cotizacion,
    m.Moneda,
    m.Fecha
FROM
    TiendaElectronicaOnline.dbo.Moneda m
        LEFT JOIN TiendaElectronicaOnline_DW.dbo.DimMoneda dm ON dm.Fecha = m.Fecha
WHERE dm.Fecha IS NULL;


--TRUNCATE TABLE FactVentas
-- Populando FactVentas
INSERT INTO TiendaElectronicaOnline_DW.dbo.FactVentas (TiempoID, ProductoID, ClienteID, ProveedorID, PedidoID, Cantidad, PrecioUnitario, MontoTotal, Ganancia, FechaPedido, FechaEnvio, CostoEnvio, EstadoEnvio)
SELECT
    dt.TiempoID,
    dp.ProductoID,
    dc.ClienteID,
    dpr.ProveedorID,
    p.PedidoID,
    dped.Cantidad,
    dped.PrecioUnitario,
    dped.Cantidad * dped.PrecioUnitario AS MontoTotal,
    (dped.Cantidad * dped.PrecioUnitario) - (dped.Cantidad * prod.Costo) AS Ganancia,
    p.FechaPedido,
    p.FechaEnvio,
    p.CostoEnvio,
    e.EstadoEnvio
FROM
    TiendaElectronicaOnline.dbo.Pedidos p
        JOIN TiendaElectronicaOnline.dbo.DetallesPedido dped ON p.PedidoID = dped.PedidoID
        JOIN TiendaElectronicaOnline.dbo.Productos prod ON dped.ProductoID = prod.ProductoID
        LEFT JOIN TiendaElectronicaOnline_DW.dbo.DimTiempo dt ON dt.Fecha = p.FechaPedido
        LEFT JOIN TiendaElectronicaOnline_DW.dbo.DimProducto dp ON dp.ProductoID = dped.ProductoID
        LEFT JOIN TiendaElectronicaOnline_DW.dbo.DimCliente dc ON dc.ClienteID = p.ClienteID
        LEFT JOIN TiendaElectronicaOnline_DW.dbo.DimProveedor dpr ON
        dpr.ProveedorSK = prod.ProveedorID AND
        CAST(p.FechaPedido AS DATE) BETWEEN dpr.FechaInicio AND ISNULL(dpr.FechaFin, '9999-12-31')
        LEFT JOIN TiendaElectronicaOnline.dbo.Envios e ON e.PedidoID = p.PedidoID;
GO