-- 1. Crear la base de datos y las tablas
USE TiendaElectronicaOnline;
GO

-- Crear la tabla Proveedores
IF OBJECT_ID('dbo.Proveedores', 'U') IS NULL
BEGIN
    CREATE TABLE Proveedores (
        ProveedorID INT IDENTITY(1,1) PRIMARY KEY,
        NombreProveedor VARCHAR(255) NOT NULL,
        NombreContacto VARCHAR(100),
        Direccion VARCHAR(255),
        Ciudad VARCHAR(100),
        CodigoPostal VARCHAR(20),
        Pais VARCHAR(100),
        Telefono VARCHAR(20),
        Clasificacion VARCHAR(50) NOT NULL,
        EsProveedorCertificado BIT NOT NULL DEFAULT 0,
        FechaInicio DATE NOT NULL,
        FechaFin DATE NULL
    );
END;
GO

-- Crear la tabla Productos
IF OBJECT_ID('dbo.Productos', 'U') IS NULL
BEGIN
    CREATE TABLE Productos (
        ProductoID INT IDENTITY(1,1) PRIMARY KEY,
        NombreProducto VARCHAR(255) NOT NULL,
        Categoria VARCHAR(100),
        Precio DECIMAL(10, 2) NOT NULL,
        Costo DECIMAL(10, 2),
        ProveedorID INT,
        FOREIGN KEY (ProveedorID) REFERENCES Proveedores(ProveedorID) ON UPDATE CASCADE ON DELETE SET NULL
    );
END;
GO

-- Crear la tabla Clientes
IF OBJECT_ID('dbo.Clientes', 'U') IS NULL
BEGIN
    CREATE TABLE Clientes (
        ClienteID INT IDENTITY(1,1) PRIMARY KEY,
        Nombre VARCHAR(100) NOT NULL,
        Apellido VARCHAR(100) NOT NULL,
        CorreoElectronico VARCHAR(255) UNIQUE,
        Telefono VARCHAR(20),
        Direccion VARCHAR(255),
        Ciudad VARCHAR(100),
        CodigoPostal VARCHAR(20),
        Pais VARCHAR(100)
    );
END;
GO

-- Crear la tabla Moneda (sólo con cotización en dólares)
IF OBJECT_ID('dbo.Moneda', 'U') IS NULL
BEGIN
    CREATE TABLE Moneda (
        MonedaID INT IDENTITY(1,1) PRIMARY KEY,
        Cotizacion DECIMAL(10, 4) NOT NULL,
        Moneda VARCHAR(50) NOT NULL DEFAULT 'Dólar',
        Fecha DATE NOT NULL
    );
END;
GO

-- Crear la tabla Pedidos
IF OBJECT_ID('dbo.Pedidos', 'U') IS NULL
BEGIN
    CREATE TABLE Pedidos (
        PedidoID INT IDENTITY(1,1) PRIMARY KEY,
        ClienteID INT,
        FechaPedido DATE NOT NULL,
        FechaEnvio DATE,
        CostoEnvio DECIMAL(10, 2),
        MontoTotal DECIMAL(10, 2),
        FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID) ON UPDATE CASCADE ON DELETE CASCADE
    );
END;
GO

-- Crear la tabla DetallesPedido
IF OBJECT_ID('dbo.DetallesPedido', 'U') IS NULL
BEGIN
    CREATE TABLE DetallesPedido (
        DetallePedidoID INT IDENTITY(1,1) PRIMARY KEY,
        PedidoID INT,
        ProductoID INT,
        Cantidad INT NOT NULL,
        PrecioUnitario DECIMAL(10, 2) NOT NULL,
        FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID) ON UPDATE CASCADE ON DELETE CASCADE
    );
END;
GO

-- Crear tabla de envíos
IF OBJECT_ID('dbo.Envios', 'U') IS NULL
BEGIN
    CREATE TABLE Envios (
        EnvioID INT IDENTITY(1,1) PRIMARY KEY,
        PedidoID INT,
        FechaEntrega DATETIME NOT NULL,
        Transportista VARCHAR(100),
        EstadoEnvio VARCHAR(50),
        FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID) ON UPDATE CASCADE ON DELETE CASCADE
    );
END;
GO

-- Crear tabla de devoluciones
IF OBJECT_ID('dbo.Devoluciones', 'U') IS NULL
BEGIN
    CREATE TABLE Devoluciones (
        DevolucionID INT IDENTITY(1,1) PRIMARY KEY,
        PedidoID INT,
        ProductoID INT,
        FechaDevolucion DATETIME NOT NULL,
        MotivoDevolucion VARCHAR(255),
        EstadoDevolucion VARCHAR(50),
        FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID) ON UPDATE CASCADE ON DELETE CASCADE
    );
END;
GO

-- Crear tabla de inventario
IF OBJECT_ID('dbo.Inventario', 'U') IS NULL
BEGIN
    CREATE TABLE Inventario (
        InventarioID INT IDENTITY(1,1) PRIMARY KEY,
        ProductoID INT,
        CantidadDisponible INT NOT NULL,
        FechaActualizacion DATETIME NOT NULL,
        FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID) ON UPDATE CASCADE ON DELETE CASCADE
    );
END;
GO

-- ============================================================
-- -- Crear la base de datos para el DATE warehouse
-- CREATE DATABASE TiendaElectronicaOnline_DW;
-- GO

USE TiendaElectronicaOnline_DW;
GO

-- Crear la tabla DimTiempo
CREATE TABLE DimTiempo (
    TiempoID INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE NOT NULL,
    Anio INT NOT NULL,
    Mes INT NOT NULL,
    NombreMes VARCHAR(10) NOT NULL,
    Trimestre INT NOT NULL,
    NombreTrimestre VARCHAR(2) NOT NULL,
    DiaSemana INT NOT NULL,
    NombreDiaSemana VARCHAR(10) NOT NULL,
    DiaDelAnio INT NOT NULL
);

-- Crear la tabla DimProducto
CREATE TABLE DimProducto (
    ProductoID INT PRIMARY KEY,
    NombreProducto VARCHAR(255) NOT NULL,
    Categoria VARCHAR(100),
    PrecioActual DECIMAL(10, 2) NOT NULL
);

-- Crear la tabla DimCliente
CREATE TABLE DimCliente (
    ClienteID INT PRIMARY KEY,
    NombreCompleto VARCHAR(200) NOT NULL,
    CorreoElectronico VARCHAR(255),
    Ciudad VARCHAR(100),
    Direccion VARCHAR(255),
    Pais VARCHAR(100)
);

-- Crear la tabla DimProveedor
CREATE TABLE DimProveedor (
    ProveedorID INT IDENTITY PRIMARY KEY,
    ProveedorSK INT NOT NULL,
    NombreProveedor VARCHAR(255) NOT NULL,
    Ciudad VARCHAR(100),
    Pais VARCHAR(100),
    Clasificacion VARCHAR(50) NOT NULL,
    EsProveedorCertificado BIT NOT NULL,
    FechaInicio date NOT NULL DEFAULT GETDATE(),
    FechaFin DATE NULL,
    Activo BIT NOT NULL DEFAULT 1
);

-- Crear la tabla DimMoneda para la conversión de ganancias
CREATE TABLE DimMoneda (
    MonedaID INT PRIMARY KEY IDENTITY(1,1),
    Cotizacion DECIMAL(10, 4) NOT NULL,
    Moneda VARCHAR(50) NOT NULL DEFAULT 'Dólar',
    Fecha DATE
);

-- Crear la tabla de hechos FactVentas
CREATE TABLE FactVentas (
    VentaID INT IDENTITY(1,1) PRIMARY KEY,
    TiempoID INT,
    ProductoID INT,
    ClienteID INT,
    ProveedorID INT,
    PedidoID INT,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10, 2) NOT NULL,
    MontoTotal DECIMAL(10, 2) NOT NULL,
    Ganancia DECIMAL(10, 2) NOT NULL,
    FechaPedido DATE NOT NULL,
    FechaEnvio DATE,
    CostoEnvio DECIMAL(10, 2),
    EstadoEnvio VARCHAR(50),
    FOREIGN KEY (TiempoID) REFERENCES DimTiempo(TiempoID),
    FOREIGN KEY (ProductoID) REFERENCES DimProducto(ProductoID),
    FOREIGN KEY (ClienteID) REFERENCES DimCliente(ClienteID),
    FOREIGN KEY (ProveedorID) REFERENCES DimProveedor(ProveedorID)
);
GO
-- ============================================
-- 4. Creación del Procedimiento Almacenado para SCD Tipo 2 en DimProveedor
-- ============================================

CREATE OR ALTER PROCEDURE ActualizarProveedorDimHistorico
    @ProveedorSK INT,
    @NuevoNombreProveedor VARCHAR(255),
    @NuevaCiudad VARCHAR(100),
    @NuevoPais VARCHAR(100),
    @NuevaClasificacion VARCHAR(50),
    @NuevoEsProveedorCertificado BIT,
    @FechaInicio DATE,
    @FechaFin DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @ExistenteProveedorID INT;
        DECLARE @ExistenteNombreProveedor VARCHAR(255);
        DECLARE @ExistenteCiudad VARCHAR(100);
        DECLARE @ExistentePais VARCHAR(100);
        DECLARE @ExistenteClasificacion VARCHAR(50);
        DECLARE @ExistenteEsProveedorCertificado BIT;
        DECLARE @ExistenteFechaInicio DATE;
        DECLARE @ExistenteFechaFin DATE;
        DECLARE @NuevoProveedorID INT;

        -- Buscar el registro activo
        SELECT
            @ExistenteProveedorID = ProveedorID,
            @ExistenteNombreProveedor = NombreProveedor,
            @ExistenteCiudad = Ciudad,
            @ExistentePais = Pais,
            @ExistenteClasificacion = Clasificacion,
            @ExistenteEsProveedorCertificado = EsProveedorCertificado,
            @ExistenteFechaInicio = FechaInicio,
            @ExistenteFechaFin = FechaFin
        FROM
            DimProveedor
        WHERE
            ProveedorSK = @ProveedorSK AND Activo = 1;

        -- Verificar si existe un registro activo
        IF @ExistenteProveedorID IS NOT NULL
        BEGIN
            -- Comparar los campos para detectar cambios
            IF @ExistenteNombreProveedor <> @NuevoNombreProveedor OR
               @ExistenteCiudad <> @NuevaCiudad OR
               @ExistentePais <> @NuevoPais OR
               @ExistenteClasificacion <> @NuevaClasificacion OR
               @ExistenteEsProveedorCertificado <> @NuevoEsProveedorCertificado
            BEGIN
                -- Marcar la versión existente como histórica
                UPDATE DimProveedor
                SET FechaFin = DATEADD(DAY, -1, @FechaInicio), -- Un día antes del inicio de la nueva versión
                    Activo = 0
                WHERE ProveedorID = @ExistenteProveedorID;

                -- Insertar la nueva versión activa
                INSERT INTO DimProveedor (
                    ProveedorSK,
                    NombreProveedor,
                    Ciudad,
                    Pais,
                    Clasificacion,
                    EsProveedorCertificado,
                    FechaInicio,
                    FechaFin,
                    Activo
                )
                VALUES (
                    @ProveedorSK,
                    @NuevoNombreProveedor,
                    @NuevaCiudad,
                    @NuevoPais,
                    @NuevaClasificacion,
                    @NuevoEsProveedorCertificado,
                    @FechaInicio,
                    @FechaFin,
                    1
                );
                SET @NuevoProveedorID = SCOPE_IDENTITY();

                -- Actualizar FactVentas
                UPDATE fv
                SET fv.ProveedorID = @NuevoProveedorID
                FROM FactVentas fv
                INNER JOIN DimProveedor dp ON fv.ProveedorID = dp.ProveedorID
                WHERE dp.ProveedorSK = @ProveedorSK
                AND fv.FechaPedido >= @FechaInicio
                AND (fv.FechaPedido < @FechaFin OR @FechaFin IS NULL);
            END
            -- Si no hay cambios, no hacer nada
        END
        ELSE
        BEGIN
            -- Si no existe un registro activo, insertar uno nuevo
            INSERT INTO DimProveedor (
                ProveedorSK,
                NombreProveedor,
                Ciudad,
                Pais,
                Clasificacion,
                EsProveedorCertificado,
                FechaInicio,
                FechaFin,
                Activo
            )
            VALUES (
                @ProveedorSK,
                @NuevoNombreProveedor,
                @NuevaCiudad,
                @NuevoPais,
                @NuevaClasificacion,
                @NuevoEsProveedorCertificado,
                @FechaInicio,
                @FechaFin,
                1
            );
            SET @NuevoProveedorID = SCOPE_IDENTITY();

            -- Actualizar FactVentas
            UPDATE fv
            SET fv.ProveedorID = @NuevoProveedorID
            FROM FactVentas fv
            INNER JOIN DimProveedor dp ON fv.ProveedorID = dp.ProveedorID
            WHERE dp.ProveedorSK = @ProveedorSK
            AND fv.FechaPedido >= @FechaInicio
            AND (fv.FechaPedido < @FechaFin OR @FechaFin IS NULL);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        -- Manejo de errores
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO









-- ============================================================
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

/*
-- Cursor para iterar sobre todos los proveedores actuales
DECLARE ProveedorCursor CURSOR FOR
SELECT
    p.ProveedorID,
    p.NombreProveedor,
    p.Ciudad,
    p.Pais,
    p.Clasificacion,
    p.EsProveedorCertificado,
    CAST(p.FechaInicio AS DATE) AS FechaInicio,
    CAST(p.FechaFin AS DATE) AS FechaFin
FROM
    TiendaElectronicaOnline.dbo.Proveedores p;

OPEN ProveedorCursor;
FETCH NEXT FROM ProveedorCursor INTO
    @ProveedorID,
    @NuevoNombreProveedor,
    @NuevaCiudad,
    @NuevoPais,
    @NuevaClasificacion,
    @NuevoEsProveedorCertificado,
    @FechaInicio,
    @FechaFin;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Llamar al procedimiento almacenado para cada proveedor
    EXEC ActualizarProveedorDimHistorico
        @ProveedorID = @ProveedorID,
        @NuevoNombreProveedor = @NuevoNombreProveedor,
        @NuevaCiudad = @NuevaCiudad,
        @NuevoPais = @NuevoPais,
        @NuevaClasificacion = @NuevaClasificacion,
        @NuevoEsProveedorCertificado = @NuevoEsProveedorCertificado,
        @FechaInicio = @FechaInicio,
        @FechaFin = @FechaFin;

    FETCH NEXT FROM ProveedorCursor INTO
        @ProveedorID,
        @NuevoNombreProveedor,
        @NuevaCiudad,
        @NuevoPais,
        @NuevaClasificacion,
        @NuevoEsProveedorCertificado,
        @FechaInicio,
        @FechaFin;
END

CLOSE ProveedorCursor;
DEALLOCATE ProveedorCursor;
GO
*/
-- aca esta la movida del error

/*
-- Populado DimProveedor con merge, para actualizar los registros existentes y agregar nuevos (actualización incremental), segunda instancia
MERGE INTO TiendaElectronicaOnline_DW.dbo.DimProveedor AS target
USING (
    SELECT
        p.ProveedorID,
        p.NombreProveedor,
        p.Ciudad,
        p.Pais,
        p.Clasificacion,
        p.EsProveedorCertificado,
        CAST(p.FechaInicio AS DATE) AS FechaInicio,
        CAST(p.FechaFin AS DATE) AS FechaFin
    FROM
        TiendaElectronicaOnline.dbo.Proveedores p
) AS source
ON
    target.ProveedorSK = source.ProveedorID AND target.Activo = 1
WHEN MATCHED AND (
        target.NombreProveedor <> source.NombreProveedor OR
        target.Ciudad <> source.Ciudad OR
        target.Pais <> source.Pais OR
        target.Clasificacion <> source.Clasificacion OR
        target.EsProveedorCertificado <> source.EsProveedorCertificado
    )
    THEN
        -- Marcar el registro existente como histórico
        UPDATE SET
            FechaFin = DATEADD(DAY, -1, source.FechaInicio),
            Activo = 0
WHEN NOT MATCHED BY TARGET
    THEN
        -- Insertar nueva versión activa
        INSERT (ProveedorSK, NombreProveedor, Ciudad, Pais, Clasificacion, EsProveedorCertificado, FechaInicio, FechaFin, Activo)
        VALUES (
            source.ProveedorID,
            source.NombreProveedor,
            source.Ciudad,
            source.Pais,
            source.Clasificacion,
            source.EsProveedorCertificado,
            source.FechaInicio,
            source.FechaFin,
            CASE WHEN source.FechaFin IS NULL THEN 1 ELSE 0 END
        )
OUTPUT $action, inserted.*, deleted.*;
GO
*/

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
--     TiendaElectronicaOnline.dbo.Proveedores p
--     LEFT JOIN TiendaElectronicaOnline_DW.dbo.DimProveedor dp ON dp.ProveedorID = p.ProveedorID
-- WHERE dp.ProveedorID IS NULL;

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

-- -- Populando FactVentas
-- INSERT INTO TiendaElectronicaOnline_DW.dbo.FactVentas (TiempoID, ProductoID, ClienteID, ProveedorSK, PedidoID, Cantidad, PrecioUnitario, MontoTotal, Ganancia, FechaPedido, FechaEnvio, CostoEnvio, EstadoEnvio)
-- SELECT
--     dt.TiempoID,
--     dp.ProductoID,
--     dc.ClienteID,
--     dpr.ProveedorSK,
--     p.PedidoID,
--     dped.Cantidad,
--     dped.PrecioUnitario,
--     dped.Cantidad * dped.PrecioUnitario AS MontoTotal,
--     (dped.Cantidad * dped.PrecioUnitario) - (dped.Cantidad * prod.Costo) AS Ganancia,
--     p.FechaPedido,
--     p.FechaEnvio,
--     p.CostoEnvio,
--     e.EstadoEnvio
-- FROM
--     TiendaElectronicaOnline.dbo.Pedidos p
--     JOIN TiendaElectronicaOnline.dbo.DetallesPedido dped ON p.PedidoID = dped.PedidoID
--     JOIN TiendaElectronicaOnline.dbo.Productos prod ON dped.ProductoID = prod.ProductoID
--     LEFT JOIN TiendaElectronicaOnline_DW.dbo.DimTiempo dt ON dt.Fecha = p.FechaPedido
--     LEFT JOIN TiendaElectronicaOnline_DW.dbo.DimProducto dp ON dp.ProductoID = dped.ProductoID
--     LEFT JOIN TiendaElectronicaOnline_DW.dbo.DimCliente dc ON dc.ClienteID = p.ClienteID
--     LEFT JOIN TiendaElectronicaOnline_DW.dbo.DimProveedor dpr ON
--         dpr.ProveedorID = prod.ProveedorID AND
--         p.FechaPedido BETWEEN dpr.FechaInicio AND ISNULL(dpr.FechaFin, '9999-12-31')
--     LEFT JOIN TiendaElectronicaOnline.dbo.Envios e ON e.PedidoID = p.PedidoID;
-- GO

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















------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
-- ============================================================
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


--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--Actualizar DimProveedor usando SCD Tipo 2 cambiando su clasificación.

-- Datos del cambio

/*
SELECT ProveedorSK, ProveedorID,
    NombreProveedor, Ciudad, Pais, Clasificacion, EsProveedorCertificado, FechaInicio, FechaFin, Activo FROM DimProveedor WHERE ProveedorID = 2
ORDER BY FechaInicio DESC;
*/

-- SELECT ProveedorID, ProveedorSK, Clasificacion, FechaInicio, FechaFin  FROM DimProveedor WHERE ProveedorID = 2;
--select  * from DetallesPedido Where ProductoID = 2
--Select * from FactVentas where ProveedorID = 37
--Select * from FactVentas where ProveedorID in (26,2)
--select * from Productos where ProductoID = 5

/*
-- Ver los registros de factventas con el id especifico
USE TiendaElectronicaOnline_DW;
GO

SELECT fv.VentaID, fv.ProveedorSK, fv.ProductoID, fv.PedidoID,    fv.Cantidad,    fv.PrecioUnitario, fv.MontoTotal, fv.Ganancia, fv.FechaPedido, dp.NombreProveedor, dp.Clasificacion,
    dp.FechaInicio, dp.FechaFin, dp.Activo
FROM
    FactVentas fv
        JOIN DimProveedor dp ON fv.ProveedorID = dp.ProveedorID
WHERE
    dp.ProveedoriD = 3
ORDER BY
    fv.FechaPedido DESC;

SELECT fv.VentaID, fv.ProveedorID, dp.ProveedorID, dp.FechaInicio, dp.FechaFin, dp.ProveedorSK, dp.NombreProveedor
FROM TiendaElectronicaOnline_DW.dbo.FactVentas fv
         JOIN TiendaElectronicaOnline_DW.dbo.DimProveedor dp ON fv.ProveedorID = dp.ProveedorSK
WHERE fv.FechaPedido NOT BETWEEN dp.FechaInicio AND ISNULL(dp.FechaFin, '9999-12-31');

DECLARE @nuevoproveedorID INT = 3;

UPDATE dbo.Proveedores
SET
    NombreProveedor = 'Jorge Espinola',
    Clasificacion = 'preferido'
WHERE
    ProveedorID = @nuevoproveedorID;
GO

UPDATE FactVentas
SET
    ProveedorID = @nuevoproveedorID;
*/
-- use TiendaElectronicaOnline
-- select * from Productos where ProductoID = 72

use TiendaElectronicaOnline_DW

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




--- ============================================================
--- ============================================================

-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------

-- Eliminar tablas de TiendaElectronicaOnline
USE TiendaElectronicaOnline;
GO

IF OBJECT_ID('dbo.Inventario', 'U') IS NOT NULL
    DROP TABLE dbo.Inventario;
GO

IF OBJECT_ID('dbo.Devoluciones', 'U') IS NOT NULL
    DROP TABLE dbo.Devoluciones;
GO

IF OBJECT_ID('dbo.Envios', 'U') IS NOT NULL
    DROP TABLE dbo.Envios;
GO

IF OBJECT_ID('dbo.DetallesPedido', 'U') IS NOT NULL
    DROP TABLE dbo.DetallesPedido;
GO

IF OBJECT_ID('dbo.Pedidos', 'U') IS NOT NULL
    DROP TABLE dbo.Pedidos;
GO

IF OBJECT_ID('dbo.Moneda', 'U') IS NOT NULL
    DROP TABLE dbo.Moneda;
GO

IF OBJECT_ID('dbo.Clientes', 'U') IS NOT NULL
    DROP TABLE dbo.Clientes;
GO

IF OBJECT_ID('dbo.Productos', 'U') IS NOT NULL
    DROP TABLE dbo.Productos;
GO

IF OBJECT_ID('dbo.Proveedores', 'U') IS NOT NULL
    DROP TABLE dbo.Proveedores;
GO

-- Eliminar tablas de TiendaElectronicaOnlineA_DW
USE TiendaElectronicaOnline_DW;
GO

IF OBJECT_ID('dbo.FactVentas', 'U') IS NOT NULL
    DROP TABLE dbo.FactVentas;
GO

IF OBJECT_ID('dbo.DimMoneda', 'U') IS NOT NULL
    DROP TABLE dbo.DimMoneda;
GO

IF OBJECT_ID('dbo.DimProveedor', 'U') IS NOT NULL
    DROP TABLE dbo.DimProveedor;
GO

IF OBJECT_ID('dbo.DimCliente', 'U') IS NOT NULL
    DROP TABLE dbo.DimCliente;
GO

IF OBJECT_ID('dbo.DimProducto', 'U') IS NOT NULL
    DROP TABLE dbo.DimProducto;
GO

IF OBJECT_ID('dbo.DimTiempo', 'U') IS NOT NULL
    DROP TABLE dbo.DimTiempo;
GO

USE TiendaElectronicaOnline_DW;
GO

IF OBJECT_ID('dbo.ActualizarProveedorDimHistorico', 'P') IS NOT NULL
    DROP PROCEDURE dbo.ActualizarProveedorDimHistorico;
GO