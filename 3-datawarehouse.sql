-- Crear la base de datos para el DATE warehouse
CREATE DATABASE TiendaElectronicaOnline_DW;
GO

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


-- Eliminar tablas de TiendaElectronicaOnline_DW
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