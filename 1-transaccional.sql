-- Crear la base de datos tansaccional
-- CREATE DATABASE TiendaElectronicaOnline;
-- GO

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

-- -- Eliminar tablas de TiendaElectronicaOnline
-- USE TiendaElectronicaOnline;
-- GO

-- IF OBJECT_ID('dbo.Inventario', 'U') IS NOT NULL
--     DROP TABLE dbo.Inventario;
-- GO

-- IF OBJECT_ID('dbo.Devoluciones', 'U') IS NOT NULL
--     DROP TABLE dbo.Devoluciones;
-- GO

-- IF OBJECT_ID('dbo.Envios', 'U') IS NOT NULL
--     DROP TABLE dbo.Envios;
-- GO

-- IF OBJECT_ID('dbo.DetallesPedido', 'U') IS NOT NULL
--     DROP TABLE dbo.DetallesPedido;
-- GO

-- IF OBJECT_ID('dbo.Pedidos', 'U') IS NOT NULL
--     DROP TABLE dbo.Pedidos;
-- GO

-- IF OBJECT_ID('dbo.Moneda', 'U') IS NOT NULL
--     DROP TABLE dbo.Moneda;
-- GO

-- IF OBJECT_ID('dbo.Clientes', 'U') IS NOT NULL
--     DROP TABLE dbo.Clientes;
-- GO

-- IF OBJECT_ID('dbo.Productos', 'U') IS NOT NULL
--     DROP TABLE dbo.Productos;
-- GO

-- IF OBJECT_ID('dbo.Proveedores', 'U') IS NOT NULL
--     DROP TABLE dbo.Proveedores;
