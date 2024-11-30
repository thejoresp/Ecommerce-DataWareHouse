-- Script de verificación de datos en pesos y dólares
use TiendaElectronicaOnline_DW
-- Ejemplo de consulta para ver los reportes en pesos y en dólares
  SELECT
       fv.VentaID,
       fv.Cantidad,
       fv.PrecioUnitario AS PrecioUnitarioEnPesos,
       fv.MontoTotal AS MontoTotalEnPesos,
       fv.Ganancia AS GananciaEnPesos,
       dm.Cotizacion AS TipoCambio,
       fv.PrecioUnitario / dm.Cotizacion AS PrecioUnitarioEnDolares,
       fv.MontoTotal / dm.Cotizacion AS MontoTotalEnDolares,
       fv.Ganancia / dm.Cotizacion AS GananciaEnDolares,
       fv.FechaPedido
   FROM
       FactVentas fv
   JOIN DimMoneda dm ON dm.Fecha = fv.FechaPedido AND dm.Moneda = 'Dólar'
   ORDER BY
       fv.FechaPedido DESC;


--Reporte de Ventas Totales en Pesos y Dólares en un Rango de Fechas
DECLARE @FechaInicio DATE = '2024-01-01';
DECLARE @FechaFin DATE = '2024-03-31';

SELECT
    SUM(fv.MontoTotal) AS VentasTotalesEnPesos,
    SUM(fv.MontoTotal / dm.Cotizacion) AS VentasTotalesEnDólares
FROM
    FactVentas fv
JOIN DimMoneda dm ON dm.Fecha = fv.FechaPedido AND dm.Moneda = 'Dólar'
WHERE
    fv.FechaPedido BETWEEN @FechaInicio AND @FechaFin;


--Reporte de Ventas Mensuales Agrupadas por Mes y Año
SELECT
    dt.Anio,
    dt.NombreMes,
    dt.Mes,
    SUM(fv.MontoTotal) AS VentasTotalesEnPesos,
    SUM(fv.MontoTotal / dm.Cotizacion) AS VentasTotalesEnDolares
FROM
    FactVentas fv
JOIN DimTiempo dt ON dt.TiempoID = fv.TiempoID
JOIN DimMoneda dm ON dm.Fecha = fv.FechaPedido AND dm.Moneda = 'Dólar'
GROUP BY
    dt.Anio,
    dt.NombreMes,
    dt.Mes
ORDER BY
    dt.Anio,
    dt.Mes;

select * from DimProveedor