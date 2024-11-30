Use TiendaElectronicaOnline_DW;

DECLARE @ProveedorSK INT = 2;                        -- ID del Proveedor a Actualizar
DECLARE @NuevoNombreProveedor VARCHAR(255) = 'Jorge Ventas'; -- Nuevo Nombre
DECLARE @NuevaCiudad VARCHAR(100) = 'CABA';      -- Nueva Ciudad
DECLARE @NuevoPais VARCHAR(100) = 'Argentina';          -- Nuevo País
DECLARE @NuevaClasificacion VARCHAR(50) = 'preferido';     -- Nueva Clasificación
DECLARE @NuevoEsProveedorCertificado BIT = 1;        -- Nueva Certificación
DECLARE @FechaInicio DATE = GETDATE() ;            -- Fecha de Inicio de la Nueva Versión
DECLARE @FechaFin DATE = NULL;                        -- Fecha Fin (NULL para activo)

-- Ejecutar el procedimiento almacenado para actualizar el proveedor
EXEC ActualizarProveedorDimHistorico
    @ProveedorSK = @ProveedorSK,
    @NuevoNombreProveedor = @NuevoNombreProveedor,
    @NuevaCiudad = @NuevaCiudad,
    @NuevoPais = @NuevoPais,
    @NuevaClasificacion = @NuevaClasificacion,
    @NuevoEsProveedorCertificado = @NuevoEsProveedorCertificado,
    @FechaInicio = @FechaInicio,
    @FechaFin = @FechaFin;

SELECT *
FROM TiendaElectronicaOnline_DW.dbo.DimProveedor
WHERE ProveedorSK = 2
ORDER BY FechaInicio DESC;



-- Verificar FactVentas después de la actualización
SELECT
    fv.VentaID,
    fv.ProveedorID,
    dp.NombreProveedor,
    fv.FechaPedido
FROM
    TiendaElectronicaOnline_DW.dbo.FactVentas fv
    JOIN TiendaElectronicaOnline_DW.dbo.DimProveedor dp ON fv.ProveedorID = dp.ProveedorID
WHERE
    dp.ProveedorSK = 2
ORDER BY
    fv.FechaPedido DESC;



-- Consultar el Histórico de Proveedores para Verificar la Actualización
SELECT
    ProveedorSK,
    ProveedorID,
    NombreProveedor,
    Ciudad,
    Pais,
    Clasificacion,
    EsProveedorCertificado,
    FechaInicio,
    FechaFin,
    Activo
FROM
    TiendaElectronicaOnline_DW.dbo.DimProveedor
WHERE
    ProveedorSK = 2
ORDER BY
    FechaInicio DESC;
